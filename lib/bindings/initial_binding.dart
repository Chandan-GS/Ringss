import 'package:get/get.dart';
import 'package:project_a_b/controllers/auth_controller.dart';
import 'package:project_a_b/controllers/theme_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // --- THIS IS THE FIX ---
    // Put the controllers that need to live for the
    // entire app session.

    Get.put(AuthController(), permanent: true);
    // --- END OF FIX ---
  }
}
