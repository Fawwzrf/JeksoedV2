import 'package:get/get.dart';
import '../controllers/home_passenger_controller.dart';

class HomePassengerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomePassengerController>(() => HomePassengerController());
  }
}
