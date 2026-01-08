part of 'pages.dart';

class CheckoutPage extends StatefulWidget {
  final PreOrderModel preOrder;
  final List<MenuModel> rawItems;
  final List<PoPickupModel> pickupList;

  const CheckoutPage({
    super.key,
    required this.preOrder,
    required this.rawItems,
    required this.pickupList,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // State UI
  List<CartItem> _cartItems = [];
  String _selectedDelivery = "Pick up";
  PoPickupModel? _selectedPickup;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default pilih lokasi pertama jika ada
    if (widget.pickupList.isNotEmpty) {
      _selectedPickup = widget.pickupList.first;
    }
    _groupItems();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // --- LOGIC UI: GROUPING ITEM ---
  void _groupItems() {
    final Map<int, CartItem> grouped = {};
    for (var menu in widget.rawItems) {
      if (menu.menuId == null) continue;
      if (grouped.containsKey(menu.menuId)) {
        grouped[menu.menuId]!.quantity++;
      } else {
        grouped[menu.menuId!] = CartItem(menu: menu);
      }
    }
    setState(() => _cartItems = grouped.values.toList());
  }

  // --- LOGIC UI: UPDATE QTY ---
  void _increment(int index) => setState(() => _cartItems[index].quantity++);

  void _decrement(int index) {
    setState(() {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems.removeAt(index);
        // Jika keranjang kosong, kembali ke halaman sebelumnya
        if (_cartItems.isEmpty) context.pop();
      }
    });
  }

  // --- LOGIC UI: TOTAL HARGA (Hanya untuk Display) ---
  double get _uiTotalPrice {
    double total = 0;
    for (var item in _cartItems) {
      double price = double.tryParse(item.menu.price.toString()) ?? 0;
      total += price * item.quantity;
    }
    return total;
  }

  // --- LOGIC UTAMA: PROCESS PAYMENT (SANGAT BERSIH) ---
  void _processPayment() async {
    // 1. Panggil ViewModel
    final orderVM = Provider.of<OrderViewModel>(context, listen: false);
final int finalTotal = _uiTotalPrice.toInt();
    final int? newOrderId = await orderVM.submitOrder(
      preOrderId: widget.preOrder.preOrderId!,
      cartItems: _cartItems,
      deliveryMode: _selectedDelivery,
      pickupLocation: _selectedPickup,
      userNote: _noteController.text,
    );

    // 3. Handle Respon UI
    if (!mounted) return;

    if (newOrderId != null) {
      // SUKSES
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text("Order Berhasil Dibuat!"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Tutup Dialog

                // [PERBAIKAN UTAMA DISINI]
                // Kita harus menyusun object OrderModel manual untuk dikirim ke PaymentPage
                // agar state.extra di AppRouter tidak null.
                
                final newOrder = OrderModel(
                  orderId: newOrderId,
                  total: finalTotal, // Pastikan tipe data int
                  status: 'PENDING', // Default status awal
                  // Field lain bisa dikosongkan/null jika tidak dipakai di PaymentPage
                );

                // Navigasi menggunakan 'extra'
                context.pushReplacementNamed(
                  'payment',
                  pathParameters: {'orderId': newOrderId.toString()},
                  extra: newOrder, // <--- KIRIM OBJECT DISINI
                );
              },
              child: const Text("Bayar Sekarang"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi Kesalahan"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // --- MODAL SELECTOR LOKASI ---
  void _showPickupSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Pilih Lokasi Pengambilan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                itemCount: widget.pickupList.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (ctx, index) {
                  final item = widget.pickupList[index];
                  bool isSelected = item == _selectedPickup;

                  // Ambil gambar pertama atau placeholder
                  String imgUrl =
                      (item.photoLocation != null &&
                          item.photoLocation!.isNotEmpty)
                      ? item.photoLocation!.first
                      : "https://placehold.co/100x100?text=No+Img";

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      setState(() => _selectedPickup = item);
                      Navigator.pop(context);
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      // [PERBAIKAN] Tambahkan errorBuilder
                      child: Image.network(
                        imgUrl,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 20),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      item.address ?? "Lokasi ${index + 1}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${item.startTime?.substring(0, 5)} - ${item.endTime?.substring(0, 5)} WIB",
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFFFF7F27),
                          )
                        : null,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Helper Image URL
    String locationImage = "https://placehold.co/150x150?text=Location";

    // Cek apakah ada foto di array
    if (_selectedPickup != null &&
        _selectedPickup!.photoLocation != null &&
        _selectedPickup!.photoLocation!.isNotEmpty) {
      locationImage = _selectedPickup!.photoLocation!.first;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(
            color: Color(0xFFFF7F27),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. DELIVERY OPTIONS
                  Row(
                    children: [
                      _buildOptionBtn("Pick up"),
                      const SizedBox(width: 8),
                      
                    ],
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                      if (widget.pickupList.length > 1) _showPickupSelector();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.pickupList.length > 1
                              ? const Color(0xFFFF7F27)
                              : Colors.transparent,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            // [PERBAIKAN] Tambahkan errorBuilder
                            child: Image.network(
                              locationImage,
                              width: 170,
                              height: 170,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.map,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Lokasi Pengambilan",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (widget.pickupList.length > 1)
                                      const Text(
                                        " (Ubah)",
                                        style: TextStyle(
                                          color: Color(0xFFFF7F27),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedPickup?.address ??
                                      "Lokasi belum ditentukan",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedPickup != null
                                      ? "${_selectedPickup!.date} • ${_selectedPickup!.startTime?.substring(0, 5)} - ${_selectedPickup!.endTime?.substring(0, 5)}"
                                      : "-",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.pickupList.length > 1)
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. LIST ITEM
                  const Text(
                    "List Items",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _cartItems.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 30),
                    itemBuilder: (context, index) => _buildCartItemCard(index),
                  ),

                  const SizedBox(height: 24),

                  // 4. CATATAN PESANAN
                  const Text(
                    "Catatan Pesanan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText:
                          "Contoh: Jangan terlalu pedas, bungkus terpisah...",
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // 6. BOTTOM TOTAL & BUTTON
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // Gunakan _uiTotalPrice untuk tampilan
                    Text(
                      "Rp ${_uiTotalPrice.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Consumer<OrderViewModel>(
                  builder: (context, orderVM, child) {
                    return ElevatedButton(
                      // Matikan tombol jika VM sedang loading
                      onPressed: orderVM.isLoading
                          ? null
                          : () => _processPayment(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7F27),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: orderVM.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Place Order",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildOptionBtn(String label) {
    bool isSelected = _selectedDelivery == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDelivery = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF7F27) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartItemCard(int index) {
    final item = _cartItems[index];
    
    // Pastikan URL valid, jika null/kosong pakai placeholder
    String imageUrl = item.menu.image ?? "";
    if (imageUrl.isEmpty) {
      imageUrl = "https://placehold.co/100x100?text=No+Img";
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- GAMBAR MENU (DIPERBAIKI) ---
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            // [FIX] Handle error jika URL mati / CORS block
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 80, 
                height: 80, 
                color: Colors.grey[300],
                child: const Icon(Icons.fastfood, color: Colors.grey),
              );
            },
            // [FIX] Tampilkan loading saat gambar sedang diambil
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 80, height: 80,
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / 
                          loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(width: 12),
        // ... Sisa kode Text/Column tetap sama ...
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.menu.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() {
                      _cartItems.removeAt(index);
                      if (_cartItems.isEmpty) context.pop();
                    }),
                    child: const Icon(Icons.cancel, color: Colors.red, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Convert Enum/String type to readable text
              Text(
                item.menu.type.toString().split('.').last,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(height: 8),
              Text(
                "Rp ${item.menu.price}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => _decrement(index),
                    child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.remove, size: 18)),
                  ),
                  Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: () => _increment(index),
                    child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.add, size: 18)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
