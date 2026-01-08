import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/repository/midtrans_repository.dart';
import 'package:uc_marketplace/repository/payment_repository.dart';

class PaymentViewModel with ChangeNotifier {
  final _repo = PaymentRepository();
  final _midtransRepo = MidtransRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> submitPaymentProof(int orderId, XFile imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Upload File & Dapat URL
      final String proofUrl = await _repo.uploadPaymentProof(
        orderId,
        imageFile,
      );

      // 2. Buat Record Pembayaran (PANGGIL FUNGSI BARU)
      await _repo.createPaymentRecord(
        orderId: orderId,
        proofUrl: proofUrl,
        method: 'TRANSFER', // Hardcode atau ambil dari parameter
      );
    } catch (e) {
      debugPrint("Payment Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? _qrString;
  String? get qrString => _qrString;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Fungsi Utama: Generate QRIS
  Future<void> generateQris(OrderModel order) async {
    _isLoading = true;
    _errorMessage = null;
    _qrString = null; // Reset QR lama
    notifyListeners();

    try {
      final result = await _midtransRepo.chargeQris(order: order);

      if (result != null) {
        _qrString = result;
      } else {
        _errorMessage = "Gagal mendapatkan kode QR dari Midtrans.";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ... kode sebelumnya ...
  
  Timer? _timer;

  // Mulai pengecekan otomatis
  void startPollingStatus(int orderId, VoidCallback onSuccess) {
    _timer?.cancel(); // Reset timer lama jika ada
    
    // Cek setiap 5 detik
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final status = await _midtransRepo.getTransactionStatus(orderId.toString());
      
      // Jika status SUKSES (settlement / capture)
      if (status == 'settlement' || status == 'capture') {
        timer.cancel(); // Hentikan timer
        onSuccess(); // Panggil callback sukses
      }
    });
  }

  // Hentikan timer saat keluar halaman
  void stopPolling() {
    _timer?.cancel();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
