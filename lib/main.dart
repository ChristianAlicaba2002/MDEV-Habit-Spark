import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:habit_spark/firebase_options.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/screens/login_page.dart';
import 'package:habit_spark/screens/home_page.dart';
import 'package:habit_spark/screens/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    if (!hasSeenOnboarding) {
      await prefs.setBool('hasSeenOnboarding', true);
      return true; // First time
    }
    return false; // Not first time
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Spark',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: _checkFirstTime(),
        builder: (context, firstTimeSnapshot) {
          if (firstTimeSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // Show onboarding if first time
          if (firstTimeSnapshot.data == true) {
            return const OnboardingPage();
          }
          
          // Otherwise check auth state
          return StreamBuilder(
            stream: AuthService().authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasData) {
                return const HomePage();
              }
              return const LoginPage();
            },
          );
        },
      ),
    );
  }
}