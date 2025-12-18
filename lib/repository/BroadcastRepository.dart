import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/model.dart';

class BroadcastRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<BroadcastModel>> getBroadcasts() async {
    try {
      // ---------------------------------------------------------
      // OPSI 1: GUNAKAN DUMMY DATA (Aktifkan ini untuk Testing UI)
      // ---------------------------------------------------------
      
      // 1. Simulasi delay network (loading) selama 2 detik
      await Future.delayed(const Duration(seconds: 2));

      // 2. Return data palsu tapi menggunakan Struktur BroadcastModel ASLI
      return [
        BroadcastModel(
          broadcastId: 101,
          preOrderId: 501,
          message: "⚠️ Info: Pengambilan PO Batch 5 dipercepat menjadi jam 12:00.",
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        BroadcastModel(
          broadcastId: 102,
          preOrderId: 502,
          message: "🔥 Flash Sale! Sisa 5 porsi Nasi Goreng Spesial.",
          createdAt: DateTime.now().subtract(const Duration(hours: 1)), 
        ),
        BroadcastModel(
          broadcastId: 103,
          preOrderId: 503,
          message: "Halo, driver sudah sampai di lobi asrama.",
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      // ---------------------------------------------------------
      // OPSI 2: GUNAKAN REAL BACKEND (Aktifkan nanti)
      // ---------------------------------------------------------
      /*
      final response = await _supabase
          .from('broadcasts') // Pastikan tabel di DB namanya 'broadcasts'
          .select()
          .order('created_at', ascending: false); // Urutkan dari yg terbaru

      // Konversi JSON dari Supabase ke List<BroadcastModel>
      return (response as List).map((e) => BroadcastModel.fromJson(e)).toList();
      */
      
    } catch (e) {
      throw Exception("Gagal memuat broadcast: $e");
    }
  }
}