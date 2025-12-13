// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:uc_marketplace/view/pages/pages.dart';
// import 'package:uc_marketplace/view/pages/seller_edit_add_menu.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   MyApp({super.key});
//   static const Color primaryOrange = Color(0xFFFF7F27);
//   static const Color textDark = Color(0xFF1F2937);
//   static const Color textGrey = Color(0xFF9CA3AF);
//   static const Color backgroundGrey = Color(0xFFF9FAFB);
//   // KONFIGURASI GO ROUTER
//   final GoRouter _router = GoRouter(
//     initialLocation: '/', // Mulai dari Splash Screen
//     routes: [
//       // 1. Splash Screen
//       GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
//       // 2. Login Page
//       GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
//       // 3. Register Page
//       GoRoute(
//         path: '/register',
//         builder: (context, state) => const RegisterPage(),
//       ),
//       // 4. Home Page (Placeholder setelah login)
//       GoRoute(path: '/home', builder: (context, state) => const HomeBuyer()),
//       GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
//       GoRoute(
//         path: '/buyerProfile',
//         builder: (context, state) => const BuyerProfilePage(),
//       ),

//       // SELLER
//       StatefulShellRoute.indexedStack(
//         builder: (context, state, navigationShell) {
//           return SellerMainPage(navigationShell: navigationShell);
//         },
//         branches: [
//           // Dashboard Branch
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: '/seller/home',
//                 builder: (context, state) => const SellerDashboardPage(),
//                 routes: [
//                   // --- NEW ROUTE HERE ---
//                   // This handles both "Add" (no extra) and "Edit" (passed extra)
//                   GoRoute(
//                     path: 'menu-form', // Full path: /seller/home/menu-form
//                     parentNavigatorKey:
//                         null, // Set this if you want to hide/show bottom bar specifically
//                     builder: (context, state) {
//                       // Retrieve the object passed via extra
//                       // Ensure MenuItem is imported
//                       final item = state.extra as MenuItem?;
//                       return AddEditMenuPage(item: item);
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     ],
//   );

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       routerConfig: _router,
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         fontFamily: 'Poppins',
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
//         useMaterial3: true,
//         inputDecorationTheme: InputDecorationTheme(
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//           filled: true,
//           fillColor: Colors.grey[100],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/router/router.dart';
import 'package:uc_marketplace/viewmodel/auth_viewmodel.dart';
import 'package:uc_marketplace/viewmodel/home_viewmodel.dart';
import 'package:uc_marketplace/viewmodel/order_viewmodel.dart';
import 'package:uc_marketplace/viewmodel/pre_order_viewmodel.dart';
import 'package:uc_marketplace/viewmodel/search_viewmodel.dart';

import 'shared/shared.dart'; // Import Router Anda

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load Environment Variables
  await dotenv.load(fileName: ".env");

  // 2. DEBUGGING: Cek apakah key terbaca?
  print("URL Check: ${Const.supabaseUrl}");
  print("Key Check: ${Const.supabaseKey}");

  // Jika hasil print kosong, berarti masalah ada di file .env atau Const

  // 3. Inisialisasi
  await Supabase.initialize(url: Const.supabaseUrl, anonKey: Const.supabaseKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const Color primaryOrange = Color(0xFFFF7F27);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF9CA3AF);
  static const Color backgroundGrey = Color(0xFFF9FAFB);
  @override
  @override
  Widget build(BuildContext context) {
    // Bungkus dengan MultiProvider agar AuthViewModel bisa diakses di seluruh aplikasi
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => PreOrderViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router, // Menggunakan Router yang sudah dipisah
        debugShowCheckedModeBanner: false,
        title: 'UC Marketplace',
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
      ),
    );
  }
}
