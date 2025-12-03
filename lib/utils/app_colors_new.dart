import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Purple Theme Colors (from Android XML)
  static const Color purple200 = Color(0xFFBB86FC);
  static const Color purple500 = Color(0xFF6200EE);
  static const Color purple700 = Color(0xFF3700B3);

  // Teal Theme Colors
  static const Color teal200 = Color(0xFF03DAC5);
  static const Color teal700 = Color(0xFF018786);

  // Basic Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Unsoed Brand Colors
  static const Color unsoed = Color(0xFFFFD803); // Unsoed Yellow
  static const Color unsoedDark = Color(0xFFCCAD02); // Darker Yellow
  static const Color unsoedLight = Color(0xFFFFF3B1); // Light Yellow

  // Primary App Colors (using Unsoed colors as primary)
  static const Color primary = unsoed;
  static const Color primaryDark = unsoedDark;
  static const Color primaryLight = unsoedLight;

  // Secondary Colors
  static const Color secondary = teal200;
  static const Color secondaryDark = teal700;
  static const Color secondaryLight = Color(0xFFB2DFDB);

  // Accent Colors
  static const Color accent = purple500;
  static const Color accentLight = purple200;
  static const Color accentDark = purple700;

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = white;
  static const Color cardBackground = white;

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textWhite = white;
  static const Color textBlack = black;
  static const Color textGrey = Color(0xFF9E9E9E);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Driver/Passenger Specific Colors
  static const Color driverOnline = success;
  static const Color driverOffline = Color(0xFF9E9E9E);
  static const Color passengerActive = primary;
  static const Color rideActive = warning;
  static const Color rideCompleted = success;

  // Map Colors
  static const Color mapRoute = primary;
  static const Color mapOrigin = success;
  static const Color mapDestination = error;

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF5F5F5);
  static const Color borderDark = Color(0xFFBDBDBD);

  // Gradient Colors
  static const List<Color> primaryGradient = [primary, primaryDark];

  static const List<Color> unsoedGradient = [unsoed, unsoedDark];

  static const List<Color> successGradient = [success, Color(0xFF388E3C)];

  static const List<Color> warningGradient = [warning, Color(0xFFF57C00)];

  static const List<Color> errorGradient = [error, Color(0xFFD32F2F)];

  static const List<Color> tealGradient = [teal200, teal700];

  static const List<Color> purpleGradient = [purple200, purple500];

  // Legacy colors (kept for backward compatibility)
  static const Color primaryYellow = primary; // JekSoed Yellow
  static const Color lightYellow = primaryLight;
}
