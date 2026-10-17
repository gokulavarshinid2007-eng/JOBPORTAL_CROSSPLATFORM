import 'package:flutter/material.dart';
import 'package:job_utils/job_utils.dart';
import 'package:flutter/foundation.dart';
import 'pages/splash_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'package:firebase_core/firebase_core.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kIsWeb
        ? const FirebaseOptions(
      apiKey: 'AIzaSyBRW1xksUDwyfEaNE2mGo9OkiRLUgZthnU',
      authDomain: 'jobportal-47b0b.firebaseapp.com',
      projectId: 'jobportal-47b0b',
      storageBucket: 'jobportal-47b0b.firebasestorage.app',
      messagingSenderId: '781443978635',
      appId: '1:781443978635:web:cfc7c30e76a123360b8b8e',
      measurementId: 'G-5ZMDS9SC6T',
    )
        : null,
  );
  debugPrint('App starting: ${capitalize("job portal")}');
  runApp(const JobPortalApp());
}
class JobPortalApp extends StatelessWidget {
  const JobPortalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp( title: 'Job Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData( fontFamily: 'Arial', scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3799)), ),
      initialRoute: '/', routes: { '/': (context) => const SplashPage(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      }, );
  }
}