import 'package:get/get.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/auth/cta/bindings/cta_binding.dart';
import '../modules/auth/cta/views/cta_view.dart';
import '../modules/auth/role_selection/bindings/role_selection_binding.dart';
import '../modules/auth/role_selection/views/role_selection_view.dart';
import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/auth/register_passenger/bindings/register_passenger_binding.dart';
import '../modules/auth/register_passenger/views/register_passenger_view.dart';
import '../modules/auth/register_driver/bindings/register_driver_binding.dart';
import '../modules/auth/register_driver/views/register_driver_view.dart';
import '../modules/auth/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/auth/forgot_password/views/forgot_password_view.dart';
import '../modules/auth/tnc/bindings/tnc_binding.dart';
import '../modules/auth/tnc/views/tnc_view.dart';
import '../modules/home_passenger/bindings/home_passenger_binding.dart';
import '../modules/home_passenger/views/home_passenger_view.dart';
import '../modules/home_driver/bindings/home_driver_binding.dart';
import '../modules/home_driver/views/home_driver_view.dart';
import '../modules/passenger/create_order/bindings/create_order_binding.dart';
import '../modules/passenger/create_order/views/create_order_view.dart';
import '../modules/passenger/main/bindings/passenger_main_binding.dart';
import '../modules/passenger/main/views/passenger_main_view.dart';
import '../modules/passenger/finding_driver/bindings/finding_driver_binding.dart';
import '../modules/passenger/finding_driver/views/finding_driver_view.dart';
import '../modules/driver/main/bindings/driver_main_binding.dart';
import '../modules/driver/main/views/driver_main_view.dart';
import '../modules/driver/all_orders/bindings/all_orders_binding.dart';
import '../modules/driver/all_orders/views/all_orders_view.dart';
import '../modules/shared/activity_detail/bindings/activity_detail_binding.dart';
import '../modules/shared/activity_detail/views/activity_detail_view.dart';
import '../modules/trip/bindings/trip_binding.dart';
import '../modules/trip/views/trip_view.dart';
import '../modules/trip/bindings/trip_completed_binding.dart';
import '../modules/trip/views/trip_completed_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/rating/bindings/rating_binding.dart';
import '../modules/rating/views/rating_view.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;
  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.cta,
      page: () => const CtaView(),
      binding: CtaBinding(),
    ),
    GetPage(
      name: Routes.roleSelection,
      page: () => const RoleSelectionView(),
      binding: RoleSelectionBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.tnc,
      page: () => const TncView(),
      binding: TncBinding(),
    ),
    GetPage(
      name: Routes.registerPassenger,
      page: () => const RegisterPassengerView(),
      binding: RegisterPassengerBinding(),
    ),
    GetPage(
      name: Routes.registerDriverStep1,
      page: () => const RegisterDriverView(),
      binding: RegisterDriverBinding(),
    ),
    GetPage(
      name: Routes.homePassenger,
      page: () => const HomePassengerView(),
      binding: HomePassengerBinding(),
    ),
    GetPage(
      name: Routes.passengerMain,
      page: () => const PassengerMainView(),
      binding: PassengerMainBinding(),
    ),
    GetPage(
      name: Routes.homeDriver,
      page: () => const HomeDriverView(),
      binding: HomeDriverBinding(),
    ),
    GetPage(
      name: Routes.createOrder,
      page: () => const CreateOrderView(),
      binding: CreateOrderBinding(),
    ),
    GetPage(
      name: Routes.findingDriver,
      page: () => const FindingDriverView(),
      binding: FindingDriverBinding(),
    ),
    GetPage(
      name: '/finding-driver/:rideRequestId',
      page: () => const FindingDriverView(),
      binding: FindingDriverBinding(),
    ),
    // Driver Routes
    GetPage(
      name: Routes.driverMain,
      page: () => const DriverMainView(),
      binding: DriverMainBinding(),
    ),
    GetPage(
      name: Routes.allOrders,
      page: () => const AllOrdersView(),
      binding: AllOrdersBinding(),
    ),
    GetPage(
      name: '/activity-detail/:rideRequestId',
      page: () => const ActivityDetailView(),
      binding: ActivityDetailBinding(),
    ),
    GetPage(
      name: '/trip/:rideRequestId',
      page: () => const TripView(),
      binding: TripBinding(),
    ),
    GetPage(
      name: '/trip-completed/:rideRequestId',
      page: () => const TripCompletedView(),
      binding: TripCompletedBinding(),
    ),
    GetPage(
      name: '/chat/:rideRequestId',
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: '/rating/:driverId/:rideRequestId',
      page: () => const RatingView(),
      binding: RatingBinding(),
    ),
  ];
}
