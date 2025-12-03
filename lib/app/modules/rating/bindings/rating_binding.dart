// filepath: lib/app/modules/rating/bindings/rating_binding.dart

import 'package:get/get.dart';
import '../controllers/rating_controller.dart';

class RatingBinding extends Bindings {
  @override
  void dependencies() {
    final driverId = Get.parameters['driverId'] ?? '';
    final rideRequestId = Get.parameters['rideRequestId'] ?? '';

    Get.lazyPut<RatingController>(
      () => RatingController(driverId: driverId, rideRequestId: rideRequestId),
    );
  }
}
