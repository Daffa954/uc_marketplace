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
      // 1. Ambil ID User yang sedang login (UUID)
      final String? userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        // Jika null, kembalikan list kosong biar ViewModel menangani logic "Empty State"
        print("Repo Error: User ID null (Belum login)");
        return [];
      }

      // 2. Query ke Supabase
      // GANTI 'owner_id' dengan nama kolom yang benar di tabel 'restaurants' Anda
      // (Bisa jadi namanya 'user_id', 'seller_id', atau 'owner_id')
      final response = await _supabase
          .from('restaurants')
          .select()
          .eq('owner_id', userId); // <--- PASTIKAN NAMA KOLOM INI BENAR

      final List<dynamic> data = response;
      return data.map((json) => RestaurantModel.fromJson(json)).toList();

    } catch (e) {
      print("Repo Error Fetch: $e");
      return []; // Return kosong jika error, jangan throw agar app tidak crash
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
