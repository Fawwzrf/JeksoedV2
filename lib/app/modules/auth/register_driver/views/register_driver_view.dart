import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io'; // Import dart:io untuk menampilkan preview gambar file
import '../controllers/register_driver_controller.dart';
import '../../../../../utils/app_colors.dart';

class RegisterDriverView extends GetView<RegisterDriverController> {
  const RegisterDriverView({super.key});  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (controller.currentStep.value > 0) {
              controller.previousStep();
            } else {
              Get.back();
            }
          },
        ),
      ),
      body: Obx(() {
        switch (controller.currentStep.value) {
          case 0:
            return _buildStep1();
          case 1:
            return _buildStep2();
          case 2:
            return _buildStep3();
          default:
            return _buildStep1();
        }
      }),
    );
  }
  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: controller.formKeyStep1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressIndicator(),
            const SizedBox(height: 32),
            const Text(
              'Identitas Driver',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lengkapi data pribadi Anda',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                  Center(
                    child: GestureDetector(
                      onTap: controller.pickProfileImage,
                      child: Obx(
                        () => Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.lightBackground,
                            border: Border.all(color: AppColors.primary),
                            image: controller.profileImagePath.value.isNotEmpty
                                ? DecorationImage(
                                    image: FileImage(
                                      File(controller.profileImagePath.value),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: controller.profileImagePath.value.isEmpty
                              ? Icon(
                                  Icons.camera_alt,
                                  color: AppColors.primary,
                                  size: 40,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: controller.nameController,
                    label: 'Nama Lengkap',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama lengkap harus diisi';
                      }
                      if (value.length < 3) {
                        return 'Nama minimal 3 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: controller.nimController,
                    label: 'NIM',
                    icon: Icons.badge,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'NIM harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: controller.emailController,
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email harus diisi';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: controller.phoneController,
                    label: 'Nomor Telepon',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nomor telepon harus diisi';
                      }
                      if (value.length < 10) {
                        return 'Nomor telepon minimal 10 digit';
                      }
                      return null;
                    },
                  ),const SizedBox(height: 16),
                  Obx(
                    () => _buildTextField(
                      controller: controller.passwordController,
                      label: 'Password',
                      icon: Icons.lock,
                      obscureText: !controller.isPasswordVisible.value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password harus diisi';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => _buildTextField(
                      controller: controller.confirmPasswordController,
                      label: 'Konfirmasi Password',
                      icon: Icons.lock_outline,
                      obscureText: !controller.isConfirmPasswordVisible.value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi password harus diisi';
                        }
                        if (value != controller.passwordController.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isConfirmPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                    ),
                  ),                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildNextButton(() => controller.submitStep1()),
        ],
      ),
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(),
          const SizedBox(height: 32),
          const Text(
            'Dokumen Kendaraan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload dokumen kendaraan yang diperlukan',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(
                    controller: controller.driverLicenseController,
                    label: 'Nomor SIM',
                    icon: Icons.credit_card,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: controller.vehiclePlateController,
                    label: 'Nomor Plat Kendaraan',
                    icon: Icons.directions_car,
                  ),
                  const SizedBox(height: 32),

                  // UPDATE: Document Upload Cards yang interaktif
                  Obx(
                    () => _buildDocumentCard(
                      'Foto SIM',
                      'Upload foto SIM yang masih berlaku',
                      Icons.card_membership,
                      controller.simPath.value,
                      () => controller.pickDocumentImage('sim'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => _buildDocumentCard(
                      'Foto STNK',
                      'Upload foto STNK kendaraan',
                      Icons.description,
                      controller.stnkPath.value,
                      () => controller.pickDocumentImage('stnk'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => _buildDocumentCard(
                      'Foto Kendaraan',
                      'Upload foto kendaraan tampak depan',
                      Icons.motorcycle,
                      controller.vehiclePath.value,
                      () => controller.pickDocumentImage('vehicle'),
                    ),
                  ),
                ],
              ),
            ),
          ),          const SizedBox(height: 24),
          _buildNextButton(() => controller.submitStep2()),
        ],
      ),
    );
  }

  // --- STEP 3: VERIFIKASI ---
  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(),
          const SizedBox(height: 32),
          const Text(
            'Verifikasi & Persetujuan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Setujui syarat dan ketentuan untuk menjadi driver',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Syarat & Ketentuan Driver JekSoed',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '1. Driver wajib memiliki SIM yang masih berlaku\n'
                          '2. Kendaraan harus dalam kondisi baik dan terawat\n'
                          '3. Driver berkomitmen memberikan pelayanan terbaik\n'
                          '4. Mengikuti semua aturan dan protokol keselamatan\n',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => CheckboxListTile(
                      value: controller.agreementAccepted.value,
                      onChanged: (value) {
                        controller.agreementAccepted.value = value ?? false;
                      },
                      title: const Text(
                        'Saya menyetujui semua syarat dan ketentuan di atas',
                        style: TextStyle(fontSize: 14),
                      ),
                      activeColor: AppColors.primary,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ],
              ),
            ),
          ),          const SizedBox(height: 24),
          Obx(() => _buildSubmitButton()),
        ],
      ),
    );
  }

  // --- WIDGETS PENDUKUNG ---

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          children: [
            for (int i = 0; i < 3; i++)
              Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: i <= controller.currentStep.value
                        ? AppColors.primary
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  // UPDATE: Widget DocumentCard sekarang support onTap dan menampilkan status terpilih
  Widget _buildDocumentCard(
    String title,
    String subtitle,
    IconData icon,
    String selectedPath,
    VoidCallback onTap,
  ) {
    final isSelected = selectedPath.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.success : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.success.withOpacity(0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSelected ? Icons.check : icon,
                color: isSelected ? AppColors.success : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSelected ? "$title (Tersimpan)" : title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.success
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSelected ? "Ketuk untuk mengubah foto" : subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.upload_file,
              color: isSelected ? AppColors.success : AppColors.textSecondary,
              size: 24,
            ),          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: const Text(
          'Lanjut',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading.value
            ? null
            : () => controller.submitStep3(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: controller.isLoading.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : const Text(
                'Daftar Sebagai Driver',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
