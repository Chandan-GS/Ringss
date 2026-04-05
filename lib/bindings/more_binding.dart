import 'package:get/get.dart';
import 'package:project_a_b/controllers/auth_controller.dart';
import 'package:project_a_b/controllers/theme_controller.dart';

class MoreBinding extends Bindings {
  @override
  void dependencies() {
    // Don't create new instances - find the existing permanent ones
    // These were already created by SplashBinding

    // Actually, you don't need to do anything here since they're permanent!
    // But if you want to be explicit:
    try {
      Get.find<ThemeController>();
    } catch (e) {
      Get.put(ThemeController(), permanent: true);
    }

    try {
      Get.find<AuthController>();
    } catch (e) {
      // This should never happen since AuthController is permanent
      print("⚠️ AuthController not found - this shouldn't happen!");
    }
  }
}
