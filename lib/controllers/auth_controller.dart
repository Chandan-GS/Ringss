import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_a_b/core/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  // --- Supabase Client ---
  final supabase = Supabase.instance.client;

  // --- Text Controllers ---
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController phoneController;
  late TextEditingController confirmPasswordController;

  // --- UI State ---
  var obscureText = true.obs;
  var isLoading = false.obs;
  var isPremium = false.obs;
  var selectedPetIndex = 0.obs;
  final List<String> petTypes = ['Pet 1', 'Pet 2', 'Pet 3'];

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    usernameController = TextEditingController();
    phoneController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // --- UI Helpers ---
  void toggleObscureText() => obscureText.toggle();
  void togglePremium(bool? value) => isPremium.value = value ?? false;
  void selectPet(int index) => selectedPetIndex.value = index;

  // --- AUTH LOGIC ---
  Future<void> deleteAccount() async {
    if (isLoading.value) return;
    try {
      isLoading(true);
      await supabase.rpc('delete_user_account');
      Get.snackbar(
        "Account Deleted",
        "Your account and all data have been permanently deleted.",
      );
    } catch (e) {
      Get.snackbar("Error", "Could not delete account: ${e.toString()}");
      isLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      isLoading(true);
      await supabase.auth.signOut();
      // --- ADD THIS BACK ---
      // If you don't have a global listener, you need this.
      Get.offAllNamed(AppRoutes.LOGIN); // Or your splash/login route
      // ---------------------
    } on AuthException catch (e) {
      _showError("Logout Failed", e.message);
    } finally {
      isLoading(false);
    }
  }

  Future<void> login() async {
    if (isLoading.value) return;

    try {
      isLoading(true);
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        throw ("Email and password cannot be empty.");
      }

      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      _clearControllers();
      // --- THIS IS THE FIX ---
      // Add the navigation back in.
      Get.offAllNamed(AppRoutes.SHELL);
      // -----------------------
    } on AuthException catch (e) {
      _showError("Login Failed", e.message);
    } catch (e) {
      _showError("Login Failed", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> signUp() async {
    if (isLoading.value) return;

    try {
      isLoading(true);
      // --- Validation ---
      if (passwordController.text != confirmPasswordController.text) {
        throw ('Passwords do not match.');
      }
      if (isPremium.value && selectedPetIndex.value == -1) {
        throw ('Please select an AI Pet to continue.');
      }

      final pet = isPremium.value ? petTypes[selectedPetIndex.value] : null;

      // 1. Create user in Supabase Auth
      // The database trigger will read this 'data'
      final authResponse = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {
          'display_name': nameController.text.trim(),
          'username': usernameController.text.trim(),
          'mobile_number': phoneController.text.trim(),
          'is_premium': isPremium.value,
          'pet_type': pet,
        },
      );

      final user = authResponse.user;
      if (user == null) {
        throw ('Sign-up failed. Please try again.');
      }

      // 2. Database trigger handles the rest.

      // 3. Navigate to main app
      _clearControllers();
      // --- THIS IS THE FIX ---
      // Add the navigation back in.
      Get.offAllNamed(AppRoutes.SHELL);
      // -----------------------
    } on AuthException catch (e) {
      _showError("Sign-up Failed", e.message);
    } catch (e) {
      _showError("Sign-up Failed", e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Placeholder for Google Sign-In
  Future<void> googleSignIn() async {
    if (isLoading.value) return;
    try {
      isLoading(true);
      _showError("Google Sign-In", "Not yet implemented.");
    } catch (e) {
      _showError("Google Sign-In", "An error occurred.");
    } finally {
      isLoading(false);
    }
  }

  void _clearControllers() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    usernameController.clear();
    phoneController.clear();
    confirmPasswordController.clear();
  }

  // --- ERROR HANDLING ---
  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red[600],
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
