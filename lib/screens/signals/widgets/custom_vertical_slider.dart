import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// CustomSliderBg Component
class CustomSliderBg extends StatelessWidget {
  const CustomSliderBg({super.key, required this.child, this.height});
  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final double buttonLeftMargin = 4;
    final double shadowTopMargin = 4;
    final double buttonTopMargin = 0;

    return Stack(
      children: [
        // Shadow
        Container(
          margin: EdgeInsets.only(top: shadowTopMargin),
          width: 35,
          height: double.infinity, // <-- FIX 1: Allow to fill parent
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
          ),
        ),
        // Field
        Container(
          margin: EdgeInsets.only(top: buttonTopMargin, left: buttonLeftMargin),
          width: 35,
          height: double.infinity, // <-- FIX 2: Allow to fill parent
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: Align(alignment: Alignment.center, child: child),
        ),
        // Center Line
        Center(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            width: 3.5,
            height: 300, // <-- Removed hardcoded height
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

// (CustomIconButtonSlider is unchanged)
class CustomIconButtonSlider extends StatelessWidget {
  const CustomIconButtonSlider({
    super.key,
    required this.iconPath,
    this.onPressed,
  });

  final String iconPath;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final brdColor = theme.cardColor.withOpacity(1);
    final double buttonLeftMargin = 4;
    final double shadowTopMargin = 4;
    final double shadowRightMargin = 4;
    final double buttonTopMargin = 0;

    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(
              top: shadowTopMargin,
              right: shadowRightMargin,
            ),
            width: 65,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black,
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: buttonTopMargin,
              left: buttonLeftMargin,
            ),
            width: 65,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: brdColor, width: 4),
              borderRadius: BorderRadius.circular(10),
              color: bgColor,
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                fit: BoxFit.contain,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// (CustomVerticalSlider is unchanged)
class CustomVerticalSlider extends StatefulWidget {
  final ValueChanged<int>? onValueChanged;
  final int initialValue;

  const CustomVerticalSlider({
    Key? key,
    this.onValueChanged,
    this.initialValue = 5,
  }) : super(key: key);

  @override
  State<CustomVerticalSlider> createState() => _CustomVerticalSliderState();
}

class _CustomVerticalSliderState extends State<CustomVerticalSlider> {
  late int _currentValue;
  late double _sliderPosition;

  @override
  void initState() {
    super.initState();
    // Set initial value from widget
    _currentValue = widget.initialValue.clamp(1, 10);
    _sliderPosition = (_currentValue - 1) / 9;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 69,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final trackHeight = height - 80;

          return GestureDetector(
            onVerticalDragUpdate: (details) {
              setState(() {
                final handleCenter = details.localPosition.dy - 30;
                final newPosition = 1.0 - (handleCenter / trackHeight);
                _sliderPosition = newPosition.clamp(0.0, 1.0);

                final rawValue = 1 + (_sliderPosition * 9);
                _currentValue = rawValue.round().clamp(1, 10);

                _sliderPosition = (_currentValue - 1) / 9;

                widget.onValueChanged?.call(_currentValue);
              });
            },
            onVerticalDragEnd: (details) {
              setState(() {
                _sliderPosition = (_currentValue - 1) / 9;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 15,
                  top: 20,
                  bottom: 20,
                  child: CustomSliderBg(child: Container()),
                ),
                Positioned(
                  left: 0,
                  bottom: 40 + (trackHeight - 60) * _sliderPosition,
                  child: CustomIconButtonSlider(iconPath: _getIconPath()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getIconPath() {
    if (_currentValue <= 3) {
      return 'lib/assets/icons/signal-min.svg';
    } else if (_currentValue <= 7) {
      return 'lib/assets/icons/signal-mid.svg';
    } else {
      return 'lib/assets/icons/signal-max.svg';
    }
  }
}
