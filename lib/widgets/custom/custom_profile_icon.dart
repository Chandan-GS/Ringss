import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// --- FIX 1: Define the list of 10 light colors ---
const List<Color> _defaultAvatarColors = [
  Color(0xFFFADADD), // Light Pink
  Color(0xFFD4F0F7), // Light Blue
  Color(0xFFD5F7D4), // Light Green
  Color(0xFFFFF8D6), // Light Yellow
  Color(0xFFF3E5F5), // Light Purple
  Color(0xFFFFE0B2), // Light Orange
  Color(0xFFD7CCC8), // Light Brown
  Color(0xFFCFD8DC), // Light Grey
  Color(0xFFFFCDD2), // Light Red
  Color(0xFFC8E6C9), // Light Mint
];
// ---------------------------------------------

class CustomProfileIcon extends StatefulWidget {
  const CustomProfileIcon({
    super.key,
    required this.onTapped,
    this.iconAsset,
    this.imageUrl,
    this.imageFile,
    this.userId, // <-- FIX 2: Add userId to the constructor
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.buttonSize,
  });

  final Function onTapped;
  final String? iconAsset;
  final String? imageUrl;
  final File? imageFile;
  final String? userId; // <-- NEW: For deriving the color
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? buttonSize;

  @override
  State<CustomProfileIcon> createState() => _CustomProfileIconState();
}

class _CustomProfileIconState extends State<CustomProfileIcon> {
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
    final shadowColor = Colors.black;
    final double buttonLeftMargin = 4;
    final double shadowTopMargin = 4;
    final double shadowLeftMargin = 0;
    final double buttonTopMargin = 0;
    final double buttonSize = widget.buttonSize ?? 45.0;

    Widget iconContent;
    bool isDefaultIcon = true; // Assume default unless an image is provided

    if (widget.imageFile != null) {
      // 1. Show local file preview
      isDefaultIcon = false;
      iconContent = Image.file(widget.imageFile!, fit: BoxFit.cover);
    } else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      // 2. Show network image
      isDefaultIcon = false;
      iconContent = Image.network(
        widget.imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (context, error, stack) {
          // Fallback to default icon
          isDefaultIcon = true;
          iconContent = SvgPicture.asset(
            widget.iconAsset ?? 'lib/assets/icons/profile.svg',
            fit: BoxFit.contain, // Use contain for default
          );
          return iconContent;
        },
      );
    } else {
      // 3. Show default SVG icon
      isDefaultIcon = true;
      iconContent = SvgPicture.asset(
        widget.iconAsset ?? 'lib/assets/icons/profile.svg',
        fit: BoxFit.contain, // Use contain for default
      );
    }

    // --- FIX 3: Dynamic Background Color Logic ---
    Color bgColor;
    if (isDefaultIcon) {
      // It's a default icon, let's derive a color
      if (widget.userId != null) {
        // Use the user's ID to pick a consistent, "random" color
        final index =
            widget.userId!.hashCode.abs() % _defaultAvatarColors.length;
        bgColor = _defaultAvatarColors[index];
      } else {
        // Fallback if no userId is provided
        bgColor = widget.backgroundColor ?? theme.scaffoldBackgroundColor;
      }
    } else {
      // It's a real image, just use the default scaffold color
      bgColor = widget.backgroundColor ?? theme.scaffoldBackgroundColor;
    }
    // --- END OF FIX ---

    // Apply padding *only* if it's the default icon
    final Widget finalContent = isDefaultIcon
        ? Padding(
            padding: EdgeInsets.all(buttonSize * 0.2), // 20% padding
            child: iconContent,
          )
        : iconContent;

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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: bgColor, // <-- Use the new dynamic color
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: finalContent, // Use the final (maybe padded) content
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
