import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/model.dart';

class MenuRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- AMBIL DAFTAR MENU BERDASARKAN RESTORAN ID ---
  Future<List<MenuModel>> getMenusByRestaurantId(int restaurantId) async {
    try {
      final data = await _supabase
          .from('menus')
          .select()
          .eq('restaurant_id', restaurantId);

      return (data as List).map((e) => MenuModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil menu berdasarkan restoran: $e');
    }
  }
Future<List<GeneralCategoryModel>> getGeneralCategories() async {
  try {
    // Debug: Cetak struktur tabel
    debugPrint("Fetching general categories...");
    
    final data = await _supabase
        .from('general_categories')
        .select()
        .order('name');
    
    // Debug: Cetak data yang diterima
    debugPrint("Raw categories data: $data");
    
    if (data.isEmpty) {
      debugPrint("No categories found in table 'general_categories'");
      
      // Coba cek tabel dengan nama berbeda
      try {
        final checkAlt = await _supabase
            .from('general_category')
            .select('count')
            .limit(1);
        debugPrint("Alternative table check: $checkAlt");
      } catch (e) {
        debugPrint("Alternative table also doesn't exist: $e");
      }
    }
    
    return (data as List).map((e) {
      debugPrint("Mapping category: $e");
      return GeneralCategoryModel.fromJson(e);
    }).toList();
  } catch (e) {
    debugPrint("Error getting categories: $e");
    // Return empty list instead of throwing
    return [];
  }
}

  Future<String?> uploadMenuImage(XFile imageFile) async {
    try {
      final fileExt = imageFile.name.split('.').last;
      final fileName = 'menu_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath =
          'menu_images/$fileName'; // Pastikan bucket 'menu_images' ada

      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        await _supabase.storage
            .from('menu_images')
            .uploadBinary(
              filePath,
              bytes,
              fileOptions: FileOptions(contentType: 'image/$fileExt'),
            );
      } else {
        await _supabase.storage
            .from('menu_images')
            .upload(
              filePath,
              File(imageFile.path),
              fileOptions: FileOptions(contentType: 'image/$fileExt'),
            );
      }

      // Get Public URL
      return _supabase.storage.from('menu_images').getPublicUrl(filePath);
    } catch (e) {
      throw Exception("Gagal upload gambar: $e");
    }
  }

  // --- B. ADD MENU (INSERT) ---
  Future<void> addMenu(MenuModel menu) async {
    try {
      // Hapus menuId agar auto-increment
      final data = menu.toJson();
      data.remove('menu_id');

      await _supabase.from('menus').insert(data);
    } catch (e) {
      throw Exception("Gagal menambah menu: $e");
    }
  }

  // --- C. UPDATE MENU (UPDATE) ---
  Future<void> updateMenu(MenuModel menu) async {
    try {
      await _supabase
          .from('menus')
          .update(menu.toJson())
          .eq('menu_id', menu.menuId!);
    } catch (e) {
      throw Exception("Gagal update menu: $e");
    }
  }

  // --- D. DELETE MENU (DELETE) ---
  Future<void> deleteMenu(int menuId) async {
    try {
      await _supabase.from('menus').delete().eq('menu_id', menuId);
    } catch (e) {
      throw Exception("Gagal menghapus menu: $e");
    }
  }
}
