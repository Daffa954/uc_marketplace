part of 'pages.dart';

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
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

  void _showRestaurantSelector(PreOrderViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return RestaurantSelectorSheet(
          ownedRestaurants: viewModel.ownedRestaurants,
          currentRestaurant: viewModel.currentRestaurant,
          onSelect: (resto) => viewModel.changeRestaurant(resto),
          onAddSuccess: _fetchData,
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
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.storefront, color: Color(0xFFFF8C42), size: 28),
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 1. HERO HEADER
              SellerHeroHeader(
                currentRestaurant: viewModel.currentRestaurant,
                onSwitchTap: () => _showRestaurantSelector(viewModel),
              ),

              // 2. KONTEN
              Container(
                width: double.infinity,
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
                    if (!viewModel.isLoading &&
                        viewModel.currentRestaurant != null)
                      DashboardSummarySection(
                        todayOrders: viewModel.todayOrders,
                        todayRevenue: viewModel.todayRevenue,
                        totalRevenue: viewModel.totalRevenue,
                      ),
                    // --- CHART ---
                    if (!viewModel.isLoading &&
                        viewModel.currentRestaurant != null)
                      SalesChartWidget(
                        weeklySales: viewModel.weeklySales,
                        totalRevenue: viewModel.totalRevenue,
                      ),

                    // --- TABS ---
                    DashboardCategoryTabs(
                      selectedCategory: selectedCategory,
                      onCategoryChanged: (cat) =>
                          setState(() => selectedCategory = cat),
                    ),

                    // --- LIST DATA ---
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
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: dataList.length,
                            separatorBuilder: (ctx, i) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              if (isPreOrderTab) {
                                return PreOrderDCard(
                                  preOrder: viewModel.preOrders[index],
                                  onTap: () {
                                    // Navigasi ke route 'po-detail' dengan membawa object PO
                                    context.go(
                                      '/seller/home/po-detail',
                                      extra: viewModel.preOrders[index],
                                    );
                                  },
                                );
                              } else {
                                return GestureDetector(
                                  onTap: () {
                                    context.go(
                                      '/seller/home/menu-detail',
                                      extra: viewModel.menus[index],
                                    );
                                  },
                                  child: MenuItemDCard(
                                    menu: viewModel.menus[index],
                                    onEdit: () {
                                      // Edit tetap ke menu-form
                                      context.go(
                                        '/seller/home/menu-form',
                                        extra: viewModel.menus[index],
                                      );
                                    },
                                  ),
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

  // Widget Helper kecil bisa tetap disini atau dipisah juga
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
