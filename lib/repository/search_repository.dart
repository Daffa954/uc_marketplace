import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/model.dart';

class SearchRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. CARI RESTORAN (Berdasarkan Nama)
  Future<List<PreOrderModel>> searchPreOrders(String query) async {
    try {
      final data = await _supabase
          .from('pre_orders')
          .select()
          .ilike('name', '%$query%'); // ilike = case insensitive search (li%ke)

      return (data as List).map((e) => PreOrderModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mencari PO: $e');
    }
  }

  // 2. AMBIL SUGGESTED RESTAURANTS (Misal: ambil 3 random/teratas)
  Future<List<PreOrderModel>> getSuggestedPreOrders() async {
    try {
      final data = await _supabase
          .from('pre_orders')
          .select()
          .limit(3); // Ambil 3 saja untuk saran

      return (data as List).map((e) => PreOrderModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal ambil saran PO: $e');
    }
  }

  // 3. AMBIL NEW ITEMS (Menu terbaru)
  Future<List<MenuModel>> getNewItems() async {
    try {
      final data = await _supabase
          .from('menus')
          .select()
          .order('menu_id', ascending: false) // ID terbesar = terbaru
          .limit(5);

      return (data as List).map((e) => MenuModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal ambil menu baru: $e');
    }
  }

  Future<List<PoPickupModel>> getAllPoPickups() async {
    try {
      final data = await _supabase.from('po_pickups').select();

      return (data as List).map((e) => PoPickupModel.fromJson(e)).toList();
    } catch (e) {
      // Return list kosong jika gagal, agar tidak crash
      return [];
    }
  }
}
