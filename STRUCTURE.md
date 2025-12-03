# JeksoedV2 - Flutter Ride Sharing App

Aplikasi ride sharing yang dibangun dengan Flutter menggunakan arsitektur MVC dan GetX untuk state management.

## Struktur Folder

```
lib/
├── main.dart                      // Entry Point
├── app/
│   ├── data/                      // Layer Data
│   │   ├── models/                // Model (User, RideRequest)
│   │   │   ├── user.dart
│   │   │   └── ride_request.dart
│   │   └── services/              // Service (Firebase, API)
│   │       ├── auth_service.dart
│   │       └── ride_service.dart
│   │
│   ├── modules/                   // Layer MVC per Halaman
│   │   ├── splash/
│   │   │   ├── bindings/          // Dependency Injection Splash
│   │   │   │   └── splash_binding.dart
│   │   │   ├── controllers/       // Logika Splash
│   │   │   │   └── splash_controller.dart
│   │   │   └── views/             // UI Splash
│   │   │       └── splash_view.dart
│   │   ├── auth/
│   │   │   └── register_passenger/
│   │   │       ├── bindings/
│   │   │       │   └── register_passenger_binding.dart
│   │   │       ├── controllers/
│   │   │       │   └── register_passenger_controller.dart
│   │   │       └── views/
│   │   │           └── register_passenger_view.dart
│   │   ├── home_passenger/
│   │   │   ├── bindings/
│   │   │   │   └── home_passenger_binding.dart
│   │   │   ├── controllers/
│   │   │   │   └── home_passenger_controller.dart
│   │   │   └── views/
│   │   │       └── home_passenger_view.dart
│   │   └── home_driver/
│   │       ├── bindings/
│   │       │   └── home_driver_binding.dart
│   │       ├── controllers/
│   │       │   └── home_driver_controller.dart
│   │       └── views/
│   │           └── home_driver_view.dart
│   │
│   └── routes/                    // Navigasi
│       ├── app_pages.dart
│       └── app_routes.dart
└── utils/                         // Aset & Konstanta Warna
    ├── app_colors.dart
    └── app_images.dart
```

## Fitur yang Sudah Dibuat

### 1. **Splash Screen**
- Loading animation
- Auto navigation ke halaman berikutnya
- Clean UI dengan logo aplikasi

### 2. **Authentication Module**
- Register Passenger dengan validasi form
- UI yang user-friendly
- Integrasi dengan AuthService

### 3. **Home Passenger**
- Bottom navigation dengan 3 tab (Home, History, Profile)
- Quick actions untuk booking ride
- Map placeholder
- Profile management

### 4. **Home Driver**
- Bottom navigation dengan 4 tab (Home, Earnings, History, Profile)
- Online/Offline status toggle
- Earnings overview
- Driver-specific features

### 5. **Services**
- **AuthService**: Login, register, logout, profile management
- **RideService**: Request ride, accept ride, ride status management

### 6. **Models**
- **User**: Model untuk data pengguna (passenger/driver)
- **RideRequest**: Model untuk data perjalanan
- **LocationData**: Model untuk data lokasi
- **RideRating**: Model untuk rating perjalanan

### 7. **Utils**
- **AppColors**: Konstanta warna aplikasi dengan tema yang konsisten
- **AppImages**: Konstanta path untuk asset gambar dan icon

## Teknologi yang Digunakan

- **Flutter**: Framework utama
- **GetX**: State management, navigation, dependency injection
- **Firebase**: Authentication, database (sudah disiapkan)
- **Material Design 3**: UI components

## Cara Menjalankan

1. Pastikan Flutter sudah terinstall
2. Clone repository ini
3. Jalankan `flutter pub get` untuk install dependencies
4. Jalankan `flutter run` untuk menjalankan aplikasi

## Status Implementasi (December 3, 2025)

### ✅ Selesai Dikerjakan:

#### 1. **Struktur Folder Lengkap**
- ✅ Entry point: `lib/main.dart`
- ✅ Data layer: `lib/app/data/` (models, services)
- ✅ Module layer: `lib/app/modules/` dengan struktur MVC
- ✅ Routes: `lib/app/routes/` (navigation system)
- ✅ Utils: `lib/utils/` (colors, images, constants, text styles)
- ✅ Assets: `assets/` (images, icons directories)

#### 2. **Models & Data Layer**
- ✅ `User` model dengan enum UserType (passenger/driver)
- ✅ `RideRequest` model dengan semua fields dan status
- ✅ `LocationData` model untuk koordinat dan alamat
- ✅ `RideRating` model untuk rating sistem
- ✅ `AuthService` untuk authentication management
- ✅ `RideService` untuk ride management
- ✅ Enums untuk RideStatus, RideType, PaymentMethod

#### 3. **Modules (MVC Architecture)**

**Splash Module:**
- ✅ `SplashController` dengan auto navigation
- ✅ `SplashView` dengan loading animation
- ✅ `SplashBinding` untuk dependency injection
- ✅ Integration dengan Firebase Auth check

