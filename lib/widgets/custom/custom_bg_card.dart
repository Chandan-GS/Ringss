import 'package:flutter/material.dart';

class CustomBgCard extends StatelessWidget {
  const CustomBgCard({
    super.key,
    required this.child,
    this.height,
    this.color,
    this.width,
    this.borderColor,
    this.borderWidth,
    this.constraints,
  });

  final Widget child;
  final double? height;
  final Color? color;
  final double? width;
  final Color? borderColor;
  final double? borderWidth;
  final BoxConstraints? constraints;

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
          height: height ?? 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
          ),
        ),
        // Field
        Container(
          constraints: constraints,
          margin: EdgeInsets.only(top: buttonTopMargin, left: buttonLeftMargin),
          // padding: const EdgeInsets.only(top: 4, left: 10, right: 10),
          width: width ?? double.infinity,
          height: height ?? 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color ?? Theme.of(context).colorScheme.primary,
            border: BoxBorder.all(
              color: borderColor ?? Colors.transparent,
              width: borderWidth ?? 0,
            ),
          ),
          child: Align(alignment: Alignment.center, child: child),
        ),
      ],
    );
  }
}
