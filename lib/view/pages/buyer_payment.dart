part of 'pages.dart';

class PaymentPage extends StatefulWidget {
  final int orderId;
  final double totalAmount;
  final int restaurantId;

  const PaymentPage({
    super.key,
    required this.orderId,
    required this.totalAmount,
    required this.restaurantId,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // State Data Restoran
  RestaurantModel? _restaurant;
  bool _isLoadingResto = true;

  
  XFile? _imageFile; 
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchRestaurantData();
  }

  Future<void> _fetchRestaurantData() async {
    final repo = RestaurantRepository();
    final data = await repo.getRestaurantById(widget.restaurantId);
    
    if (mounted) {
      setState(() {
        _restaurant = data;
        _isLoadingResto = false;
      });
    }
  }

  // [PERBAIKAN 2] Simpan langsung ke XFile
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() => _imageFile = image);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Nomor rekening disalin!"), duration: Duration(seconds: 1)),
    );
  }

  // ... kode sebelumnya ...

  void _submitPayment() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap upload bukti transfer!"), backgroundColor: Colors.red),
      );
      return;
    }

    // 1. Panggil ViewModel (Pastikan sudah didaftarkan di MultiProvider main.dart)
    final paymentVM = Provider.of<PaymentViewModel>(context, listen: false);

    // Set UI loading manual (opsional, karena tombol sudah pakai VM.isLoading)
    setState(() => _isUploading = true);

    try {
      // 2. PROSES UPLOAD
      await paymentVM.submitPaymentProof(widget.orderId, _imageFile!);

      if (!mounted) return;
      
      // 3. SUKSES
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          content: const Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.verified, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text("Pembayaran Dikirim!"),
            Text("Admin akan memverifikasi bukti Anda.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
          ]),
          actions: [
            TextButton(
              onPressed: () {
      Navigator.of(ctx).pop(); // 1. Tutup Dialog (Hapus Overlay)
      context.go('/buyer/home'); // 2. Pindah Halaman
    },
              child: const Text("OK")
            ),
          ],
        ),
      );

    } catch (e) {
      // 4. ERROR
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal upload: $e"), backgroundColor: Colors.red),
      );
    } finally {
       if (mounted) setState(() => _isUploading = false);
    }
  }

  // ... rest of code ...

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pembayaran", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => context.go('/buyer/home'),
        ),
      ),
      body: _isLoadingResto
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7F27)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER TOTAL ---
                  Center(
                    child: Column(
                      children: [
                        const Text("Total Tagihan", style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormatter.format(widget.totalAmount),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFF7F27)),
                        ),
                        const SizedBox(height: 8),
                        Text("Order ID: #${widget.orderId}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- INFO REKENING ---
                  const Text("Silahkan transfer ke:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  if (_restaurant != null && _restaurant!.bankAccount != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50, height: 35,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.blue[900], borderRadius: BorderRadius.circular(4)),
                            child: const Text("BANK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_restaurant!.name, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1),
                                const SizedBox(height: 4),
                                Text(_restaurant!.bankAccount!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _copyToClipboard(_restaurant!.bankAccount!),
                            icon: const Icon(Icons.copy, color: Color(0xFFFF7F27)),
                          )
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                      child: const Text("Data rekening restoran tidak tersedia.", style: TextStyle(color: Colors.red)),
                    ),

                  const SizedBox(height: 24),

                  // --- UPLOAD BUKTI ---
                  const Text("Upload Bukti Transfer", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              
                              // [PERBAIKAN 3] Logic Render Gambar (Web vs Mobile)
                              // Kita gunakan 'kIsWeb' (dari flutter/foundation.dart) 
                              // Import 'dart:io' tetap dibutuhkan untuk File() di mobile.
                              child: kIsWeb
                                  ? Image.network(
                                      _imageFile!.path, // Di Web, path ini adalah Blob URL
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_imageFile!.path), // Di Mobile, ini Path File System
                                      fit: BoxFit.cover,
                                    ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text("Tap untuk upload gambar", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                    ),
                  ),
                  
                  if (_imageFile != null)
                    Center(
                      child: TextButton(onPressed: _pickImage, child: const Text("Ganti Gambar")),
                    )
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          onPressed: _isUploading ? null : _submitPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF7F27),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isUploading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("Konfirmasi Pembayaran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}