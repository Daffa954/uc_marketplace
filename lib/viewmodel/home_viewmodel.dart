import 'package:flutter/material.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/repository/home_repository.dart';
import 'package:uc_marketplace/repository/po_repository.dart';

class HomeViewModel with ChangeNotifier {
  final _homeRepo = HomeRepository();
  final _poRepo = PreOrderRepository();
  // [BARU] State General Categories
  List<GeneralCategoryModel> _categories = [];
  List<GeneralCategoryModel> get categories => _categories;

  // State untuk Restaurant
  List<RestaurantModel> _restaurants = [];
  List<RestaurantModel> get restaurants => _restaurants;

  // State untuk Menu
  List<MenuModel> _menus = [];
  List<MenuModel> get menus => _menus;

  // --- STATE LIST PO (Untuk Home Page) ---
  List<PreOrderModel> _preOrders = [];
  List<PreOrderModel> get preOrders => _preOrders;

  // --- STATE MENU PO (Untuk Halaman Detail PO) ---
  List<MenuModel> _pOMenus = [];
  List<MenuModel> get pOMenus => _pOMenus;

  List<PreOrderModel> _closingSoonPreOrders = [];
  List<PreOrderModel> get closingSoonPreOrders => _closingSoonPreOrders;

  List<PreOrderModel> _hiddenGemsPreOrders = [];
  List<PreOrderModel> get hiddenGemsPreOrders => _hiddenGemsPreOrders;

  List<PreOrderModel> _popularPreOrders = [];
  List<PreOrderModel> get popularPreOrders => _popularPreOrders;


  // State Loading & Error
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  int _selectedCategoryId = 0;
  int get selectedCategoryId => _selectedCategoryId;
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
        _poRepo.getActivePreOrders(),
        _poRepo.getAllPreOrderMenus(),
        _homeRepo.getCategories(), // Index 4 [BARU]
        _poRepo.getClosingSoonPreOrders(), // [BARU]
        _poRepo.getHiddenGemsPreOrders(), // [BARU]
        _poRepo.getPopularPreOrders(), // [BARU]
      ]);

      _restaurants = results[0] as List<RestaurantModel>;
      _menus = results[1] as List<MenuModel>;
      _preOrders = results[2] as List<PreOrderModel>;
      _pOMenus = results[3] as List<MenuModel>;
      _categories = results[4] as List<GeneralCategoryModel>; // [BARU]
      _closingSoonPreOrders = results[5] as List<PreOrderModel>; // [BARU]
      _hiddenGemsPreOrders = results[6] as List<PreOrderModel>; // [BARU]
      _popularPreOrders = results[7] as List<PreOrderModel>; // [BARU]
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(int id) {
    _selectedCategoryId = id;
    notifyListeners();

    // Nanti di sini bisa ditambahkan logika filtering list Menu/PO
    // filterDataByCategoryId(id);
  }
}
