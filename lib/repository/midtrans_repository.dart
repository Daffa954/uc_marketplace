import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/shared/shared.dart';
import '../model/model.dart';

class MidtransRepository {
  final _supabase = Supabase.instance.client;

  // [FIX 1] Pisahkan Base URL (Tanpa /charge)
  static const String _baseUrl = "https://api.sandbox.midtrans.com/v2";

  /// 1. Request Generate QRIS
  Future<String?> chargeQris({required OrderModel order}) async {
    try {
      String serverKey = Const.midtrans_key;
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$serverKey:'))}';

      // [FIX 2] Gunakan endpoint spesifik /charge
      String finalUrl = "$_baseUrl/charge";
      
      if (kIsWeb) {
        finalUrl = "https://cors-anywhere.herokuapp.com/$finalUrl";
      }

      Map<String, dynamic> body = {
        "payment_type": "qris",
        "transaction_details": {
          // [FIX 3] Gunakan ID ASLI saja (Hapus QRIS- dan timestamp)
          // Agar sinkron dengan ID yang dicek saat polling status nanti.
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
        if (data.containsKey('qr_string')) return data['qr_string'];
        if (data.containsKey('actions')) {
          List actions = data['actions'];
          var qrAction = actions.firstWhere((e) => e['name'] == 'generate-qr-code', orElse: () => null);
          return qrAction?['url'];
        }
        return null;
      } else {
        debugPrint("Midtrans Error: ${response.body}");
        // Jika error "Duplicate Order ID", user harus checkout ulang (Order Baru)
        return null;
      }
    } catch (e) {
      debugPrint("Error Core API: $e");
      rethrow;
    }
  }

  /// 2. Cek Status Transaksi (Polling)
  /// 2. Cek Status Transaksi Manual (Polling)
  Future<String> getTransactionStatus(String orderId) async {
    String serverKey = Const.midtrans_key;
    
    // 1. Siapkan URL Asli
    String statusUrl = '$_baseUrl/$orderId/status';

    // [FIX KHUSUS WEB] Gunakan Proxy agar tidak error "Failed to fetch" (CORS)
    if (kIsWeb) {
      statusUrl = "https://cors-anywhere.herokuapp.com/$statusUrl";
    }
    
    final url = Uri.parse(statusUrl); 
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('$serverKey:'))}';

    // [DEBUG LOG]
    debugPrint("========================================");
    debugPrint("[MIDTRANS REPO] Cek Status untuk Order ID: '$orderId'");
    debugPrint("[MIDTRANS REPO] URL Request: '$url'");

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': basicAuth,
          // [FIX] Header wajib jika lewat Proxy
          if (kIsWeb) "X-Requested-With": "XMLHttpRequest",
        },
      );

      debugPrint("[MIDTRANS REPO] Response Code: ${response.statusCode}");
      debugPrint("[MIDTRANS REPO] Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['transaction_status'] ?? 'unknown';
        debugPrint("[MIDTRANS REPO] Status Parsed: $status");
        return status;
      } else {
        debugPrint("[MIDTRANS REPO] Error: Status code bukan 200");
        return 'error';
      }
    } catch (e) {
      debugPrint("[MIDTRANS REPO] Exception: $e");
      return 'error';
    } finally {
      debugPrint("========================================");
    }
  }
}
