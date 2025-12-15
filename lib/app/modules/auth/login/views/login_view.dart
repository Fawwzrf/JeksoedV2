import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../widget/primary_button.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hai Bung!",
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Welcome Back!",
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Email Field
                    TextField(
                      controller: controller.emailC,
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "Masukan email kamu",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    Obx(
                      () => TextField(
                        controller: controller.passwordC,
                        obscureText: !controller.isPasswordVisible.value,
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Masukan password kamu",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                      ),
                    ),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: controller.goToForgotPassword,
                        child: Text(
                          "Lupa Password?",
                          style: TextStyle(
                            color: AppColors.accentDark,
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    Obx(
                      () => controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : PrimaryButton(
                              text: "Masuk",
                              onPressed: controller.login,
                              containerColor: const Color(0xFFFFC107),
                              contentColor: Colors.black,
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Register Link
                    Center(
                      child: GestureDetector(
                        onTap: controller.goToRoleSelection,
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            children: [
                              const TextSpan(text: "Belum punya akun? "),
                              TextSpan(
                                text: "Daftar disini!",
                                style: TextStyle(
                                  color: AppColors.accentDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Terms and Conditions - Positioned at bottom
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: controller.goToTerms,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    children: [
                      const TextSpan(text: "Aku setuju sama "),
                      TextSpan(
                        text: "Syarat & Ketentuan",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: " Privasi kita."),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
