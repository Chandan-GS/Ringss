import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_a_b/controllers/auth_controller.dart';
import 'package:project_a_b/core/routes/app_routes.dart';
import 'package:project_a_b/widgets/custom/custom_app_bar.dart';
import 'package:project_a_b/widgets/custom/custom_text_button.dart';
import 'package:project_a_b/widgets/custom/custom_text_field.dart';
import 'package:project_a_b/widgets/custom/google_auth_button.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _showEmail = true.obs; // For switching between email/phone

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.scaffoldBackgroundColor,
      // 1. APP BAR
      appBar: CustomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Don't have an account?",
              style: GoogleFonts.pixelifySans(
                // Font call
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            // Your GestureDetector button from your code
            CustomTextButton(
              width: 100,
              onTapped: () {
                Get.toNamed(AppRoutes.SIGNUP);
              },
              text: "Sign up",
            ),
          ],
        ),
      ),
      // 2. BODY
      body: Stack(
        children: [
          // Background SVGs
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: SvgPicture.asset(
                    "lib/assets/images/small_logo_right.svg",
                    width: 170,
                    height: 170,
                    fit: BoxFit.fill,
                  ),
                ),

                Align(
                  alignment: Alignment.bottomLeft,
                  child: SvgPicture.asset(
                    "lib/assets/images/small_logo_left.svg",
                    width: 170,
                    height: 170,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ),
          // Form
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(
                      () => _showEmail.value
                          ? _buildEmailField(theme)
                          : _buildPhoneField(theme),
                    ),
                    _buildLoginToggle(theme, _showEmail),
                    const SizedBox(height: 40),
                    Obx(
                      () => CustomTextField(
                        child: TextField(
                          controller: controller.passwordController,
                          cursorColor: theme.textTheme.bodyMedium?.color,
                          cursorHeight: 15,
                          obscuringCharacter: "∗",
                          obscureText: controller.obscureText.value,
                          style: GoogleFonts.pixelifySans(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 18,
                          ),
                          decoration: _buildInputDecoration(
                            theme,
                            hint: "password",
                            iconAsset: "lib/assets/icons/lock_icon.svg",
                            suffixIcon: IconButton(
                              onPressed: () => controller.toggleObscureText(),
                              icon: Icon(
                                controller.obscureText.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: theme.hintColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildForgotAndUpgrade(theme),
                    const SizedBox(height: 40),
                    Obx(
                      () => CustomTextButton(
                        onTapped: controller.isLoading.value
                            ? () {} // Do nothing
                            : () => controller.login(),
                        text: controller.isLoading.value
                            ? "Loading..."
                            : "Login",
                        width: 200,
                        height: 60,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "------------------------ or ------------------------",
                      style: GoogleFonts.pixelifySans(
                        color: const Color.fromARGB(255, 178, 172, 172),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GoogleAuthButton(onTapped: () => controller.googleSignIn()),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginToggle(ThemeData theme, RxBool showEmail) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          const SizedBox(width: 3),
          Text(
            "Login using",
            style: GoogleFonts.pixelifySans(
              fontSize: 16,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          GestureDetector(
            onTap: () => showEmail.toggle(),
            child: Obx(
              () => Text(
                showEmail.value ? " mobile number" : " e-mail",
                style: GoogleFonts.pixelifySans(
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotAndUpgrade(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            /* controller.forgotPassword(); */
          },
          child: Padding(
            padding: EdgeInsetsGeometry.only(top: 10),
            child: Text(
              "Forgot password ?",
              style: GoogleFonts.pixelifySans(
                fontSize: 16,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return CustomTextField(
      child: TextField(
        controller: controller.emailController,
        cursorColor: theme.textTheme.bodyMedium?.color,
        cursorHeight: 15,
        style: GoogleFonts.pixelifySans(
          color: theme.textTheme.bodyMedium?.color,
          fontSize: 18,
        ),
        decoration: _buildInputDecoration(
          theme,
          hint: "e-mail",
          iconAsset: "lib/assets/icons/mail_icon.svg",
        ),
      ),
    );
  }

  Widget _buildPhoneField(ThemeData theme) {
    return CustomTextField(
      child: TextField(
        controller: controller.phoneController,
        keyboardType: TextInputType.number,
        cursorColor: theme.textTheme.bodyMedium?.color,
        cursorHeight: 15,
        style: GoogleFonts.pixelifySans(
          color: theme.textTheme.bodyMedium?.color,
          fontSize: 18,
        ),
        decoration: _buildInputDecoration(
          theme,
          hint: "mobile number",
          iconAsset: "lib/assets/icons/phone_icon.svg",
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    ThemeData theme, {
    required String hint,
    required String iconAsset,
    String? prefixText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      border: InputBorder.none, // <-- Fixes border issue
      prefixText: prefixText,
      prefixStyle: GoogleFonts.pixelifySans(
        color: theme.textTheme.bodyMedium?.color,
        fontSize: 18,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(10),
        child: SvgPicture.asset(
          iconAsset,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(theme.hintColor, BlendMode.srcIn),
        ),
      ),
      hintStyle: GoogleFonts.pixelifySans(color: theme.hintColor, fontSize: 18),
      hintText: hint,
      suffixIcon: suffixIcon,
    );
  }
}
