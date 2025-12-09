import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/model.dart';

class SearchRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. CARI RESTORAN (Berdasarkan Nama)
  Future<List<RestaurantModel>> searchRestaurants(String query) async {
    try {
      final data = await _supabase
          .from('restaurants')
          .select()
          .ilike('name', '%$query%'); // ilike = case insensitive search (li%ke)

      return (data as List).map((e) => RestaurantModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mencari restoran: $e');
    }
  }

  // 2. AMBIL SUGGESTED RESTAURANTS (Misal: ambil 3 random/teratas)
  Future<List<RestaurantModel>> getSuggestedRestaurants() async {
    try {
      final data = await _supabase
          .from('restaurants')
          .select()
          .limit(3); // Ambil 3 saja untuk saran

      return (data as List).map((e) => RestaurantModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal ambil saran restoran: $e');
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
}