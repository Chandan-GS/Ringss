import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_a_b/data/models/signal_model.dart';
import 'package:project_a_b/widgets/custom/custom_bg_card.dart';

class SmallCards extends StatelessWidget {
  const SmallCards({super.key, required this.signal, required this.onTap});

  final SignalModel signal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // --- FIX: Removed the Expanded widget ---
    // The parent (Wrap > Container) now controls the size.
    return GestureDetector(
      onTap: onTap,
      child: CustomBgCard(
        color: signal.headerColor, // Use dynamic color
        height: 100,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  signal.title ?? "Signal", // Dynamic Title
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  signal.content, // Dynamic Content (desc)
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
