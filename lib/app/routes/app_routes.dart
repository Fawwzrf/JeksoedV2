part of 'app_pages.dart';

abstract class Routes {
  // Auth Routes
  static const splash = '/splash';
  static const cta = '/cta';
  static const login = '/login';
  static const roleSelection = '/role-selection';
  static const forgotPassword = '/forgot-password';
  static const tnc = '/tnc';

  // Registration Routes
  static const registerPassenger = '/register-passenger';
  static const registerDriver = '/register-driver';
  static const registerDriverStep1 = '/register-driver-step1';
  static const registerDriverStep2 = '/register-driver-step2';
  static const registerDriverStep3 = '/register-driver-step3';
  // Main App Routes
  static const homePassenger = '/home-passenger';
  static const homeDriver = '/home-driver';
  static const passengerMain = '/passenger-main';

  // Passenger Routes
  static const createOrder = '/create-order';
  static const findingDriver = '/finding-driver';
  static const editProfile = '/edit-profile';

  // Trip Routes
  static const trip = '/trip';
  static const tripCompleted = '/trip-completed';
  static const rating = '/rating';

  // Chat & Activity
  static const chat = '/chat';
  static const activityDetail = '/activity-detail';

  // Driver Routes
  static const allOrders = '/all-orders';
  static const driverMain = '/driver-main';

  // Helper methods for parameterized routes
  static String createFindingDriverRoute(String rideRequestId) =>
      '/finding-driver/$rideRequestId';
  static String createTripRoute(String rideRequestId) => '/trip/$rideRequestId';
  static String createTripCompletedRoute(String rideRequestId) =>
      '/trip-completed/$rideRequestId';
  static String createRatingRoute(String driverId, String rideRequestId) =>
      '/rating/$driverId/$rideRequestId';
  static String createChatRoute(String rideRequestId) => '/chat/$rideRequestId';
  static String createActivityDetailRoute(String rideRequestId) =>
      '/activity-detail/$rideRequestId';
}
