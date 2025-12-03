class AppImages {
  AppImages._();

  // Base path for assets
  static const String _basePath = 'assets/images/';
  static const String _iconPath = 'assets/icons/';

  // App Logo & Branding
  static const String appLogo = '${_basePath}app_logo.png';
  static const String appLogoWhite = '${_basePath}app_logo_white.png';
  static const String splashLogo = '${_basePath}splash_logo.png';

  // Icons
  static const String carIcon = '${_iconPath}car_icon.png';
  static const String motorcycleIcon = '${_iconPath}motorcycle_icon.png';
  static const String userIcon = '${_iconPath}user_icon.png';
  static const String driverIcon = '${_iconPath}driver_icon.png';
  static const String passengerIcon = '${_iconPath}passenger_icon.png';

  // Map Related
  static const String mapMarker = '${_iconPath}map_marker.png';
  static const String locationPin = '${_iconPath}location_pin.png';
  static const String destinationMarker = '${_iconPath}destination_marker.png';
  static const String originMarker = '${_iconPath}origin_marker.png';
  static const String driverMarker = '${_iconPath}driver_marker.png';

  // Vehicle Icons
  static const String sedanCar = '${_iconPath}sedan_car.png';
  static const String suvCar = '${_iconPath}suv_car.png';
  static const String hatchbackCar = '${_iconPath}hatchback_car.png';
  static const String motorcycle = '${_iconPath}motorcycle.png';

  // Status Icons
  static const String onlineStatus = '${_iconPath}online_status.png';
  static const String offlineStatus = '${_iconPath}offline_status.png';
  static const String busyStatus = '${_iconPath}busy_status.png';

  // Payment Icons
  static const String cashIcon = '${_iconPath}cash_icon.png';
  static const String creditCardIcon = '${_iconPath}credit_card_icon.png';
  static const String digitalWalletIcon = '${_iconPath}digital_wallet_icon.png';

  // Rating & Review
  static const String starFilled = '${_iconPath}star_filled.png';
  static const String starEmpty = '${_iconPath}star_empty.png';
  static const String starHalf = '${_iconPath}star_half.png';

  // Navigation Icons
  static const String homeIcon = '${_iconPath}home_icon.png';
  static const String historyIcon = '${_iconPath}history_icon.png';
  static const String profileIcon = '${_iconPath}profile_icon.png';
  static const String settingsIcon = '${_iconPath}settings_icon.png';
  static const String helpIcon = '${_iconPath}help_icon.png';

  // Background Images
  static const String loginBackground = '${_basePath}login_background.png';
  static const String registerBackground =
      '${_basePath}register_background.png';
  static const String splashBackground = '${_basePath}splash_background.png';

  // Empty States
  static const String noRideHistory = '${_basePath}no_ride_history.png';
  static const String noNotifications = '${_basePath}no_notifications.png';
  static const String noInternet = '${_basePath}no_internet.png';
  static const String errorState = '${_basePath}error_state.png';

  // Promotional Images
  static const String welcomeBanner = '${_basePath}welcome_banner.png';
  static const String promotionalBanner = '${_basePath}promotional_banner.png';
  static const String driverPromo = '${_basePath}driver_promo.png';
  static const String passengerPromo = '${_basePath}passenger_promo.png';

  // Utility method to check if image exists
  static bool imageExists(String imagePath) {
    // This would typically check if the asset exists
    // For now, return true as placeholder
    return true;
  }

  // Get default image if specified image doesn't exist
  static String getImageOrDefault(String imagePath, String defaultImage) {
    return imageExists(imagePath) ? imagePath : defaultImage;
  }
}
