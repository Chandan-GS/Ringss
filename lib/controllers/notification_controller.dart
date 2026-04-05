import 'dart:async';
import 'package:get/get.dart';
import 'package:project_a_b/controllers/rings_management_controller.dart';
import 'package:project_a_b/data/models/notification_model.dart';
import 'package:project_a_b/data/models/ring_model.dart'; // Import this
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsController extends GetxController {
  final supabase = Supabase.instance.client;
  final String currentUserId = Supabase.instance.client.auth.currentUser!.id;

  var isLoading = true.obs;
  var notifications = <NotificationModel>[].obs;

  /// Reactive boolean for showing the red dot
  var hasUnreadNotifications = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();

    // Refresh notifications every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchNotifications();
    });

    // setupPushNotifications(); // Call this to init FCM
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading(true);
      final data = await supabase
          .from('notifications')
          .select('*, actor:actor_id(*)') // Join the actor's profile
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false);

      notifications.value = data
          .map((map) => NotificationModel.fromMap(map))
          .toList();

      hasUnreadNotifications.value = notifications.any((n) => !n.isRead);
    } catch (e) {
      Get.snackbar("Error", "Could not load notifications: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }

  Future<void> markAllAsRead() async {
    if (!hasUnreadNotifications.value) return; // No need to update

    hasUnreadNotifications.value = false;
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', currentUserId)
        .eq('is_read', false);

    for (var n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
  }

  /// --- NEW SIMPLIFIED LOGIC ---
  /// This is called when a user taps one of the three ring icons
  Future<void> acceptPing(
    NotificationModel notification,
    UserRingModel myRing,
  ) async {
    try {
      // 1. Update *my* ring_members table (add them to my ring)
      await supabase.from('ring_members').insert({
        'ring_id': myRing.id,
        'user_id': notification.actor.id,
        'status': 'accepted',
      });

      // 2. Update *their* ring_members table (the original ping)
      await supabase
          .from('ring_members')
          .update({'status': 'accepted'})
          .eq('id', notification.relatedPingId!);

      // 3. Create a new "ping_accepted" notification for *them*
      await supabase.from('notifications').insert({
        'user_id': notification.actor.id, // The user who pinged me
        'actor_id': currentUserId, // I am the actor
        'type': 'ping_accepted',
      });

      // 4. Delete this "ping_request" notification
      await supabase.from('notifications').delete().eq('id', notification.id);

      // 5. Refresh UI
      fetchNotifications(); // Refresh the notification list
      Get.snackbar(
        "Connection Made!",
        "${notification.actor.username} added to your ${myRing.ringName}.",
      );

      // Refresh the main rings screen to show new member
      if (Get.isRegistered<RingsManagementController>()) {
        Get.find<RingsManagementController>().fetchCurrentUserRings();
      }
    } catch (e) {
      Get.snackbar("Error", "Could not accept ping: ${e.toString()}");
    }
  }

  Future<void> clearAcceptedPings() async {
    try {
      // 1. Delete from database
      await supabase
          .from('notifications')
          .delete()
          .eq('user_id', currentUserId)
          .eq('type', 'ping_accepted');

      // 2. Optimistic UI update
      notifications.removeWhere((n) => n.type == 'ping_accepted');
    } catch (e) {
      print("Error clearing notifications: $e");
    }
  }

  /// When a user hits "Decline"
  Future<void> declinePing(NotificationModel notification) async {
    try {
      // 1. Delete the original ping request from `ring_members`
      await supabase
          .from('ring_members')
          .delete()
          .eq('id', notification.relatedPingId!);

      // 2. Delete this notification
      await supabase.from('notifications').delete().eq('id', notification.id);

      // 3. Refresh UI
      fetchNotifications();
      Get.snackbar(
        "Ping Declined",
        "You declined the request from ${notification.actor.username}.",
      );
    } catch (e) {
      Get.snackbar("Error", "Could not decline ping: ${e.toString()}");
    }
  }

  /*
  // --- PUSH NOTIFICATION SETUP (Future) ---
  
  Future<void> setupPushNotifications() async {
    // 1. Initialize Firebase (requires google-services.json, etc.)
    // await Firebase.initializeApp();
    
    // 2. Get the FCM token
    // final fcmToken = await FirebaseMessaging.instance.getToken();
    
    // 3. Save it to your Supabase profile
    // if (fcmToken != null) {
    //   await supabase
    //       .from('profiles')
    //       .update({'fcm_token': fcmToken})
    //       .eq('id', currentUserId);
    // }
    
    // 4. Listen for incoming messages
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message whilst in the foreground!');
    //   if (message.notification != null) {
    //     Get.snackbar(message.notification!.title ?? "New Notification",
    //                  message.notification!.body ?? "");
    //     fetchNotifications(); // Refresh the in-app list
    //   }
    // });
  }
  */
}
