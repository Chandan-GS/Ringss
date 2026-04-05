import 'package:flutter/material.dart';

/// This is your UniversalTextFields, renamed and refactored
/// to use your "shadow-to-the-left" logic.
class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key, required this.child, this.height = 60});

  final TextField child;
  final double height;

  @override
  Widget build(BuildContext context) {
    // Your shadow logic
    final double buttonLeftMargin = 4;
    final double shadowTopMargin = 4;
    final double shadowRightMargin = 4;
    final double buttonTopMargin = 0;

    return Stack(
      children: [
        // Shadow
        Container(
          margin: EdgeInsets.only(
            top: shadowTopMargin,
            right: shadowRightMargin,
          ),
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
          ),
        ),
        // Field
        Container(
          margin: EdgeInsets.only(top: buttonTopMargin, left: buttonLeftMargin),
          padding: const EdgeInsets.only(top: 4, left: 10, right: 10),
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Align(alignment: Alignment.center, child: child),
        ),
      ],
    );
  }
}
