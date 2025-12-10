// filepath: lib/chat_test_main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/app_constants.dart';

// Import chat module components
import 'app/modules/chat/bindings/chat_binding.dart';
import 'app/modules/chat/views/chat_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  runApp(ChatTestApp());
}

class ChatTestApp extends StatelessWidget {
  const ChatTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Chat Test',
      initialRoute: '/test',
      getPages: [
        // Test route to navigate to chat
        GetPage(name: '/test', page: () => ChatTestScreen()),
        // Chat route
        GetPage(
          name: '/chat/:rideRequestId',
          page: () => const ChatView(),
          binding: ChatBinding(),
        ),
      ],
    );
  }
}

class ChatTestScreen extends StatelessWidget {
  const ChatTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Module Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chat Implementation Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navigate to chat screen with test ride request ID
                Get.toNamed('/chat/test-ride-request-123');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text('Test Chat Screen'),
            ),
            SizedBox(height: 40),
            Text(
              'Features Implemented:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildFeatureItem('✅ Real-time messaging with Firebase'),
            _buildFeatureItem('✅ Text messages with custom bubbles'),
            _buildFeatureItem('✅ Image sharing from gallery'),
            _buildFeatureItem('✅ User info loading (names & photos)'),
            _buildFeatureItem('✅ Message timestamp handling'),
            _buildFeatureItem('✅ Custom UI matching Android design'),
            _buildFeatureItem('✅ Firebase Storage integration'),
            _buildFeatureItem('✅ Auto-scroll to latest messages'),
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
