// filepath: lib/app/modules/shared/activity_detail/bindings/activity_detail_binding.dart

import 'package:get/get.dart';
import '../controllers/activity_detail_controller.dart';

class ActivityDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActivityDetailController>(() => ActivityDetailController());
  }
}
