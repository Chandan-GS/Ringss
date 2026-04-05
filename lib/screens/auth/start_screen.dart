import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:project_a_b/core/routes/app_routes.dart';
import 'package:project_a_b/widgets/custom/custom_app_bar.dart';
import 'package:project_a_b/widgets/custom/custom_dialog_card.dart';
import 'package:project_a_b/widgets/custom/custom_icon_button.dart';
import 'package:project_a_b/widgets/custom/custom_text_button.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  /// Shows the "Welcome" dialog
  void _showWelcomeDialog(BuildContext context) {
    final theme = Theme.of(context);

    // This text style matches your cardDesc function
    final descStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      height: 1.5,
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return CustomDialogCard(
          title: "Welcome,",
          content: SingleChildScrollView(
            child: Text(
              "Get ready to eliminate all your distractions with Ringss. Dive into a social media experience designed to begin intellectual conversations and genuine connections. Share your thoughts, ideas, and creative impulses.",
              style: descStyle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // This text style matches your bgTitle function
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      fontSize: 60,
      fontWeight: FontWeight.normal,
    );

    // This text style matches your bgDesc function
    final descStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.normal,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // 1. APP BAR
      appBar: CustomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title from image
            Text(
              "Rings",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            // New CustomTextButton for the '?'
            CustomIconButton(
              onTapped: () {
                _showWelcomeDialog(context);
              },
              iconAsset: "lib/assets/icons/question_icon.svg",
            ),
          ],
        ),
      ),

      // 2. BODY
      body: SingleChildScrollView(
        // Added to prevent overflow on small screens
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 250),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Hero(
                        tag: 'logo_left',
                        child: SvgPicture.asset(
                          'lib/assets/images/left_logo.svg', // From your asset list
                          width: 350,
                          height: 350,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Hero(
                          tag: 'logo_right',
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: SvgPicture.asset(
                              'lib/assets/images/logo_right.svg', // From your asset list
                              width: 350,
                              height: 350,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),

                        // Title and Subtitle
                        Container(
                          margin: const EdgeInsets.only(top: 30, left: 30),
                          width: 240,
                          height: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Ringss", style: titleStyle),
                              const SizedBox(height: 20),
                              Text(
                                "Social media for the intellects",
                                style: descStyle,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 3. GET STARTED BUTTON
              const SizedBox(height: 20),
              CustomTextButton(
                onTapped: () {
                  // Use GetX for navigation
                  Get.offNamed(AppRoutes.LOGIN);
                },
                text: "Get Started",
                width: 170,
                height: 60,
                // Use theme colors for the pink button
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
