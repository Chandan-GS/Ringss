import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:project_a_b/data/models/signal_model.dart';
import 'package:project_a_b/data/models/user_model.dart';
import 'package:project_a_b/widgets/custom/custom_bg_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SourceController extends GetxController {
  final supabase = Supabase.instance.client;
  final String currentUserId = Supabase.instance.client.auth.currentUser!.id;

  // --- Page State ---
  final PageController pageController = PageController();
  var currentPage = 0.obs;
  var selectedSignal = Rx<SignalModel?>(null);

  // --- Data State ---
  var isLoading = true.obs;
  var currentUserProfile = Rx<UserModel?>(null);

  // Lists of signals grouped by month
  var mySignalsByMonth = <String, List<SignalModel>>{}.obs;
  var mySavedSignalsByMonth = <String, List<SignalModel>>{}.obs;
  var myResignalsByMonth = <String, List<SignalModel>>{}.obs;

  var isEditMode = false.obs;
  var isUploading = false.obs;
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  var selectedProfileImage = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchAllSourceData();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // --- PAGE NAVIGATION ---
  void changePage(int index) {
    currentPage.value = index;
    selectedSignal.value = null; // Clear selection when changing tabs
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void selectSignal(SignalModel signal) {
    selectedSignal.value = signal;
  }

  void clearSelectedSignal() {
    selectedSignal.value = null;
  }

  /// Toggles edit mode and populates text fields
  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (isEditMode.value) {
      // Entering edit mode, populate controllers
      final profile = currentUserProfile.value;
      if (profile != null) {
        nameController.text = profile.displayName;
        usernameController.text = profile.username;
        bioController.text = profile.bio ?? '';
      }
    } else {
      // Leaving edit mode, clear any picked image
      selectedProfileImage.value = null;
    }
  }

  /// Picks and compresses a new profile image
  Future<void> pickProfileImage() async {
    if (!isEditMode.value) return; // Can only change pic in edit mode

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    try {
      final compressedFile = await _compressImage(pickedFile.path);
      selectedProfileImage.value = compressedFile;
    } catch (e) {
      _showCustomSnackbar("Error", "Could not compress image: $e");
    }
  }

  /// Compresses an image file
  Future<File> _compressImage(String path) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      "${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      quality: 5,
      minWidth: 500,
      minHeight: 500,
    );
    if (result == null) throw Exception("Image compression failed");
    return File(result.path);
  }

  /// Saves all profile changes to Supabase
  Future<void> updateProfile() async {
    if (isUploading.value) return;
    try {
      isUploading(true);
      String? newImageUrl;

      // 1. Upload new image if one was selected
      if (selectedProfileImage.value != null) {
        final imageFile = selectedProfileImage.value!;
        // Use a consistent file name for the user's profile pic
        final filePath = 'public/$currentUserId/profile.jpg';

        await supabase.storage
            .from('profile-pictures')
            .upload(
              filePath,
              imageFile,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );

        // Get the public URL. We add a timestamp to bust the cache.
        newImageUrl =
            supabase.storage.from('profile-pictures').getPublicUrl(filePath) +
            '?t=${DateTime.now().millisecondsSinceEpoch}';
      }

      // 2. Prepare data for update
      final updates = {
        'display_name': nameController.text.trim(),
        'username': usernameController.text.trim(),
        'bio': bioController.text.trim(),
        if (newImageUrl != null) 'profile_pic_url': newImageUrl,
      };

      // 3. Update the database
      await supabase.from('profiles').update(updates).eq('id', currentUserId);

      // 4. Refresh local data and exit edit mode
      await fetchCurrentUserProfile(); // Get the fresh data
      isEditMode.value = false;
      selectedProfileImage.value = null;
      _showCustomSnackbar("Success", "Profile updated!");
    } catch (e) {
      _showCustomSnackbar("Error", "Could not update profile: ${e.toString()}");
    } finally {
      isUploading(false);
    }
  }

  // --- DATA FETCHING ---
  Future<void> fetchAllSourceData() async {
    try {
      isLoading(true);
      // Fetch all data in parallel
      await Future.wait([
        fetchCurrentUserProfile(),
        fetchMySignals(),
        fetchMySavedSignals(),
        fetchMyResignals(),
      ]);
    } catch (e) {
      _showCustomSnackbar(
        "Error",
        "Could not load your Source: ${e.toString()}",
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchCurrentUserProfile() async {
    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', currentUserId)
          .single();
      currentUserProfile.value = UserModel.fromMap(data);
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> fetchMySignals() async {
    try {
      final data = await _fetchFullSignalData(
        baseTable: 'signals',
        filterColumn: 'owner_id',
        filterValue: currentUserId,
      );
      mySignalsByMonth.value = _groupSignalsByMonth(data);
    } catch (e) {
      print("Error fetching my signals: $e");
    }
  }

  Future<void> fetchMySavedSignals() async {
    try {
      final data = await _fetchFullSignalData(
        baseTable: 'user_saved_signals',
        filterColumn: 'user_id',
        filterValue: currentUserId,
      );
      mySavedSignalsByMonth.value = _groupSignalsByMonth(data);
    } catch (e) {
      print("Error fetching saved signals: $e");
    }
  }

  Future<void> fetchMyResignals() async {
    try {
      final data = await _fetchFullSignalData(
        baseTable: 'user_resignaled_signals',
        filterColumn: 'user_id',
        filterValue: currentUserId,
      );
      myResignalsByMonth.value = _groupSignalsByMonth(data);
    } catch (e) {
      print("Error fetching resignals: $e");
    }
  }

  // --- DATA ACTIONS ---
  Future<void> deleteSignal(SignalModel signal) async {
    try {
      // 1. This is your database delete command. It will now work
      //    because of the new RLS policy.
      await supabase.from('signals').delete().eq('id', signal.id);

      // 2. Optimistic UI update (now removes from ALL lists)
      mySignalsByMonth.forEach((key, list) {
        list.removeWhere((s) => s.id == signal.id);
      });
      mySavedSignalsByMonth.forEach((key, list) {
        list.removeWhere((s) => s.id == signal.id);
      });
      myResignalsByMonth.forEach((key, list) {
        list.removeWhere((s) => s.id == signal.id);
      });

      // Refresh all three Obx maps
      mySignalsByMonth.refresh();
      mySavedSignalsByMonth.refresh();
      myResignalsByMonth.refresh();

      selectedSignal.value = null; // Go back to list

      _showCustomSnackbar("Deleted", "Your signal has been deleted.");
    } catch (e) {
      _showCustomSnackbar("Error", "Could not delete signal: ${e.toString()}");
    }
  }

  // --- HELPER FUNCTIONS ---

  /// Groups a list of signals into a Map where keys are month names (e.g., "This month", "August")
  Map<String, List<SignalModel>> _groupSignalsByMonth(
    List<SignalModel> signals,
  ) {
    final Map<String, List<SignalModel>> grouped = {};
    final now = DateTime.now();
    final thisMonthFormat = DateFormat('MMMM');

    for (var signal in signals) {
      String key;
      if (signal.createdAt.year == now.year &&
          signal.createdAt.month == now.month) {
        key = "This month";
      } else {
        key = thisMonthFormat.format(signal.createdAt);
      }

      if (grouped.containsKey(key)) {
        grouped[key]!.add(signal);
      } else {
        grouped[key] = [signal];
      }
    }
    return grouped;
  }

  /// A complex helper to fetch full signal data from a base table (signals, user_saved_signals, etc.)
  Future<List<SignalModel>> _fetchFullSignalData({
    required String baseTable,
    required String filterColumn,
    required String filterValue,
  }) async {
    // This is a complex query. It's better to make a Postgres Function (RPC)
    // to handle this, but here is the client-side version.

    List<String> signalIds = [];

    if (baseTable == 'signals') {
      // Base table is already signals, just get IDs
      final idData = await supabase
          .from('signals')
          .select('id')
          .eq(filterColumn, filterValue);
      signalIds = idData.map((e) => e['id'] as String).toList();
    } else {
      // Base table is a join table (saved/resignaled), get signal_id
      final idData = await supabase
          .from(baseTable)
          .select('signal_id')
          .eq(filterColumn, filterValue);
      signalIds = idData.map((e) => e['signal_id'] as String).toList();
    }

    if (signalIds.isEmpty) return [];

    // 1. Fetch all signals with their authors
    final signalsData = await supabase
        .from('signals')
        .select('*, profiles(*)') // Join the author's profile
        .filter('id', 'in', signalIds)
        .order('created_at', ascending: false);

    // 2. For each signal, fetch its dynamic data
    final fetchedSignals = <SignalModel>[];
    for (var data in signalsData) {
      final signalId = data['id'];

      // Re-use the logic from SignalController (or move to a shared service)
      final voteData = await supabase
          .from('signal_votes')
          .select('user_id, vote_value')
          .eq('signal_id', signalId);
      final resignalData = await supabase
          .from('user_resignaled_signals')
          .select('user_id')
          .eq('signal_id', signalId);
      final savedData = await supabase
          .from('user_saved_signals')
          .select('id')
          .eq('signal_id', signalId)
          .eq('user_id', currentUserId)
          .maybeSingle();
      final myResignalData = resignalData.firstWhereOrNull(
        (e) => e['user_id'] == currentUserId,
      );
      final myVoteData = voteData.firstWhereOrNull(
        (e) => e['user_id'] == currentUserId,
      );

      int score = 0;
      for (var vote in voteData) {
        score += (vote['vote_value'] as int);
      }
      score += resignalData.length;
      score = score.clamp(0, 100);

      fetchedSignals.add(
        SignalModel.fromMap(data, currentUserId)
          ..score.value = score
          ..myVote.value = (myVoteData?['vote_value'] as int?) ?? 0
          ..isSaved.value = savedData != null
          ..isResignaled.value = myResignalData != null,
      );
    }
    return fetchedSignals;
  }

  void _showCustomSnackbar(
    String title,
    String message, {
    bool isError = false,
  }) {
    final theme = Get.theme;

    Get.rawSnackbar(
      backgroundColor: Colors.transparent, // Make GetX's bg transparent
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(20), // Float it
      padding: EdgeInsets.zero,
      duration: const Duration(seconds: 1),

      messageText: CustomBgCard(
        borderColor: theme.cardColor,
        borderWidth: 4,
        height: 100,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),

          // --- THIS IS THE FIX ---
          // Removed the 'Expanded' widget that was here.
          // The Column will now correctly fill the Padding.
          child: Row(
            // <-- Your own fix from the controller
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError ? Colors.red : Colors.green,
                size: 30,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    Text(
                      message,
                      style: TextStyle(fontSize: 16, color: theme.hintColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // --- END OF FIX ---
        ),
      ),
    );
  }
}
