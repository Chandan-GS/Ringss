import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_a_b/data/models/ring_model.dart';
import 'package:project_a_b/data/models/user_model.dart';
import 'package:project_a_b/widgets/custom/custom_bg_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RingsManagementController extends GetxController {
  final supabase = Supabase.instance.client;
  // --- ADDED: Get currentUserId ---
  final String currentUserId = Supabase.instance.client.auth.currentUser!.id;

  // --- Global State ---
  var isLoading = true.obs;
  var isEditMode = false.obs;
  var selectedEditRingIndex = 0.obs;

  // --- Rings Data ---
  var rings = <UserRingModel>[].obs;

  // --- Add People Data ---
  var allUsers = <UserModel>[].obs;
  var pingsSent = <String>{}.obs; // Set of user IDs we've pinged
  var suggestions = <UserModel>[].obs;

  // --- Edit Ring Data ---
  var isMemberEditMode = false.obs;
  var selectedMemberIds = <String>{}.obs;
  final ringNameController = TextEditingController();

  // --- Signal Data ---
  final signalTitleController = TextEditingController();
  final signalContentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // --- THIS IS THE FIX (Part 1) ---
    // We *only* call fetchCurrentUserRings here.
    // The other fetches will be chained after it.
    fetchCurrentUserRings();
    // fetchAllUsers(); // <-- DO NOT CALL HERE
    // fetchSuggestedUsers(); // <-- DO NOT CALL HERE
  }

  // --- 1. DATA FETCHING ---

  Future<void> fetchCurrentUserRings() async {
    try {
      isLoading(true);
      final data = await supabase
          .from('rings')
          .select()
          .eq('owner_id', currentUserId)
          .order('ring_type', ascending: true);

      final fetchedRings = data
          .map((map) => UserRingModel.fromMap(map))
          .toList();

      for (var ring in fetchedRings) {
        await fetchMembersForRing(ring);
      }

      rings.assignAll(fetchedRings);

      // --- THIS IS THE FIX (Part 2) ---
      // Now that `rings` is populated, we can
      // safely call the other functions.
      await fetchAllUsers();
      await fetchSuggestedUsers();
      // ---------------------------------
    } catch (e) {
      _showCustomSnackbar(
        "Error",
        "Could not fetch your rings: ${e.toString()}",
        isError: true,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchMembersForRing(UserRingModel ring) async {
    try {
      final data = await supabase
          .from('ring_members')
          .select('profiles(*)')
          .eq('ring_id', ring.id)
          .eq('status', 'accepted');

      final members = data
          .map((map) => UserModel.fromMap(map['profiles']))
          .toList();
      ring.members.assignAll(members);
    } catch (e) {
      _showCustomSnackbar(
        "Error",
        "Could not fetch members for ${ring.ringName}",
        isError: true,
      );
    }
  }

  Future<void> fetchAllUsers() async {
    try {
      // 1. Get a list of all member IDs I'm already connected to (in any ring)
      final List<String> myMemberIds = [];
      for (var ring in rings) {
        myMemberIds.addAll(ring.members.map((m) => m.id));
      }

      final data = await supabase
          .from('profiles')
          .select()
          .neq('id', currentUserId); // All users *except* me

      // 3. Filter out users I'm already connected to
      final allProfiles = data.map((map) => UserModel.fromMap(map)).toList();
      allProfiles.removeWhere((user) => myMemberIds.contains(user.id));

      allUsers.assignAll(allProfiles);
    } catch (e) {
      _showCustomSnackbar("Error", "Could not fetch users list", isError: true);
    }
  }

  // --- NEW: fetchSuggestedUsers ---
  Future<void> fetchSuggestedUsers() async {
    try {
      // 1. Call the RPC. This returns a List<dynamic>
      final data = await supabase.rpc('get_suggested_users');

      // --- THIS IS THE FIX ---
      // 2. Cast the dynamic list to the correct type
      final list = data as List<dynamic>;

      // 3. Map the list, casting each element to the required Map type
      final suggestedProfiles = list.map((map) {
        return UserModel.fromMap(map as Map<String, dynamic>);
      }).toList();
      // --- END OF FIX ---

      // 4. (Rest of your logic is the same)
      suggestedProfiles.removeWhere((user) => pingsSent.contains(user.id));
      suggestions.assignAll(suggestedProfiles);
    } catch (e) {
      _showCustomSnackbar(
        "Error",
        "Could not fetch suggestions: ${e.toString()}",
        isError: true,
      );
    }
  }

  // --- 2. RINGS VIEW ---

  void toggleEditMode(bool isEditing) {
    isEditMode.value = isEditing;
    if (isEditing) {
      selectRingForEdit(0);
    }
  }

  // --- 3. ADD MEMBERS SECTION ---

  // --- FIX: Removed the first, incorrect pingUser function ---
  // (The old function was here)

  // --- 4. EDIT RINGS SECTION ---

  void selectRingForEdit(int index) {
    selectedEditRingIndex.value = index;
    final ring = rings[index];
    ringNameController.text = ring.ringName;
    isMemberEditMode.value = false;
    selectedMemberIds.clear();
  }

  Future<void> updateRingName() async {
    final newName = ringNameController.text.trim();
    if (newName.isEmpty) {
      _showCustomSnackbar("Error", "Ring name cannot be empty.", isError: true);
      return;
    }

    final ring = rings[selectedEditRingIndex.value];
    if (ring.ringName == newName) return;

    try {
      await supabase
          .from('rings')
          .update({'ring_name': newName})
          .eq('id', ring.id);

      ring.ringName = newName;
      rings.refresh();
      _showCustomSnackbar(
        "Success",
        "${ring.ringType} ring renamed to $newName",
      );
    } catch (e) {
      _showCustomSnackbar(
        "Error",
        "Could not update ring name: ${e.toString()}",
        isError: true,
      );
    }
  }

  void toggleMemberEditMode(bool active) {
    isMemberEditMode.value = active;
    if (!active) {
      selectedMemberIds.clear();
    }
  }

  void toggleMemberSelection(String memberId) {
    if (selectedMemberIds.contains(memberId)) {
      selectedMemberIds.remove(memberId);
    } else {
      selectedMemberIds.add(memberId);
    }
  }

  void toggleSelectAll() {
    final ring = rings[selectedEditRingIndex.value];
    final allMemberIds = ring.members.map((m) => m.id).toList();

    if (selectedMemberIds.length == allMemberIds.length) {
      selectedMemberIds.clear();
    } else {
      selectedMemberIds.assignAll(allMemberIds);
    }
  }

  Future<void> deleteSelectedMembers() async {
    // Get the list of user IDs to remove
    final membersToDelete = selectedMemberIds.toList();
    if (membersToDelete.isEmpty) return;

    try {
      // Loop through each selected user and call the RPC
      // This is safer than a single complex query
      for (var memberId in membersToDelete) {
        await supabase.rpc('break_connection', params: {'user_b_id': memberId});
      }

      // Optimistic UI update: Remove these members from ALL local rings
      for (var ring in rings) {
        ring.members.removeWhere((m) => membersToDelete.contains(m.id));
      }
      rings.refresh(); // Refresh all ring UIs

      // Reset the UI
      toggleMemberEditMode(false);
      selectedMemberIds.clear();
      _showCustomSnackbar(
        "Connection Removed",
        "Selected users have been removed from all your rings.",
      );
    } catch (e) {
      _showCustomSnackbar(
        "Error",
        "Could not remove connection: ${e.toString()}",
        isError: true,
      );
    }
  }

  // This is the correct, full-featured pingUser function
  Future<void> pingUser(UserModel user, UserRingModel ring) async {
    try {
      final pingData = await supabase
          .from('ring_members')
          .insert({'ring_id': ring.id, 'user_id': user.id, 'status': 'pending'})
          .select('id')
          .single();

      final pingId = pingData['id'];

      await supabase.from('notifications').insert({
        'user_id': user.id,
        'actor_id': currentUserId,
        'type': 'ping_request',
        'related_ping_id': pingId,
      });

      // (Push Notification logic would go here)

      pingsSent.add(user.id);
      _showCustomSnackbar(
        "Ping Sent!",
        "Your request was sent to ${user.displayName}",
      );
    } catch (e) {
      if (e.toString().contains('23505')) {
        _showCustomSnackbar(
          "Ping Already Sent",
          "You have already pinged ${user.displayName}.",
          isError: true,
        );
        pingsSent.add(user.id);
      } else {
        _showCustomSnackbar(
          "Error",
          "Could not send ping: ${e.toString()}",
          isError: true,
        );
      }
    }
  }

  Future<void> moveSelectedMembers(UserRingModel targetRing) async {
    final sourceRing = rings[selectedEditRingIndex.value];
    if (sourceRing.id == targetRing.id) return;

    try {
      await supabase
          .from('ring_members')
          .update({'ring_id': targetRing.id})
          .eq('ring_id', sourceRing.id)
          .filter('user_id', 'in', selectedMemberIds.toList());

      final membersToMove = sourceRing.members
          .where((m) => selectedMemberIds.contains(m.id))
          .toList();
      sourceRing.members.removeWhere((m) => selectedMemberIds.contains(m.id));
      targetRing.members.addAll(membersToMove);

      toggleMemberEditMode(false);
      selectedMemberIds.clear();
    } catch (e) {
      _showCustomSnackbar(
        "Error",
        "Could not move members: ${e.toString()}",
        isError: true,
      );
    }
  }

  // --- 5. CREATE SIGNAL SECTION ---

  Future<void> createSignal(int ringIndex) async {
    final title = signalTitleController.text.trim();
    final content = signalContentController.text.trim();
    if (content.isEmpty) {
      _showCustomSnackbar(
        "Error",
        "Signal content cannot be empty.",
        isError: true,
      );
      return;
    }

    final selectedRing = rings[ringIndex];
    // final currentUserId = supabase.auth.currentUser!.id; // Already defined at class level

    List<String> targetRingTypes = [];
    if (selectedRing.ringType == 'outer') {
      targetRingTypes = ['outer', 'middle', 'inner'];
    } else if (selectedRing.ringType == 'middle') {
      targetRingTypes = ['middle', 'inner'];
    } else {
      targetRingTypes = ['inner'];
    }

    final memberIdsToSignal = <String>{};
    for (var ring in rings) {
      if (targetRingTypes.contains(ring.ringType)) {
        memberIdsToSignal.addAll(ring.members.map((m) => m.id));
      }
    }
    memberIdsToSignal.add(currentUserId);

    try {
      final signalData = await supabase
          .from('signals')
          .insert({
            'owner_id': currentUserId,
            'ring_type': selectedRing.ringType,
            'title': title.isEmpty ? null : title,
            'content': content,
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
    } catch (e) {
      _showCustomSnackbar(
        "Error",
        "Could not post signal: ${e.toString()}",
        isError: true,
      );
    }
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
