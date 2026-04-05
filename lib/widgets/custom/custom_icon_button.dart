import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIconButton extends StatefulWidget {
  const CustomIconButton({
    super.key,
    required this.onTapped,
    required this.iconAsset,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
  });

  final Function onTapped;
  final String iconAsset;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
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

    // Use provided colors or fallback to the app's theme
    final bgColor = widget.backgroundColor ?? theme.scaffoldBackgroundColor;
    final brdColor = widget.borderColor ?? theme.cardColor.withOpacity(1);
    final iconColor = widget.iconColor ?? theme.textTheme.titleSmall?.color;
    final shadowColor = Colors.black;

    // Your shadow logic
    final double buttonLeftMargin = 4;
    final double shadowTopMargin = 4;
    final double shadowLeftMargin = 0;
    final double buttonTopMargin = 0;

    // Your new requested size
    final double buttonSize = 45.0;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: SizedBox(
        width: buttonSize + buttonLeftMargin,
        height: buttonSize + shadowTopMargin,
        child: Stack(
          children: [
            // Shadow
            Container(
              margin: EdgeInsets.fromLTRB(
                shadowLeftMargin,
                shadowTopMargin,
                0,
                0,
              ),
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: shadowColor,
              ),
            ),

            // Button (animated)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 30),
              top: _isPressed ? shadowTopMargin : buttonTopMargin,
              left: _isPressed ? shadowLeftMargin : buttonLeftMargin,
              child: Container(
                width: buttonSize,
                height: buttonSize,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  border: Border.all(color: brdColor, width: 4),
                  borderRadius: BorderRadius.circular(10),
                  color: bgColor,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    widget.iconAsset,
                    colorFilter: ColorFilter.mode(
                      iconColor ?? Colors.black,
                      BlendMode.srcIn,
                    ),
                    width: 25, // Icon size can stay the same
                    height: 25,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
