import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uc_marketplace/view/pages/pages.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  static const Color primaryOrange = Color(0xFFFF7F27);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF9CA3AF);
  static const Color backgroundGrey = Color(0xFFF9FAFB);
  // KONFIGURASI GO ROUTER
  final GoRouter _router = GoRouter(
    initialLocation: '/', // Mulai dari Splash Screen
    routes: [
      // 1. Splash Screen
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      // 2. Login Page
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      // 3. Register Page
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      // 4. Home Page (Placeholder setelah login)
      GoRoute(path: '/home', builder: (context, state) => const HomeBuyer()),

      // SELLER
      StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return SellerMainPage(navigationShell: navigationShell);
      },
      branches: [
        // Dashboard Branch
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/seller/home', builder: (context, state) => const SellerDashboardPage()),
          ]
        ),
      ]
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}
