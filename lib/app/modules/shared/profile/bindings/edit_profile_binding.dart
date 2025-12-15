import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../views/edit_profile_view.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfileController>(() => EditProfileController());
  }
}
