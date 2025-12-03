// filepath: lib/app/modules/shared/activity/bindings/activity_binding.dart

import 'package:get/get.dart';
import '../controllers/activity_controller.dart';

class ActivityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActivityController>(() => ActivityController());
  }
}
