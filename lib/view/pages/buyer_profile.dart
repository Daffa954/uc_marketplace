part of 'pages.dart';

class BuyerProfilePage extends StatelessWidget {
  const BuyerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              // --- HEADER (Back Button, Title, More) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => context.pop(), // Kembali ke halaman sebelumnya
                  ),
                  const Text(
                    "Menu Profile",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MyApp.textDark,
                    ),
                  ),
                  _buildCircleButton(
                    icon: Icons.more_horiz,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- PROFILE INFO (Avatar & Name) ---
              Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=12'), // Gambar dummy user cowok
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Septa",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: MyApp.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "I love fast food",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- GROUP 1: Personal Info ---
              _buildMenuContainer(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    iconColor: Colors.orange,
                    title: "Personal Info",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.map_outlined,
                    iconColor: Colors.purple,
                    title: "Addresses",
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- GROUP 2: Cart, Favorite, etc ---
              _buildMenuContainer(
                children: [
                  _buildMenuItem(
                    icon: Icons.shopping_bag_outlined,
                    iconColor: Colors.blue,
                    title: "Cart",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.favorite_border,
                    iconColor: Colors.purpleAccent,
                    title: "Favourite",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_none,
                    iconColor: Colors.orangeAccent,
                    title: "Notifications",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.credit_card,
                    iconColor: Colors.blueAccent,
                    title: "Payment Method",
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- GROUP 3: General ---
              _buildMenuContainer(
                children: [
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    iconColor: Colors.deepOrange,
                    title: "FAQs",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.rate_review_outlined,
                    iconColor: Colors.teal,
                    title: "User Reviews",
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    iconColor: Colors.indigo,
                    title: "Settings",
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- GROUP 4: Log Out ---
              _buildMenuContainer(
                children: [
                  _buildMenuItem(
                    icon: Icons.logout,
                    iconColor: Colors.red,
                    title: "Log Out",
                    isLogOut: true, // Opsional: untuk styling khusus jika mau
                    onTap: () {
                      // Logika logout, misal kembali ke login
                      context.go('/login');
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: MyApp.textDark, size: 20),
      ),
    );
  }

  Widget _buildMenuContainer({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // Warna background abu-abu sangat muda
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool isLogOut = false,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [ // Bayangan halus untuk icon
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
            )
          ]
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: MyApp.textDark,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
    );
  }
}