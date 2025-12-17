import 'package:flutter/material.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/repository/po_repository.dart';

class PreOrderViewModel with ChangeNotifier {
  final _repo = PreOrderRepository();

  // --- STATE LIST PO (Untuk Home Page) ---
  List<PreOrderModel> _preOrders = [];
  List<PreOrderModel> get preOrders => _preOrders;

  // --- STATE MENU PO (Untuk Halaman Detail PO) ---
  List<MenuModel> _selectedPOMenus = [];
  List<MenuModel> get selectedPOMenus => _selectedPOMenus;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

List<PoPickupModel> _pickupList = [];
  List<PoPickupModel> get pickupList => _pickupList;

  // Constructor: Langsung ambil data PO saat ViewModel dibuat
  PreOrderViewModel() {
    fetchPreOrders();
  }

  // 1. Fetch List PO
  Future<void> fetchPreOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _preOrders = await _repo.getActivePreOrders();
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
}