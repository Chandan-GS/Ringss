// import 'package:flutter/material.dart';
// import 'package:project_a_b/screens/rings/rings_management_screen.dart';

// class RingssStack extends StatefulWidget {
//   const RingssStack({
//     super.key,
//     required this.getHoveredIndex,
//     required this.isSmall,
//   });

//   final void Function(int index) getHoveredIndex;
//   final bool isSmall;
//   @override
//   State<RingssStack> createState() => _RingssStackState();
// }

// class _RingssStackState extends State<RingssStack> {
//   int? hoveredRingIndex;
//   final GlobalKey stackKey = GlobalKey();

//   bool isPointInRing(Offset localPosition, double ringSize, double thickness) {
//     if (stackKey.currentContext == null) return false;

//     final center = Offset(
//       stackKey.currentContext!.size!.width / 2,
//       stackKey.currentContext!.size!.height / 2,
//     );

//     final distance = (localPosition - center).distance;
//     final outerRadius = ringSize / 2;
//     final innerRadius = outerRadius - thickness;

//     return distance >= innerRadius && distance <= outerRadius;
//   }

//   void _handlePanUpdate(DragUpdateDetails details) {
//     if (stackKey.currentContext == null) return;

//     final RenderBox box =
//         stackKey.currentContext!.findRenderObject() as RenderBox;
//     final localPosition = box.globalToLocal(details.globalPosition);

//     // This loop now correctly uses the global 'ringsFinalList'
//     for (int i = ringsFinalList.length - 1; i >= 0; i--) {
//       final ring = ringsFinalList[i];
//       if (isPointInRing(localPosition, ring.size, ring.thickness)) {
//         setState(() {
//           hoveredRingIndex = i;
//         });
//         return;
//       }
//     }

//     setState(() {
//       hoveredRingIndex = null;
//     });
//   }

//   void _handlePanEnd(DragEndDetails details) {
//     setState(() {
//       if (hoveredRingIndex != null) {
//         widget.getHoveredIndex(hoveredRingIndex!);
//       }
//       hoveredRingIndex = null;
//     });
//   }

//   @override
//   Widget build(BuildContext ontext) {
//     return ClipRect(
//       // Ensures rings can overflow but still appear clipped
//       child: Stack(
//         key: stackKey,
//         alignment: Alignment.center,
//         children: [
//           ...ringsFinalList.asMap().entries.map((entry) {
//             final index = entry.key;
//             final ring = entry.value;

//             return GestureDetector(
//               onPanStart: (_) {}, // Make sure pan is detected
//               onPanUpdate: _handlePanUpdate,
//               onPanEnd: _handlePanEnd,
//               child: OverflowBox(
//                 maxWidth: double.infinity,
//                 maxHeight: double.infinity,
//                 child: AnimatedScale(
//                   // --- THIS IS THE FIX ---
//                   // Scales to 0.95 (shrinks) when hovered
//                   scale: hoveredRingIndex == index ? 0.95 : 1.0,
//                   // ---------------------
//                   duration: const Duration(milliseconds: 120),
//                   child: ring,
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:project_a_b/data/models/ring_model.dart';
// ---------------------------------------------
import 'package:project_a_b/screens/rings/widgets/pixelated_circle.dart';

class RingssStack extends StatefulWidget {
  const RingssStack({
    super.key,
    required this.getHoveredIndex,
    required this.isSmall,
    // --- FIX 3: This widget now takes the DYNAMIC list of rings ---
    required this.rings,
  });

  final void Function(int index) getHoveredIndex;
  final bool isSmall;
  final List<UserRingModel> rings;

  @override
  State<RingssStack> createState() => _RingssStackState();
}

class _RingssStackState extends State<RingssStack> {
  int? hoveredRingIndex;
  final GlobalKey stackKey = GlobalKey();

  // (isPointInRing logic is unchanged)
  bool isPointInRing(Offset localPosition, double ringSize, double thickness) {
    if (stackKey.currentContext == null) return false;
    final center = Offset(
      stackKey.currentContext!.size!.width / 2,
      stackKey.currentContext!.size!.height / 2,
    );
    final distance = (localPosition - center).distance;
    final outerRadius = ringSize / 2;
    final innerRadius = outerRadius - thickness;
    return distance >= innerRadius && distance <= outerRadius;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (stackKey.currentContext == null) return;

    final RenderBox box =
        stackKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);

    // --- FIX 4: Loop over the DYNAMIC widget.rings list ---
    for (int i = widget.rings.length - 1; i >= 0; i--) {
      final ring = widget.rings[i]; // This is now a UserRingModel
      if (isPointInRing(localPosition, ring.size, ring.thickness)) {
        setState(() {
          hoveredRingIndex = i;
        });
        return;
      }
    }
    // ---------------------------------------------

    setState(() {
      hoveredRingIndex = null;
    });
  }

  // (_handlePanEnd logic is unchanged)
  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      if (hoveredRingIndex != null) {
        widget.getHoveredIndex(hoveredRingIndex!);
      }
      hoveredRingIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        key: stackKey,
        alignment: Alignment.center,
        children: [
          // --- FIX 5: Build the stack from the DYNAMIC widget.rings list ---
          ...widget.rings.asMap().entries.map((entry) {
            final index = entry.key;
            final ringData = entry.value; // This is the UserRingModel

            // We dynamically create the PixelatedCircle widget
            final ringWidget = PixelatedCircle(
              text: ringData.ringName, // <-- YOUR DYNAMIC NAME
              size: ringData.size,
              thickness: ringData.thickness,
              color: ringData.color,
              pixelSize: 10,
            );

            return GestureDetector(
              onPanStart: (_) {},
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              child: OverflowBox(
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: AnimatedScale(
                  scale: hoveredRingIndex == index ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 120),
                  child: ringWidget, // Use the dynamic widget
                ),
              ),
            );
          }),
          // ---------------------------------------------
        ],
      ),
    );
  }
}
