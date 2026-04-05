import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_a_b/controllers/notification_controller.dart';

import 'package:project_a_b/controllers/signals_controller.dart';
import 'package:project_a_b/screens/signals/widgets/notification_screen.dart';

import 'package:project_a_b/screens/signals/widgets/signal_card.dart';
import 'package:project_a_b/widgets/custom/custom_app_bar.dart';
import 'package:project_a_b/widgets/custom/custom_icon_button.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

class SignalsFeedScreen extends GetView<SignalController> {
  const SignalsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put *both* controllers
    Get.put(SignalController());
    final notificationsController = Get.put(
      NotificationsController(),
    ); // <-- 3. Put
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Signals",
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Stack(
              alignment: Alignment.topRight,
              children: [
                CustomIconButton(
                  onTapped: () {
                    // --- 4. Open the new screen ---
                    Get.bottomSheet(
                      const NotificationsScreen(),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    );
                  },
                  iconAsset: 'lib/assets/icons/notification.svg',
                ),
                // --- 5. Show the red dot based on controller state ---
                Obx(
                  () => Visibility(
                    visible:
                        notificationsController.hasUnreadNotifications.value,
                    child: Positioned(
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.signals.isEmpty) {
          return Center(
            child: Image.asset(
              "lib/assets/gifs/loading.gif",
              gaplessPlayback: true,
              height: 30,
              width: 30,
              color: Colors.red,
            ),
          );
        }

        return CustomRefreshIndicator(
          onRefresh: () => controller.fetchSignalFeed(),
          builder: (context, child, indicatorController) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: indicatorController.isLoading ? 1.0 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Image.asset(
                      "lib/assets/gifs/loading.gif",
                      gaplessPlayback: true,
                      height: 30,
                      width: 30,
                      color: Colors.red,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, 100 * indicatorController.value),
                  child: child,
                ),
              ],
            );
          },
          child: controller.signals.isEmpty
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: const Center(
                          child: Text("Your signal feed is empty."),
                        ),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  itemCount: controller.signals.length,
                  padding: const EdgeInsets.only(top: 20, left: 13, right: 13),
                  itemBuilder: (context, index) {
                    final signal = controller.signals[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: SignalCard(signal: signal),
                    );
                  },
                ),
        );
      }),
    );
  }
}
