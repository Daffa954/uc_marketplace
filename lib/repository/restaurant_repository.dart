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

  Future<List<RestaurantModel>> getRestaurantsByOwner() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('restaurants')
          .select()
          .eq('owner_id', user.id); // Pastikan kolom di DB adalah 'owners_id'

      return (response as List)
          .map((e) => RestaurantModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception("Gagal mengambil daftar restoran: $e");
    }
  }

Future<void> createRestaurant({
    required String name,
    required String description,
    required String address,
    required String city,
    required String province,
    required String bankAccount,
  }) async {
    try {
      // 1. AMBIL USER YANG SEDANG LOGIN (Otomatis)
      final user = _supabase.auth.currentUser;
      
      if (user == null) {
        throw Exception("Sesi habis. Silakan login kembali.");
      }

      // 2. MASUKKAN ID USER KE DALAM MODEL
      // Kita tidak minta dari parameter, tapi ambil dari variable 'user.id' di atas
      final newResto = RestaurantModel(
        name: name,
        description: description,
        address: address,
        city: city,
        province: province,
        bankAccount: bankAccount,
        ownerId: user.id, // <--- INI BAGIAN PENTINGNYA
      );

      // 3. KIRIM KE DATABASE
      // Fungsi .toJson() akan mengubah 'ownerId' menjadi key 'owners_id' sesuai model Anda
      await _supabase.from('restaurants').insert(newResto.toJson());

    } catch (e) {
      throw Exception("Gagal membuat restoran: $e");
    }
  }
}
