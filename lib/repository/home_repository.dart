import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/model.dart';

class HomeRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- AMBIL DAFTAR RESTORAN (Limit 5 untuk Home) ---
  Future<List<RestaurantModel>> getRestaurants({int limit = 5}) async {
    try {
      final data = await _supabase
          .from('restaurants')
          .select()
          .limit(limit);

      return (data as List).map((e) => RestaurantModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal memuat restoran: $e');
    }
  }

  // --- AMBIL DAFTAR MENU (Limit 5 untuk Popular Food) ---
  Future<List<MenuModel>> getMenus({int limit = 5}) async {
    try {
      // Kita ambil menu secara acak atau urut ID
      final data = await _supabase
          .from('menus')
          .select()
          .limit(limit);

      return (data as List).map((e) => MenuModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal memuat menu: $e');
    }
  }
}