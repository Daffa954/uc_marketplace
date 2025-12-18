import 'package:flutter/material.dart';
import 'package:uc_marketplace/repository/restaurant_repository.dart';

class AddRestaurantViewModel with ChangeNotifier {
  final _repo = RestaurantRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String?> saveRestaurant({
    required String name,
    required String description,
    required String address,
    required String city,
    required String province,
    required String bankAccount,
  }) async {
    // Validasi sederhana
    if (name.isEmpty ||
        address.isEmpty ||
        city.isEmpty ||
        bankAccount.isEmpty) {
      return "Mohon lengkapi data wajib (Nama, Alamat, Kota, Rekening).";
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _repo.createRestaurant(
        name: name,
        description: description,
        address: address,
        city: city,
        province: province,
        bankAccount: bankAccount,
        // Hapus parameter imageFile karena tidak digunakan
      );
      return null; // Sukses (return null artinya tidak ada error)
    } catch (e) {
      return e.toString().replaceAll("Exception:", "").trim();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}