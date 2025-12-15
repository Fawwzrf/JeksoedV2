import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cta_controller.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../widget/primary_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    final ctrl = Get.find<CtaController>();
    print('CtaView build - controller: $ctrl');

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
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/jeksoed_logo.svg',
                    width: 48,
                    height: 48,
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/images/jeksoed_name.svg',
                    width: 120,
                    height: 30,
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

              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: controller.pageController,
                        onPageChanged: controller.onPageChanged,
                        itemCount: pages.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  pages[index].title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  pages[index].description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pages[index].subDescription,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => GestureDetector(
                            onTap: () {
                              controller.pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: controller.currentPage.value == index
                                  ? 24
                                  : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: controller.currentPage.value == index
                                    ? const Color(0xFF272343)
                                    : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),

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
                                borderRadius: BorderRadius.circular(25),
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
                                color: AppColors.accentDark,
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
            ],
          ),
        ),
      ),
    );
  }
}
