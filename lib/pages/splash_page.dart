import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _goToHomeAfterDelay();
  }

  Future<void> _goToHomeAfterDelay() async {
    // Wait 2.5 seconds, then move to Home and remove Splash from the
    // navigation stack (so the back button won't return to it).
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A3D62),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.briefcase,
              size: 70,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'JobConnect',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Online Recruitment System',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}