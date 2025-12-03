// filepath: lib/rating_test_main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import rating module components
import 'app/modules/rating/bindings/rating_binding.dart';
import 'app/modules/rating/views/rating_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(RatingTestApp());
}

class RatingTestApp extends StatelessWidget {
  const RatingTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Rating Test',
      initialRoute: '/test',
      getPages: [
        // Test route to navigate to rating
        GetPage(name: '/test', page: () => RatingTestScreen()),
        // Rating route
        GetPage(
          name: '/rating/:driverId/:rideRequestId',
          page: () => const RatingView(),
          binding: RatingBinding(),
        ),
      ],
    );
  }
}

class RatingTestScreen extends StatelessWidget {
  const RatingTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rating Module Test'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Rating Implementation Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navigate to rating screen with test parameters
                Get.toNamed('/rating/test-driver-123/test-ride-request-456');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text('Test Rating Screen'),
            ),
            SizedBox(height: 40),
            Text(
              'Features Implemented:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildFeatureItem('✅ Driver info loading from Firebase'),
            _buildFeatureItem('✅ Trip details with route display'),
            _buildFeatureItem('✅ Interactive 5-star rating system'),
            _buildFeatureItem('✅ Comment input for feedback'),
            _buildFeatureItem('✅ Rating submission to Firebase'),
            _buildFeatureItem('✅ Driver rating calculation update'),
            _buildFeatureItem('✅ Trip completion dialog'),
            _buildFeatureItem('✅ UI matching Android design 100%'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(feature, style: TextStyle(fontSize: 16))],
      ),
    );
  }
}
