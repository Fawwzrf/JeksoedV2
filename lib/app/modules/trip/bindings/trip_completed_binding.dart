// filepath: lib/app/modules/trip/bindings/trip_completed_binding.dart

import 'package:get/get.dart';
import '../controllers/trip_completed_controller.dart';

class TripCompletedBinding extends Bindings {
  @override
  void dependencies() {
    final rideRequestId = Get.parameters['rideRequestId'] ?? '';
    Get.lazyPut<TripCompletedController>(
      () => TripCompletedController(rideRequestId: rideRequestId),
    );
  }
}
