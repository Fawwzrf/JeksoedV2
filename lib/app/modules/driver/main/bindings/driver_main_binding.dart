import 'package:get/get.dart';
import '../controllers/driver_main_controller.dart';
import '../../../shared/activity/controllers/activity_controller.dart';
import '../../../shared/profile/controllers/profile_controller.dart';

class DriverMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverMainController>(() => DriverMainController());
    Get.lazyPut<ActivityController>(() => ActivityController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
