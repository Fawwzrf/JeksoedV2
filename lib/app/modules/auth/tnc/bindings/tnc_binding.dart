import 'package:get/get.dart';
import '../controllers/tnc_controller.dart';

class TncBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TncController>(() => TncController());
  }
}
