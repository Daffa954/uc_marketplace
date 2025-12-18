part of 'pages.dart'; // Sesuaikan dengan struktur project Anda

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  // State untuk Tab Aktif
  String selectedCategory = 'PRE-ORDER';
  
  // [DEBUG] Variabel untuk menampung info user
  String _debugUserName = "Loading...";
  String _debugAuthId = "Loading...";

  @override
  void initState() {
    super.initState();
    // Fetch data awal saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
      _loadDebugInfo(); // Load info user untuk debugging
    });
  }

  // [DEBUG] Fungsi ambil info user dari Supabase
  void _loadDebugInfo() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        // Ambil nama dari metadata, atau gunakan email jika nama kosong
        _debugUserName = user.userMetadata?['name'] ?? user.email ?? "Unknown User";
        _debugAuthId = user.id;
      });
    } else {
      setState(() {
        _debugUserName = "No User";
        _debugAuthId = "-";
      });
    }
  }

  // Fungsi Refresh Data (Panggil ViewModel)
  Future<void> _fetchData() async {
    await context.read<PreOrderViewModel>().initSellerDashboard();
  }

  // --- LOGIC GANTI RESTORAN (POP UP) ---
  void _showRestaurantSelector(BuildContext context, PreOrderViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 450, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Pop-up
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Pilih Cabang Restoran",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              
              // LIST RESTORAN
              Expanded(
                child: viewModel.ownedRestaurants.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.store_mall_directory_outlined, size: 50, color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            const Text("Kamu belum punya restoran.", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: viewModel.ownedRestaurants.length,
                        itemBuilder: (context, index) {
                          final resto = viewModel.ownedRestaurants[index];
                          // Cek apakah ini restoran yang sedang aktif
                          // Pastikan model RestaurantModel punya field 'id' atau 'restaurantId'
                          final bool isSelected = resto.id == viewModel.currentRestaurant?.id;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFffe3c9) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected 
                                ? Border.all(color: const Color(0xFFFF8C42)) 
                                : Border.all(color: Colors.grey.shade300),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFFF8C42),
                                child: Text(
                                  resto.name.isNotEmpty ? resto.name[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                resto.name, 
                                style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)
                              ),
                              trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFFFF8C42)) : null,
                              onTap: () {
                                viewModel.changeRestaurant(resto); 
                                Navigator.pop(ctx); 
                              },
                            ),
                          );
                        },
                      ),
              ),
              
              // TOMBOL TAMBAH RESTORAN BARU
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx); // 1. Tutup Pop-up
                    
                    // 2. Buka Halaman Tambah Restoran
                    // Menggunakan MaterialPageRoute agar kita bisa menunggu hasil (await)
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (_) => AddRestaurantViewModel(),
                          child: const AddRestaurantPage(),
                        ),
                      ),
                    );

                    // 3. Jika berhasil tambah (result == true), Refresh Dashboard
                    if (result == true) {
                      _fetchData();
                    }
                  },
                  icon: const Icon(Icons.add_business, color: Color(0xFFFF8C42)),
                  label: const Text("Tambah Restoran Baru", style: TextStyle(color: Color(0xFFFF8C42))),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFFF8C42)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PreOrderViewModel>();
    final bool isPreOrderTab = selectedCategory == 'PRE-ORDER';
    
    // Tentukan data yang ditampilkan berdasarkan Tab
    final dataList = isPreOrderTab ? viewModel.preOrders : viewModel.menus;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      
      // [BARU] APPBAR DEBUGGING
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi, $_debugUserName", // Nama User
              style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "ID: $_debugAuthId", // Auth ID (UUID)
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
            ),
          ],
        ),
        actions: [
          // Tombol Logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if(mounted) context.go('/login'); // Sesuaikan rute login Anda
            },
          )
        ],
      ),
      
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: const Color(0xFFFF8C42),
        child: Column(
          children: [
            // 1. HEADER (Banner + Card Info Resto)
            _buildHeader(context, viewModel),

            // 2. KONTEN (Tabs + List)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFffe3c9), // Background orange muda
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // TABS
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCategoryTab('PRE-ORDER'),
                          const SizedBox(width: 40),
                          _buildCategoryTab('MENU'),
                        ],
                      ),
                    ),

                    // LIST DATA
                    Expanded(
                      child: viewModel.isLoading
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C42)))
                          : dataList.isEmpty
                              ? _buildEmptyState(isPreOrderTab)
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                                  itemCount: dataList.length,
                                  separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    if (isPreOrderTab) {
                                      // ITEM PRE-ORDER
                                      final item = viewModel.preOrders[index];
                                      return PreOrderItemCard(
                                        preOrder: item,
                                        onTap: () {
                                          // Navigasi detail PO (Opsional)
                                        },
                                      );
                                    } else {
                                      // ITEM MENU
                                      final item = viewModel.menus[index];
                                      return MenuItemCard(
                                        menu: item,
                                        onEdit: () {
                                          // Navigasi Edit Menu
                                          context.go('/seller/home/menu-form', extra: item);
                                        },
                                      );
                                    }
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // FLOATING ACTION BUTTON (Add)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isPreOrderTab) {
            context.go('/seller/home/add-preorder');
          } else {
            // Mode Add New Menu
            context.go('/seller/home/menu-form', extra: null);
          }
        },
        backgroundColor: const Color(0xFFFF8C42),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // --- WIDGET HEADER (Banner + Card Floating) ---
  Widget _buildHeader(BuildContext context, PreOrderViewModel viewModel) {
    return Stack(
      children: [
        // Background Banner
        Container(
          height: 240, 
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/banner.jpeg'), // Ganti NetworkImage jika ada
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),
        ),
        
        // Card Info Restoran (Floating)
        Positioned(
          bottom: 25,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Logo Toko Placeholder
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFffe3c9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront, color: Color(0xFFFF8C42), size: 30),
                ),
                const SizedBox(width: 12),
                
                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.currentRestaurant?.name ?? 'Memuat Toko...',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        viewModel.currentRestaurant?.description ?? 'Kelola tokomu disini',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Tombol Ganti
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _showRestaurantSelector(context, viewModel),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: const [
                        Text(
                          "Ganti",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                        Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET TAB KATEGORI ---
  Widget _buildCategoryTab(String category) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF593A1D) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: const Color(0xFF593A1D), width: 1.5),
        ),
        child: Text(
          category,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF593A1D),
          ),
        ),
      ),
    );
  }

  // --- WIDGET TAMPILAN KOSONG ---
  Widget _buildEmptyState(bool isPreOrder) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isPreOrder ? Icons.calendar_month_outlined : Icons.restaurant_menu,
          size: 60,
          color: Colors.brown.withOpacity(0.4),
        ),
        const SizedBox(height: 16),
        Text(
          isPreOrder ? "Belum ada jadwal PO" : "Belum ada Menu",
          style: TextStyle(
            color: Colors.brown.withOpacity(0.6),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Tekan tombol + untuk menambahkan",
          style: TextStyle(color: Colors.brown.withOpacity(0.4), fontSize: 12),
        ),
      ],
    );
  }
}