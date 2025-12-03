import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uc_marketplace/view/pages/pages.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // KONFIGURASI GO ROUTER
  final GoRouter _router = GoRouter(
    initialLocation: '/', // Mulai dari Splash Screen
    routes: [
      // 1. Splash Screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      // 2. Login Page
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      // 3. Register Page
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      // 4. Home Page (Placeholder setelah login)
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePagev2(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}