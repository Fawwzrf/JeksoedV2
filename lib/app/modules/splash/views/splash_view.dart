import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 120,
          height: 120,
          child: Image.asset('assets/images/apk_logo_2.jpeg'),
        ),
      ),
    );
  }
}
