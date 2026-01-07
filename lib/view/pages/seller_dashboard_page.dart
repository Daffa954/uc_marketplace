part of 'pages.dart';

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  // State
  String selectedCategory = 'PRE-ORDER';
  String _debugUserName = "Loading...";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
      _loadDebugInfo();
    });
  }

  void _loadDebugInfo() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _debugUserName =
            user.userMetadata?['name'] ?? user.email ?? "Unknown User";
      });
    }
  }

  Future<void> _fetchData() async {
    await context.read<PreOrderViewModel>().initSellerDashboard();
  }

  // --- LOGIC GANTI RESTORAN (POP UP) ---
  void _showRestaurantSelector(
    BuildContext context,
    PreOrderViewModel viewModel,
  ) {
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
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Expanded(
                child: viewModel.ownedRestaurants.isEmpty
                    ? const Center(
                        child: Text(
                          "Kamu belum punya restoran.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: viewModel.ownedRestaurants.length,
                        itemBuilder: (context, index) {
                          final resto = viewModel.ownedRestaurants[index];
                          final bool isSelected =
                              resto.id == viewModel.currentRestaurant?.id;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFffe3c9)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: const Color(0xFFFF8C42))
                                  : Border.all(color: Colors.grey.shade300),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFFF8C42),
                                child: Text(
                                  resto.name.isNotEmpty
                                      ? resto.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                resto.name,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFFFF8C42),
                                    )
                                  : null,
                              onTap: () {
                                viewModel.changeRestaurant(resto);
                                Navigator.pop(ctx);
                              },
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (_) => AddRestaurantViewModel(),
                          child: const AddRestaurantPage(),
                        ),
                      ),
                    );
                    if (result == true) _fetchData();
                  },
                  icon: const Icon(
                    Icons.add_business,
                    color: Color(0xFFFF8C42),
                  ),
                  label: const Text(
                    "Tambah Restoran Baru",
                    style: TextStyle(color: Color(0xFFFF8C42)),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFFF8C42)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
    final dataList = isPreOrderTab ? viewModel.preOrders : viewModel.menus;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Icon(
            Icons.storefront,
            color: const Color(0xFFFF8C42),
            size: 28,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dashboard Penjual",
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _debugUserName,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.red, size: 20),
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (mounted) context.go('/login');
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: const Color(0xFFFF8C42),
        // 1. PERBAIKAN: Gunakan SingleChildScrollView
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 1. HERO HEADER
              _buildHeroHeader(context, viewModel),

              // 2. KONTEN (Chart + Tabs + List)
              Container(
                width: double.infinity,
                // Pastikan container punya tinggi minimal agar rounded corner terlihat bagus
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // --- CHART GRAFIK PENJUALAN ---
                    if (!viewModel.isLoading &&
                        viewModel.currentRestaurant != null)
                      SalesChartWidget(
                        weeklySales: viewModel.weeklySales,
                        totalRevenue: viewModel.totalRevenue,
                      ),

                    // --- TABS ---
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

                    // --- LIST DATA ---
                    // 2. PERBAIKAN: Hapus Expanded, Gunakan shrinkWrap & physics mati
                    viewModel.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFF8C42),
                              ),
                            ),
                          )
                        : dataList.isEmpty
                        ? _buildEmptyState(isPreOrderTab)
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                            shrinkWrap: true, // List mengikuti tinggi konten
                            physics: const NeverScrollableScrollPhysics(), // Scroll ikut Parent
                            itemCount: dataList.length,
                            separatorBuilder: (ctx, i) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              if (isPreOrderTab) {
                                final item = viewModel.preOrders[index];
                                return PreOrderItemCard(
                                  preOrder: item,
                                  onTap: () {},
                                );
                              } else {
                                final item = viewModel.menus[index];
                                return MenuItemCard(
                                  menu: item,
                                  onEdit: () {
                                    context.go(
                                      '/seller/home/menu-form',
                                      extra: item,
                                    );
                                  },
                                );
                              }
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isPreOrderTab) {
            context.go('/seller/home/add-preorder');
          } else {
            context.go('/seller/home/menu-form', extra: null);
          }
        },
        backgroundColor: const Color(0xFFFF8C42),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildHeroHeader(BuildContext context, PreOrderViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF8C42), Color(0xFFFF6B35)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.dashboard_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dashboard Penjual",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Kelola semua aktivitas toko Anda",
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.storefront,
                  color: Color(0xFFFF8C42),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.currentRestaurant?.name ?? 'Memuat Toko...',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        viewModel.currentRestaurant?.description ??
                            'Kelola tokomu disini',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _showRestaurantSelector(context, viewModel),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8C42),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          "Ganti",
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        Icon(Icons.swap_horiz, size: 16, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String category) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF8C42) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: isSelected
              ? null
              : Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Text(
          category,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isPreOrder) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPreOrder
                ? Icons.calendar_month_outlined
                : Icons.restaurant_menu_outlined,
            size: 50,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            isPreOrder ? "Belum ada Pre-Order" : "Belum ada Menu",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isPreOrder
                ? "Tambahkan jadwal pre-order"
                : "Tambahkan menu pertama",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// WIDGET CHART (Fixed Height & Responsive)
// =========================================================

class SalesChartWidget extends StatelessWidget {
  final List<double> weeklySales;
  final double totalRevenue;

  const SalesChartWidget({
    super.key,
    required this.weeklySales,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Cari nilai tertinggi untuk batas atas grafik
    final double maxVal = weeklySales.isEmpty
        ? 100000
        : weeklySales.reduce((curr, next) => curr > next ? curr : next);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pendapatan 7 Hari Terakhir",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(totalRevenue),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFffe3c9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.show_chart, color: Color(0xFFFF8C42)),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // 3. PERBAIKAN: Gunakan SizedBox agar tinggi chart stabil di desktop
          SizedBox(
            height: 300, // Tinggi tetap 300px
            width: double.infinity,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: Color(0xff68737d),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        );
                        // Nama Hari (Sederhana)
                        const days = [
                          'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'
                        ];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return SideTitleWidget(
                            fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                            meta: meta,
                            child: Text(days[value.toInt()], style: style),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: maxVal == 0
                    ? 100
                    : maxVal * 1.2, // Tambah padding atas 20%
                lineBarsData: [
                  LineChartBarData(
                    spots: weeklySales
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8C42), Color(0xFFFF6B35)],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF8C42).withOpacity(0.3),
                          const Color(0xFFFF6B35).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}