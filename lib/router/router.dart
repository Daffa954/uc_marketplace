import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uc_marketplace/main_wrapper.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/view/pages/pages.dart';
import 'package:uc_marketplace/view/pages/seller_edit_add_menu.dart';

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
      GoRoute(
        path: '/buyer/po-detail',
        // parentNavigatorKey: rootNavigatorKey, // Menutupi Bottom Nav
        builder: (context, state) {
          // Ambil object yang dikirim
          final po = state.extra as PreOrderModel;
          return PreOrderDetailPage(preOrder: po);
        },
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
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/buyer/search',
                builder: (context, state) => const SearchPage(),
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
                    path: 'menu-form',
                    parentNavigatorKey: rootNavigatorKey, // Pakai key static
                    builder: (context, state) {
                      final item = state.extra as MenuItem?;
                      return AddEditMenuPage(item: item);
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
                path: '/seller/products',
                builder: (context, state) =>
                    const Center(child: Text("Halaman Produk")),
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
