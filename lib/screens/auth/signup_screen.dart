import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_a_b/controllers/auth_controller.dart';
import 'package:project_a_b/core/theme/app_colors.dart';
import 'package:project_a_b/widgets/custom/custom_app_bar.dart';
import 'package:project_a_b/widgets/custom/custom_text_button.dart';
import 'package:project_a_b/widgets/custom/custom_text_field.dart';
import 'package:project_a_b/widgets/custom/google_auth_button.dart';

class SignUpScreen extends GetView<AuthController> {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.scaffoldBackgroundColor,
      // 1. APP BAR
      appBar: CustomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Have an account?",
              style: GoogleFonts.pixelifySans(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            CustomTextButton(
              width: 100,
              onTapped: () {
                Get.back();
              },
              text: "Login",
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
                Hero(
                  tag: 'logo_right',
                  child: Align(
                    alignment: Alignment.topRight,
                    child: SvgPicture.asset(
                      "lib/assets/images/small_logo_right.svg",
                      width: 170,
                      height: 170,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Hero(
                  tag: 'logo_left',
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: SvgPicture.asset(
                      "lib/assets/images/small_logo_left.svg",
                      width: 170,
                      height: 170,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Form
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    _buildTextField(
                      theme,
                      controller: controller.nameController,
                      hint: "Full name",
                    ),
                    _buildTextField(
                      theme,
                      controller: controller.usernameController,
                      hint: "username",
                      maxLength: 20,
                    ),
                    _buildTextField(
                      theme,
                      controller: controller.phoneController,
                      hint: "mobile number",
                      iconAsset: "lib/assets/icons/phone_icon.svg",

                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      theme,
                      controller: controller.emailController,
                      hint: "e-mail",
                      iconAsset: "lib/assets/icons/mail_icon.svg",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    Obx(
                      () => _buildTextField(
                        theme,
                        controller: controller.passwordController,
                        hint: "password",
                        iconAsset: "lib/assets/icons/lock_icon.svg",
                        isPassword: controller.obscureText.value,
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
                    _buildTextField(
                      theme,
                      controller: controller.confirmPasswordController,
                      hint: "Confirm Password",
                      iconAsset: "lib/assets/icons/lock_icon.svg",
                      isPassword: true,
                    ),
                    const SizedBox(height: 20),
                    _buildPremiumToggle(theme, controller.isPremium),
                    const SizedBox(height: 20),
                    Obx(
                      () => Visibility(
                        visible: controller.isPremium.value,
                        child: _buildPetSelector(
                          theme,
                          controller.selectedPetIndex,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Obx(
                      () => CustomTextButton(
                        onTapped: controller.isLoading.value
                            ? () {}
                            : () => controller.signUp(),
                        text: controller.isLoading.value
                            ? "Loading..."
                            : "Sign up",
                        width: 200,
                        height: 60,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "------------------------ or ------------------------",
                      style: GoogleFonts.pixelifySans(
                        color: const Color.fromARGB(255, 178, 172, 172),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GoogleAuthButton(
                      onTapped: () => controller.googleSignIn(),
                      text: "Sign up with Google",
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    ThemeData theme, {
    required TextEditingController controller,
    required String hint,
    String? iconAsset,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? prefixText,
    Widget? suffixIcon,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13.0),
      child: CustomTextField(
        child: TextField(
          controller: controller,
          maxLength: maxLength,
          keyboardType: keyboardType,
          cursorColor: theme.textTheme.bodyMedium?.color,
          cursorHeight: 15,
          obscuringCharacter: "∗",
          obscureText: isPassword,
          style: GoogleFonts.pixelifySans(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixText: prefixText,
            prefixStyle: GoogleFonts.pixelifySans(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 18,
            ),
            prefixIcon: iconAsset != null
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      iconAsset,
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        theme.hintColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  )
                : null,
            suffixIcon: suffixIcon,
            hintStyle: GoogleFonts.pixelifySans(
              color: theme.hintColor,
              fontSize: 18,
            ),
            hintText: hint,
            counterText: "", // Hide the default counter
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumToggle(ThemeData theme, RxBool isPremium) {
    return CustomTextButton(
      onTapped: () {
        isPremium.toggle();
      },
      text: "Unlock Pets!",
      width: 200,
      height: 60,
    );
  }

  Widget _buildPetSelector(ThemeData theme, RxInt selectedIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Choose your AI Pet:",
          style: GoogleFonts.pixelifySans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPetOption(theme, 0, "Pet 1", selectedIndex),
            _buildPetOption(theme, 1, "Pet 2", selectedIndex),
            _buildPetOption(theme, 2, "Pet 3", selectedIndex),
          ],
        ),
      ],
    );
  }

  Widget _buildPetOption(
    ThemeData theme,
    int index,
    String name,
    RxInt selectedIndex,
  ) {
    return Obx(() {
      final isSelected = selectedIndex.value == index;
      return GestureDetector(
        onTap: () => selectedIndex.value = index,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryPinkLight
                : theme.colorScheme.primary,
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryRed
                  : theme.colorScheme.secondary,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              name,
              style: GoogleFonts.pixelifySans(
                color: theme.textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    });
  }
}
