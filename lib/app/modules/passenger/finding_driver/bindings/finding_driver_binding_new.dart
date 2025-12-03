import 'package:get/get.dart';
import '../controllers/finding_driver_controller.dart';

class FindingDriverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FindingDriverController>(() => FindingDriverController());
  }
}
