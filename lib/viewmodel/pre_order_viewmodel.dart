import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/repository/menu_repository.dart';
import 'package:uc_marketplace/repository/po_repository.dart';
import 'package:uc_marketplace/repository/restaurant_repository.dart';
import 'package:uc_marketplace/viewmodel/auth_viewmodel.dart';

class PreOrderViewModel with ChangeNotifier {
  final _repo = PreOrderRepository();
  final _menuRepo = MenuRepository();
  final _restoRepo = RestaurantRepository();
  AuthViewModel _authVM;

  // --- STATE ---
  RestaurantModel? _currentRestaurant;
  RestaurantModel? get currentRestaurant => _currentRestaurant;

  List<PreOrderModel> _preOrders = [];
  List<PreOrderModel> get preOrders => _preOrders;

  List<MenuModel> _menus = [];
  List<MenuModel> get menus => _menus;

  // State Detail PO
  List<MenuModel> _selectedPOMenus = [];
  List<MenuModel> get selectedPOMenus => _selectedPOMenus;

  List<PoPickupModel> _pickupList = [];
  List<PoPickupModel> get pickupList => _pickupList;

  List<RestaurantModel> _ownedRestaurants = [];
  List<RestaurantModel> get ownedRestaurants => _ownedRestaurants;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- STATE CHART ---
  List<double> _weeklySales = List.filled(7, 0.0); // Default 0 semua (Sen-Ming)
  List<double> get weeklySales => _weeklySales;

  double _totalRevenue = 0;
  double get totalRevenue => _totalRevenue;

  PreOrderViewModel({required AuthViewModel authVM}) : _authVM = authVM;

  void updateAuth(AuthViewModel newAuthVM) {
    _authVM = newAuthVM;

    // Cek logika: Jika sekarang User SUDAH login, tapi data restoran masih kosong
    // Maka jalankan initSellerDashboard secara otomatis.
    if (_authVM.currentUser != null &&
        _ownedRestaurants.isEmpty &&
        !_isLoading) {
      debugPrint("Auth updated & User detected: Auto-fetching dashboard...");
      initSellerDashboard();
    } else {
      // debugPrint("gagal");
    }

    notifyListeners();
  }

  // ===========================================================================
  // 1. FUNGSI UTAMA (INIT & REFRESH)
  // ===========================================================================

