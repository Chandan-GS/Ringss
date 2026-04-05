import 'package:flutter/material.dart';
import 'package:project_a_b/widgets/custom/custom_icon_button.dart';

class CustomDialogCard extends StatelessWidget {
  const CustomDialogCard({
    super.key,
    required this.title,
    required this.content,
    this.width = 350,
    this.height = 400,
  });

  final String title;
  final Widget content;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // This style will use Pixelify Sans IF you have fixed main.dart
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      fontSize: 40,
      fontWeight: FontWeight.normal,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(24),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            // Your new Shadow
            Container(
              margin: const EdgeInsets.fromLTRB(0, 5, 5, 5),
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black,
              ),
            ),
            // Your new Card
            Container(
              margin: const EdgeInsets.fromLTRB(5, 0, 0, 10),
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.primary, width: 3),
                color: theme.colorScheme.primary,
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  top: 10,
                  bottom: 20,
                  right: 10, // Added right padding
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Close Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomIconButton(
                          onTapped: () {
                            // --- THIS IS THE FIX ---
                            // Use Flutter's Navigator to pop the dialog
                            Navigator.of(context).pop();
                            // -------------------------
                          },
                          iconAsset: 'lib/assets/icons/cancel_button.svg',
                        ),
                      ],
                    ),
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: titleStyle),
                              const SizedBox(height: 20),
                              content, // Your cardDesc widget
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
