import 'package:flutter/material.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/repository/home_repository.dart';

class HomeViewModel with ChangeNotifier {
  final _homeRepo = HomeRepository();

  // State untuk Restaurant
  List<RestaurantModel> _restaurants = [];
  List<RestaurantModel> get restaurants => _restaurants;

  // State untuk Menu
  List<MenuModel> _menus = [];
  List<MenuModel> get menus => _menus;

  // State Loading & Error
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Constructor langsung panggil fetch data
  HomeViewModel() {
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Jalankan request secara paralel agar lebih cepat
      final results = await Future.wait([
        _homeRepo.getRestaurants(),
        _homeRepo.getMenus(),
      ]);

      _restaurants = results[0] as List<RestaurantModel>;
      _menus = results[1] as List<MenuModel>;

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}