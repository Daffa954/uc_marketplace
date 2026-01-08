part of 'pages.dart';

class PreOrderDetailPage extends StatefulWidget {
  final PreOrderModel preOrder;

  const PreOrderDetailPage({super.key, required this.preOrder});

  @override
  State<PreOrderDetailPage> createState() => _PreOrderDetailPageState();
}

class _PreOrderDetailPageState extends State<PreOrderDetailPage> {
  // State keranjang belanja sementara
  final List<MenuModel> _cartItems = [];

  int get _totalItems => _cartItems.length;

  double get _totalPrice {
    double total = 0;
    for (var item in _cartItems) {
      total += double.tryParse(item.price.toString()) ?? 0;
    }
    return total;
  }

  void _addToCart(MenuModel menu) {
    setState(() {
      _cartItems.add(menu);
    });
  }

  @override
  void initState() {
    super.initState();
    // Fetch Menu & Info Pickup saat halaman dibuka
    Future.microtask(() {
      if (widget.preOrder.preOrderId != null) {
        Provider.of<PreOrderViewModel>(
          context,
          listen: false,
        ).fetchMenusForPO(widget.preOrder.preOrderId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Logic Cek Status Open/Close
    bool isOpen = false;
    if (widget.preOrder.closeOrderDate != null) {
      final closeDate = DateTime.parse(
        "${widget.preOrder.closeOrderDate} ${widget.preOrder.closeOrderTime ?? '00:00:00'}",
      );
      isOpen = DateTime.now().isBefore(closeDate);
    }

    // [BARU] Ambil URL Gambar
    final String? imageUrl = widget.preOrder.image;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- 1. KONTEN UTAMA (SCROLLABLE) ---
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: 120,
            ), // Padding bawah lebih besar untuk cart
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // [PERBAIKAN] A. HEADER IMAGE (ASLI)
                SizedBox( // Bungkus dengan SizedBox agar tinggi pasti
                  width: double.infinity,
                  height: 250,
                  child: (imageUrl != null && imageUrl.isNotEmpty)
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder(); // Placeholder jika error
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(color: Color(0xFFFF7F27)),
                              ),
                            );
                          },
                        )
                      : _buildImagePlaceholder(), // Placeholder jika null
                ),

                // B. KONTEN DETAIL
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  transform: Matrix4.translationValues(
                    0.0,
                    -24.0,
                    0.0,
                  ), // Efek overlap ke atas
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Judul & Status Badge
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isOpen ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isOpen ? "OPEN PO" : "CLOSED",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 2. Info Waktu (Card Kecil)
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
                              widget.preOrder.closeOrderDate ?? "-",
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.grey[300],
                            ),
                            _buildInfoItem(
                              Icons.access_time_filled,
                              "Jam Tutup",
                              "${widget.preOrder.closeOrderTime?.substring(0, 5)} WIB",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --- 3. INFO PICKUP (BARU) ---
                      Consumer<PreOrderViewModel>(
                        builder: (context, poVM, child) {
                          final pickups = poVM.pickupList;

                          if (pickups.isEmpty) return const SizedBox.shrink();

                          final firstPickup = pickups.first;
                          final extraCount = pickups.length - 1;

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Informasi Pengambilan",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    if (extraCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          "+$extraCount Lokasi Lain",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        firstPickup.address ??
                                            "Lokasi belum ditentukan",
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${firstPickup.date ?? '-'} • ${firstPickup.startTime?.substring(0, 5)} - ${firstPickup.endTime?.substring(0, 5)} WIB",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        "Menu Tersedia",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 4. List Menu
                      Consumer<PreOrderViewModel>(
                        builder: (context, poVM, child) {
                          if (poVM.isLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(
                                  color: Color(0xFFFF7F27),
                                ),
                              ),
                            );
                          }

                          if (poVM.selectedPOMenus.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(30),
                                child: Text("Belum ada menu di PO ini."),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount: poVM.selectedPOMenus.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final menu = poVM.selectedPOMenus[index];

                              return PreOrderMenuHorizontalCard(
                                menu: menu,
                                onTap: () {
                                  context.push(
                                    '/buyer/home/menu-detail',
                                    extra: menu,
                                  );
                                },
                                onAddTap: isOpen
                                    ? () {
                                        _addToCart(menu);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "${menu.name} ditambahkan",
                                            ),
                                            duration: const Duration(
                                              milliseconds: 800,
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    : () {},
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- 2. TOMBOL BACK ---
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

          // --- 2b. TOMBOL CHAT ---
          Positioned(
            top: 50,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: Color(0xFFFF7F27),
                ),
                onPressed: () async {
                  final currentUser = Provider.of<AuthViewModel>(
                    context,
                    listen: false,
                  ).currentUser;
                  if (currentUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Silakan login terlebih dahulu"),
                      ),
                    );
                    return;
                  }

                  if (widget.preOrder.restaurantId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Info restoran tidak tersedia"),
                      ),
                    );
                    return;
                  }

                  try {
                    final restaurantRepo = RestaurantRepository();
                    final restaurant = await restaurantRepo.getRestaurantById(
                      widget.preOrder.restaurantId!,
                    );

                    if (restaurant == null || restaurant.ownerId == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Gagal memuat info toko"),
                          ),
                        );
                      }
                      return;
                    }

                    if (context.mounted) {
                      final chatVM = Provider.of<ChatViewModel>(
                        context,
                        listen: false,
                      );
                      final chatId = await chatVM.createChatWithSeller(
                        restaurant.ownerId!,
                        currentUser.userId!,
                      );

                      if (context.mounted) {
                        context.push(
                          '/buyer/chat/detail',
                          extra: {'chatId': chatId, 'title': restaurant.name},
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Gagal memulai chat: $e")),
                      );
                    }
                  }
                },
              ),
            ),
          ),

          // --- 3. BOTTOM CART CARD ---
          if (_totalItems > 0)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  final pickupList = Provider.of<PreOrderViewModel>(
                    context,
                    listen: false,
                  ).pickupList;

                  context.push(
                    '/buyer/home/checkout',
                    extra: {
                      'preOrder': widget.preOrder,
                      'items': _cartItems,
                      'pickupList': pickupList,
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7F27),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "$_totalItems",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total $_totalItems item",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "Rp ${_totalPrice.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Text(
                        "Checkout",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper Widget: Info Kecil
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  // Helper Widget: Placeholder Gambar
  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFFFF7F27).withOpacity(0.1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_not_supported_outlined, size: 50, color: Color(0xFFFF7F27)),
            const SizedBox(height: 8),
            Text(
              widget.preOrder.name, // Menampilkan nama PO sebagai fallback
              style: const TextStyle(color: Color(0xFFFF7F27), fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}