import 'package:get/get.dart';
import '../controllers/register_passenger_controller.dart';

class RegisterPassengerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterPassengerController>(
      () => RegisterPassengerController(),
    );
  }
}
