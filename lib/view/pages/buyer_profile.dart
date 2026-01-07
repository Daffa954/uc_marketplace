part of 'pages.dart';

class BuyerProfilePage extends StatefulWidget {
  const BuyerProfilePage({super.key});

  @override
  State<BuyerProfilePage> createState() => _BuyerProfilePageState();
}

class _BuyerProfilePageState extends State<BuyerProfilePage> {
  
  @override
  void initState() {
    super.initState();
    // Fetch data user saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthViewModel>(context, listen: false).loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Consumer<AuthViewModel>(
            builder: (context, userVM, child) {
              
              // 1. LOADING STATE
              if (userVM.isLoading) {
                return const SizedBox(
                  height: 400,
                  child: Center(child: CircularProgressIndicator(color: Color(0xFFFF7F27))),
                );
              }

              // 2. DATA USER (Bisa Null jika error/belum login)
              final user = userVM.user;
              final userName = user?.name ?? "Guest User";
              final userEmail = user?.email ?? "Silakan Login";
              // Avatar sementara pakai inisial nama jika tidak ada foto
              final initial = userName.isNotEmpty ? userName[0].toUpperCase() : "G";

              return Column(
                children: [
                  // --- HEADER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCircleButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => context.pop(), 
                      ),
                      const Text(
                        "Menu Profile",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      _buildCircleButton(
                        icon: Icons.more_horiz,
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- PROFILE INFO (Dinamis dari Supabase) ---
                  Row(
                    children: [
                      // Avatar Inisial (karena model belum ada field photoURL)
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: const Color(0xFFFF7F27).withOpacity(0.2),
                        child: Text(
                          initial,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFF7F27)),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userEmail,
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

                  // --- GROUP 2: History & Cart ---
                  _buildMenuContainer(
                    children: [
                       _buildMenuItem(
                        icon: Icons.history, // Icon History
                        iconColor: Colors.green,
                        title: "Riwayat Pesanan",
                        onTap: () {
                          // Navigasi ke Halaman History Order
                          context.push('/buyer/history');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.shopping_bag_outlined,
                        iconColor: Colors.blue,
                        title: "Cart",
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
                        isLogOut: true,
                        onTap: () async {
                          // Konfirmasi Logout
                          final bool? confirm = await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Logout"),
                              content: const Text("Apakah Anda yakin ingin keluar?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Ya, Keluar")),
                              ],
                            ),
                          );

                          if (confirm == true && mounted) {
                            
                             if (mounted) context.go('/login');
                          }
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                ],
              );
            }
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
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }

  Widget _buildMenuContainer({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
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
          boxShadow: [
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
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
    );
  }
}