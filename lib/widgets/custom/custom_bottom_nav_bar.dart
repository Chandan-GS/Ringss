import 'package:flutter/material.dart';

/// This is your exact UniversalBottomNavigationBar code, just renamed.
class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Give the container a predictable height
      child: Stack(
        children: [
          // Shadow (your exact margins)
          Container(
            margin: const EdgeInsets.fromLTRB(13, 3, 15, 0),
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black,
            ),
          ),
          // Bar (your exact margins)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 12, 3),
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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
}
