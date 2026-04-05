import 'package:flutter/material.dart';

class GoogleAuthButton extends StatefulWidget {
  const GoogleAuthButton({
    super.key,
    required this.onTapped,
    this.text = "Login with Google",
  });

  final Function onTapped;
  final String text;

  @override
  State<GoogleAuthButton> createState() => _GoogleAuthButtonState();
}

class _GoogleAuthButtonState extends State<GoogleAuthButton> {
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
    // Your "shadow-to-the-left" logic
    final double buttonLeftMargin = 4;
    final double shadowTopMargin = 4;
    final double shadowLeftMargin = 0;
    final double buttonTopMargin = 0;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: SizedBox(
        width: double.infinity,
        height: 60 + shadowTopMargin,
        child: Stack(
          children: [
            // Shadow
            Container(
              margin: EdgeInsets.only(
                top: shadowTopMargin,
                left: shadowLeftMargin,
              ),
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black,
              ),
            ),
            // Button (Animated)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 60),
              top: _isPressed ? shadowTopMargin : buttonTopMargin,
              left: _isPressed ? shadowLeftMargin : buttonLeftMargin,
              right: _isPressed ? 0 : -buttonLeftMargin,
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 0, 140, 255),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          widget.text,
                          // Font comes from theme
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Container(
                        width: 70,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            "lib/assets/icons/google.png",
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ],
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
