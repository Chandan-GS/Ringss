import 'package:get/get.dart';
import 'package:project_a_b/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // This just finds the already-existing AuthController
    // This is useful if the controller was ever terminated
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
