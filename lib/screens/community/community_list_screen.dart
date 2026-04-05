import 'package:flutter/material.dart';

import 'package:project_a_b/widgets/custom/custom_app_bar.dart';
import 'package:project_a_b/widgets/custom/custom_icon_button.dart';

class CommunityListScreen extends StatelessWidget {
  const CommunityListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Community",
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            CustomIconButton(
              onTapped: () {
                // e.g., Create new community
              },
              iconAsset: 'lib/assets/icons/add_arrow.svg', // Placeholder
            ),
          ],
        ),
      ),
      body: Center(
        child: Text("Community List Screen", style: theme.textTheme.bodyMedium),
      ),
    );
  }
}
