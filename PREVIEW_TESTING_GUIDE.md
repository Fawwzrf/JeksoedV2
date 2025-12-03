# 🧪 PREVIEW TESTING GUIDE
*JekSoed V2 - Complete Application Flow Testing*

## 🎯 **TESTING OBJECTIVES**

Memverifikasi bahwa seluruh alur aplikasi berfungsi dengan baik tanpa backend, menggunakan mock data untuk simulasi pengalaman pengguna yang lengkap.

---

## 📋 **TEST SCENARIOS**

### **Scenario 1: Authentication Flow** 🔐

#### **Test 1.1: Initial Launch**
1. **Launch aplikasi** → Lihat splash screen (3 detik)
2. **Auto redirect** → CTA screen dengan 2 pilihan utama
3. **Verify UI** → Logo, judul "Masuk dulu yuk!", dan 2 buttons
4. **Expected**: Clean design dengan warna branded

#### **Test 1.2: Login Existing User**
1. **Tap "Login"** → Navigate ke login screen
2. **Input credentials**:
   - Email: `passenger@jeksoed.com`
   - Password: `apapun` (anything)
3. **Tap "Login"** → Success redirect ke passenger main
4. **Expected**: Login berhasil, navigate ke dashboard penumpang

#### **Test 1.3: Login Driver**
1. **Go back ke login**
2. **Input credentials**:
   - Email: `driver@jeksoed.com`  
   - Password: `apapun` (anything)
3. **Tap "Login"** → Success redirect ke driver main
4. **Expected**: Login berhasil, navigate ke dashboard driver

#### **Test 1.4: Registration Flow**
1. **From CTA → Tap "Register"** → Role selection screen
2. **Choose "Penumpang"** → Passenger registration form
3. **Fill form**:
   - Nama: `Test User`
   - NIM: `2024001001`
   - Email: `test@jeksoed.com`
   - Phone: `081234567890`
   - Password: `password123`
4. **Submit** → Auto navigate ke passenger main
5. **Expected**: Registration success, langsung masuk dashboard

#### **Test 1.5: Driver Registration (3-Step)**
1. **From role selection → Choose "Driver"**
2. **Step 1 - Identitas**: Fill personal info
3. **Step 2 - Dokumen**: Fill SIM & plat kendaraan
4. **Step 3 - Verifikasi**: Accept terms & conditions
5. **Submit** → Navigate ke driver main
6. **Expected**: Complete 3-step flow dengan validasi

---

### **Scenario 2: Passenger Experience** 👤

#### **Test 2.1: Home Screen Navigation**
1. **Bottom navigation** → 3 tabs (Home, Activity, Profile)
2. **Home tab active** → Category cards, search, recommendations
3. **Category selection** → Car, Motor, Cleaning, Wisata, Cafe
4. **Quick actions** → Recent destinations, favorites
5. **Expected**: Responsive UI dengan smooth transitions

#### **Test 2.2: Create Order Flow**
1. **Search pickup location** → Input/select "Fakultas Teknik"
2. **Tap "Lanjut"** → Pickup confirmation screen
3. **Confirm pickup** → Route selection screen
4. **Search destination** → Input/select "Asrama Putra"
5. **Select vehicle type** → Car/Motor options
6. **View fare estimate** → Distance, time, price
7. **Confirm order** → Finding driver screen
8. **Expected**: Complete booking flow dengan real-time updates

#### **Test 2.3: Finding Driver Simulation**
1. **Finding driver screen** → Loading dengan search animation
2. **Auto-find driver** → Driver found notification
3. **Accept driver** → Navigate ke trip screen
4. **Expected**: Realistic finding process (5-10 detik)

#### **Test 2.4: Trip Experience**
1. **Trip screen** → Map dengan route, driver info
2. **Real-time tracking** → Driver location updates
3. **Chat button** → Open chat dengan driver
4. **Trip completion** → Automatic detection arrival
5. **Rating screen** → 5-star rating untuk driver
6. **Expected**: Complete trip experience dengan feedback

#### **Test 2.5: Activity History**
1. **Activity tab** → List of completed trips
2. **Trip details** → Tap any trip untuk detail
3. **Trip info** → Date, route, fare, driver info
4. **Chat history** → Access old conversations
5. **Expected**: Comprehensive trip history management

#### **Test 2.6: Profile Management**
1. **Profile tab** → User info, settings, options
2. **Edit profile** → Update personal information
3. **Settings** → App preferences, notifications
4. **Logout** → Return ke auth flow
5. **Expected**: Complete profile management

---

### **Scenario 3: Driver Experience** 🚗

#### **Test 3.1: Driver Dashboard**
1. **Home screen** → Map, online status, statistics
2. **Online toggle** → Switch online/offline status
3. **Driver stats** → Balance, rating, completed orders
4. **Notification area** → New request indicators
5. **Expected**: Professional driver interface

#### **Test 3.2: Request Management**
1. **Online mode** → Wait for incoming requests
2. **Request popup** → Passenger info, pickup, destination
3. **Accept request** → Navigate ke trip management
4. **Reject option** → Decline dan wait for next
5. **Expected**: Efficient request handling system

#### **Test 3.3: Trip Management (Driver Side)**
1. **Accept trip** → Navigation ke pickup location
2. **Arrive pickup** → Notify passenger, start trip
3. **En-route** → Real-time navigation, chat access
4. **Complete trip** → Mark as completed
5. **Rating passenger** → 5-star rating system
6. **Expected**: Complete trip lifecycle management

#### **Test 3.4: Driver Activity**
1. **Activity tab** → Daily stats, earnings summary
2. **Filter options** → All, Completed, Cancelled
3. **Trip history** → Detailed trip records
4. **Earnings tracker** → Daily/weekly/monthly totals
5. **Expected**: Comprehensive activity tracking

