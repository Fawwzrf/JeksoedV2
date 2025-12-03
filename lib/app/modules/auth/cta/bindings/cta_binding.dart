import 'package:get/get.dart';
import '../controllers/cta_controller.dart';

class CtaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CtaController>(() => CtaController());
  }
}
