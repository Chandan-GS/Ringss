import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PixelatedCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double pixelSize;
  final double thickness;
  final String? text;

  const PixelatedCircle({
    Key? key,
    required this.size,
    this.color = Colors.black,
    this.pixelSize = 4.0,
    this.thickness = 8.0,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: _PixelatedCirclePainter(
            color: color,
            pixelSize: pixelSize,
            thickness: thickness,
          ),
        ),

        // --- THIS IS THE FIX ---
        if (text != null)
          Positioned(
            // This calculation places the text on the top arc of its ring
            // (size / 2) = center
            // -(size / 2) = top of the stack
            // +(thickness / 2.5) = move down into the ring
            top: (size / 2) - (size / 2) + (thickness / 2.5),
            left: 0,
            right: 0,
            child: Text(
              text!,
              textAlign: TextAlign.center,
              style: GoogleFonts.pixelifySans(
                fontSize: 20, // A good readable size
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        // ---------------------
      ],
    );
  }
}

class _PixelatedCirclePainter extends CustomPainter {
  final Color color;
  final double pixelSize;
  final double thickness;

  _PixelatedCirclePainter({
    required this.color,
    required this.pixelSize,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final pixelsX = (size.width / pixelSize).floor();
    final pixelsY = (size.height / pixelSize).floor();

    for (int x = 0; x < pixelsX; x++) {
      for (int y = 0; y < pixelsY; y++) {
        final pixelCenter = Offset(
          (x + 0.5) * pixelSize,
          (y + 0.5) * pixelSize,
        );

        final distance = (pixelCenter - center).distance;
        final rect = Rect.fromLTWH(
          x * pixelSize,
          y * pixelSize,
          pixelSize,
          pixelSize,
        );

        final paint = Paint()..style = PaintingStyle.fill;

        if (distance <= radius && distance >= radius - thickness) {
          paint.color = color;
          canvas.drawRect(rect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_PixelatedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.pixelSize != pixelSize ||
        oldDelegate.thickness != thickness;
  }
}