#### **Test 3.5: Driver Profile & Settings**
1. **Profile tab** → Driver info, vehicle details
2. **Edit profile** → Update personal & vehicle info
3. **Vehicle management** → Add/edit vehicle details
4. **Earnings & balance** → Financial overview
5. **Settings & logout** → App preferences
6. **Expected**: Professional driver profile management

---

### **Scenario 4: Integration Features** 🔄

#### **Test 4.1: Real-time Chat**
1. **During trip** → Open chat from either side
2. **Send messages** → Text communication
3. **Image sharing** → Send/receive photos
4. **Message status** → Delivery indicators
5. **Chat history** → Persistent conversation
6. **Expected**: Seamless real-time messaging

#### **Test 4.2: Rating System**
1. **Trip completion** → Auto-show rating screen
2. **5-star selection** → Interactive star rating
3. **Optional feedback** → Text comments
4. **Submit rating** → Update user profiles
5. **Rating history** → View past ratings given/received
6. **Expected**: Comprehensive feedback system

#### **Test 4.3: Cross-Platform Navigation**
1. **Deep links** → Navigate between different sections
2. **Back navigation** → Proper back button handling
3. **Route persistence** → Maintain navigation state
4. **Multi-tab support** → Bottom navigation consistency
5. **Expected**: Smooth navigation experience

---

## 🎨 **UI/UX VERIFICATION CHECKLIST**

### **Visual Design** ✅
- [ ] **Colors**: Consistent green (#4CAF50) & yellow (#FFF9D9)
- [ ] **Typography**: Proper font weights & sizes
- [ ] **Spacing**: Consistent margins & padding
- [ ] **Icons**: Proper icon usage & alignment
- [ ] **Shadows**: Card elevations & drop shadows

### **Interactions** ✅
- [ ] **Buttons**: Tap feedback & state changes
- [ ] **Forms**: Validation & error handling
- [ ] **Animations**: Smooth transitions & loading states
- [ ] **Gestures**: Swipe, tap, scroll responsiveness
- [ ] **Feedback**: Visual & haptic feedback

### **Responsiveness** ✅
- [ ] **Different screen sizes**: Mobile, tablet, desktop
- [ ] **Orientation**: Portrait & landscape support
- [ ] **Text scaling**: Accessibility font sizes
- [ ] **Touch targets**: Minimum 44px touch areas
- [ ] **Safe areas**: Notch & navigation bar handling

---

## 🐛 **KNOWN LIMITATIONS (Preview Mode)**

### **Expected Behaviors** ⚠️
- **No real authentication**: Mock users only
- **No backend calls**: All data is simulated
- **No real location**: Mock coordinates used
- **No push notifications**: UI simulation only
- **No image upload**: Placeholder images
- **No payment integration**: Mock payment flow

### **Simulated Features** 🎭
- **Trip tracking**: Animated progress updates
- **Real-time chat**: Local message simulation
- **Driver matching**: Automatic mock matching
- **Location services**: Predefined locations
- **Rating persistence**: Temporary mock storage

---

## 🎯 **SUCCESS CRITERIA**

### **Functional Requirements** ✅
- [ ] **Complete auth flow** works smoothly
- [ ] **All navigation** functions properly  
- [ ] **UI components** render correctly
- [ ] **Mock data** displays appropriately
- [ ] **State management** works consistently

### **Performance Requirements** ✅
- [ ] **Fast loading**: < 3 seconds initial load
- [ ] **Smooth animations**: 60 FPS interactions
- [ ] **Memory efficient**: No memory leaks
- [ ] **Responsive UI**: < 100ms tap response
- [ ] **Stable navigation**: No crashes/freezes

### **User Experience** ✅
- [ ] **Intuitive flow**: Clear user journey
- [ ] **Visual consistency**: Cohesive design
- [ ] **Error handling**: Graceful error states
- [ ] **Feedback systems**: Clear user feedback
- [ ] **Accessibility**: Basic accessibility support

---

## 📊 **TEST RESULTS TEMPLATE**

```
TESTING DATE: [Date]
TESTER: [Name]
DEVICE/BROWSER: [Device/Chrome/etc]

=== AUTHENTICATION ===
✅ CTA Flow
✅ Login (Passenger)  
✅ Login (Driver)
✅ Registration (Passenger)
✅ Registration (Driver)

=== PASSENGER FLOW ===
✅ Home Navigation
✅ Create Order
✅ Finding Driver
✅ Trip Experience
✅ Activity History  
✅ Profile Management

=== DRIVER FLOW ===
✅ Driver Dashboard
✅ Request Management
✅ Trip Management
✅ Driver Activity
✅ Driver Profile

=== INTEGRATION ===
✅ Real-time Chat
✅ Rating System
✅ Cross-Platform Navigation

=== UI/UX ===
✅ Visual Design
✅ Interactions
✅ Responsiveness

OVERALL SCORE: [X]/20
NOTES: [Any issues or observations]
```

---

## 🚀 **POST-TESTING ACTIONS**

### **If All Tests Pass** ✅
1. **Document results** → Complete test report
2. **Demo recording** → Screen recording untuk stakeholder
3. **Prepare production** → Enable Firebase & backend
4. **Deploy staging** → Set up staging environment

### **If Issues Found** 🔧
1. **Log bugs** → Document issues dengan screenshots
2. **Prioritize fixes** → Critical vs nice-to-have
3. **Fix & re-test** → Iterative improvement
4. **Re-validate** → Complete testing cycle

---

**Happy Testing! 🎉**
