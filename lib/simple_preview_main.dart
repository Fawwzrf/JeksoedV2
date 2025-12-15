import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/controllers/preview_controller.dart';
import 'utils/app_colors.dart';

// Simple routes for preview
class PreviewRoutes {
  static const splash = '/';
  static const cta = '/cta';
  static const login = '/login';
  static const registerPassenger = '/register-passenger';
  static const registerDriver = '/register-driver';
  static const passengerMain = '/passenger-main';
  static const driverMain = '/driver-main';
}

void main() {
  // Initialize preview controller
  Get.put(PreviewNavigationController());

  runApp(JekSoedPreviewApp());
}

class JekSoedPreviewApp extends StatelessWidget {
  const JekSoedPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'JekSoed Preview',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: PreviewRoutes.splash,
      getPages: [
        GetPage(name: PreviewRoutes.splash, page: () => PreviewSplashView()),
        GetPage(name: PreviewRoutes.cta, page: () => PreviewCtaView()),
        GetPage(name: PreviewRoutes.login, page: () => PreviewLoginView()),
        GetPage(
          name: PreviewRoutes.registerPassenger,
          page: () => PreviewRegisterPassengerView(),
        ),
        GetPage(
          name: PreviewRoutes.registerDriver,
          page: () => PreviewRegisterDriverView(),
        ),
        GetPage(
          name: PreviewRoutes.passengerMain,
          page: () => PreviewPassengerMainView(),
        ),
        GetPage(
          name: PreviewRoutes.driverMain,
          page: () => PreviewDriverMainView(),
        ),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}

class PreviewSplashView extends StatelessWidget {
  const PreviewSplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Auto navigate after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Get.offNamed(PreviewRoutes.cta);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.directions_car, size: 60, color: Colors.white),
            ),
            SizedBox(height: 24),
            Text(
              'JekSoed',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Preview Mode',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class PreviewCtaView extends StatelessWidget {
  const PreviewCtaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 2),

              // Logo
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.directions_car,
                  size: 80,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 32),

              // Title
              Text(
                'Masuk dulu yuk!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16),

              Text(
                'Nikmati kemudahan transportasi di kampus dengan JekSoed',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              Spacer(flex: 3),

              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(PreviewRoutes.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.toNamed(PreviewRoutes.registerPassenger),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary, width: 2),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Belum ada akun? Gas bikin!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class PreviewLoginView extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final previewController = Get.find<PreviewNavigationController>();

  PreviewLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32),

            Text(
              'Selamat datang kembali!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 8),

            Text(
              'Masuk untuk melanjutkan',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),

            SizedBox(height: 32),

            // Email field
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'passenger@jeksoed.com atau driver@jeksoed.com',
              ),
            ),

            SizedBox(height: 16),

            // Password field
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Ketik apa saja',
              ),
            ),

            SizedBox(height: 24),

            // Info text
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Preview mode: Gunakan passenger@jeksoed.com atau driver@jeksoed.com',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Login button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  String email = emailController.text.toLowerCase();
                  if (email.contains('passenger')) {
                    Get.offAllNamed(PreviewRoutes.passengerMain);
                  } else if (email.contains('driver')) {
                    Get.offAllNamed(PreviewRoutes.driverMain);
                  } else {
                    Get.snackbar(
                      'Info',
                      'Gunakan email test: passenger@jeksoed.com atau driver@jeksoed.com',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Register link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Belum punya akun? '),
                TextButton(
                  onPressed: () => Get.toNamed(PreviewRoutes.registerPassenger),
                  child: Text(
                    'Daftar di sini',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            Spacer(),
          ],
        ),
      ),
    );
  }
}

class PreviewRegisterPassengerView extends StatelessWidget {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  PreviewRegisterPassengerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Daftar Penumpang'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32),

            Text(
              'Daftar sebagai Penumpang',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 32),

            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 16),

            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      emailController.text.isNotEmpty) {
                    Get.snackbar(
                      'Success',
                      'Registrasi berhasil! Selamat datang ${nameController.text}',
                    );
                    Get.offAllNamed(PreviewRoutes.passengerMain);
                  } else {
                    Get.snackbar('Error', 'Mohon isi semua field');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Daftar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            SizedBox(height: 16),

            Center(
              child: TextButton(
                onPressed: () => Get.toNamed(PreviewRoutes.registerDriver),
                child: Text(
                  'Atau daftar sebagai Driver',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PreviewRegisterDriverView extends StatelessWidget {
  const PreviewRegisterDriverView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Daftar Driver'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(height: 32),

            Icon(Icons.local_taxi, size: 80, color: AppColors.primary),

            SizedBox(height: 24),

            Text(
              'Daftar Driver - Coming Soon',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16),

            Text(
              'Fitur registrasi driver dalam tahap pengembangan',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32),

            ElevatedButton(
              onPressed: () => Get.offAllNamed(PreviewRoutes.driverMain),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text('Preview Driver Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class PreviewPassengerMainView extends StatelessWidget {
  const PreviewPassengerMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Dashboard Penumpang'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 100, color: AppColors.primary),
            SizedBox(height: 24),
            Text(
              'Dashboard Penumpang',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Implementasi lengkap tersedia di main app',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(PreviewRoutes.cta),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class PreviewDriverMainView extends StatelessWidget {
  const PreviewDriverMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Dashboard Driver'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_taxi, size: 100, color: AppColors.primary),
            SizedBox(height: 24),
            Text(
              'Dashboard Driver',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Implementasi lengkap tersedia di main app',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(PreviewRoutes.cta),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
