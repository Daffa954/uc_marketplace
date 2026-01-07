import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/rating.dart';

class RatingRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Kirim Rating Baru
  Future<void> addRating(RatingModel rating) async {
    try {
      await _supabase.from('ratings').insert(rating.toJson());
    } catch (e) {
      throw Exception('Gagal mengirim ulasan: $e');
    }
  }

  // Ambil Rating berdasarkan Menu ID (untuk ditampilkan di Menu Detail)
  Future<List<RatingModel>> getRatingsByMenu(int menuId) async {
    try {
      // Select rating dan join ke tabel users untuk ambil nama pereview
      final response = await _supabase
          .from('ratings')
          .select('*, users(*)') 
          .eq('menu_id', menuId)
          .order('created_at', ascending: false);

      return (response as List).map((e) => RatingModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal memuat ulasan: $e');
    }
  }
}