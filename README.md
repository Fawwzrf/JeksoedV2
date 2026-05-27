# JeksoedV2

JeksoedV2 adalah aplikasi *ride-hailing* (ojek online) yang dikembangkan menggunakan Flutter. Aplikasi ini mencakup berbagai fitur utama seperti pemesanan perjalanan, manajemen status perjalanan (*trip management*), pelacakan lokasi secara real-time dengan Google Maps, serta manajemen driver dan penumpang.

## 🚀 Tech Stack

- **Framework**: Flutter
- **State Management & Routing**: GetX
- **Backend & Authentication**: Supabase
- **Maps & Location**: Google Maps Flutter, Geolocator, Geocoding
- **Architecture**: MVC (Model-View-Controller) / Modular Pattern via GetX

## 👨‍💻 Peran Anda: Frontend Developer

Sebagai **Frontend Developer** di proyek JeksoedV2, tanggung jawab dan fokus utama Anda meliputi:

1. **Implementasi UI/UX**: Menerjemahkan desain antarmuka menjadi kode Flutter yang responsif dan interaktif (misal: halaman `CreateOrderView`, `DriverMainView`, `TripView`, dsb).
2. **State Management**: Mengelola alur data dan status antarmuka pengguna menggunakan **GetX**. Memastikan transisi antar *stage* (seperti `OrderStage.search`, `pickupConfirm`, `routeConfirm`, `findingDriver`) berjalan mulus dan sinkron dengan UI.
3. **Integrasi Peta & Lokasi**: Mengimplementasikan Google Maps, menampilkan marker dinamis (penumpang dan pengemudi), menggambar rute (*polylines*), dan menyesuaikan tampilan *bottom sheet* (*DraggableScrollableSheet*) di atas peta.
4. **Integrasi Backend (Supabase)**: Menghubungkan fungsi-fungsi frontend dengan layanan Supabase (seperti autentikasi pengguna, membaca/menulis data pesanan, dan mendengarkan perubahan status secara real-time).
5. **Optimasi & Refactoring**: Memastikan kode frontend bersih, modular, dan mematuhi *best practices* di Flutter (mengurangi *dead code*, mengelola komponen *reusable*, dan menyelesaikan peringatan linter).

## 📁 Struktur Proyek (GetX Pattern)

```text
lib/
├── app/
│   ├── data/             # Model data dan Service API (Supabase, Maps API)
│   ├── modules/          # Modul fitur utama aplikasi
│   │   ├── auth/         # Autentikasi (Login, Register)
│   │   ├── chat/         # Fitur obrolan pengemudi & penumpang
│   │   ├── driver/       # Halaman dan fungsi khusus pengemudi
│   │   ├── passenger/    # Halaman utama penumpang & pemesanan (Create Order)
│   │   ├── rating/       # Sistem ulasan setelah perjalanan selesai
│   │   ├── shared/       # Tampilan yang digunakan bersama (Profil, Aktivitas)
│   │   └── trip/         # Manajemen perjalanan saat berlangsung
│   └── routes/           # Definisi rute halaman GetX
├── utils/                # Konstanta (AppColors), helper, formatter
└── main.dart             # Entry point aplikasi
```

## 🛠️ Cara Menjalankan Aplikasi

1. Pastikan Anda telah menginstal [Flutter SDK](https://flutter.dev/docs/get-started/install).
2. Lakukan clone repositori ini.
3. Jalankan perintah untuk mengunduh dependencies:
   ```bash
   flutter pub get
   ```
4. Hubungkan perangkat fisik atau jalankan emulator.
5. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## 🐞 Catatan Analisis Kode

Berdasarkan *Flutter Analyzer*, aplikasi ini sudah berjalan dan berhasil di-*compile* tanpa *error* fatal. Namun, ada beberapa peringatan *technical debt* yang perlu dibereskan di sisi frontend:
- **Penggunaan `print`**: Terdapat banyak pemanggilan `print()` di *controller* yang sebaiknya diganti dengan *logger* atau dihapus di *production*.
- **Dead Code**: Terdapat logika yang tidak pernah dieksekusi di `activity_view.dart`, `trip_passenger_sheet.dart`, dan `trip_completed_controller.dart` akibat *null check* yang berlebihan.
- **Kesalahan Handler Future**: Pada `trip_controller.dart` baris 243, parameter `onError` me-return *void* padahal diharapkan mengembalikan nilai `FutureOr<Null>`.
- **Metode *Deprecated***: Pembaruan fungsi-fungsi lama seperti `withOpacity` (gunakan `withValues`), `color` (gunakan `colorFilter`), dan `fromBytes` di `marker_utils.dart`.
