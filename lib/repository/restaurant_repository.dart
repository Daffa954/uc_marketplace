import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/model.dart';

class RestaurantRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fungsi untuk mengambil data restoran berdasarkan ID
  Future<RestaurantModel?> getRestaurantById(int id) async {
    try {
      final data = await _supabase
          .from('restaurants')
          .select()
          .eq('restaurants_id', id)
          .single();

      return RestaurantModel.fromJson(data);
    } catch (e) {
      return null; // Return null jika tidak ketemu
    }
  }
}