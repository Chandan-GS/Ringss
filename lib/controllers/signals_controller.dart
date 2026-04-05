import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_a_b/data/models/ring_model.dart';
import 'package:project_a_b/data/models/signal_model.dart';
import 'package:project_a_b/screens/signals/widgets/signal_comment_sheet.dart';
import 'package:project_a_b/widgets/custom/custom_bg_card.dart'; // Import your card
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SignalController extends GetxController {
  final supabase = Supabase.instance.client;
  final String currentUserId = Supabase.instance.client.auth.currentUser!.id;

  var isLoading = true.obs;
  var signals = <SignalModel>[].obs;

  // Controllers for creating a signal
  final signalTitleController = TextEditingController();
  final signalContentController = TextEditingController();

  // Image Picker State
  final ImagePicker _picker = ImagePicker();
  var selectedImage = Rx<File?>(null);
  var isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSignalFeed();
  }

  // (fetchSignalFeed is unchanged)
  Future<void> fetchSignalFeed() async {
    try {
      isLoading(true);
      final recipientData = await supabase
          .from('signal_recipients')
          .select('signal_id')
          .eq('recipient_id', currentUserId);

      final signalIds = recipientData
          .map((e) => e['signal_id'] as String)
          .toList();

      if (signalIds.isEmpty) {
        signals.clear();
        isLoading(false);
        return;
      }

      final signalsData = await supabase
          .from('signals')
          .select('*, profiles(*)')
          .filter('id', 'in', signalIds)
          .order('created_at', ascending: false);

      final fetchedSignals = <SignalModel>[];
      for (var data in signalsData) {
        final signalId = data['id'];
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
      signals.assignAll(fetchedSignals);
    } catch (e) {
      _showCustomSnackbar(
        "Error",
        "Could not load your signal feed: ${e.toString()}",
        isError: true,
      );
    } finally {
      isLoading(false);
    }
  }

  // (pickImage, _compressImage, clearImage are unchanged)
  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;
    try {
      final compressedFile = await _compressImage(pickedFile.path);
      selectedImage.value = compressedFile;
    } catch (e) {
      _showCustomSnackbar(
        "Error",
        "Could not compress image: $e",
        isError: true,
      );
    }
  }

  Future<File> _compressImage(String path) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      "${DateTime.now().millisecondsSinceEpoch}.jpg",
    );
    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      quality: 70,
      minWidth: 1080,
    );
    if (result == null) throw Exception("Image compression failed");
    return File(result.path);
  }

  void clearImage() {
    selectedImage.value = null;
  }

  // (createSignal is updated to use the new snackbar)
  Future<void> createSignal(
    List<UserRingModel> userRings,
    int ringIndex,
  ) async {
    if (isUploading.value) return;
    final title = signalTitleController.text.trim();
    final content = signalContentController.text.trim();
    if (content.isEmpty && selectedImage.value == null) {
      _showCustomSnackbar(
        "Error",
        "Signal content cannot be empty.",
        isError: true,
      );
      return;
    }
    final selectedRing = userRings[ringIndex];
    try {
      isUploading(true);
      String? imageUrl;
      if (selectedImage.value != null) {
        final imageFile = selectedImage.value!;
        final fileExt = p.extension(imageFile.path);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExt';
        final filePath = 'public/signal_images/$currentUserId/$fileName';
        await supabase.storage
            .from('signal_images')
            .upload(filePath, imageFile);
        imageUrl = supabase.storage
            .from('signal_images')
            .getPublicUrl(filePath);
      }
      List<String> targetRingTypes = [];
      if (selectedRing.ringType == 'outer') {
        targetRingTypes = ['outer', 'middle', 'inner'];
      } else if (selectedRing.ringType == 'middle') {
        targetRingTypes = ['middle', 'inner'];
      } else {
        targetRingTypes = ['inner'];
      }
      final memberIdsToSignal = <String>{};
      for (var ring in userRings) {
        if (targetRingTypes.contains(ring.ringType)) {
          memberIdsToSignal.addAll(ring.members.map((m) => m.id));
        }
      }
      memberIdsToSignal.add(currentUserId);
      final signalData = await supabase
          .from('signals')
          .insert({
            'owner_id': currentUserId,
            'ring_type': selectedRing.ringType,
            'title': title.isEmpty ? null : title,
            'content': content,
            'image_url': imageUrl,
          })
          .select('id')
          .single();
      final signalId = signalData['id'];
      final recipients = memberIdsToSignal
          .map((id) => {'signal_id': signalId, 'recipient_id': id})
          .toList();
      await supabase.from('signal_recipients').insert(recipients);
      Get.back();
      _showCustomSnackbar("Signal Sent!", "Your signal has been posted.");
      signalTitleController.clear();
      signalContentController.clear();
      clearImage();
      fetchSignalFeed();
    } catch (e) {
      _showCustomSnackbar(
        "Error",
        "Could not post signal: ${e.toString()}",
        isError: true,
      );
    } finally {
      isUploading(false);
    }
  }

  // (amplifyDampen is updated)
  Future<void> amplifyDampen(SignalModel signal, int value) async {
    int newVote = 0;
    if (value > 5)
      newVote = 1;
    else if (value < 5)
      newVote = -1;
    if (signal.myVote.value == newVote) return;
    try {
      await supabase.from('signal_votes').upsert({
        'signal_id': signal.id,
        'user_id': currentUserId,
        'vote_value': newVote,
      }, onConflict: 'signal_id, user_id');
      int scoreChange = newVote;
      if (signal.myVote.value != 0) {
        scoreChange = newVote - signal.myVote.value;
      }
      signal.score.value = (signal.score.value + scoreChange).clamp(0, 100);
      signal.myVote.value = newVote;
    } catch (e) {
      _showCustomSnackbar(
        "Error",
        "Could not cast vote: ${e.toString()}",
        isError: true,
      );
    }
  }

  // --- MODIFIED: toggleSave ---
  Future<void> toggleSave(SignalModel signal) async {
    try {
      if (signal.isSaved.value) {
        // --- Un-save ---
        await supabase
            .from('user_saved_signals')
            .delete()
            .eq('signal_id', signal.id)
            .eq('user_id', currentUserId);
        signal.isSaved.value = false;
        // Use custom snackbar
        _showCustomSnackbar("Unsaved", "Signal removed from your saved list.");
      } else {
        // --- Save ---
        await supabase.from('user_saved_signals').insert({
          'signal_id': signal.id,
          'user_id': currentUserId,
        });
        signal.isSaved.value = true;
        // Use custom snackbar
        _showCustomSnackbar("Saved!", "Signal saved to your profile.");
      }
    } catch (e) {
      _showCustomSnackbar(
        "Error",
        "Could not update saved signals: ${e.toString()}",
        isError: true,
      );
    }
  }
  // --- END OF MODIFICATION ---

  // (toggleResignal is updated)
  Future<void> toggleResignal(SignalModel signal) async {
    try {
      if (signal.isResignaled.value) {
        await supabase
            .from('user_resignaled_signals')
            .delete()
            .eq('signal_id', signal.id)
            .eq('user_id', currentUserId);
        signal.isResignaled.value = false;
        signal.score.value = (signal.score.value - 1).clamp(0, 100);
      } else {
        await supabase.from('user_resignaled_signals').insert({
          'signal_id': signal.id,
          'user_id': currentUserId,
        });
        signal.isResignaled.value = true;
        signal.score.value = (signal.score.value + 1).clamp(0, 100);
        _showCustomSnackbar("Resignaled!", "This signal has been re-posted.");
      }
    } catch (e) {
      _showCustomSnackbar(
        "Error",
        "Could not resignal: ${e.toString()}",
        isError: true,
      );
    }
  }

  // (openComments is unchanged)
  void openComments(SignalModel signal) {
    Get.bottomSheet(
      SignalCommentsSheet(signal: signal),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // --- NEW: Custom Snackbar Helper ---
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
