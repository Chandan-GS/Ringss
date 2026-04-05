import 'dart:io'; // Import for File
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_a_b/controllers/rings_management_controller.dart';
import 'package:project_a_b/controllers/signals_controller.dart';
import 'package:project_a_b/widgets/custom/custom_bg_card.dart';
import 'package:project_a_b/widgets/custom/custom_icon_button.dart';
import 'package:project_a_b/widgets/custom/custom_text_button.dart';

// --- FIX 1: Convert to StatefulWidget ---
class CreateSignalScreen extends StatefulWidget {
  const CreateSignalScreen({super.key, required this.index});

  final int index;

  @override
  State<CreateSignalScreen> createState() => _CreateSignalScreenState();
}

class _CreateSignalScreenState extends State<CreateSignalScreen> {
  // --- FIX 2: Get controllers ---
  late final RingsManagementController ringsController;
  late final SignalController signalController;

  @override
  void initState() {
    super.initState();
    // --- FIX 3: Find controllers in initState ---
    ringsController = Get.find<RingsManagementController>();
    signalController = Get.find<SignalController>();

    // --- FIX 4: Move the clear() logic here ---
    // This now runs ONLY ONCE when the sheet opens.
    signalController.signalTitleController.clear();
    signalController.signalContentController.clear();
    signalController.clearImage();
  }

  @override
  Widget build(BuildContext context) {
    // Controllers are now available as class members
    final theme = Theme.of(context);
    final selectedRing =
        ringsController.rings[widget.index]; // Use widget.index

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Spacer(),
              Text(
                "Signal to ${selectedRing.ringName}", // Dynamic name
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const Spacer(),
              CustomIconButton(
                onTapped: () => Get.back(),
                iconAsset: "lib/assets/icons/cancel_button.svg",
              ),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 20),

          // --- TITLE ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomBgCard(
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Added padding
                child: TextField(
                  controller:
                      signalController.signalTitleController, // This works
                  cursorColor: theme.textTheme.bodyMedium?.color,
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: "Title",
                    hintStyle: TextStyle(fontSize: 18, color: theme.hintColor),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),

          // --- IMAGE PREVIEW ---
          Obx(() {
            if (signalController.selectedImage.value == null) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      signalController.selectedImage.value!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomIconButton(
                      backgroundColor:
                          theme.scaffoldBackgroundColor, // Your color
                      onTapped: () => signalController.clearImage(),
                      iconAsset: 'lib/assets/icons/cancel_button.svg',
                    ),
                  ),
                ],
              ),
            );
          }),

          // --- CONTENT CARD ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomBgCard(
              height: 350,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: signalController
                              .signalContentController, // This works
                          style: TextStyle(
                            fontSize: 16, // Your style
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                          cursorColor: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "What's on your mind?",
                            hintStyle: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // --- ADD IMAGE BUTTON ---
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomIconButton(
                          onTapped: () => signalController.pickImage(),
                          iconAsset: 'lib/assets/icons/attachment.svg',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),

          // --- SUBMIT BUTTON ---
          Obx(
            () => CustomTextButton(
              onTapped: signalController.isUploading.value
                  ? () {}
                  : () => signalController.createSignal(
                      ringsController.rings,
                      widget.index, // Use widget.index
                    ),
              text: signalController.isUploading.value
                  ? "Uploading..."
                  : "Signal",
              width: 150,
              height: 60,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
