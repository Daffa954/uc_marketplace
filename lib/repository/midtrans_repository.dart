import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/shared/shared.dart';
import '../model/model.dart';

class MidtransRepository {
  final _supabase = Supabase.instance.client;

  // Base URL API (Tanpa /charge)
  static const String _baseUrl = "https://api.sandbox.midtrans.com/v2";

  /// 1. Request Generate QRIS (Core API)
  Future<String?> chargeQris({required OrderModel order}) async {
    try {
      String serverKey = Const.midtrans_key; 
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$serverKey:'))}';

      // Endpoint Charge
      String finalUrl = "$_baseUrl/charge";
      
      // Handle CORS Proxy (Khusus Web)
      if (kIsWeb) {
        finalUrl = "https://cors-anywhere.herokuapp.com/$finalUrl";
      }

      Map<String, dynamic> body = {
        "payment_type": "qris",
        "transaction_details": {
          // [FIX] Gunakan ID Asli saja agar sinkron dengan Polling Status
          // Hapus timestamp prefix jika ingin polling berjalan lancar untuk testing
          "order_id": order.orderId.toString(), 
          "gross_amount": order.total,
        },
        "qris": {
          "acquirer": "gopay",
        },
      };

      final response = await http.post(
        Uri.parse(finalUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": basicAuth,
          "X-Requested-With": "XMLHttpRequest",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        if (data.containsKey('qr_string')) {
          return data['qr_string'];
        } else if (data.containsKey('actions')) {
          List actions = data['actions'];
          var qrAction = actions.firstWhere(
            (e) => e['name'] == 'generate-qr-code',
            orElse: () => null,
          );
          return qrAction?['url'];
        }
        return null;
      } else {
        // Log Error detail dari Midtrans (misal: Duplicate Order ID)
        debugPrint("Midtrans Error: ${response.body}");
        throw Exception("Gagal QRIS: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error Core API: $e");
      rethrow;
    }
  }

  /// 2. Cek Status Transaksi Manual (Polling)
  Future<String> getTransactionStatus(String orderId) async {
    String serverKey = Const.midtrans_key;
    
    // URL Status: .../v2/[ORDER_ID]/status
    final url = Uri.parse('$_baseUrl/$orderId/status'); 
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('$serverKey:'))}';

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': basicAuth,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // transaction_status: settlement (sukses), pending, deny, expire, cancel
        return data['transaction_status'] ?? 'unknown';
      } else {
        return 'error'; // Order ID tidak ditemukan di Midtrans
      }
    } catch (e) {
      return 'error';
    }
  }
}