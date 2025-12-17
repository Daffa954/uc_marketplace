import 'dart:io';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class PaymentRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- 1. UPLOAD GAMBAR (Logic Tetap Sama) ---
  Future<String> uploadPaymentProof(int orderId, XFile imageFile) async {
    try {
      final fileExt = imageFile.name.split('.').last;
      final fileName = 'proof_${orderId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'payment_proofs/$fileName'; 

      // Logic Upload Web vs Mobile
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        await _supabase.storage.from('payment_proofs').uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(contentType: 'image/$fileExt'),
        );
      } else {
        await _supabase.storage.from('payment_proofs').upload(
          filePath,
          File(imageFile.path),
          fileOptions: FileOptions(contentType: 'image/$fileExt'),
        );
      }

      // Ambil Public URL
      final String publicUrl = _supabase.storage
          .from('payment_proofs')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception("Gagal upload gambar: $e");
    }
  }

  // --- 2. CREATE PAYMENT RECORD (Logic Baru) ---
  // Fungsi ini sekarang melakukan INSERT ke tabel 'payments'
  Future<void> createPaymentRecord({
    required int orderId,
    required String proofUrl,
    String method = 'TRANSFER', // Default Transfer
  }) async {
    try {
      // A. INSERT ke Tabel 'payments'
      await _supabase.from('payments').insert({
        'order_id': orderId,
        'payment_proof': proofUrl, // URL Gambar disimpan di sini
        'status': 'PENDING',       // Status pembayaran menunggu verifikasi admin/seller
        'method': method,
        'paid_at': DateTime.now().toIso8601String(),
      });

      // B. UPDATE Status di Tabel 'orders' (Opsional tapi disarankan)
      // Agar status pesanan berubah jadi "Menunggu Verifikasi"
      await _supabase.from('orders').update({
        'status': 'WAITING_VERIFICATION' 
      }).eq('order_id', orderId);

    } catch (e) {
      throw Exception("Gagal menyimpan data pembayaran: $e");
    }
  }
}