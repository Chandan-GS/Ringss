import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'themeMode';

  // Make the themeMode reactive
  final themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromBox();
  }

  // Load the saved theme from storage
  void _loadThemeFromBox() {
    String themeString = _box.read(_key) ?? 'System';
    themeMode.value = _getThemeModeFromString(themeString);
    Get.changeThemeMode(themeMode.value);
  }

  // Set the new theme and save it
  void setThemeMode(String mode) {
    themeMode.value = _getThemeModeFromString(mode);
    Get.changeThemeMode(themeMode.value);
    _box.write(_key, mode);
  }

  ThemeMode _getThemeModeFromString(String mode) {
    switch (mode) {
      case 'Light':
        return ThemeMode.light;
      case 'Dark':
        return ThemeMode.dark;
      case 'System':
      default:
        return ThemeMode.system;
    }
  }

  String getThemeString() {
    switch (themeMode.value) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
      default:
        return 'System';
    }
  }
}
