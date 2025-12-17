part of 'package:uc_marketplace/view/pages/pages.dart';

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {

  String selectedCategory = 'PRE-ORDER'; 

  @override
  void initState() {
    super.initState();
    // 2. Fetch both PreOrders and Menus when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PreOrderViewModel>().initSellerDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PreOrderViewModel>();

    final bool isPreOrderTab = selectedCategory == 'PRE-ORDER';

    return Scaffold(
      body: Column(
        children: [
          // Top Image Section
          Container(
            height: 250,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/banner.png'), // Use your banner image
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Business Info Section (White background)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.currentRestaurant?.name ?? 'No name available',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  viewModel.currentRestaurant?.description ?? 'No description available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          
          // Orange Section with Tabs and Products
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFffe3c9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Category Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCategoryTab('PRE-ORDER'),
                        _buildCategoryTab('MENU')
                      ],
                    ),
                  ),
                  
                  // PreOrder List (Using ViewModel)
                  Expanded(
                    child: viewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            // Check which list length to use
                            itemCount: isPreOrderTab 
                                ? viewModel.preOrders.length 
                                : viewModel.menus.length,
                            itemBuilder: (context, index) {
                              if (isPreOrderTab) {
                                // Show PreOrder Item
                                return PreOrderItem(
                                  preOrder: viewModel.preOrders[index],
                                );
                              } else {
                                // Show Menu Item (ProductItem)
                                return ProductItem(
                                  menu: viewModel.menus[index],
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
      
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedCategory == 'PRE-ORDER') {
            // Navigate to PO Form
            context.go('/seller/home/po-form'); 
          } else {
            // Navigate to Menu Form
            context.go('/seller/home/menu-form', extra: null);
          }
        },
        backgroundColor: const Color(0xFFFF8C42),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryTab(String category) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Column(
        children: [
          Text(
            category,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xFF593A1D),
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 2,
              width: 40,
              color: const Color(0xFF593A1D),
            ),
        ],
      ),
    );
  }
}

// Separate widget for product items
class PreOrderItem extends StatelessWidget {
  final PreOrderModel preOrder;

  const PreOrderItem({
    super.key,
    required this.preOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12), // Increased padding slightly
      decoration: BoxDecoration(
        color: Colors.white, // Changed to white to pop against the orange bg
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Placeholder (Since PreOrderModel doesn't have an image url)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.calendar_month, color: Color(0xFFFF8C42)),
          ),
          const SizedBox(width: 12),

          // PreOrder Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Name
                Text(
                  preOrder.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // 2. Open Order Date & Time
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Open: ${preOrder.orderDate ?? '-'} ${preOrder.orderTime ?? ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // 3. Close Order Date & Time
                Row(
                  children: [
                    const Icon(Icons.access_time_filled, size: 14, color: Colors.redAccent),
                    const SizedBox(width: 4),
                    Text(
                      'Close: ${preOrder.closeOrderDate ?? '-'} ${preOrder.closeOrderTime ?? ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final MenuModel menu;

  const ProductItem({
    super.key,
    required this.menu,
  });

  // Helper to format currency manually if you don't use the intl package
  String _formatCurrency(int price) {
    // Simple manual formatting. 
    // Ideally use NumberFormat.currency from 'intl' package if available.
    String priceStr = price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return 'Rp. $priceStr,00';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white, // Changed to white for better contrast
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/image1.png', // Hardcoded as requested
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[300],
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  menu.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  menu.description ?? 'No description available',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                // Price
                Text(
                  _formatCurrency(menu.price),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}