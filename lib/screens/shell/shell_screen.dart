import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_a_b/controllers/shell_controller.dart';

import 'package:project_a_b/screens/community/community_list_screen.dart';
import 'package:project_a_b/screens/profile/source_screen.dart';
import 'package:project_a_b/screens/rings/rings_management_screen.dart';
import 'package:project_a_b/screens/signals/signals_feed_screen.dart';
import 'package:project_a_b/widgets/custom/custom_bottom_nav_bar.dart';
import 'package:project_a_b/widgets/custom/custom_icon_button.dart';

class ShellScreen extends GetView<ShellController> {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // This is the list of your 4 main pages
    final List<Widget> screens = [
      const SignalsFeedScreen(),
      const RingsManagementScreen(),
      const CommunityListScreen(),
      const SourceScreen(),
    ];

    return Scaffold(
      // The body is an IndexedStack that swaps pages
      // based on the controller's tabIndex
      body: Obx(
        () => IndexedStack(index: controller.tabIndex.value, children: screens),
      ),

      bottomNavigationBar: SafeArea(
        child: CustomBottomNavBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavButton(
                theme: theme,
                iconAsset: 'lib/assets/icons/signal.svg', // Signals
                index: 0,
              ),
              _buildNavButton(
                theme: theme,
                iconAsset: 'lib/assets/icons/ringss.svg', // Rings
                index: 1,
              ),
              _buildNavButton(
                theme: theme,
                iconAsset: 'lib/assets/icons/community.svg', // Community
                index: 2,
              ),
              _buildNavButton(
                theme: theme,
                iconAsset: 'lib/assets/icons/profile.svg', // Profile
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build each nav button
  Widget _buildNavButton({
    required ThemeData theme,
    required String iconAsset,
    required int index,
  }) {
    // Obx makes this button rebuild when the tabIndex changes
    return Obx(() {
      final isSelected = controller.tabIndex.value == index;

      // Use bright red if selected, otherwise use the default theme color
      final activeColor = isSelected
          ? theme.cardColor
          : theme.scaffoldBackgroundColor;

      return CustomIconButton(
        onTapped: () => controller.changeTabIndex(index),
        iconAsset: iconAsset,
        backgroundColor: activeColor,
      );
    });
  }
}
