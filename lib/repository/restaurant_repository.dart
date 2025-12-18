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

  // Fungsi untuk mengambil data restoran berdasarkan Owner ID (User ID)
  Future<RestaurantModel?> getRestaurantByOwnerId(int ownerId) async {
    print("RestaurantRepository: Fetching restaurant for ownerId: $ownerId");
    try {
      final data = await _supabase
          .from('restaurants')
          .select()
          .eq('owners_id', ownerId)
          .maybeSingle(); // Use maybeSingle in case user has no restaurant yet

      print("RestaurantRepository: Data found: $data");

      if (data == null) return null;
      return RestaurantModel.fromJson(data);
    } catch (e) {
      print("RestaurantRepository: Error fetching restaurant: $e");
      return null;
    }
  }
}
