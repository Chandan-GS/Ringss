import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_a_b/controllers/source_controller.dart';
import 'package:project_a_b/core/routes/app_routes.dart';
import 'package:project_a_b/data/models/signal_model.dart';
import 'package:project_a_b/screens/profile/widgets/signal_card_profile.dart';
import 'package:project_a_b/screens/profile/widgets/small_cards.dart';
import 'package:project_a_b/screens/signals/widgets/signal_card.dart';
import 'package:project_a_b/widgets/custom/custom_app_bar.dart';
import 'package:project_a_b/widgets/custom/custom_bg_card.dart';
import 'package:project_a_b/widgets/custom/custom_icon_button.dart';
import 'package:project_a_b/widgets/custom/custom_profile_icon.dart';
import 'package:project_a_b/widgets/custom/custom_text_field.dart'; // Import for TextFields

class SourceScreen extends GetView<SourceController> {
  const SourceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SourceController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "The Source",
              style: TextStyle(
                color: theme.textTheme.titleMedium?.color,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            CustomIconButton(
              onTapped: () {
                Get.toNamed(AppRoutes.MORE);
              },
              iconAsset: 'lib/assets/icons/more.svg',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Profile Card - Only visible when on Pet section
          Obx(
            () => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: controller.currentPage.value == 0 ? null : 0,
              child: controller.currentPage.value == 0
                  ? _buildProfileCard(theme)
                  : const SizedBox.shrink(),
            ),
          ),

          // Tab Buttons
          Padding(
            padding: EdgeInsets.fromLTRB(
              13,
              // Use Obx to rebuild padding based on page
              controller.currentPage.value == 0 ? 20 : 20,
              13,
              0,
            ),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextButtonSource(
                    backgroundColor: controller.currentPage.value == 0
                        ? theme.cardColor
                        : theme.scaffoldBackgroundColor,
                    onTapped: () => controller.changePage(0),
                    iconAsset: "lib/assets/icons/pet_paw.svg",
                    width: 80,
                  ),
                  CustomTextButtonSource(
                    backgroundColor: controller.currentPage.value == 1
                        ? theme.cardColor
                        : theme.scaffoldBackgroundColor,
                    onTapped: () => controller.changePage(1),
                    iconAsset: "lib/assets/icons/signal.svg",
                    width: 80,
                  ),
                  CustomTextButtonSource(
                    backgroundColor: controller.currentPage.value == 2
                        ? theme.cardColor
                        : theme.scaffoldBackgroundColor,
                    onTapped: () => controller.changePage(2),
                    iconAsset: "lib/assets/icons/re_signal.svg",
                    width: 80,
                  ),
                  CustomTextButtonSource(
                    backgroundColor: controller.currentPage.value == 3
                        ? theme.cardColor
                        : theme.scaffoldBackgroundColor,
                    onTapped: () => controller.changePage(3),
                    iconAsset: "lib/assets/icons/save_signal.svg",
                    width: 80,
                  ),
                ],
              ),
            ),
          ),

          // PageView with 4 sections
          Expanded(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: (index) {
                controller.currentPage.value = index;
                controller.clearSelectedSignal();
              },
              children: [
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: _buildPetSection(theme),
                ),
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: _buildSignalSection(context, theme),
                ),
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: _buildReSignalSection(context, theme),
                ),
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: _buildSaveSignalSection(context, theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 20, 13, 0),
      child: CustomBgCard(
        height: 210, // <-- Fixed height is respected
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          child: Obx(() {
            final profile = controller.currentUserProfile.value;
            if (profile == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final isEditing = controller.isEditMode.value;

            // --- FIX: Wrap the Column in a SingleChildScrollView ---
            // This prevents the RenderFlex overflow when in edit mode.
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: isEditing
                            ? Column(
                                children: [
                                  _buildEditTextField(
                                    controller: controller.nameController,
                                    hint: "Display Name",
                                  ),
                                  const SizedBox(height: 8),
                                  _buildEditTextField(
                                    controller: controller.usernameController,
                                    hint: "Username",
                                  ),
                                ],
                              )
                            : Column(
                                // Show Text
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.displayName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  Text(
                                    profile.username,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.textTheme.bodyMedium?.color
                                          ?.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      // --- Edit/Save Button ---
                      Obx(
                        () => controller.isUploading.value
                            ? const SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : CustomIconButton(
                                onTapped: () {
                                  if (isEditing) {
                                    controller.updateProfile();
                                  } else {
                                    controller.toggleEditMode();
                                  }
                                },
                                iconAsset: isEditing
                                    ? 'lib/assets/icons/save_signal.svg'
                                    : 'lib/assets/icons/edit_ring.svg',
                              ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // --- BODY: Profile Pic and Bio ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- Profile Icon (now handles image preview) ---
                      Obx(
                        () => CustomProfileIcon(
                          onTapped: () => controller.pickProfileImage(),
                          imageFile: controller.selectedProfileImage.value,
                          imageUrl: profile.profilePicUrl,
                          userId: profile.id, // <-- FIX: Pass the user's ID
                          iconAsset: "lib/assets/icons/profile.svg",
                          buttonSize: 90,
                        ),
                      ),

                      const SizedBox(width: 10),
                      Expanded(
                        child: isEditing
                            ? _buildEditTextField(
                                // Bio TextField
                                controller: controller.bioController,
                                hint: "Your bio...",
                                maxLines: 4,
                              )
                            : Center(
                                // Bio Text
                                child: FittedBox(
                                  child: Text(profile.bio ?? "No bio yet."),
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            );
            // --- END OF FIX ---
          }),
        ),
      ),
    );
  }

  // Helper widget for the edit text fields
  Widget _buildEditTextField({
    required TextEditingController controller,
    required String hint,
    int? maxLines = 1,
  }) {
    return CustomTextField(
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 14,
          color: Get.theme.textTheme.bodyMedium?.color,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Get.theme.hintColor),
        ),
      ),
    );
  }

  Widget _buildPetSection(ThemeData theme) {
    // This section remains mostly static as per your file
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Obx(
              () => Text(
                "xp - ${controller.currentUserProfile.value?.petLevel ?? 0}", // Dynamic
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 5),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              "lib/assets/gifs/pet_1.gif",
              height: 250,
              width: 250,
              scale: 0.4,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomIconButton(
                  onTapped: () {},
                  iconAsset: "lib/assets/icons/paint.svg",
                ),
                const SizedBox(height: 20),
                CustomIconButton(
                  onTapped: () {},
                  iconAsset: "lib/assets/icons/battle.svg",
                ),
                const SizedBox(height: 20),
                CustomIconButton(
                  onTapped: () {},
                  iconAsset: "lib/assets/icons/food.svg",
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // --- Dynamic Signal List Sections ---

  Widget _buildSignalSection(BuildContext context, ThemeData theme) {
    return Obx(() {
      if (controller.selectedSignal.value != null) {
        // Show the SignalCardProfile with delete button
        return SignalCardProfile(signal: controller.selectedSignal.value!);
      }
      // Show the list grouped by month
      return _buildGroupedSignalList(
        context,
        theme,
        controller.mySignalsByMonth,
        (signal) => controller.selectSignal(signal),
      );
    });
  }

  Widget _buildReSignalSection(BuildContext context, ThemeData theme) {
    return Obx(() {
      if (controller.selectedSignal.value != null) {
        // Show the standard SignalCard with slider
        return SignalCard(signal: controller.selectedSignal.value!);
      }
      // Show the list grouped by month
      return _buildGroupedSignalList(
        context,
        theme,
        controller.myResignalsByMonth,
        (signal) => controller.selectSignal(signal),
      );
    });
  }

  Widget _buildSaveSignalSection(BuildContext context, ThemeData theme) {
    return Obx(() {
      if (controller.selectedSignal.value != null) {
        // Show the standard SignalCard with slider
        return SignalCard(signal: controller.selectedSignal.value!);
      }
      // Show the list grouped by month
      return _buildGroupedSignalList(
        context,
        theme,
        controller.mySavedSignalsByMonth,
        (signal) => controller.selectSignal(signal),
      );
    });
  }

  /// Helper to build the grouped list UI
  Widget _buildGroupedSignalList(
    BuildContext context,
    ThemeData theme,
    Map<String, List<SignalModel>> signalGroups,
    Function(SignalModel) onSignalTap,
  ) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (signalGroups.isEmpty) {
      return const Center(child: Text("Nothing here yet."));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: signalGroups.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key, // "This month", "August", etc.
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 10),
              // Use Wrap to handle layout of SmallCards
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: entry.value.map((signal) {
                  return Container(
                    width: (MediaQuery.of(context).size.width / 2) - 25,
                    child: SmallCards(
                      signal: signal,
                      onTap: () => onSignalTap(signal),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// (CustomTextButtonSource is unchanged)
class CustomTextButtonSource extends StatefulWidget {
  const CustomTextButtonSource({
    super.key,
    required this.onTapped,
    required this.iconAsset,
    this.width = double.infinity,
    this.height = 40.0,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.textSize,
  });

  final Function onTapped;
  final String iconAsset;
  final double width;
  final double height;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final double? textSize;

  @override
  State<CustomTextButtonSource> createState() => _CustomTextButtonSourceState();
}

class _CustomTextButtonSourceState extends State<CustomTextButtonSource> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    widget.onTapped();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.scaffoldBackgroundColor;
    final brdColor = widget.borderColor ?? theme.cardColor;
    final shadowColor = Colors.black;
    final double buttonLeftMargin = 4;
    final double shadowTopMargin = 4;
    final double shadowLeftMargin = 4;
    final double buttonTopMargin = 0;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: SizedBox(
        width: widget.width + buttonLeftMargin,
        height: widget.height + shadowTopMargin,
        child: Stack(
          children: [
            // Shadow
            Container(
              margin: EdgeInsets.only(
                top: shadowTopMargin,
                right: shadowLeftMargin,
              ),
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: shadowColor,
              ),
            ),
            // Button
            AnimatedPositioned(
              duration: const Duration(milliseconds: 30),
              top: _isPressed ? shadowTopMargin : buttonTopMargin,
              left: _isPressed ? buttonTopMargin : buttonLeftMargin,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  border: Border.all(color: brdColor, width: 4),
                  borderRadius: BorderRadius.circular(10),
                  color: bgColor,
                ),
                child: Center(
                  child: widget.iconAsset.isNotEmpty
                      ? SvgPicture.asset(
                          widget.iconAsset,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).textTheme.bodyMedium?.color ??
                                Colors.black,
                            BlendMode.srcIn,
                          ),
                          width: 25,
                          height: 25,
                          fit: BoxFit.contain,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
