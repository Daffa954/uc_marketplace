import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uc_marketplace/model/enums.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/repository/menu_repository.dart';

class AddEditMenuViewModel extends ChangeNotifier {
  final MenuRepository _repo = MenuRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  XFile? _selectedImage;
  XFile? get selectedImage => _selectedImage;

  List<GeneralCategoryModel> _categories = [];
  List<GeneralCategoryModel> get categories => _categories;
  
  bool _categoriesLoading = false;
  bool get categoriesLoading => _categoriesLoading;

  void setImage(XFile? image) {
    _selectedImage = image;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      _categoriesLoading = true;
      notifyListeners();
      
      debugPrint("Loading categories from repository...");
      _categories = await _repo.getGeneralCategories();
      debugPrint("Loaded ${_categories.length} categories");
      
      _categoriesLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading categories: $e");
      _categories = [];
      _categoriesLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<String?> saveMenu({
    required bool isNewItem,
    required int? currentMenuId,
    required String name,
    required String description,
    required String priceStr,
    required String? oldImageUrl,
    required MenuType type,
    required int restaurantId,
    required int? generalCategoryId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Validation
      if (name.trim().isEmpty) {
        return "Nama menu wajib diisi.";
      }
      
      if (priceStr.trim().isEmpty) {
        return "Harga wajib diisi.";
      }

      final price = double.tryParse(priceStr);
      if (price == null || price <= 0) {
        return "Harga harus berupa angka positif.";
      }

      // Upload image if new
      String? finalImageUrl = oldImageUrl;
      if (_selectedImage != null) {
        final uploadedUrl = await _repo.uploadMenuImage(_selectedImage!);
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
        }
      }

      // Create menu object
      final menuObj = MenuModel(
        menuId: isNewItem ? null : currentMenuId,
        restaurantId: restaurantId,
        name: name.trim(),
        description: description.trim().isEmpty ? null : description.trim(),
        price: price.toInt(),
        image: finalImageUrl,
        type: type,
        generalCategoryId: generalCategoryId,
      );

      // Save to database
      if (isNewItem) {
        await _repo.addMenu(menuObj);
      } else {
        await _repo.updateMenu(menuObj);
      }

      return null; // Success
    } catch (e) {
      return e.toString().replaceAll("Exception:", "").trim();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> deleteMenu(int menuId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _repo.deleteMenu(menuId);
      return null;
    } catch (e) {
      return e.toString().replaceAll("Exception:", "").trim();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _selectedImage = null;
    _categories = [];
    notifyListeners();
  }
}