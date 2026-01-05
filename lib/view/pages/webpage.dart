import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransWebviewPage extends StatefulWidget {
  final String url;

  const MidtransWebviewPage({super.key, required this.url});

  @override
  State<MidtransWebviewPage> createState() => _MidtransWebviewPageState();
}

class _MidtransWebviewPageState extends State<MidtransWebviewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi WebViewController (Format WebView Flutter Terbaru v4.x)
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            // LOGIKA PENTING: Deteksi jika pembayaran selesai
            // Biasanya Midtrans akan redirect ke URL tertentu jika sukses/gagal
            // Anda bisa menyesuaikan logic ini.
            
            // Contoh: Jika URL mengandung kata 'success' atau 'status_code=200'
            // Kita anggap user sudah selesai bayar, lalu tutup webview.
            if (request.url.contains('status_code=200') || 
                request.url.contains('transaction_status=settlement') ||
                request.url.contains('success')) {
              
              Navigator.pop(context, "SUCCESS"); // Kirim sinyal sukses ke halaman sebelumnya
              return NavigationDecision.prevent; // Jangan lanjut load URL itu
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selesaikan Pembayaran"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF7F27)),
            ),
        ],
      ),
    );
  }
}