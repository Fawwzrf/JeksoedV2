import 'package:get/get.dart';
import '../controllers/finding_driver_controller_new.dart';

class FindingDriverBindingNew extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FindingDriverController>(() => FindingDriverController());
  }
}
