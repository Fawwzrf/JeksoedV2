# JeksoedV2

JeksoedV2 adalah aplikasi ride-hailing (ojek online) komprehensif yang dibangun menggunakan Flutter, GetX, dan Supabase untuk manajemen pesanan serta pelacakan lokasi real-time dengan Google Maps.

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![GetX](https://img.shields.io/badge/State_Management-GetX-purple)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ecf8e?logo=supabase)
![Google Maps](https://img.shields.io/badge/Google_Maps-Integration-4285F4?logo=google-maps)

</div>

---

## Tentang Proyek

**JeksoedV2** adalah sistem *ride-hailing* lengkap yang memfasilitasi pengguna (penumpang) dan penyedia layanan (pengemudi) untuk terhubung secara real-time. Aplikasi ini berfokus pada manajemen perjalanan (*trip management*), integrasi database *real-time*, dan visualisasi *geolocation* presisi untuk menghadirkan pengalaman layaknya aplikasi ojek online profesional.

## Fitur Utama

- **Real-Time Ride Tracking**: Memantau lokasi pengemudi dan rute perjalanan secara langsung di atas peta interaktif menggunakan **Google Maps**.
- **Responsive UI/UX**: Alur pesanan interaktif dengan *Draggable scrollable sheets* yang secara mulus memperbarui antarmuka berdasarkan tahapan pesanan pengguna (Mencari Pengemudi, Menunggu Jemputan, Perjalanan).
- **Backend & Auth Terpusat**: Autentikasi yang aman dan penyimpanan sinkronisasi data yang didukung penuh oleh **Supabase Realtime**.
- **Sistem Multi-Role**: Ekosistem dua sisi aplikasi yang efisien, menavigasikan penumpang dan pengemudi dalam satu *codebase* dengan pemisahan peran yang aman.

---



## Struktur Arsitektur (GetX Pattern)

Kode *frontend* disusun menggunakan arsitektur fitur-modular, mengelompokkan komponen ke dalam domain bisnis mereka masing-masing:

```text
lib/
├── app/
│   ├── data/             # Definisi Model Data & Service Layer (Supabase, Maps API)
│   ├── modules/          # Core Features (Diisolasi secara modular)
│   │   ├── auth/         # Modul Registrasi & Login
│   │   ├── chat/         # Obrolan In-App (Pengemudi-Penumpang)
│   │   ├── driver/       # Tampilan Khusus Penerimaan Order Pengemudi
│   │   ├── passenger/    # Tampilan Pemesanan Penumpang (Create Order)
│   │   ├── trip/         # Visualisasi Perjalanan Real-time
│   │   └── shared/       # Tampilan Bersama (Profil, Aktivitas)
│   └── routes/           # Registrasi Sistem Rute GetX
├── utils/                # Konstanta (AppColors), Konfigurasi Maps, Formatters
└── main.dart             # Entry point & Inisialisasi Tema Aplikasi
```

## Cara Menjalankan Aplikasi

### Prasyarat Instalasi
- [Flutter SDK](https://flutter.dev/docs/get-started/install) versi 3.x
- Akun dan Proyek [Supabase](https://supabase.com)
- Google Cloud Console API Key (untuk aktivasi Google Maps & Routes)

### Langkah Eksekusi

1. **Clone Repositori**:
   ```bash
   git clone https://github.com/Fawwzrf/JeksoedV2.git
   cd jeksoedv2
   ```

2. **Instal Dependensi**:
   ```bash
   flutter pub get
   ```

3. **Jalankan Aplikasi (Debug)**:
   ```bash
   flutter run
   ```

---

<div align="center">
  Dibuat dengan ❤️ menggunakan Flutter & Supabase
</div>
