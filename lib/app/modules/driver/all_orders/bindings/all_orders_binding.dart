// filepath: lib/app/modules/driver/all_orders/bindings/all_orders_binding.dart

import 'package:get/get.dart';
import '../controllers/all_orders_controller.dart';

class AllOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllOrdersController>(() => AllOrdersController());
  }
}
