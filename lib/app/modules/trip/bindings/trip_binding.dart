// filepath: lib/app/modules/trip/bindings/trip_binding.dart

import 'package:get/get.dart';
import '../controllers/trip_controller.dart';

class TripBinding extends Bindings {
  @override
  void dependencies() {
    final rideRequestId = Get.parameters['rideRequestId'] ?? '';
    Get.lazyPut<TripController>(
      () => TripController(rideRequestId: rideRequestId),
    );
  }
}
