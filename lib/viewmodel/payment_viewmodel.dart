import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uc_marketplace/repository/payment_repository.dart';

class PaymentViewModel with ChangeNotifier {
  final _repo = PaymentRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> submitPaymentProof(int orderId, XFile imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Upload File & Dapat URL
      final String proofUrl = await _repo.uploadPaymentProof(orderId, imageFile);

      // 2. Buat Record Pembayaran (PANGGIL FUNGSI BARU)
      await _repo.createPaymentRecord(
        orderId: orderId, 
        proofUrl: proofUrl,
        method: 'TRANSFER' // Hardcode atau ambil dari parameter
      );

    } catch (e) {
      debugPrint("Payment Error: $e");
      rethrow; 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}