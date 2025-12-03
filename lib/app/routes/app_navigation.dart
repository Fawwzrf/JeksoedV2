import 'package:get/get.dart';

class AppNavigation {
  // Navigation methods that mirror the Android Compose navigation

  // Auth Navigation
  static void goToSplash() {
    Get.offAllNamed('/splash');
  }

  static void goToCta() {
    Get.toNamed('/cta');
  }

  static void goToLogin() {
    Get.toNamed('/login');
  }

  static void goToRoleSelection() {
    Get.toNamed('/role-selection');
  }

  static void goToForgotPassword() {
    Get.toNamed('/forgot-password');
  }

  static void goToTnc() {
    Get.toNamed('/tnc');
  }

  // Registration Navigation
  static void goToRegisterPassenger() {
    Get.toNamed('/register-passenger');
  }

  static void goToRegisterDriverStep1() {
    Get.toNamed('/register-driver-step1');
  }

  static void goToRegisterDriverStep2() {
    Get.toNamed('/register-driver-step2');
  }

  static void goToRegisterDriverStep3() {
    Get.toNamed('/register-driver-step3');
  }

  // Main App Navigation
  static void goToPassengerMain() {
    Get.offAllNamed('/home-passenger');
  }

  static void goToDriverMain() {
    Get.offAllNamed('/home-driver');
  }

  // Passenger Navigation
  static void goToCreateOrder() {
    Get.toNamed('/create-order');
  }

  static void goToEditProfile() {
    Get.toNamed('/edit-profile');
  }

  // Trip Navigation with parameters
  static void goToFindingDriver(String rideRequestId) {
    Get.toNamed('/finding-driver/$rideRequestId');
  }

  static void goToTrip(String rideRequestId) {
    Get.toNamed('/trip/$rideRequestId');
  }

  static void goToTripCompleted(String rideRequestId) {
    Get.toNamed('/trip-completed/$rideRequestId');
  }

  static void goToRating(String driverId, String rideRequestId) {
    Get.toNamed('/rating/$driverId/$rideRequestId');
  }

  // Chat & Activity Navigation
  static void goToChat(String rideRequestId) {
    Get.toNamed('/chat/$rideRequestId');
  }

  static void goToActivityDetail(String rideRequestId) {
    Get.toNamed('/activity-detail/$rideRequestId');
  }

  // Driver Navigation
  static void goToAllOrders() {
    Get.toNamed('/all-orders');
  }

  // Navigation with transitions (similar to Android's slide animations)
  static void goToCreateOrderWithSlideTransition() {
    Get.toNamed('/create-order');
  }

  // Pop/Back navigation
  static void goBack() {
    Get.back();
  }

  static void popUntil(String routeName) {
    Get.until((route) => route.settings.name == routeName);
  }

  // Replace navigation (equivalent to popUpTo in Android)
  static void replaceWith(String routeName) {
    Get.offNamed(routeName);
  }

  static void replaceAllWith(String routeName) {
    Get.offAllNamed(routeName);
  }

  // Helper method to extract parameters from current route
  static Map<String, String?> getCurrentParameters() {
    return Get.parameters;
  }

  // Helper method to get specific parameter
  static String? getParameter(String key) {
    return Get.parameters[key];
  }

  // Helper method for conditional navigation (like in the original Android code)
  static void navigateBasedOnAuthState({
    required bool isAuthenticated,
    required String? userRole,
  }) {
    if (!isAuthenticated) {
      goToLogin();
      return;
    }

    if (userRole == 'passenger') {
      goToPassengerMain();
    } else if (userRole == 'driver') {
      goToDriverMain();
    } else {
      goToLogin();
    }
  }
}
