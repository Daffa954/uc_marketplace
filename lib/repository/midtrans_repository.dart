import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/shared/shared.dart';
import '../model/model.dart';

class MidtransRepository {
  final _supabase = Supabase.instance.client;

  // Ganti dengan SERVER KEY SANDBOX Anda dari Dashboard Midtrans
  // Jangan lupa tambahkan titik dua (:) di akhir saat encode base64 nanti

  static const String _coreApiUrl =
      "https://api.sandbox.midtrans.com/v2/charge";

  /// Request Generate QRIS (Core API)
  /// Mengembalikan String QR Code (bukan URL gambar, tapi raw string)
  Future<String?> chargeQris({required OrderModel order}) async {
    try {
      // 1. Ambil Server Key dari Const
      String serverKey =
          Const.midtrans_key; // Pastikan ini Server Key, bukan Client Key
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$serverKey:'))}';

      // 2. Susun Body Request untuk QRIS
      Map<String, dynamic> body = {
        "payment_type": "qris",
        "transaction_details": {
          // Order ID harus unik. Tambah timestamp agar tidak error "Duplicate Order ID" saat tes ulang
          "order_id":
              "QRIS-${order.orderId}-${DateTime.now().millisecondsSinceEpoch}",
          "gross_amount": order.total,
        },
        "qris": {
          "acquirer":
              "gopay", // Penyedia QRIS (di Sandbox pakai gopay sbg emulator)
        },
      };

      // 3. Handle CORS Proxy (Khusus Web)
      String finalUrl = _coreApiUrl;
      if (kIsWeb) {
        finalUrl = "https://cors-anywhere.herokuapp.com/$_coreApiUrl";
      }

      // 4. Kirim Request
      final response = await http.post(
        Uri.parse(finalUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": basicAuth,
          "X-Requested-With": "XMLHttpRequest", // Header wajib buat Proxy
        },
        body: jsonEncode(body),
      );

      // 5. Cek Response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Ambil 'qr_string' (Data mentah QR Code)
        // Midtrans kadang mengembalikan 'actions' kadang langsung field.
        // Di Core API v2 biasanya ada di field 'qr_string' atau 'actions'.

        if (data.containsKey('qr_string')) {
          return data['qr_string'];
        }
        // Fallback untuk struktur respon lain (Gopay deep link)
        else if (data.containsKey('actions')) {
          List actions = data['actions'];
          var qrAction = actions.firstWhere(
            (e) => e['name'] == 'generate-qr-code',
            orElse: () => null,
          );
          return qrAction?['url'];
        }

        return null;
      } else {
        throw Exception(
          "Gagal QRIS (${response.statusCode}): ${response.body}",
        );
      }
    } catch (e) {
      debugPrint("Error Core API: $e");
      rethrow;
    }
  }

  /// 2. Update Order di Supabase dengan Link Pembayaran
  Future<void> updateOrderPaymentData(
    int orderId,
    String snapToken,
    String paymentUrl,
  ) async {
    try {
      await _supabase
          .from('orders')
          .update({
            'snap_token': snapToken,
            'payment_url': paymentUrl,
            // Status tetap PENDING sampai user bayar
          })
          .eq('order_id', orderId);
    } catch (e) {
      rethrow;
    }
  }
static const String _baseUrl = "https://api.sandbox.midtrans.com/v2";
  // [BARU] Cek Status Transaksi Manual
  Future<String> getTransactionStatus(String orderId) async {
    String serverKey = Const.midtrans_key;
   final url = Uri.parse('$_baseUrl/$orderId/status'); 

  final String basicAuth = 'Basic ${base64Encode(utf8.encode('$serverKey:'))}';
   

    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json', 'Authorization': basicAuth},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // transaction_status bisa: settlement, capture, pending, deny, expire, cancel
        return data['transaction_status'] ?? 'unknown';
      } else {
        return 'error';
      }
    } catch (e) {
      return 'error';
    }
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': newStatus})
          .eq('order_id', orderId);
    } catch (e) {
      throw Exception("Gagal update status: $e");
    }
  }
}
