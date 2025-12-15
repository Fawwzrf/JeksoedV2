import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jeksoedv2/utils/app_colors.dart';
import '../controllers/register_passenger_controller.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widget/primary_button.dart';

class RegisterPassengerView extends GetView<RegisterPassengerController> {
  const RegisterPassengerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selamat Bergabung!",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Daftar dulu, Kak!",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            _buildTextField(controller.nameC, "Nama", "Masukan nama kamu"),
            _buildTextField(controller.nimC, "NIM", "Masukan NIM kamu"),
            _buildTextField(controller.emailC, "Email", "Masukan email kamu"),
            _buildTextField(
              controller.phoneC,
              "Nomor Hp",
              "Masukan nomor hp kamu",
              isNumber: true,
            ),            Obx(
              () => TextField(
                controller: controller.passwordC,
                obscureText: !controller.isPasswordVisible.value,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Masukan password kamu",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Color(0xFFFFC107), width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
              ),
            ),            const SizedBox(height: 32),

            Obx(
              () => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      text: "Daftar",
                      onPressed: controller.register,
                      containerColor: const Color(0xFFFFC107),
                      contentColor: Colors.black,
                    ),
            ),

            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => Get.toNamed(Routes.login),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(text: "Udah ada akun? "),
                      TextSpan(
                        text: "Masuk",
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
    );
  }
  Widget _buildTextField(
    TextEditingController c,
    String label,
    String hint, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color(0xFFFFC107), width: 2),
          ),
        ),
      ),
    );
  }
}
