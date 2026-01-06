import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uc_marketplace/main.dart';

import 'package:uc_marketplace/view/pages/new_order_tab_view.dart';
import 'package:uc_marketplace/view/pages/pages.dart';

// --- WRAPPER BUYER ---
class BuyerMainWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const BuyerMainWrapper({super.key, required this.navigationShell});

  void _showOrderSelectionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Order & Search Options",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF7622),
                ),
              ),
              const SizedBox(height: 15),

              ListTile(
                leading: const Icon(Icons.search, color: Color(0xFFFF7622)),
                title: const Text("Search"),
                onTap: () {
                  Navigator.pop(context);

                  navigationShell.goBranch(1);
                },
              ),
              // Option 2: NEW ONGOING PAGE
              ListTile(
                leading: const Icon(
                  Icons.timer_outlined,
                  color: Color(0xFFFF7622),
                ),
                title: const Text("Ongoing Orders"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => const NewOrderTabView(initialIndex: 0),
                    ),
                  );
                },
              ),
              // Option 3: NEW HISTORY PAGE
              ListTile(
                leading: const Icon(Icons.history, color: Color(0xFFFF7622)),
                title: const Text("Order History"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => const NewOrderTabView(initialIndex: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: MyApp.primaryOrange,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          // INTERCEPT THE TIMER ICON (Index 1)
          if (index == 1) {
            _showOrderSelectionMenu(context);
          } else {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          }
        },
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            activeIcon: Icon(Icons.timer),
            label: 'History', // This now opens the menu
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// --- WRAPPER SELLER --- (STAYS EXACTLY THE SAME)
class SellerMainWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const SellerMainWrapper({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF7F27),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Produk'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
