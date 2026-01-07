import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uc_marketplace/main_wrapper.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/view/pages/pages.dart';
import 'package:uc_marketplace/view/widgets/widgets.dart';

class AppRouter {
  // Global Key untuk Navigator paling luar (untuk menutupi BottomBar)
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // --- PUBLIC ROUTES ---
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // =======================================================================
      // 1. BUYER SHELL
      // =======================================================================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BuyerMainWrapper(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/buyer/home',
                builder: (context, state) => const HomeBuyer(),
                routes: [
                  GoRoute(
                    path: 'search',
                    builder: (context, state) {
                      return SearchPage();
                    },
                  ),
                  GoRoute(
                    path: 'po-detail',
                    builder: (context, state) {
                      final po = state.extra as PreOrderModel;
                      return PreOrderDetailPage(preOrder: po);
                    },
                  ),
                  GoRoute(
                    path:
                        'menu-detail',
                    parentNavigatorKey: rootNavigatorKey, // Tutup bottom bar
                    builder: (context, state) {
                      final menu = state.extra as MenuModel;
                      return MenuDetailPage(menu: menu);
                    },
                  ),
                  GoRoute(
                    path: 'checkout', // Path: /buyer/home/checkout
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      // 1. Ambil Map extras
                      final extras = state.extra as Map<String, dynamic>;

                      // 2. Extract data sesuai key yang dikirim
                      final preOrder = extras['preOrder'] as PreOrderModel;
                      final items = extras['items'] as List<MenuModel>;

                      // 3. AMBIL PICKUP LIST (Penambahan Baru)
                      // Pastikan casting-nya ke List<PoPickupModel>
                      final pickupList =
                          extras['pickupList'] as List<PoPickupModel>;

                      // 4. Kirim ke Constructor CheckoutPage
                      return CheckoutPage(
                        preOrder: preOrder,
                        rawItems: items,
                        pickupList: pickupList, // <--- Masukkan di sini
                      );
                    },
                  ),
                  GoRoute(
                    path: 'payment/:orderId', // URL pattern
                    name: 'payment', // Nama route untuk dipanggil
                    parentNavigatorKey:
                        rootNavigatorKey, // <--- TAMBAHKAN INI (Agar Full Screen & Tutup Bottom Bar)
                    builder: (context, state) {
                      // Validasi agar tidak crash jika extra null (misal refresh browser)
                      if (state.extra == null) {
                        return const Scaffold(
                          body: Center(
                            child: Text("Data Order Tidak Ditemukan"),
                          ),
                        );
                      }

                      // Casting object yang dikirim
                      final orderObj = state.extra as OrderModel;

                      return PaymentPage(order: orderObj);
                    },
                  ),
                ],
              ),

            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/buyer/history',
                builder: (context, state) => const HistoryOrderPage(),
              ),
            ],
          ),
           StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/buyer/chat',
                builder: (context, state) => const HistoryOrderPage(),
              ),
            ],
          ),
          // Branch 2: Chat (NEW BRANCH ADDED HERE)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/buyer/chat',
                builder: (context, state) => const BuyerChatPage(), // Link to buyer_chat.dart
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/buyer/profile',
                builder: (context, state) => const BuyerProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // =======================================================================
      // 2. SELLER SHELL
      // =======================================================================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return SellerMainWrapper(navigationShell: navigationShell);
        },
        branches: [
          // Branch Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/seller/home',
                builder: (context, state) => const SellerDashboardPage(),
                routes: [
                  // Halaman Detail yang menutupi Bottom Bar
                  GoRoute(
                    path: 'add-preorder',
                    parentNavigatorKey:
                        rootNavigatorKey, // Covers the bottom bar
                    builder: (context, state) => const SellerAddPreOrderPage(),
                    routes: [
                      // 2. Sub-route for the Add Pickup Page we just built
                      GoRoute(
                        path:
                            'pickup-place', // Full path: /seller/home/add-preorder/pickup-place
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) {
                          // Ensure the preOrderId is passed from the previous page
                          final int id = state.extra as int;
                          return AddPickupPage(preOrderId: id);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'menu-form',
                    parentNavigatorKey: rootNavigatorKey, // Pakai key static
                    builder: (context, state) {
                      return AddEditMenuPage();
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch Products
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/seller/chats',
                builder: (context, state) => const Center(child: Text("Chat")),
              ),
            ],
          ),
          // Branch Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/seller/settings',
                builder: (context, state) =>
                    const Center(child: Text("Halaman Setting")),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
