import 'package:flutter/material.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/repository/menu_repository.dart';
import 'package:uc_marketplace/repository/po_repository.dart';

class DetailViewModel with ChangeNotifier {
  final _poRepo = PreOrderRepository();
  final _menuRepo = MenuRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- STATE UNTUK PO DETAIL ---
  List<PoPickupModel> _pickupList = [];
  List<PoPickupModel> get pickupList => _pickupList;

  List<MenuModel> _poMenuList = [];
  List<MenuModel> get poMenuList => _poMenuList;

  // --- FUNGSI LOAD DETAIL PO ---
  Future<void> loadPoDetails(int preOrderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch Pickups & Menus secara paralel
      final results = await Future.wait([
        _poRepo.getPickupList(preOrderId),
        _poRepo.getMenusByPreOrder(preOrderId),
      ]);

      _pickupList = results[0] as List<PoPickupModel>;
      _poMenuList = results[1] as List<MenuModel>;
    } catch (e) {
      debugPrint("Error loading PO details: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- FUNGSI DELETE MENU (Opsional) ---
  Future<bool> deleteMenu(int menuId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Asumsi ada fungsi delete di repo
      // await _menuRepo.deleteMenu(menuId); 
      // Simulasi sukses
      await Future.delayed(const Duration(seconds: 1)); 
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}