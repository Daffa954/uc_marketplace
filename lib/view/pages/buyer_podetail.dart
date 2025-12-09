part of 'pages.dart';


class PreOrderDetailPage extends StatefulWidget {
  // Kita butuh object PreOrderModel yang dikirim dari Home
  final PreOrderModel preOrder;

  const PreOrderDetailPage({super.key, required this.preOrder});

  @override
  State<PreOrderDetailPage> createState() => _PreOrderDetailPageState();
}

class _PreOrderDetailPageState extends State<PreOrderDetailPage> {
  
  @override
  void initState() {
    super.initState();
    // Saat halaman dibuka, langsung ambil menu khusus untuk PO ini
    // Menggunakan Future.microtask agar tidak error saat build belum selesai
    Future.microtask(() {
      if (widget.preOrder.preOrderId != null) {
        Provider.of<PreOrderViewModel>(context, listen: false)
            .fetchMenusForPO(widget.preOrder.preOrderId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Logic Cek Status Open/Close
    bool isOpen = false;
    if (widget.preOrder.closeOrderDate != null) {
      final closeDate = DateTime.parse(
          "${widget.preOrder.closeOrderDate} ${widget.preOrder.closeOrderTime ?? '00:00:00'}");
      isOpen = DateTime.now().isBefore(closeDate);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      // Menggunakan Stack agar tombol Back bisa melayang di atas gambar
      body: Stack(
        children: [
          // --- KONTEN UTAMA (Scrollable) ---
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Image
                Image.network(
                  "https://placehold.co/600x400/png?text=${Uri.encodeComponent(widget.preOrder.name)}",
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    // Efek melengkung ke atas sedikit
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  transform: Matrix4.translationValues(0.0, -24.0, 0.0), // Geser naik
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Judul & Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.preOrder.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isOpen ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isOpen ? "OPEN PO" : "CLOSED",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 3. Info Waktu (Card Kecil)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoItem(
                              Icons.calendar_today, 
                              "Batas Order", 
                              widget.preOrder.closeOrderDate ?? "-"
                            ),
                            Container(width: 1, height: 30, color: Colors.grey[300]),
                            _buildInfoItem(
                              Icons.access_time_filled, 
                              "Jam Tutup", 
                              "${widget.preOrder.closeOrderTime?.substring(0,5)} WIB"
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      const Text(
                        "Menu Tersedia",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // 4. Grid Menu (Dari ViewModel)
                     Consumer<PreOrderViewModel>(
                        builder: (context, poVM, child) {
                          if (poVM.isLoading) {
                            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF7F27)));
                          }

                          if (poVM.selectedPOMenus.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(30.0),
                                child: Text("Belum ada menu di PO ini."),
                              ),
                            );
                          }

                          // MENGGUNAKAN LISTVIEW (Bukan GridView lagi)
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: poVM.selectedPOMenus.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12), // Jarak antar kartu
                            itemBuilder: (context, index) {
                              final menu = poVM.selectedPOMenus[index];
                              
                              // Panggil Widget Horizontal Card
                              return PreOrderMenuHorizontalCard(
                                menu: menu,
                                onTap: () {
                                  // Navigasi ke Halaman Detail Menu
                                  // Pastikan route ini sudah didaftarkan (Lihat langkah 3)
                                  context.push('/buyer/menu-detail', extra: menu);
                                },
                                onAddTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("${menu.name} ditambahkan (+1)")),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      
                      // Space bawah agar tidak tertutup
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- TOMBOL BACK (Floating) ---
          Positioned(
            top: 50,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => context.pop(),
              ),
            ),
          ),
        ],
      ),
      
      // --- FLOATING ACTION BUTTON (Keranjang) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isOpen ? () {
          // Aksi checkout
        } : null, // Disable jika closed
        backgroundColor: isOpen ? const Color(0xFFFF7F27) : Colors.grey,
        icon: const Icon(Icons.shopping_cart, color: Colors.white),
        label: const Text("Lihat Keranjang", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}