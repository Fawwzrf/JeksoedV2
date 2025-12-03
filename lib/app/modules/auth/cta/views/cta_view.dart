import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cta_controller.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../widget/primary_button.dart';

// Data untuk setiap halaman di PageView
class CtaPage {
  final String title;
  final String description;
  final String subDescription;

  CtaPage({
    required this.title,
    required this.description,
    required this.subDescription,
  });
}

class CtaView extends GetView<CtaController> {
  const CtaView({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      CtaPage(
        title: "Selamat datang di JEKSOED!",
        description: "Ojek andalan anak Unsoed!",
        subDescription: "Siap anterin kamu ke sekitar Unsoed kapanpun.",
      ),
      CtaPage(
        title: "Mau kemana hari ini?",
        description: "Mau berpergian, tapi ragu keamanan?",
        subDescription: "Dengan JEKSOED dijamin aman! Ayo cobain.",
      ),
      CtaPage(
        title: "Cari freelance?",
        description: "Ga cuma jadi penumpang",
        subDescription: "kalian, mahasiswa, bisa banget gabung jadi driver.",
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Logo and App Name
              Row(
                children: [
                  Image.asset(
                    'assets/images/apk_logo_2.jpeg',
                    width: 48,
                    height: 48,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'JEKSOED',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Illustration
              Image.asset(
                'assets/images/home_bg.png',
                width: double.infinity,
                height: 250,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 32),

              // PageView Content
              Expanded(
                child: Obx(
                  () => Column(
                    children: [
                      // Content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Text(
                              pages[controller.currentPage.value].title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              pages[controller.currentPage.value].description,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pages[controller.currentPage.value]
                                  .subDescription,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Page Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: controller.currentPage.value == index
                                  ? const Color(0xFF272343)
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Buttons
                      Column(
                        children: [
                          PrimaryButton(
                            text: "Masuk dulu, yuk!",
                            onPressed: controller.goToLogin,
                            containerColor: const Color(0xFFFFC107),
                            contentColor: Colors.black,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: controller.goToRoleSelection,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFFFC107),
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Belum ada akun? Gas bikin!",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Terms and Conditions
                      GestureDetector(
                        onTap: controller.goToTerms,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    "Masuk atau daftar artinya kamu udah oke dan setuju sama ",
                              ),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
