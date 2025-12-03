import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_passenger_controller.dart';
import '../../../../routes/app_pages.dart';

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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Daftar dulu, Kak!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            ),

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
            ),

            const SizedBox(height: 32),

            Obx(
              () => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        onPressed: controller.register,
                        child: const Text(
                          "Daftar",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Get.toNamed(Routes.login),
                child: const Text("Udah ada akun? Masuk"),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
        ),
      ),
    );
  }
}
