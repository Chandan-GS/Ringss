import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:project_a_b/controllers/comments_controller.dart';
import 'package:project_a_b/data/models/signal_model.dart';
import 'package:project_a_b/screens/signals/widgets/comment_card.dart';
import 'package:project_a_b/widgets/custom/custom_icon_button.dart';
import 'package:project_a_b/widgets/custom/custom_text_button.dart';
import 'package:project_a_b/widgets/custom/custom_text_field.dart';

class SignalCommentsSheet extends StatelessWidget {
  const SignalCommentsSheet({super.key, required this.signal});

  final SignalModel signal;

  @override
  Widget build(BuildContext context) {
    // --- MODIFIED: Pass the signal to the controller ---
    final controller = Get.put(
      CommentsController(signalId: signal.id, signal: signal),
    );
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // --- HEADER ---
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Spacer(),
              Column(
                children: [
                  Text(
                    "Join the Signal",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    signal.title ?? "Signal discussion",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const Spacer(),
              CustomIconButton(
                onTapped: () => Get.back(), // Closes the sheet
                iconAsset: "lib/assets/icons/cancel_button.svg",
              ),
            ],
          ),
          const SizedBox(height: 10),

          // --- TABS ---
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                CustomTextButton(
                  backgroundColor: controller.selectedType.value == 'harmonize'
                      ? theme.cardColor
                      : theme.scaffoldBackgroundColor,
                  onTapped: () => controller.changeType('harmonize'),
                  text: "Harmonize",
                  width: MediaQuery.of(context).size.width * 0.28,
                ),
                const Spacer(),
                CustomTextButton(
                  backgroundColor: controller.selectedType.value == 'clarify'
                      ? theme.cardColor
                      : theme.scaffoldBackgroundColor,
                  onTapped: () => controller.changeType('clarify'),
                  text: "Clarify",
                  width: MediaQuery.of(context).size.width * 0.28,
                ),
                const Spacer(),
                CustomTextButton(
                  backgroundColor: controller.selectedType.value == 'counter'
                      ? theme.cardColor
                      : theme.scaffoldBackgroundColor,
                  onTapped: () => controller.changeType('counter'),
                  text: "Counter",
                  width: MediaQuery.of(context).size.width * 0.28,
                ),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // --- NEW: AI SUGGESTIONS SECTION ---
          _buildAiSuggestions(context, controller),
          // ---------------------------------

          // --- COMMENT LIST ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.comments.isEmpty) {
                return const Center(child: Text("Be the first to comment!"));
              }
              return ListView.builder(
                itemCount: controller.comments.length,
                itemBuilder: (context, index) {
                  final comment = controller.comments[index];
                  // Render the top-level comment card
                  return CommentCard(comment: comment, depth: 0);
                },
              );
            }),
          ),

          // --- TEXT INPUT FIELD ---
          Column(
            children: [
              // "Replying to" banner
              Obx(() {
                if (controller.replyingTo.value == null) {
                  return const SizedBox.shrink();
                }
                final replyingToUser =
                    controller.replyingTo.value!.author.username;
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Replying to @$replyingToUser...",
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: SvgPicture.asset(
                          "lib/assets/icons/cancel_button.svg",
                          colorFilter: ColorFilter.mode(
                            theme.textTheme.bodyMedium?.color ?? Colors.black,
                            BlendMode.srcIn,
                          ),
                          width: 25,
                          height: 25,
                          fit: BoxFit.contain,
                        ),
                        onPressed: () => controller.setReplyingTo(null),
                      ),
                    ],
                  ),
                );
              }),

              // --- GIF PREVIEW ---
              Obx(() {
                if (controller.selectedGifUrl.value == null) {
                  return const SizedBox.shrink();
                }
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        controller.selectedGifUrl.value!,
                        height: 150,
                      ),
                    ),
                    CustomIconButton(
                      onTapped: () => controller.clearGif(),
                      iconAsset: 'lib/assets/icons/cancel_button.svg',
                    ),
                  ],
                );
              }),

              const SizedBox(height: 5),
              // The text field
              CustomTextField(
                height: 70, // Your height
                child: TextField(
                  cursorColor: theme.textTheme.bodyMedium?.color,
                  controller: controller.textController,
                  maxLines: 10,
                  minLines: 1,
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  decoration: InputDecoration(
                    hintText: "Add a comment...",
                    hintStyle: TextStyle(color: theme.hintColor),
                    border: InputBorder.none,

                    // --- NEW: GIF Button ---

                    // -------------------------
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // You can add your image attachment button here
                        // CustomIconButton(
                        //   onTapped: () {},
                        //   iconAsset: "lib/assets/icons/attachment.svg",
                        // ),
                        CustomIconButton(
                          onTapped: () => controller.pickGif(context),
                          iconAsset: "lib/assets/icons/gif.svg", // Your path
                        ),
                        const SizedBox(width: 10),
                        CustomIconButton(
                          onTapped: () => controller.postComment(),
                          iconAsset: "lib/assets/icons/send-arrow.svg",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  // --- NEW: AI Suggestions Widget ---
  Widget _buildAiSuggestions(
    BuildContext context,
    CommentsController controller,
  ) {
    final theme = Theme.of(context);
    return Obx(() {
      // 1. Show Loading
      if (controller.isAiLoading.value) {
        return const SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      }

      // 2. Show Error / Retry
      if (controller.isAiError.value) {
        return Container(
          height: 60,
          padding: const EdgeInsets.only(bottom: 10),
          child: Center(
            child: GestureDetector(
              onTap: () => controller.fetchAiSuggestions(),
              child: Text(
                "AI suggestions failed. Tap to retry.",
                style: GoogleFonts.pixelifySans(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }

      // 3. Show Suggestions (if any)
      if (controller.aiSuggestions.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        height: 100,
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Pet Suggestions (${controller.aiSuggestionCategory.value}):",
              style: GoogleFonts.pixelifySans(
                fontSize: 14,
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.aiSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = controller.aiSuggestions[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CustomTextButton(
                      textSize: 12,
                      onTapped: () => controller.postAiSuggestion(suggestion),
                      text: suggestion,
                      height: 50,
                      width: 200,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
