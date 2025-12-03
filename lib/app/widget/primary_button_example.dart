import 'package:flutter/material.dart';
import '../widget/primary_button.dart';
import '../../utils/app_colors.dart';

class PrimaryButtonExample extends StatelessWidget {
  const PrimaryButtonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Primary Button Examples')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Default Button (equivalent to "Default Button" preview)
            Text(
              'Default Button',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            PrimaryButton(
              text: 'Login',
              onPressed: () {
                print('Login pressed');
              },
            ),

            SizedBox(height: 24),

            // Custom Color Button (equivalent to "Custom Color Button" preview)
            Text(
              'Custom Color Button',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            PrimaryButton(
              text: 'Register',
              onPressed: () {
                print('Register pressed');
              },
            ),

            SizedBox(height: 24),

            // Disabled Button Example
            Text(
              'Disabled Button',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            PrimaryButton(
              text: 'Disabled',
              isEnabled: false,
              onPressed: () {
                print('This should not print');
              },
            ),

            SizedBox(height: 24),

            // Custom Colors Example
            Text(
              'Custom Colors',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            PrimaryButton(
              text: 'Custom Colors',
              containerColor: AppColors.error,
              contentColor: AppColors.textWhite,
              onPressed: () {
                print('Custom colors pressed');
              },
            ),

            SizedBox(height: 24),

            // Custom Size Example
            Text(
              'Custom Size',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            PrimaryButton(
              text: 'Custom Size',
              height: 60,
              fontSize: 18,
              onPressed: () {
                print('Custom size pressed');
              },
            ),

            SizedBox(height: 24),

            // Fixed Width Button
            Text(
              'Fixed Width Button',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Center(
              child: PrimaryButton(
                text: 'Fixed Width',
                width: 200,
                onPressed: () {
                  print('Fixed width pressed');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
