import 'package:flutter/material.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/repository/menu_repository.dart';
import 'package:uc_marketplace/repository/po_repository.dart';
import 'package:uc_marketplace/repository/restaurant_repository.dart';
import 'package:uc_marketplace/viewmodel/auth_viewmodel.dart';

class PreOrderViewModel with ChangeNotifier {
  final _repo = PreOrderRepository();
  final _menuRepo = MenuRepository();
  final _restoRepo = RestaurantRepository();

  final AuthViewModel _authVM;

  RestaurantModel? _currentRestaurant;
  RestaurantModel? get currentRestaurant => _currentRestaurant;

  // --- STATE LIST PO (Untuk Home Page) ---
  List<PreOrderModel> _preOrders = [];
  List<PreOrderModel> get preOrders => _preOrders;

  // --- STATE MENU PO (Untuk Halaman Detail PO) ---
  List<MenuModel> _selectedPOMenus = [];
  List<MenuModel> get selectedPOMenus => _selectedPOMenus;

  List<MenuModel> _menus = [];
  List<MenuModel> get menus => _menus;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PoPickupModel> _pickupList = [];
  List<PoPickupModel> get pickupList => _pickupList;

  // Constructor: Langsung ambil data PO saat ViewModel dibuat
  PreOrderViewModel({required AuthViewModel authVM})  : _authVM = authVM;

  Future<void> initSellerDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Check if user is logged in
      final userId = _authVM.currentUser?.userId; // Assuming userId is accessible
      if (userId == null) {
        debugPrint("User not logged in");
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 2. Fetch Restaurant AND WAIT until it finishes
      await fetchRestaurant(); 

      // 3. Only if restaurant exists, fetch the rest
      if (_currentRestaurant != null) {
        // We can run these two in parallel to save time, 
        // because we now have the restaurant ID
        await Future.wait([
          fetchPreOrders(),
          fetchMenus(),
        ]);
      }
      
    } catch (e) {
      debugPrint("Error initializing dashboard: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 1. Fetch List PO
  Future<void> fetchPreOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _preOrders = await _repo.getPreOrdersByRestaurantId(_currentRestaurant!.id!);
    } catch (e) {
      debugPrint("Error fetching POs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Fetch Menu berdasarkan ID PO (Dipanggil saat kartu PO diklik)
  Future<void> fetchMenusForPO(int preOrderId) async {
    _isLoading = true;
    _selectedPOMenus = [];
    _pickupList = []; // Reset
    notifyListeners();

    try {
      final results = await Future.wait([
        _repo.getMenusByPreOrder(preOrderId),
        _repo.getPickupList(preOrderId), // Panggil fungsi baru
      ]);

      _selectedPOMenus = results[0] as List<MenuModel>;
      _pickupList = results[1] as List<PoPickupModel>; // Cast ke List
      
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // for creating PO pickup places
  Future<bool> createPoPickupPlaces(int preOrderId, List<PoPickupModel> pickupPlaces) async {
    _isLoading = true;
    notifyListeners(); // 1. Tell UI to show loading spinner

    try {
      // 2. Execute the repository call
      await _repo.createPickupPlaces(preOrderId, pickupPlaces);
      
      // 3. Refresh the data (this syncs your local _pickupList with the DB)
      await fetchMenusForPO(preOrderId);
      
      return true; // Return success to the UI
    } catch (e) {
      debugPrint("Error creating PO pickup places: $e");
      return false; // Return failure
    } finally {
      _isLoading = false;
      notifyListeners(); // 4. Tell UI to hide loading spinner
    }
  }
  // Fetch Semua Menu
  Future<void> fetchMenus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Jalankan request secara paralel agar lebih cepat
      final results = await Future.wait([
        _menuRepo.getMenusByRestaurantId(_currentRestaurant!.id!)
      ]);

      _menus = results as List<MenuModel>;

    } catch (e) {
      debugPrint("Error fetching menus: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Restaurant (asumsi hanya ada satu restaurant)
  Future<void> fetchRestaurant() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentRestaurant = await _restoRepo.getRestaurantByOwnerId(_authVM.currentUser!.userId!);
      _isLoading = false;
    } catch (e) {
      debugPrint("Error fetching restaurant: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}