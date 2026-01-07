import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/rating.dart';
import 'package:uc_marketplace/repository/rating_repository.dart';

class RatingViewModel with ChangeNotifier {
  final _repo = RatingRepository();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Kirim Rating
  Future<bool> submitRating({
    required int menuId,
    required int ratingValue,
    String? comment,
    int? orderId,
    int? preOrderId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception("User belum login");

      final newRating = RatingModel(
        userId: userId,
        menuId: menuId,
        rating: ratingValue,
        comment: comment,
        orderId: orderId,
        preOrderId: preOrderId,
      );

      await _repo.addRating(newRating);
      return true; // Sukses
    } catch (e) {
      debugPrint("Error submit rating: $e");
      return false; // Gagal
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}