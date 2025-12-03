// filepath: lib/app/modules/chat/bindings/chat_binding.dart

import 'package:get/get.dart';
import '../controllers/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    final rideRequestId = Get.parameters['rideRequestId'] ?? '';

    Get.lazyPut<ChatController>(
      () => ChatController(rideRequestId: rideRequestId),
    );
  }
}
