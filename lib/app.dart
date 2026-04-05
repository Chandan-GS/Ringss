import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_a_b/bindings/initial_binding.dart';
import 'package:project_a_b/core/routes/app_pages.dart';
import 'package:project_a_b/core/theme/app_theme.dart';
import 'package:project_a_b/controllers/theme_controller.dart';

class RingssApp extends StatelessWidget {
  const RingssApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ThemeController
    final ThemeController themeController = Get.put(ThemeController());

    // DON'T wrap the entire GetMaterialApp in Obx
    return GetMaterialApp(
      title: "Ringss",
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Use a simple getter that reacts to changes
      themeMode: themeController.themeMode.value,

      getPages: AppPages.routes,
      initialRoute: AppPages.INITIAL,

      initialBinding: InitialBinding(),
    );
  }
}
