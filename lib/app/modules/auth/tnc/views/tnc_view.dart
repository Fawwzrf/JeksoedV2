import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tnc_controller.dart';
import '../../../../../utils/app_colors.dart';

class TncView extends GetView<TncController> {
  const TncView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: controller.onBackPressed,
        ),
        title: const Text(
          "Syarat & Ketentuan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Syarat dan Ketentuan Penggunaan",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              "1. Ketentuan Umum",
              "Dengan menggunakan aplikasi Jeksoed, Anda menyetujui untuk terikat dengan syarat dan ketentuan yang berlaku. Aplikasi ini menyediakan layanan transportasi online yang menghubungkan penumpang dengan driver.",
            ),

            _buildSection(
              "2. Penggunaan Layanan",
              "- Anda harus berusia minimal 17 tahun untuk menggunakan layanan ini\n- Anda bertanggung jawab atas keakuratan informasi yang diberikan\n- Dilarang menggunakan layanan untuk kegiatan ilegal\n- Kami berhak menolak atau membatalkan layanan tanpa pemberitahuan sebelumnya",
            ),

            _buildSection(
              "3. Kebijakan Privasi",
              "Kami berkomitmen untuk melindungi privasi Anda. Data pribadi yang dikumpulkan akan digunakan sesuai dengan kebijakan privasi kami dan tidak akan dibagikan kepada pihak ketiga tanpa persetujuan Anda.",
            ),

            _buildSection(
              "4. Pembayaran dan Tarif",
              "- Tarif dihitung berdasarkan jarak dan waktu tempuh\n- Pembayaran dapat dilakukan secara tunai atau non-tunai\n- Tarif dapat berubah sewaktu-waktu tanpa pemberitahuan sebelumnya\n- Biaya tambahan dapat dikenakan untuk kondisi tertentu",
            ),

            _buildSection(
              "5. Tanggung Jawab",
              "Kami tidak bertanggung jawab atas kerugian atau kerusakan yang timbul akibat penggunaan layanan ini. Pengguna menggunakan layanan dengan risiko sendiri.",
            ),

            _buildSection(
              "6. Perubahan Syarat dan Ketentuan",
              "Kami berhak mengubah syarat dan ketentuan ini sewaktu-waktu. Perubahan akan berlaku efektif setelah dipublikasikan dalam aplikasi.",
            ),

            const SizedBox(height: 32),

            Center(
              child: Text(
                "Terakhir diperbarui: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
