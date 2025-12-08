import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:uc_marketplace/data/app_exception.dart';
import 'package:uc_marketplace/data/network/base_api_service.dart';
import 'package:uc_marketplace/shared/shared.dart';

/// Implementasi BaseApiServices untuk menangani request GET, POST ke API RajaOngkir.
class NetworkApiServices implements BaseApiServices {
  Map<String, String> get _headers => {
    'Content-Type': 'application/json', // Supabase butuh JSON
    'apikey': Const.supabaseKey, // Wajib
    'Authorization': 'Bearer ${Const.supabaseKey}', // Wajib untuk RLS
    // 'Prefer': 'return=representation' // Opsional: agar POST mengembalikan data yang disimpan
  };
  @override
  Future<dynamic> getApiResponse(String endpoint) async {
    try {
      // Endpoint contoh: "products?select=*"
      // Gabungkan URL: https://xyz.supabase.co/rest/v1/products?select=*
      final uri = Uri.parse("${Const.restUrl}$endpoint");

      _logRequest('GET', uri, Const.supabaseKey);

      final response = await http.get(
        uri,
        headers: _headers, // Gunakan header Supabase
      );

      return _returnResponse(response);
    } on SocketException {
      throw NoInternetException('No internet connection');
    } on TimeoutException {
      throw FetchDataException('Network request timeout!');
    } catch (e) {
      throw FetchDataException('Unexpected error: $e');
    }
  }

  /// Melakukan request POST dengan body form-url-encoded.
  /// Mengembalikan JSON ter-decode atau melempar AppException yang sesuai.
  @override
  Future<dynamic> postApiResponse(String endpoint, dynamic data) async {
    try {
      final uri = Uri.parse("${Const.restUrl}$endpoint");

      // PERUBAHAN PENTING:
      // Data harus di-encode ke JSON string, bukan Map mentah
      final bodyPayload = jsonEncode(data);

      _logRequest('POST', uri, Const.supabaseKey, bodyPayload);

      final response = await http.post(
        uri,
        headers: {
          ..._headers,
          'Prefer':
              'return=representation', // Agar Supabase mengembalikan data yg baru diinsert
        },
        body: bodyPayload, // Kirim JSON String
      );

      return _returnResponse(response);
    } on SocketException {
      throw NoInternetException('No internet connection!');
    } on TimeoutException {
      throw FetchDataException('Network request timeout!');
    } on FormatException {
      throw FetchDataException('Invalid response format!');
    } catch (e) {
      throw FetchDataException('Unexpected error: $e');
    }
  }

  /// Print debug metadata request (method, URL, header, body).
 
  void _logRequest(String method, Uri uri, String apiKey, [dynamic data]) {
    print("== $method REQUEST (Supabase) ==");
    print("Final URL: $uri");
    if (data != null) {
      print("Data body: $data");
    }
    print("");
  }

  /// Print debug detail respons (status, content-type, body).
  void _logResponse(int statusCode, String? contentType, String body) {
    print("Status code: $statusCode");
    print("Content-Type: ${contentType ?? '-'}");

    if (body.isEmpty) {
      print("Body: <empty>");
    } else {
      String formattedBody;
      try {
        final decoded = jsonDecode(body);
        const encoder = JsonEncoder.withIndent('  ');
        formattedBody = encoder.convert(decoded);
      } catch (_) {
        formattedBody = body;
      }

      const maxLen = 8000;
      if (formattedBody.length > maxLen) {
        print(
          "Body (terpotong): ${formattedBody.substring(0, maxLen)}... [${formattedBody.length - maxLen} lebih karakter]",
        );
      } else {
        print("Body: $formattedBody");
      }
    }
    print("");
  }

  /// Memetakan HTTP response menjadi JSON ter-decode atau melempar exception bertipe.
  dynamic _returnResponse(http.Response response) {
    _logResponse(
      response.statusCode,
      response.headers['content-type'],
      response.body,
    );

   
    switch (response.statusCode) {
      case 200:
      case 201: // Supabase sering mengembalikan 201 Created untuk POST
        try {
          if (response.body.isEmpty) return null; // Handle body kosong
          final decoded = jsonDecode(response.body);
          return decoded;
        } catch (_) {
          throw FetchDataException('Invalid JSON');
        }
      case 400:
        throw BadRequestException(response.body);
      case 401:
        throw FetchDataException('Unauthorized: Cek API Key / Token');
      case 404:
        throw NotFoundException('Not Found: ${response.body}');
      case 500:
        throw ServerErrorException('Server error: ${response.body}');
      default:
        throw FetchDataException(
          'Unexpected status ${response.statusCode}: ${response.body}',
        );
    }
  }
}
