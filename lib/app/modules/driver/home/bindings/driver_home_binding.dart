// filepath: lib/app/modules/driver/home/bindings/driver_home_binding.dart

import 'package:get/get.dart';
import '../controllers/driver_home_controller.dart';

class DriverHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverHomeController>(() => DriverHomeController());
  }
}
