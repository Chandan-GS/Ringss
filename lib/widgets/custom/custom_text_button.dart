import 'package:flutter/material.dart';

class CustomTextButton extends StatefulWidget {
  const CustomTextButton({
    super.key,
    required this.onTapped,
    required this.text,
    this.width,
    this.height = 40.0, // <-- UPDATED to match icon button
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.textSize,
    this.padding,
  });

  final Function onTapped;
  final String text;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final double? textSize;
  final EdgeInsets? padding;

  @override
  State<CustomTextButton> createState() => _CustomTextButtonState();
}

class _CustomTextButtonState extends State<CustomTextButton> {
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

    // --- UPDATED COLORS ---
    // These now match CustomIconButton
    final bgColor = widget.backgroundColor ?? theme.scaffoldBackgroundColor;
    final brdColor = widget.borderColor ?? theme.cardColor;
    final txtColor = widget.textColor ?? theme.textTheme.titleSmall?.color;
    // ------------------------

    final shadowColor = Colors.black;

    // Your shadow logic
    final double buttonLeftMargin = 4;
    final double shadowTopMargin = 4;
    final double shadowLeftMargin = 0;
    final double buttonTopMargin = 0;

    final double? buttonWidth = widget.width;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: SizedBox(
        width: buttonWidth != null ? buttonWidth + buttonLeftMargin : null,
        height: widget.height + shadowTopMargin, // Base height + shadow offset
        child: Stack(
          children: [
            // Shadow
            Container(
              margin: EdgeInsets.only(
                top: shadowTopMargin,
                left: shadowLeftMargin,
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
              left: _isPressed ? shadowLeftMargin : buttonLeftMargin,
              child: Container(
                padding: widget.padding ?? EdgeInsets.all(0),
                width: buttonWidth,
                height: widget.height,
                decoration: BoxDecoration(
                  border: Border.all(color: brdColor, width: 4),
                  borderRadius: BorderRadius.circular(10),
                  color: bgColor,
                ),
                child: Center(
                  child: Text(
                    textAlign: TextAlign.center,

                    widget.text,
                    // Use the theme's text style
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.1,
                      color: txtColor,
                      fontSize: widget.textSize ?? 18,
                      fontWeight: FontWeight.normal,
                    ),
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
