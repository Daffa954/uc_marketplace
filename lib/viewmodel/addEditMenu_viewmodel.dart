import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uc_marketplace/model/enums.dart'; // Pastikan import enum
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/repository/menu_repository.dart';

class AddEditMenuViewModel with ChangeNotifier {
  final _repo = MenuRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  XFile? _selectedImage;
  XFile? get selectedImage => _selectedImage;

  void setImage(XFile? image) {
    _selectedImage = image;
    notifyListeners();
  }

  // --- SAVE DATA (ADD / EDIT) ---
  Future<String?> saveMenu({
    required bool isNewItem,
    required int? currentMenuId,
    required String name,
    required String description,
    required String priceStr,
    required String? oldImageUrl,
    required MenuType type, 
    required int restaurantId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (name.isEmpty || priceStr.isEmpty) {
        throw "Nama dan Harga wajib diisi.";
      }
      double price = double.tryParse(priceStr) ?? 0;

      String? finalImageUrl = oldImageUrl;
      if (_selectedImage != null) {
        finalImageUrl = await _repo.uploadMenuImage(_selectedImage!);
      }

      final menuObj = MenuModel(
        menuId: isNewItem ? null : currentMenuId,
        restaurantId: restaurantId,
        name: name,
        description: description,
        price: price.toInt(),
        image: finalImageUrl,
        type: type, // [PERBAIKAN] Gunakan variable type dari parameter
      );

      if (isNewItem) {
        await _repo.addMenu(menuObj);
      } else {
        await _repo.updateMenu(menuObj);
      }

      return null; 
    } catch (e) {
      return e.toString().replaceAll("Exception:", "").trim();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ... (Fungsi deleteMenu tetap sama)
  Future<String?> deleteMenu(int menuId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repo.deleteMenu(menuId);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}