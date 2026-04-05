import 'package:flutter/material.dart';

/// This is your exact UniversalAppBar code, just renamed.
/// It implements PreferredSizeWidget so it can be used in a Scaffold's appBar.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.5),
      child: Stack(
        children: [
          // Shadow (your exact margins)
          Container(
            margin: const EdgeInsets.fromLTRB(13, 63, 15, 0),
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.black,
            ),
          ),
          // Button (your exact margins)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 60, 12, 0),
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Theme.of(context).appBarTheme.backgroundColor,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ), // Added right padding
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120); // 60 (top margin) + 50 (height) + 10 (padding)
}
