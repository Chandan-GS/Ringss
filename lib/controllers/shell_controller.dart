import 'package:get/get.dart';

class ShellController extends GetxController {
  // 0 = Signals, 1 = Rings, 2 = Community, 3 = Profile
  // You want "Rings" to be the default.
  var tabIndex = 1.obs;

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}
