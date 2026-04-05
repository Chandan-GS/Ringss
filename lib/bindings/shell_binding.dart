import 'package:get/get.dart';
import 'package:project_a_b/controllers/shell_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShellController>(() => ShellController());
  }
}
