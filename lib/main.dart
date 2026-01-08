import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/router/router.dart';
import 'package:uc_marketplace/viewmodel/addEditMenu_viewmodel.dart';
import 'package:uc_marketplace/viewmodel/auth_viewmodel.dart';
import 'package:uc_marketplace/viewmodel/broadcast_viewmodel.dart';
import 'package:uc_marketplace/viewmodel/history_viewmodel.dart';
import 'package:uc_marketplace/viewmodel/chat_viewmodel.dart';
import 'package:uc_marketplace/viewmodel/home_viewmodel.dart';
import 'package:uc_marketplace/viewmodel/order_viewmodel.dart';
import 'package:uc_marketplace/viewmodel/payment_viewmodel.dart';
import 'package:uc_marketplace/viewmodel/pre_order_viewmodel.dart';
import 'package:uc_marketplace/viewmodel/search_viewmodel.dart';
import 'package:uc_marketplace/viewmodel/seller_order_viewmodel.dart';

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
        ChangeNotifierProxyProvider<AuthViewModel, PreOrderViewModel>(
          create: (context) => PreOrderViewModel(
            authVM: Provider.of<AuthViewModel>(context, listen: false),
          ),
          update: (context, authVM, previousPreOrderVM) {
            // 1. Ambil instance lama (previous)
            final vm = previousPreOrderVM ?? PreOrderViewModel(authVM: authVM);

            // 2. Update AuthVM-nya dengan yang terbaru
            vm.updateAuth(authVM);

            // 3. Kembalikan instance yang sama (bukan buat baru)
            return vm;
          },
        ),
        ChangeNotifierProvider(create: (_) => BroadcastViewModel()),
        ChangeNotifierProxyProvider<AuthViewModel, OrderViewModel>(
          create: (context) => OrderViewModel(
            authVM: Provider.of<AuthViewModel>(context, listen: false),
          ),
          update: (context, authVM, previousOrderVM) =>
              // Setiap kali AuthVM berubah (misal login/logout),
              // OrderVM mendapat instance AuthVM terbaru
              OrderViewModel(authVM: authVM),
        ),
        ChangeNotifierProvider(create: (_) => PaymentViewModel()),
        ChangeNotifierProvider(create: (_) => AddEditMenuViewModel()),
        ChangeNotifierProvider(create: (_) => HistoryViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => SellerOrderViewModel()), // Tambahkan ini
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