**Auth Modules:**
- ✅ **Login Module**: Controller, View, Binding dengan Firebase Auth
- ✅ **Register Passenger Module**: Form validation, Firebase integration

**Home Modules:**
- ✅ **Home Passenger**: Bottom nav (Home, History, Profile), ride booking UI
- ✅ **Home Driver**: Bottom nav (Home, Earnings, History, Profile), online/offline status

#### 4. **Navigation & Routes**
- ✅ GetX routing system dengan `app_pages.dart` dan `app_routes.dart`
- ✅ Route definitions untuk semua modules
- ✅ Binding integration untuk dependency injection

#### 5. **UI & Theming**
- ✅ `AppColors`: Color constants dengan tema yang konsisten
- ✅ `AppImages`: Image asset path management
- ✅ `AppConstants`: App-wide constants dan helper methods
- ✅ `AppTextStyles`: Typography system yang lengkap
- ✅ Material Design 3 integration di main.dart

#### 6. **Firebase Integration**
- ✅ Firebase dependencies setup (Core, Auth, Firestore, Messaging)
- ✅ Firebase options configuration file
- ✅ Authentication flow dengan error handling
- ✅ Firestore integration untuk user data

#### 7. **State Management**
- ✅ GetX implementation di semua modules
- ✅ Reactive variables (Rx) untuk real-time updates
- ✅ Controller lifecycle management
- ✅ Service initialization di main.dart

#### 8. **Error Handling & Validation**
- ✅ Form validation di register dan login
- ✅ Firebase error handling dengan custom messages
- ✅ User feedback dengan snackbars
- ✅ Loading states management

### 🔄 Ready for Next Development:

#### Maps & Location
- Google Maps integration
- Real-time location tracking
- Route calculation dan navigation

#### Real-time Features  
- Driver-passenger matching
- Live ride tracking
- Push notifications

#### Payment Integration
- Payment gateway integration
- Multiple payment methods
- Receipt generation

#### Advanced Features
- Chat system between driver & passenger
- Rating & review system
- Ride history dengan detail
- Driver vehicle management
- Admin dashboard

### 📁 File Structure Summary:

```
lib/
├── main.dart ✅
├── firebase_options.dart ✅
├── app/
│   ├── data/
│   │   ├── models/ ✅
│   │   │   ├── user.dart
│   │   │   └── ride_request.dart
│   │   └── services/ ✅
│   │       ├── auth_service.dart
│   │       └── ride_service.dart
│   ├── modules/
│   │   ├── splash/ ✅
│   │   ├── auth/
│   │   │   ├── login/ ✅
│   │   │   └── register_passenger/ ✅
│   │   ├── home_passenger/ ✅
│   │   └── home_driver/ ✅
│   └── routes/ ✅
│       ├── app_pages.dart
│       └── app_routes.dart
└── utils/ ✅
    ├── app_colors.dart
    ├── app_images.dart
    ├── app_constants.dart
    └── app_text_styles.dart
```

### 🚀 Cara Menjalankan:

1. Clone repository
2. Jalankan `flutter pub get`
3. Setup Firebase project (opsional untuk testing dasar)
4. Jalankan `flutter run`

Aplikasi siap digunakan untuk development lebih lanjut dengan foundation yang kuat dan arsitektur yang bersih!

## Pengembangan Selanjutnya

### Yang perlu ditambahkan:
1. **Firebase Integration**: Implementasi auth dan database yang sebenarnya
2. **Maps Integration**: Google Maps untuk tracking lokasi real-time
3. **Payment Gateway**: Integrasi dengan payment provider
4. **Push Notifications**: Notifikasi untuk status ride
5. **Chat Feature**: Chat antara driver dan passenger
6. **GPS Tracking**: Real-time location tracking
7. **Rating System**: Rating dan review untuk driver/passenger
8. **Admin Panel**: Dashboard untuk admin mengelola aplikasi

### Modul yang bisa ditambahkan:
- **Login Module**: Halaman login untuk user yang sudah terdaftar
- **Driver Registration**: Formulir registrasi khusus driver
- **Ride History Detail**: Halaman detail untuk setiap perjalanan
- **Settings**: Pengaturan aplikasi
- **Help & Support**: Halaman bantuan dan dukungan
- **Notifications**: Manajemen notifikasi

## Arsitektur

Aplikasi ini menggunakan **Clean Architecture** dengan pola **MVC (Model-View-Controller)**:

- **Model**: Representasi data (User, RideRequest, dll)
- **View**: UI layer (Splash, Home, Auth screens)
- **Controller**: Business logic dan state management
- **Service**: External communication (API, Firebase)
- **Binding**: Dependency injection untuk setiap modul

Setiap modul (feature) memiliki struktur yang sama untuk konsistensi dan kemudahan maintenance.

## Kontribusi

Untuk berkontribusi pada project ini:
1. Fork repository
2. Buat branch fitur baru
3. Commit perubahan
4. Submit pull request

---

**JeksoedV2** - Ride Sharing Made Easy
