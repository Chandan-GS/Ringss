import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_a_b/controllers/signals_controller.dart';
import 'package:project_a_b/controllers/source_controller.dart';
import 'package:project_a_b/data/models/signal_model.dart';
import 'package:project_a_b/widgets/custom/custom_bg_card.dart';
import 'package:project_a_b/widgets/custom/custom_icon_button.dart';
import 'package:project_a_b/widgets/custom/custom_profile_icon.dart';

class SignalCardProfile extends StatelessWidget {
  const SignalCardProfile({super.key, required this.signal});

  final SignalModel signal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final SourceController sourceController = Get.find();
    final SignalController signalController = Get.find();

    final titleController = TextEditingController(text: signal.title);
    final contentController = TextEditingController(text: signal.content);

    return CustomBgCard(
      height: 500,
      child: Column(
        children: [
          // --- DYNAMIC HEADER ---
          Obx(
            () => Container(
              height: 70,
              padding: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: signal.headerColor, // Dynamic
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
                    CustomProfileIcon(onTapped: () {}),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            signal.author.displayName, // Dynamic
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            signal.author.username, // Dynamic
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.6),
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
                          signal.signalTypeName, // Dynamic
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          DateFormat(
                            'dd-MM-yy',
                          ).format(signal.createdAt), // Dynamic
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // --- DYNAMIC CONTENT ---
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (signal.title != null)
                                  TextField(
                                    controller: titleController,
                                    readOnly: true,
                                    maxLines: null,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                TextField(
                                  controller: contentController,
                                  readOnly: true,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                  cursorColor: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // --- DYNAMIC ACTIONS ---
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 0),
                            CustomIconButton(
                              onTapped: () =>
                                  signalController.openComments(signal),
                              iconAsset: "lib/assets/icons/comment.svg",
                            ),
                            const SizedBox(width: 20),
                            CustomIconButton(
                              onTapped: () {
                                // TODO: Share logic
                              },
                              iconAsset: "lib/assets/icons/share_signal.svg",
                            ),
                            const SizedBox(width: 20),
                            CustomIconButton(
                              onTapped: () =>
                                  sourceController.deleteSignal(signal),
                              iconAsset: "lib/assets/icons/user-minus.svg",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
