import 'package:get/get.dart';
import '../controllers/register_passenger_controller.dart';
import '../../../shared/activity/controllers/activity_controller.dart';
import '../../../shared/profile/controllers/profile_controller.dart';
import '../../../home_passenger/controllers/home_passenger_controller.dart';

class RegisterPassengerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterPassengerController>(
      () => RegisterPassengerController(),
    );
    Get.lazyPut<HomePassengerController>(() => HomePassengerController());
    Get.lazyPut<ActivityController>(() => ActivityController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
