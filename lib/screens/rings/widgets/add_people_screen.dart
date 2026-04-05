import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_a_b/controllers/rings_management_controller.dart';
import 'package:project_a_b/data/models/user_model.dart';
import 'package:project_a_b/screens/rings/widgets/pixelated_circle.dart';
import 'package:project_a_b/widgets/custom/custom_bg_card.dart';
import 'package:project_a_b/widgets/custom/custom_icon_button.dart';
import 'package:project_a_b/widgets/custom/custom_profile_icon.dart';
import 'package:project_a_b/widgets/custom/custom_text_button.dart';

class AddPeopleScreen extends GetView<RingsManagementController> {
  const AddPeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align titles to the left
        children: [
          // --- SEARCH BAR ---
          CustomBgCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'lib/assets/icons/search.svg',
                    colorFilter: ColorFilter.mode(
                      theme.textTheme.titleSmall?.color?.withOpacity(0.5) ??
                          Colors.black.withOpacity(0.5),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      cursorColor:
                          theme.textTheme.bodyMedium?.color ?? Colors.black,
                      style: GoogleFonts.pixelifySans(
                        fontSize: 16,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: 'search people',
                        hintStyle: GoogleFonts.pixelifySans(
                          fontSize: 16,
                          color:
                              theme.textTheme.titleSmall?.color?.withOpacity(
                                0.5,
                              ) ??
                              Colors.black.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  CustomIconButton(
                    onTapped: () {
                      Navigator.pop(context);
                    },
                    iconAsset: 'lib/assets/icons/cancel_button.svg',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- PING TEXT ---
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Start building your rings by sending a “Ping” to the people you know.",
            ),
          ),
          const SizedBox(height: 20),

          // --- NEW: SUGGESTIONS SECTION ---
          Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
            child: Text(
              "Suggestions",
              style: GoogleFonts.pixelifySans(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Obx(() {
            if (controller.suggestions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Center(
                  child: Text(
                    "No suggestions right now.",
                    style: GoogleFonts.pixelifySans(color: theme.hintColor),
                  ),
                ),
              );
            }
            return Container(
              height: 120, // Give suggestions a fixed height
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // Make it scroll sideways
                itemCount: controller.suggestions.length,
                itemBuilder: (context, index) {
                  final user = controller.suggestions[index];
                  return Container(
                    width: 300, // Give each card a fixed width
                    padding: const EdgeInsets.only(right: 10.0, bottom: 15.0),
                    child: _buildUserTile(context, theme, user),
                  );
                },
              ),
            );
          }),

          // --- ALL USERS SECTION ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Obx(() {
                if (controller.allUsers.isEmpty) {
                  return Center(
                    child: Text(
                      "No other users to show.",
                      style: GoogleFonts.pixelifySans(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.5,
                        ),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: controller.allUsers.length,
                  itemBuilder: (context, index) {
                    final user = controller.allUsers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: _buildUserTile(context, theme, user),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // _buildUserTile is unchanged
  Widget _buildUserTile(BuildContext context, ThemeData theme, UserModel user) {
    return CustomBgCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomProfileIcon(
              onTapped: () {},
              imageUrl: user.profilePicUrl,
              userId: user.id, // <-- FIX: Pass the user's ID
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: GoogleFonts.pixelifySans(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    user.username,
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
            Obx(() {
              if (controller.pingsSent.contains(user.id)) {
                return CustomTextButton(
                  onTapped: () {},
                  text: "Ping Sent",
                  width: 110,
                  textSize: 12,
                );
              }
              return Row(
                children: controller.rings.asMap().entries.map((entry) {
                  final ring = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: GestureDetector(
                      onTap: () => controller.pingUser(user, ring),
                      child: PixelatedCircle(
                        size: 30,
                        text: "",
                        thickness: 5,
                        pixelSize: 2.5,
                        color: ring.color,
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
