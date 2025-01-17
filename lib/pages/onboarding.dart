import 'package:flutter/material.dart';
import 'package:mpbasic/pages/home.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  'Smart Eco Saline',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple, // Theme color updated to purple
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Monitor, optimize, and manage saline levels with ease using Smart Eco Saline. Enhance efficiency and sustainability for healthier outcomes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            Image.asset(
              'assets/onboarding.png', // Image reflecting the saline theme
              height: 250,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                backgroundColor:
                    Colors.purple, // Button background color set to purple
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // Button text color updated to white
                    ),
                  ),
                  SizedBox(width: 8), // Adjusted spacing
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white, // Icon color updated to white
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
