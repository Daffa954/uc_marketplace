part of 'pages.dart';

class PaymentPage extends StatefulWidget {
  final OrderModel order;

  const PaymentPage({super.key, required this.order});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Timer? _pollingTimer; // Timer untuk cek otomatis

  @override
  void initState() {
    super.initState();
    
    // Setup awal saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<PaymentViewModel>(context, listen: false);
      
      // 1. Generate QR Code dari Midtrans
      vm.generateQris(widget.order);

      // 2. Mulai Polling Status (Cek tiap 5 detik)
      _startPolling(vm);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Matikan timer saat keluar halaman
    super.dispose();
  }

  // Fungsi Cek Status Otomatis
  void _startPolling(PaymentViewModel vm) {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      // Panggil API Cek Status Midtrans
      final status = await MidtransRepository().getTransactionStatus(widget.order.orderId.toString());
      
      if (status == 'settlement' || status == 'capture') {
        timer.cancel(); // Stop cek jika sudah sukses
        if (mounted) _handleSuccessPayment();
      }
    });
  }

  // Fungsi Update Database & Pindah Halaman (Dipakai Otomatis & Manual)
  Future<void> _handleSuccessPayment() async {
    try {
      // Update Status di Supabase
      await OrderRepository().updateOrderStatus(widget.order.orderId!, 'PAID'); // Bisa 'PAID' atau 'PROCESS'

      if (mounted) {
        // Tampilkan Dialog Sukses
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 60),
                SizedBox(height: 12),
                Text("Pembayaran Berhasil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              "Terima kasih! Pesanan Anda sedang diproses oleh penjual.",
              textAlign: TextAlign.center,
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); 
                    context.go('/buyer/home'); // Kembali ke Home
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7F27)),
                  child: const Text("OK", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint("Gagal update status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    const Color brandColor = Color(0xFFFF7F27);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => context.go('/buyer/home'),
        ),
      ),
      body: Consumer<PaymentViewModel>(
        builder: (context, vm, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // --- CARD TOTAL ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      const Text("Total Tagihan", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 5),
                      Text(
                        currencyFormatter.format(widget.order.total),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: brandColor),
                      ),
                      const SizedBox(height: 5),
                      Text("Order ID: #${widget.order.orderId}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                // --- QR CODE AREA ---
                if (vm.isLoading)
                  const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: brandColor)))
                else if (vm.qrString != null)
                  _buildQrSection(vm.qrString!, brandColor)
                else
                  Center(
                    child: ElevatedButton(
                      onPressed: () => vm.generateQris(widget.order),
                      child: const Text("Muat Ulang QR"),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      // --- BOTTOM BUTTON (MANUAL CHECK) ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: SafeArea(
          child: Consumer<PaymentViewModel>(
            builder: (context, vm, child) {
              return ElevatedButton(
                onPressed: (vm.qrString != null) 
                  ? () async {
                      // Manual Trigger: Tampilkan Loading -> Update Status
                      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
                      await _handleSuccessPayment();
                    }
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: const Text("Saya Sudah Membayar", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildQrSection(String qrData, Color brandColor) {
    // Generate URL Gambar QR Public
    final String publicQrImageUrl = "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${Uri.encodeComponent(qrData)}";

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              const Text("Scan QRIS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 20),
              
              // Tampilkan QR Code
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 250.0,
              ),
              
              const SizedBox(height: 20),
              
              // --- FITUR UNTUK SIMULATOR ---
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Untuk Simulator Midtrans:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 12)),
                    const SizedBox(height: 5),
                    SelectableText(publicQrImageUrl, style: const TextStyle(fontSize: 10)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 35,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: publicQrImageUrl));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link Gambar Disalin!")));
                        },
                        icon: const Icon(Icons.copy, size: 14, color: Colors.white),
                        label: const Text("Salin Link Gambar", style: TextStyle(fontSize: 12, color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, elevation: 0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text("Panduan:", style: TextStyle(fontWeight: FontWeight.bold)),
        const Text("1. Salin link gambar di atas.", style: TextStyle(fontSize: 12)),
        const Text("2. Buka link di browser & simpan gambar.", style: TextStyle(fontSize: 12)),
        const Text("3. Upload ke Simulator Midtrans.", style: TextStyle(fontSize: 12)),
        const Text("4. Jika sudah, klik tombol hijau di bawah.", style: TextStyle(fontSize: 12)),
      ],
    );
  }
}