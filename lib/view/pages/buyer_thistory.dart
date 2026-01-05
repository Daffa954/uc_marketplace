part of 'pages.dart';

class HistoryOrderPage extends StatefulWidget {
  const HistoryOrderPage({super.key});

  @override
  State<HistoryOrderPage> createState() => _HistoryOrderPageState();
}

class _HistoryOrderPageState extends State<HistoryOrderPage> {
  @override
  void initState() {
    super.initState();
    // Fetch data saat halaman dibuka
   WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryViewModel>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text("Pesanan Saya", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          bottom: const TabBar(
            labelColor: Color(0xFFFF7F27),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFFF7F27),
            tabs: [
              Tab(text: "Berlangsung"),
              Tab(text: "Riwayat"),
            ],
          ),
        ),
        body: Consumer<HistoryViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFFF7F27)));
            }

            return TabBarView(
              children: [
                _buildOrderList(vm.activeOrders, true),
                _buildOrderList(vm.pastOrders, false),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Widget List ---
  Widget _buildOrderList(List<OrderModel> orders, bool isActiveTab) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              isActiveTab ? "Belum ada pesanan aktif" : "Belum ada riwayat pesanan",
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<HistoryViewModel>(context, listen: false).fetchOrders();
      },
      color: const Color(0xFFFF7F27),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: 16),
        itemBuilder: (ctx, index) {
          return _OrderCard(order: orders[index]);
        },
      ),
    );
  }
}

// --- Widget Kartu Pesanan ---
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    // Ambil item pertama sebagai highlight (Contoh: "Nasi Goreng & 2 menu lainnya")
    String title = "Pesanan #${order.orderId}";
    String subtitle = "Menunggu info menu...";
    String imageUrl = "https://placehold.co/100x100";

    if (order.items != null && order.items!.isNotEmpty) {
      final firstItem = order.items!.first;
      // Karena join di repo, kita akses menu via nested object jika model sudah support
      // Atau gunakan logika sederhana ini:
      title = firstItem.menu?.name ?? "Menu #${firstItem.menuId}";
      
      if (order.items!.length > 1) {
        subtitle = "+ ${order.items!.length - 1} menu lainnya";
      } else {
        subtitle = "${firstItem.quantity} pcs";
      }

      if (firstItem.menu?.image != null) {
        imageUrl = firstItem.menu!.image!;
      }
    }

    // Warna status
    Color statusColor;
    String statusText;
    switch (order.status) {
      case 'PENDING': statusColor = Colors.orange; statusText = "Menunggu Bayar"; break;
      case 'PAID': statusColor = Colors.blue; statusText = "Dibayar"; break;
      case 'PROCESS': statusColor = Colors.blue; statusText = "Diproses"; break;
      case 'SHIPPING': statusColor = Colors.blue; statusText = "Siap Diambil"; break;
      case 'COMPLETED': statusColor = Colors.green; statusText = "Selesai"; break;
      case 'CANCELLED': statusColor = Colors.red; statusText = "Dibatalkan"; break;
      default: statusColor = Colors.grey; statusText = order.status;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Header: Tanggal & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                // Format tanggal pakai intl: DateFormat('dd MMM yyyy').format(...)
                order.createdAt != null 
                  ? order.createdAt!.substring(0, 10) 
                  : "-",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const Divider(height: 24),
          
          // Body: Gambar & Nama Menu
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                  errorBuilder: (ctx, _, __) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.fastfood, size: 20, color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Footer: Total & Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Belanja", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(currencyFormatter.format(order.total), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              
              // Tombol Action dinamis
              if (order.status == 'PENDING')
                ElevatedButton(
                  onPressed: () {
                    // Masuk ke Payment Page lagi
                    // Kita perlu kirim OrderModel
                    context.pushNamed(
                      'payment', 
                      pathParameters: {'orderId': order.orderId.toString()},
                      extra: order
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7F27),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                  child: const Text("Bayar", style: TextStyle(color: Colors.white, fontSize: 12)),
                )
              else
                 OutlinedButton(
                  onPressed: () {
                    // TODO: Arahkan ke Halaman Detail Transaksi
                    // context.push('/buyer/home/history-detail', extra: order);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(color: Colors.grey.shade300)
                  ),
                  child: const Text("Detail", style: TextStyle(color: Colors.black, fontSize: 12)),
                )
            ],
          )
        ],
      ),
    );
  }
}