import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_a_b/controllers/rings_management_controller.dart';
import 'package:project_a_b/data/models/ring_model.dart';
import 'package:project_a_b/data/models/user_model.dart';
import 'package:project_a_b/screens/rings/widgets/add_people_screen.dart';
import 'package:project_a_b/screens/rings/widgets/pixelated_circle.dart';
import 'package:project_a_b/screens/rings/widgets/rings_stack.dart';
import 'package:project_a_b/screens/signals/create_signal_screen.dart';
import 'package:project_a_b/widgets/custom/custom_app_bar.dart';
import 'package:project_a_b/widgets/custom/custom_bg_card.dart';
import 'package:project_a_b/widgets/custom/custom_icon_button.dart';
import 'package:project_a_b/widgets/custom/custom_profile_icon.dart';
import 'package:project_a_b/widgets/custom/custom_text_button.dart';

class RingsManagementScreen extends GetView<RingsManagementController> {
  const RingsManagementScreen({super.key});

  void _showCreateSignalScreen(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(30),
        ),
        height: MediaQuery.of(context).size.height * 0.9,
        child: CreateSignalScreen(index: index),
      ),
    );
  }

  void _showAddPeopleScreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(30),
        ),
        height: MediaQuery.of(context).size.height * 0.9,
        child: const AddPeopleScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Put the controller
    Get.put(RingsManagementController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Rings",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Obx(
                  () => CustomIconButton(
                    onTapped: () =>
                        controller.toggleEditMode(!controller.isEditMode.value),
                    iconAsset: controller.isEditMode.value
                        ? 'lib/assets/icons/cancel_button.svg'
                        : 'lib/assets/icons/edit_ring.svg',
                  ),
                ),
                const SizedBox(width: 10),
                CustomIconButton(
                  onTapped: () => _showAddPeopleScreen(context),
                  iconAsset: 'lib/assets/icons/user-plus.svg',
                ),
              ],
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Image.asset(
              "lib/assets/gifs/loading.gif",
              height: 30,
              width: 30,
              color: Colors.red,
            ),
          );
        }
        return controller.isEditMode.value
            ? _buildEditView(context)
            : _buildCenterView(context);
      }),
    );
  }

  Widget _buildCenterView(BuildContext context) {
    return AnimatedAlign(
      alignment: Alignment.center,
      duration: Duration(milliseconds: 100),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: SizedBox(
            width: 800,
            height: 800,
            child: RingssStack(
              isSmall: false,
              rings: controller.rings,
              getHoveredIndex: (receivedIndex) {
                _showCreateSignalScreen(context, receivedIndex);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditView(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('edit_view'),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Member Count Circle
                Obx(() {
                  final selectedRing =
                      controller.rings[controller.selectedEditRingIndex.value];
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      PixelatedCircle(
                        size: 200,
                        text: "",
                        thickness: 60,
                        color: selectedRing.color,
                      ),
                      Text(
                        "${selectedRing.memberCount}/${selectedRing.ringType == 'inner' ? '10' : '20'}", // Dynamic count
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  );
                }),
                // Ring selection buttons
                Expanded(
                  child: Column(
                    children: controller.rings.asMap().entries.map((entry) {
                      final index = entry.key;
                      final ring = entry.value;
                      return Obx(
                        () => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildRingButton(
                            context,
                            ring.ringName,
                            controller.selectedEditRingIndex.value == index,
                            () => controller.selectRingForEdit(index),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Edit options section
          Obx(
            () => _buildEditSection(
              context,
              controller.rings[controller.selectedEditRingIndex.value],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRingButton(
    BuildContext context,
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    // This uses CustomTextButton but applies the selected styling
    return CustomTextButton(
      onTapped: onTap,
      text: text,
      width: 150,
      height: 60,
      // color: isSelected ? Theme.of(context).cardColor : null,
    );
  }

  Widget _buildEditSection(BuildContext context, UserRingModel selectedRing) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Ring Name TextField
          TextField(
            controller: controller.ringNameController,
            cursorColor: theme.textTheme.bodyMedium?.color,
            style: GoogleFonts.pixelifySans(
              fontSize: 20,
              color: theme.textTheme.bodyMedium?.color,
            ),
            maxLength: 15,
            decoration: InputDecoration(
              suffixIcon: GestureDetector(
                onTap: () => controller.updateRingName(), // Save on tap
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(
                    'lib/assets/icons/edit_ring.svg',
                    colorFilter: ColorFilter.mode(
                      theme.textTheme.titleSmall?.color ?? Colors.black,
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              hintText: selectedRing.ringName,
              hintStyle: GoogleFonts.pixelifySans(fontSize: 20),
              counterText: '',
              border: InputBorder.none,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: theme.textTheme.titleSmall?.color ?? Colors.black,
                  width: 2.0,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: theme.textTheme.titleSmall?.color ?? Colors.black,
                  width: 2.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Search bar (UI only for now)
          CustomBgCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      // Add controller.ringSearchController here
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
                  Text(
                    '${selectedRing.memberCount}', // Dynamic member count
                    style: GoogleFonts.pixelifySans(
                      fontSize: 16,
                      color:
                          theme.textTheme.titleSmall?.color?.withOpacity(0.5) ??
                          Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),
          // "Select All" and Edit actions
          _buildEditActions(context, theme, selectedRing),
          const SizedBox(height: 15),
          // Members list
          _buildMemberList(context, selectedRing),
        ],
      ),
    );
  }

  Widget _buildEditActions(
    BuildContext context,
    ThemeData theme,
    UserRingModel selectedRing, // Assuming UserRingModel exists
  ) {
    return Obx(
      () => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Show "Done" button if in member edit mode
              if (controller.isMemberEditMode.value) ...[
                GestureDetector(
                  onTap: () => controller.toggleMemberEditMode(false),
                  child: Text(
                    'Done',
                    style: GoogleFonts.pixelifySans(
                      fontSize: 16,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                const Spacer(),
              ],
              controller.isMemberEditMode.value
                  ? Text(
                      'select all',
                      style: GoogleFonts.pixelifySans(
                        fontSize: 16,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(width: 10),
              controller.isMemberEditMode.value
                  ? GestureDetector(
                      onTap: () => controller.toggleSelectAll(),
                      child: Obx(() {
                        final allSelected =
                            controller.selectedMemberIds.length ==
                                selectedRing.memberCount &&
                            selectedRing.memberCount > 0;
                        return SvgPicture.asset(
                          allSelected
                              ? 'lib/assets/icons/checkbox_checked.svg'
                              : 'lib/assets/icons/checkbox_unchecked.svg',
                          colorFilter: ColorFilter.mode(
                            allSelected
                                ? Colors.red
                                : theme.textTheme.bodyMedium?.color ??
                                      Colors.black,
                            BlendMode.srcIn,
                          ),
                          width: 30,
                          height: 30,
                          fit: BoxFit.contain,
                        );
                      }),
                    )
                  : const SizedBox(),
            ],
          ),
          if (controller.isMemberEditMode.value) ...[
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Delete Button
                CustomIconButton(
                  onTapped: () => controller.deleteSelectedMembers(),
                  iconAsset: 'lib/assets/icons/user-minus.svg',
                ),

                // --- START: CORRECTED CODE BLOCK ---
                CustomTextButton(
                  onTapped: () {
                    // Use the 'context' from the method parameters to show the dialog
                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        // 'dialogContext' is the context for the dialog itself
                        // --- FIX: Wrap your custom layout in a Dialog widget ---
                        return Dialog(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          child: Center(
                            child: Container(
                              // margin: EdgeInsets.all(30), // Dialog handles margin
                              child: CustomBgCard(
                                height: 250,
                                // --- FIX: Add Column for layout ---
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          SizedBox(width: 10),
                                          Text(
                                            "Move To?",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Spacer(),
                                          CustomIconButton(
                                            // --- FIX: Pass a function, not a function call ---
                                            onTapped: () => Get.back(),
                                            iconAsset:
                                                'lib/assets/icons/cancel_button.svg',
                                          ),
                                        ],
                                      ),
                                    ),
                                    // --- FIX: Add Expanded + SingleChildScrollView ---
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // --- FIX: Use spread operator (...) ---
                                            ...controller.rings
                                                .where(
                                                  (ring) =>
                                                      ring.id !=
                                                      selectedRing.id,
                                                ) // Get other rings
                                                // --- FIX: Correct .map() syntax ---
                                                .map(
                                                  (targetRing) => Padding(
                                                    // Add padding to act as a spacer
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 10.0,
                                                        ),
                                                    child: CustomTextButton(
                                                      onTapped: () {
                                                        controller
                                                            .moveSelectedMembers(
                                                              targetRing,
                                                            );
                                                        // Pop the dialog
                                                        Navigator.of(
                                                          dialogContext,
                                                        ).pop();
                                                      },
                                                      text: targetRing.ringName,
                                                      width: 150,
                                                      textSize: 16,
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  text: "Move",
                  width: 100,
                ),
                // --- END: CORRECTED CODE BLOCK ---
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberList(BuildContext context, UserRingModel selectedRing) {
    // Use an Obx to rebuild the list when members change
    return Obx(
      () => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: selectedRing.members.length,
        itemBuilder: (context, index) {
          final user = selectedRing.members[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: _buildMemberTile(context, user),
          );
        },
      ),
    );
  }

  Widget _buildMemberTile(BuildContext context, UserModel user) {
    final theme = Theme.of(context);
    return GestureDetector(
      onLongPress: () => controller.toggleMemberEditMode(true),
      onTap: () {
        if (controller.isMemberEditMode.value) {
          controller.toggleMemberSelection(user.id);
        }
      },
      child: CustomBgCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomProfileIcon(
                onTapped: () {},
                imageUrl: user.profilePicUrl,
                userId: user.id, // <-- FIX: Pass the author's ID
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
                        fontWeight: FontWeight.w600,
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
              // Checkbox (only visible in edit mode)
              Obx(
                () => Visibility(
                  visible: controller.isMemberEditMode.value,
                  maintainSize: true, // Keeps layout consistent
                  maintainAnimation: true,
                  maintainState: true,
                  child: Obx(() {
                    final isSelected = controller.selectedMemberIds.contains(
                      user.id,
                    );
                    return SvgPicture.asset(
                      isSelected
                          ? 'lib/assets/icons/checkbox_checked.svg'
                          : 'lib/assets/icons/checkbox_unchecked.svg',
                      colorFilter: ColorFilter.mode(
                        isSelected
                            ? Colors.red
                            : theme.textTheme.bodyMedium?.color ?? Colors.black,
                        BlendMode.srcIn,
                      ),
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
