part of 'pages.dart';

class PaymentPage extends StatefulWidget {
  final OrderModel order;

  const PaymentPage({super.key, required this.order});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  void initState() {
    super.initState();
    // Auto-generate QR saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentViewModel>(context, listen: false).generateQris(widget.order);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    const Color brandColor = Color(0xFFFF7F27); // Warna Oranye Utama

    return Scaffold(
      backgroundColor: Colors.grey[50], // Background sedikit abu agar card menonjol
      appBar: AppBar(
        title: const Text(
          "Pembayaran",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- 1. HEADER SUMMARY CARD ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text("Total Pembayaran", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormatter.format(widget.order.total),
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: brandColor),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Order ID: #${widget.order.orderId}",
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700], fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- 2. QR CODE SECTION ---
                if (vm.isLoading)
                  _buildLoadingState(brandColor)
                else if (vm.errorMessage != null)
                  _buildErrorState(vm, widget.order)
                else if (vm.qrString != null)
                  _buildQrContent(vm.qrString!, brandColor)
                else
                  _buildInitialState(vm, widget.order, brandColor),

                const SizedBox(height: 30),

                // --- 3. CARA PEMBAYARAN (INSTRUCTION) ---
                if (vm.qrString != null)
                  _buildInstructionSection(),
                  
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildQrContent(String qrData, Color brandColor) {
    return Column(
      children: [
        // Title Section
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, color: Colors.blue[800], size: 20),
            const SizedBox(width: 8),
            const Text("QRIS Payment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 16),

        // QR Frame Container
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              // Logo Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _paymentIconPlaceholder("GoPay", Colors.blue),
                  const SizedBox(width: 8),
                  _paymentIconPlaceholder("OVO", Colors.purple),
                  const SizedBox(width: 8),
                  _paymentIconPlaceholder("Dana", Colors.blueAccent),
                  const SizedBox(width: 8),
                  const Text("& Lainnya", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 24), // Padding diperbesar sedikit
              
              // --- THE ACTUAL QR CODE (LEBIH BESAR) ---
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 280.0, // <--- UKURAN DIPERBESAR (dari 220)
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(0), // Hilangkan padding default agar maksimal
              ),
              
              const SizedBox(height: 24),
              const Text(
                "Scan QR di atas",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Menerima semua aplikasi pembayaran",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 20),
              
              // --- TOMBOL DOWNLOAD QR (BARU) ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Logika Download Gambar QR
                    // (Untuk saat ini simulasi pakai SnackBar)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("QR Code berhasil disimpan ke Galeri! (Simulasi)"),
                        backgroundColor: Colors.green,
                      )
                    );
                    
                    // CATATAN UNTUK DEVELOPER:
                    // Untuk download gambar beneran, Anda perlu:
                    // 1. Wrap QrImageView dengan widget 'RepaintBoundary' + GlobalKey.
                    // 2. Convert boundary jadi image (dart:ui).
                    // 3. Convert image jadi bytes (PNG).
                    // 4. Pakai package 'image_gallery_saver' untuk simpan ke galeri.
                    // Ini cukup rumit untuk fitur MVP tambahan, jadi simulasi SnackBar sudah cukup baik.
                  },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text("Simpan Gambar QR"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: brandColor,
                    side: BorderSide(color: brandColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: Border.all(color: Colors.transparent), // Hilangkan border default expansion
        leading: const Icon(Icons.help_outline, color: Colors.grey),
        title: const Text("Cara Pembayaran", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _stepItem("1", "Buka aplikasi E-Wallet (GoPay, OVO, Dana) atau Mobile Banking Anda."),
                _stepItem("2", "Pilih menu 'Scan' atau 'Bayar'."),
                _stepItem("3", "Arahkan kamera ke kode QR di atas."),
                _stepItem("4", "Periksa nama merchant & nominal, lalu bayar."),
                _stepItem("5", "Klik tombol 'Saya Sudah Membayar' di bawah."),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(Color color) {
    return Container(
      height: 300,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: color),
          const SizedBox(height: 20),
          const Text("Sedang membuat QR Code...", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorState(PaymentViewModel vm, OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 12),
          Text(vm.errorMessage ?? "Error", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => vm.generateQris(order),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Coba Lagi", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildInitialState(PaymentViewModel vm, OrderModel order, Color color) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => vm.generateQris(order),
        icon: const Icon(Icons.refresh, color: Colors.white),
        label: const Text("Muat Ulang QR", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: color),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Consumer<PaymentViewModel>(
          builder: (context, vm, child) {
            // Disable tombol jika QR belum muncul
            bool isEnabled = vm.qrString != null;
            
            return ElevatedButton(
              onPressed: isEnabled ? _showSuccessDialog : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                "Saya Sudah Membayar",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            );
          }
        ),
      ),
    );
  }

  // Helper kecil untuk bullet point instruksi
  Widget _stepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$number. ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.4))),
        ],
      ),
    );
  }

  // Placeholder icon buat visualisasi saja
  Widget _paymentIconPlaceholder(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3))
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 12),
            Text("Verifikasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Sistem sedang mengecek pembayaran Anda. Mohon tunggu notifikasi selanjutnya.\n\n(Sandbox: Pastikan sudah scan di Simulator).",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/buyer/home');
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFF7F27),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              child: const Text("Kembali ke Beranda"),
            ),
          ),
        ],
      ),
    );
  }
}