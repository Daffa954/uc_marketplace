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

// --- WIDGET KARTU PESANAN (PERBAIKAN) ---
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Format Tanggal
    String dateStr = "-";
    if (order.createdAt != null) {
      try {
        final date = DateTime.parse(order.createdAt!).toLocal();
        dateStr = DateFormat('dd MMM yyyy, HH:mm').format(date);
      } catch (_) {}
    }

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

    // [FIX 1] Bungkus dengan InkWell agar seluruh kartu bisa diklik untuk detail
    return InkWell(
      onTap: () => _showDetailBottomSheet(context, currencyFormatter),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Order #${order.orderId}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(dateStr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6)
                  ),
                  child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const Divider(height: 24),

            // Footer
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Tagihan", style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(currencyFormatter.format(order.total),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF7F27))),
                    ],
                  ),
                ),
                
                // [FIX 2] Tombol Detail Selalu Muncul (TextButton)
                TextButton(
                  onPressed: () => _showDetailBottomSheet(context, currencyFormatter),
                  child: const Text("Detail", style: TextStyle(color: Colors.grey)),
                ),

                // Tombol Bayar (Hanya jika PENDING)
                if (order.status == 'PENDING') ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.pushNamed('payment',
                          pathParameters: {'orderId': order.orderId.toString()},
                          extra: order);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7F27),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      minimumSize: const Size(0, 36)
                    ),
                    child: const Text("Bayar", style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIC BOTTOM SHEET (YANG PASTI MUNCUL) ---
  void _showDetailBottomSheet(BuildContext context, NumberFormat currencyFormatter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Penting agar bisa full height
      backgroundColor: Colors.transparent, // Transparan agar rounded corner terlihat
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75, // 75% Tinggi Layar
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle Bar (Garis kecil di atas)
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header Sheet
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Detail Order #${order.orderId}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
              const Divider(height: 1),

              // List Items (Scrollable)
              Expanded(
                child: (order.items == null || order.items!.isEmpty)
                    ? const Center(child: Text("Tidak ada detail item."))
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: order.items!.length,
                        separatorBuilder: (c, i) => const Divider(height: 24),
                        itemBuilder: (context, index) {
                          final item = order.items![index];
                          // Validasi harga
                          final double itemPrice = double.tryParse(item.price.toString()) ?? 0;
                          final int itemQty = item.quantity ?? 1;
                          final double itemTotal = itemPrice * itemQty;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Gambar Menu
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.menu?.image ?? "https://placehold.co/100x100", 
                                  width: 60, height: 60, fit: BoxFit.cover,
                                  errorBuilder: (ctx, _, __) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.fastfood, color: Colors.grey)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Info Menu
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.menu?.name ?? "Menu #${item.menuId}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      maxLines: 2, overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${itemQty}x  ${currencyFormatter.format(itemPrice)}",
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Total per Item
                              Text(
                                currencyFormatter.format(itemTotal),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          );
                        },
                      ),
              ),

              // Footer Sheet: Grand Total
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Pembayaran", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(currencyFormatter.format(order.total),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF7F27))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}