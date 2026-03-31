import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:habit_spark/firebase_options.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/screens/login_page.dart';
import 'package:habit_spark/screens/home_page.dart';
import 'package:habit_spark/screens/onboarding_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkUserOnboarding(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    
    if (doc.exists) {
      return doc.data()?['hasSeenOnboarding'] ?? false;
    }
    return false;
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
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // If user is logged in, check if they've seen onboarding
          if (snapshot.hasData) {
            final userId = snapshot.data!.uid;
            return FutureBuilder<bool>(
              future: _checkUserOnboarding(userId),
              builder: (context, onboardingSnapshot) {
                if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                
                // Show onboarding if user hasn't seen it
                if (onboardingSnapshot.data == false) {
                  return OnboardingPage(userId: userId);
                }
                
                // Otherwise show home page
                return const HomePage();
              },
            );
          }
          
          // If not logged in, show login page
          return const LoginPage();
        },
      ),
    );
  }
}