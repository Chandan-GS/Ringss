import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_a_b/controllers/signals_controller.dart';
import 'package:project_a_b/data/models/signal_model.dart';
import 'package:project_a_b/screens/signals/widgets/custom_vertical_slider.dart';
import 'package:project_a_b/widgets/custom/custom_icon_button.dart';
import 'package:project_a_b/widgets/custom/custom_profile_icon.dart';

// --- This is your new widget, which we will use ---
class CustomBgCardSignal extends StatelessWidget {
  const CustomBgCardSignal({
    super.key,
    required this.child,
    this.height,
    this.color,
    this.width,
    this.borderColor,
    this.borderWidth,
    this.constraints,
  });

  final Widget child;
  final double? height;
  final Color? color;
  final double? width;
  final Color? borderColor;
  final double? borderWidth;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    // Your shadow logic
    final double buttonLeftMargin = 4;
    final double shadowTopMargin = 4;
    final double shadowRightMargin = 4;
    final double buttonTopMargin = 0;

    return Stack(
      children: [
        // Shadow
        Container(
          constraints: constraints,
          margin: EdgeInsets.only(
            top: shadowTopMargin,
            right: shadowRightMargin,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
          ),
          child: Opacity(opacity: 0, child: child),
        ),
        // Field
        Container(
          constraints: constraints,
          margin: EdgeInsets.only(top: buttonTopMargin, left: buttonLeftMargin),
          width: width ?? double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color ?? Theme.of(context).colorScheme.primary,
            border: Border.all(
              color: borderColor ?? Colors.transparent,
              width: borderWidth ?? 0,
            ),
          ),
          child: Align(alignment: Alignment.topCenter, child: child),
        ),
      ],
    );
  }
}
// --- End of CustomBgCardSignal ---

class SignalCard extends GetView<SignalController> {
  const SignalCard({super.key, required this.signal});

  final SignalModel signal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final titleController = TextEditingController(text: signal.title);
    final contentController = TextEditingController(text: signal.content);

    return CustomBgCardSignal(
      constraints: const BoxConstraints(minHeight: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- 1. HEADER (FIXED HEIGHT) ---
          Obx(
            () => Container(
              height: 70,
              padding: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: signal.headerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomProfileIcon(
                      onTapped: () {},
                      imageUrl: signal.author.profilePicUrl,
                      userId: signal.author.id,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            signal.author.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            signal.author.username,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          signal.signalTypeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          DateFormat('dd-MM-yy').format(signal.createdAt),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- 2. CONTENT & ACTIONS (DYNAMIC) ---
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 330),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Left Side (Content + Buttons) ---
                  Expanded(
                    child: Column(
                      children: [
                        // --- Content Area (starts at top) ---
                        Container(
                          padding: const EdgeInsets.only(
                            left: 10,
                            top: 10,
                            right: 5,
                            bottom: 5,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              if (signal.title != null &&
                                  signal.title!.isNotEmpty)
                                TextField(
                                  controller: titleController,
                                  readOnly: true,
                                  maxLines: null,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),

                              // Image
                              if (signal.imageUrl != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      signal.imageUrl!,
                                      width: double.infinity,
                                      height: 250,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, progress) {
                                            if (progress == null) return child;
                                            return Container(
                                              height: 250,
                                              width: double.infinity,
                                              color: theme.cardColor,
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              height: 250,
                                              width: double.infinity,
                                              color: theme.cardColor,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.error_outline,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),

                              // Content
                              TextField(
                                controller: contentController,
                                readOnly: true,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                                cursorColor: theme.textTheme.bodyMedium?.color,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Spacer to push buttons to bottom
                        const Spacer(),

                        // Buttons at the bottom
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Save Button
                              Obx(
                                () => CustomIconButton(
                                  backgroundColor: signal.isSaved.value
                                      ? theme.cardColor
                                      : theme.scaffoldBackgroundColor,
                                  onTapped: () => controller.toggleSave(signal),
                                  iconAsset: "lib/assets/icons/save_signal.svg",
                                ),
                              ),
                              // Join (Comment) Button
                              CustomIconButton(
                                onTapped: () => controller.openComments(signal),
                                iconAsset: "lib/assets/icons/comment.svg",
                              ),
                              // Resignal Button
                              Obx(
                                () => CustomIconButton(
                                  backgroundColor: signal.isResignaled.value
                                      ? theme.cardColor
                                      : theme.scaffoldBackgroundColor,
                                  onTapped: () =>
                                      controller.toggleResignal(signal),
                                  iconAsset: "lib/assets/icons/re_signal.svg",
                                ),
                              ),
                              // Share Button
                              CustomIconButton(
                                onTapped: () {
                                  // TODO: Add Share logic
                                },
                                iconAsset: "lib/assets/icons/share_signal.svg",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- Slider at the bottom right ---
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 330,
                        child: CustomVerticalSlider(
                          initialValue:
                              (signal.myVote.value + 1) *
                              5, // -1->0, 0->5, 1->10
                          onValueChanged: (value) {
                            controller.amplifyDampen(signal, value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
