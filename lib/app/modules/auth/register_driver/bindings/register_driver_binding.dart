// filepath: lib/app/modules/auth/register_driver/bindings/register_driver_binding.dart
import 'package:get/get.dart';
import '../controllers/register_driver_controller.dart';

class RegisterDriverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterDriverController>(() => RegisterDriverController());
  }
}
