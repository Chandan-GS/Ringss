import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_a_b/controllers/auth_controller.dart';
import 'package:project_a_b/controllers/theme_controller.dart';
import 'package:project_a_b/widgets/custom/custom_app_bar.dart';
import 'package:project_a_b/widgets/custom/custom_bg_card.dart';
import 'package:project_a_b/widgets/custom/custom_dialog_card.dart';
import 'package:project_a_b/widgets/custom/custom_icon_button.dart';
import 'package:project_a_b/widgets/custom/custom_text_button.dart';

class MoreScreen extends GetView<ThemeController> {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final theme = Theme.of(context);
    final Map<String, String> themeItems = {
      'Light': 'lib/assets/icons/light_icon.svg',
      'Dark': 'lib/assets/icons/dark_icon.svg',
      'System': 'lib/assets/icons/system.svg', // Assumed path for 'System'
    };

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        // (Rest of your AppBar is correct)
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "More Options",
              style: GoogleFonts.pixelifySans(
                color: theme.textTheme.titleMedium?.color,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            CustomIconButton(
              onTapped: () => Get.back(),
              iconAsset: 'lib/assets/icons/cancel_button.svg',
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- Theme Section ---
          Text(
            "Appearance",
            style: GoogleFonts.pixelifySans(
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 10),
          CustomBgCard(
            child: Obx(() {
              // Get the currently selected theme string
              final String selectedValue = controller.getThemeString();

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: DropdownButton<String>(
                  value: selectedValue,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  dropdownColor: theme.cardColor,
                  isDense: true, // Reduces default padding
                  // --- FIX 2: Add your custom dropdown arrow ---
                  icon: SvgPicture.asset(
                    'lib/assets/icons/down.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      theme.textTheme.bodyMedium?.color ?? Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),

                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.setThemeMode(newValue);
                    }
                  },

                  items: themeItems.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            entry.value, // Icon path
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              theme.textTheme.bodyMedium?.color ?? Colors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            entry.key, // "Light", "Dark", "System"
                            style: GoogleFonts.pixelifySans(
                              fontSize: 16,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  // --- FIX 4: Build the SELECTED item (the button) ---
                  selectedItemBuilder: (BuildContext context) {
                    return themeItems.entries.map((entry) {
                      return Row(
                        children: [
                          SvgPicture.asset(
                            entry.value, // Icon path
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              theme.textTheme.bodyMedium?.color ?? Colors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            entry.key, // "Light", "Dark", "System"
                            style: GoogleFonts.pixelifySans(
                              fontSize: 16,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 30),

          // --- About Section ---
          _buildMenuButton(
            theme: theme,
            title: "About Ringss",
            icon: 'lib/assets/icons/info.svg', // You'll need an info icon
          ),
          const SizedBox(height: 30),

          // // --- Logout Button ---
          // _buildMenuButton(
          //   theme: theme,
          //   title: "Logout",
          //   icon: 'lib/assets/icons/logout.svg', // You'll need a logout icon
          //   onTap: () {
          //     Get.dialog(
          //       CustomDialogCard(
          //         title: "Logout",
          //         height: 250, // Smaller height
          //         content: _DialogConfirmationContent(
          //           content: "Are you sure you want to log out?",
          //           confirmText: "Logout",
          //           onConfirm: () => authController.signOut(),
          //         ),
          //       ),
          //     );
          //   },
          // ),

          // --- Delete Account Button ---
          const SizedBox(height: 10),
          // _buildMenuButton(
          //   theme: theme,
          //   title: "Delete Account",
          //   icon: 'lib/assets/icons/delete_ring.svg',
          //   textColor: Colors.red,
          //   onTap: () {
          //     Get.dialog(
          //       CustomDialogCard(
          //         title: "Delete Account",
          //         height: 300, // Taller for more text
          //         content: _DialogConfirmationContent(
          //           content:
          //               "This is permanent. All your data, rings, and signals will be deleted. Are you absolutely sure?",
          //           confirmText: "Delete",
          //           confirmButtonColor: Colors.red,
          //           onConfirm: () => authController.deleteAccount(),
          //         ),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  // (The _buildMenuButton helper is unchanged)
  Widget _buildMenuButton({
    required ThemeData theme,
    required String title,
    required String icon,
  }) {
    return InkWell(
      child: CustomBgCard(
        height: 400,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Image.asset("lib/assets/images/rings_letter_head.png"),
                      Text(
                        "What if a social network was actually... social? What if it was designed not for mindless consumption, but for mindful contribution?\n\n"
                        "We built Ringss because we were tired of the noise. We wanted a space where substance, nuance, and intellectual curiosity could thrive. This is a platform for the ideas that need more than a fleeting glance—a digital salon for the 21st-century thinker.\n\n"
                        "The core of our app is the \"Ring\" system. We've replaced the \"follower\" count with circles of trust. You decide the audience for every thought, from a private journal shared with one person to an idea you're testing with a trusted group of peers. This is a place for the conversations you can't have on mainstream platforms.\n\n"
                        "We're also the social app that wants you to spend less time with us.\n\n"
                        "Your AI Pet is a revolutionary companion, an anti-addiction feature built into the app's DNA. It encourages you to take breaks, reflect on your screen time, and engage with the world offline. It thrives when you find a healthy balance, turning digital well-being from a chore into a core part of the experience.\n\n"
                        "We're not here to help you \"go viral.\" We're here to help you grow.\n\n"
                        "Share your signal. Find your circle.\n"
                        "Welcome to Ringss.",

                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5, // Line height
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Crafted by",
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 255, 110, 110),
                    ),
                  ),
                  SizedBox(width: 5),
                  SvgPicture.asset(
                    "lib/assets/icons/GD_logo.svg",
                    colorFilter: ColorFilter.mode(
                      theme.textTheme.bodyMedium?.color ?? Colors.black,
                      BlendMode.srcIn,
                    ),
                    width: 25,
                    height: 25,
                  ),
                  SizedBox(width: 5),
                  Text("GrenckDevs", style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// (The _DialogConfirmationContent helper is unchanged)
class _DialogConfirmationContent extends StatelessWidget {
  const _DialogConfirmationContent({
    required this.content,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText = "Cancel",
    this.confirmButtonColor,
  });

  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final Color? confirmButtonColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          content,
          textAlign: TextAlign.center,
          style: GoogleFonts.pixelifySans(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CustomTextButton(
              onTapped: () => Get.back(), // Close the dialog
              text: cancelText,
              width: 100,
            ),
            CustomTextButton(
              onTapped: () {
                Get.back(); // Close the dialog
                onConfirm(); // Run the action
              },
              text: confirmText,
              width: 100,
            ),
          ],
        ),
      ],
    );
  }
}
