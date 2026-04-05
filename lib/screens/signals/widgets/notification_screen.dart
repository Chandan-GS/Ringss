import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_a_b/controllers/notification_controller.dart';
import 'package:project_a_b/controllers/rings_management_controller.dart';
import 'package:project_a_b/data/models/notification_model.dart';
import 'package:project_a_b/screens/rings/widgets/pixelated_circle.dart';
import 'package:project_a_b/widgets/custom/custom_bg_card.dart';
import 'package:project_a_b/widgets/custom/custom_icon_button.dart';
import 'package:project_a_b/widgets/custom/custom_profile_icon.dart';
import 'package:timeago/timeago.dart' as timeago;
// --- END OF FIX ---

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Mark as read when the screen is opened
    controller.markAllAsRead();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // --- HEADER ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Notifications",
                style: GoogleFonts.pixelifySans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              CustomIconButton(
                onTapped: () => Get.back(),
                iconAsset: "lib/assets/icons/cancel_button.svg",
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- NOTIFICATION LIST ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.notifications.isEmpty) {
                return Center(
                  child: Text(
                    "You have no notifications.",
                    style: GoogleFonts.pixelifySans(fontSize: 16),
                  ),
                );
              }
              return ListView.builder(
                itemCount: controller.notifications.length,
                itemBuilder: (context, index) {
                  final notification = controller.notifications[index];
                  // Build a different tile based on notification type
                  if (notification.type == 'ping_request') {
                    return _buildPingRequestTile(theme, notification);
                  } else {
                    return _buildSimpleTile(theme, notification);
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Tile for "ping_accepted" or other simple info
  Widget _buildSimpleTile(ThemeData theme, NotificationModel notification) {
    final title = "${notification.actor.username} accepted your ping!";
    final timeAgo = timeago.format(
      notification.createdAt,
    ); // This line is now valid

    return CustomBgCard(
      height: 70,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            CustomProfileIcon(
              onTapped: () {},
              imageUrl: notification.actor.profilePicUrl,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.pixelifySans(
                      fontSize: 16,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    timeAgo,
                    style: GoogleFonts.pixelifySans(
                      fontSize: 14,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // (The rest of your file is unchanged)
  Widget _buildPingRequestTile(
    ThemeData theme,
    NotificationModel notification,
  ) {
    final RingsManagementController ringsController = Get.find();

    return CustomBgCard(
      height: 110,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomProfileIcon(
                  onTapped: () {},
                  imageUrl: notification.actor.profilePicUrl,
                  userId: notification.actor.id, // <-- FIX: Pass the actor's ID
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.actor.displayName,
                        style: GoogleFonts.pixelifySans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      Text(
                        notification.actor.username,
                        style: GoogleFonts.pixelifySans(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ringsController.rings.map((ring) {
                    return Row(
                      children: [
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () =>
                              controller.acceptPing(notification, ring),
                          child: PixelatedCircle(
                            size: 30,
                            text: "",
                            thickness: 5,
                            pixelSize: 2.5,
                            color: ring.color,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(width: 10),
                CustomIconButton(
                  onTapped: () => controller.declinePing(notification),
                  iconAsset: 'lib/assets/icons/cancel_button.svg',
                  backgroundColor: theme.scaffoldBackgroundColor,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              "wants to connect. Add them to a ring.",
              style: GoogleFonts.pixelifySans(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
