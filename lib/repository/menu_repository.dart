import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/model.dart';

class MenuRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- AMBIL DAFTAR MENU BERDASARKAN RESTORAN ID ---
  Future<List<MenuModel>> getMenusByRestaurantId(int restaurantId) async {
    try {
      final data = await _supabase
          .from('menus')
          .select()
          .eq('restaurant_id', restaurantId);

      return (data as List).map((e) => MenuModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil menu berdasarkan restoran: $e');
    }
  }
}