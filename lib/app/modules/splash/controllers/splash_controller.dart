import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void onReady() {
    super.onReady();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1500)); // Delay logo

    final session = _supabase.auth.currentSession;
    if (session == null) {
      // Belum login
      Get.offNamed(Routes.cta);
    } else {
      // Sudah login, cek role user di database
      try {
        final user = await _supabase
            .from('users')
            .select('role')
            .eq('id', session.user.id)
            .maybeSingle();

        final role = user?['role'];

        if (role == 'driver') {
          Get.offAllNamed(Routes.driverMain);
        } else {
          Get.offAllNamed(Routes.passengerMain);
        }
      } catch (e) {
        // Jika error (misal koneksi), default ke login/cta atau tetap coba masuk
        print("Error checking role: $e");
        Get.offNamed(Routes.cta);
      }
    }
  }
}