  Future<void> initSellerDashboard() async {
    // Set Loading Global SEKALI SAJA di sini
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _authVM.currentUser?.userId;
      if (userId == null) {
        debugPrint("User not logged in");
        return;
      }

      // 1. Ambil Data Restoran (Internal - Tanpa ubah loading)
      await _fetchRestaurantInternal();

      // 2. Jika Restoran ada, Ambil Data Menu & PO (Internal - Tanpa ubah loading)
      if (_currentRestaurant != null && _currentRestaurant!.id != null) {
        await Future.wait([
          _fetchPreOrdersInternal(), 
          _fetchMenusInternal(),
          _fetchSalesChartData(_currentRestaurant!.id!)
        ]);
      }
    } catch (e) {
      debugPrint("Error initializing dashboard: $e");
    } finally {
      // Matikan Loading Global SEKALI SAJA di sini
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeRestaurant(RestaurantModel newResto) async {
    _currentRestaurant = newResto;
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentRestaurant!.id != null) {
        await Future.wait([
          _fetchPreOrdersInternal(),
          _fetchMenusInternal(),
          _fetchSalesChartData(newResto.id!),
        ]);
      }
    } catch (e) {
      debugPrint("Error changing restaurant: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Dipanggil saat klik kartu PO
  Future<void> fetchMenusForPO(int preOrderId) async {
    _isLoading = true;
    _selectedPOMenus = [];
    _pickupList = [];
    notifyListeners();

    try {
      final results = await Future.wait([
        _repo.getMenusByPreOrder(preOrderId),
        _repo.getPickupList(preOrderId),
      ]);

      _selectedPOMenus = results[0] as List<MenuModel>;
      _pickupList = results[1] as List<PoPickupModel>;
    } catch (e) {
      debugPrint("Error detail PO: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // 3. FUNGSI INTERNAL (CORE LOGIC)
  // ===========================================================================

  Future<void> _fetchRestaurantInternal() async {
    try {
      debugPrint("--- START FETCH RESTAURANT ---");
      final restaurants = await _restoRepo.getRestaurantsByOwner();
      debugPrint("Restoran ditemukan: ${restaurants.length}");

      if (restaurants.isEmpty) {
        _ownedRestaurants = [];
        _currentRestaurant = null;
        debugPrint("Warning: List restoran kosong.");
        return;
      }

      _ownedRestaurants = restaurants;

      if (_currentRestaurant == null) {
        _currentRestaurant = restaurants.first;
        debugPrint("Auto-select restoran pertama: ${_currentRestaurant?.name}");
      } else {
        try {
          final foundResto = restaurants.firstWhere(
            (r) => r.id == _currentRestaurant!.id,
          );
          _currentRestaurant = foundResto;
        } catch (e) {
          _currentRestaurant = restaurants.first;
        }
      }
    } catch (e) {
      debugPrint("ERROR _fetchRestaurantInternal: $e");
    }
  }

  Future<void> _fetchPreOrdersInternal() async {
    if (_currentRestaurant?.id == null) return;
    try {
      _preOrders = await _repo.getPreOrdersByRestaurantId(
        _currentRestaurant!.id!,
      );
    } catch (e) {
      debugPrint("Internal Error fetching POs: $e");
    }
  }

  Future<void> _fetchMenusInternal() async {
    if (_currentRestaurant?.id == null) return;
    try {
      _menus = await _menuRepo.getMenusByRestaurantId(_currentRestaurant!.id!);
    } catch (e) {
      debugPrint("Internal Error fetching menus: $e");
    }
  }

  // ===========================================================================
  // 4. FUNGSI CREATE (POST DATA) - SUDAH DIPERBAIKI
  // ===========================================================================

  Future<bool> createPoPickupPlaces(
    int preOrderId,
    List<PoPickupModel> pickupPlaces,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repo.createPickupPlaces(preOrderId, pickupPlaces);
      await fetchMenusForPO(preOrderId);
      return true;
    } catch (e) {
      debugPrint("Error creating pickup: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createFullPreOrder({
    required PreOrderModel preOrder,
    required List<PoPickupModel> pickups,
    required Map<int, int> menuStocks, // Menerima Map (ID, Stock)
    XFile? imageFile, // Menerima File Gambar
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final restaurantId = _currentRestaurant?.id;
      if (restaurantId == null) throw Exception("Restaurant not found");

      // 1. UPLOAD IMAGE (Jika Ada)
      String? uploadedImageUrl;
      if (imageFile != null) {
        uploadedImageUrl = await _repo.uploadPreOrderImage(imageFile);
      }

      // 2. Create Parent PO (Masukkan URL Gambar ke Model)
      final createdPO = await _repo.createPreOrder(
        preOrder.copyWith(
          restaurantId: restaurantId,
          image: uploadedImageUrl, // <--- PENTING: Masukkan URL di sini
        ),
      );
      
      final newPoId = createdPO.preOrderId;
      if (newPoId == null) throw Exception("Failed to get new PreOrder ID");

      // 3. Create Pickups & Menus Parallel
      final pickupFutures = pickups.map((p) {
        return _repo.createPoPickup(p.copyWith(preOrderId: newPoId));
      }).toList();

      // Loop Menu + Stock
      final menuFutures = menuStocks.entries.map((entry) {
        final menuId = entry.key;
        final stockQty = entry.value;

        final poMenu = PreOrderMenuModel(
          preOrderId: newPoId,
          menuId: menuId,
          stock: stockQty, // Masukkan stok ke Model
        );
        return _repo.createPreOrderMenu(poMenu);
      }).toList();

      await Future.wait([...pickupFutures, ...menuFutures]);

      // 4. Refresh List PO
      await _fetchPreOrdersInternal();

      return true;
    } catch (e) {
      debugPrint("Error creating full PO: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchSalesChartData(int restaurantId) async {
    try {
      final rawData = await _repo.getWeeklySalesData(restaurantId);

      List<double> tempSales = List.filled(7, 0.0);
      double tempTotal = 0;

      for (var item in rawData) {
        final dateStr = item['order_date'] as String;
        final amount = (item['total_amount'] as num).toDouble();

        final date = DateTime.parse(dateStr).toLocal();
        final dayIndex = date.weekday - 1; // 0=Senin, 6=Minggu

        if (dayIndex >= 0 && dayIndex < 7) {
          tempSales[dayIndex] += amount;
        }

        tempTotal += amount;
      }

      _weeklySales = tempSales;
      _totalRevenue = tempTotal;

      debugPrint("Chart Data Updated: $_weeklySales");
      debugPrint("Total Revenue: $_totalRevenue");
    } catch (e) {
      debugPrint("Error processing chart data: $e");
      _weeklySales = List.filled(7, 0.0);
      _totalRevenue = 0;
    }
  }
}