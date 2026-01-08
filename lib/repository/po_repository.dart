import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/model.dart';

class PreOrderRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
Future<List<Map<String, dynamic>>> getActivePreOrdersWithLocation() async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await _supabase
          .from('pre_orders')
          .select('*, po_pickup!po_pickup_pre_order_id_fkey1(*)') // [FIX] Update disini juga
          .gte('close_order_date', now);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetch location data: $e");
      return [];
    }
  }
  // --- 1. AMBIL LIST BATCH PRE-ORDER ---
  Future<List<PreOrderModel>> getActivePreOrders() async {
    try {
      final data = await _supabase
          .from('pre_orders')
          .select()
          .order(
            'close_order_date',
            ascending: true,
          ); // Urutkan berdasarkan tanggal tutup terdekat

      return (data as List).map((e) => PreOrderModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data Pre-Order: $e');
    }
  }

  // --- 2. AMBIL MENU SPESIFIK UNTUK PO TERTENTU (CRITICAL FIX) ---
  Future<List<MenuModel>> getMenusByPreOrder(int preOrderId) async {
    try {
      final data = await _supabase
          .from('pre_order_menu')
          .select('pre_order_menu_id, menus(*)')
          .eq('pre_order_id', preOrderId);

      return (data as List)
          .map((e) {
            if (e['menus'] == null) return null;

            final Map<String, dynamic> menuData = Map<String, dynamic>.from(
              e['menus'],
            );

            // Inject ID Relasi agar tidak NULL
            menuData['pre_order_menu_id'] = e['pre_order_menu_id'];

            return MenuModel.fromJson(menuData);
          })
          .whereType<MenuModel>()
          .toList(); // Filter null jika ada data kotor
    } catch (e) {
      throw Exception('Gagal mengambil menu PO: $e');
    }
  }

  Future<List<MenuModel>> getAllPreOrderMenus() async {
    try {
      final data = await _supabase.from('pre_order_menu').select('menus(*)');

      final List<MenuModel> allMenus = (data as List).map((e) {
        return MenuModel.fromJson(e['menus']);
      }).toList();

      // OPTIONAL: Hapus Duplikat
      // Jika Menu A ada di PO 1 dan PO 2, kita hanya ingin menampilkannya sekali
      final uniqueMenus = <int, MenuModel>{};
      for (var menu in allMenus) {
        if (menu.menuId != null) {
          uniqueMenus[menu.menuId!] = menu;
        }
      }
      return uniqueMenus.values.toList();
    } catch (e) {
      throw Exception('Gagal mengambil semua menu PO: $e');
    }
  }

  // --- AMBIL LIST PICKUP (1 PO BISA BANYAK LOKASI) ---
  Future<List<PoPickupModel>> getPickupList(int preOrderId) async {
    try {
      final data = await _supabase
          .from('po_pickup')
          .select()
          .eq('pre_order_id', preOrderId); // Ambil semua yang cocok

      // Mapping ke List Model
      return (data as List).map((e) => PoPickupModel.fromJson(e)).toList();
    } catch (e) {
      return []; // Return list kosong jika error/tidak ada
    }
  }

  // --- CREATE PICKUP PLACES UNTUK PO TERTENTU ---
  Future<void> createPickupPlaces(
    int preOrderId,
    List<PoPickupModel> pickupPlaces,
  ) async {
    try {
      final List<Map<String, dynamic>> insertData = pickupPlaces.map((place) {
        return {
          'pre_order_id': preOrderId, // Primary/Foreign Key
          'date': place.date, // Matches schema
          'start_time': place.startTime, // Matches schema
          'end_time': place.endTime, // Matches schema
          'address': place.address, // Maps to 'address' in schema
          'detail_address': place.detailAddress, // Maps to 'detail_address'
          'longitude': place.longitude, // Matches schema
          'latitude': place.latitude, // ATTENTION: Using schema name 'latitude'
          'photo_location':
              place.photoLocation, // Maps to 'photo_location(json)'
        };
      }).toList();

      // Batch insert into Supabase
      await _supabase.from('po_pickup').insert(insertData);
    } catch (e) {
      throw Exception('Gagal membuat pickup places: $e');
    }
  }

  Future<List<PreOrderModel>> getPreOrdersByRestaurantId(
    int restaurantId,
  ) async {
    try {
      final data = await _supabase
          .from('pre_orders')
          .select()
          .eq('restaurant_id', restaurantId) // Filter: Column Name, Value
          .order('close_order_date', ascending: true);

      return (data as List).map((e) => PreOrderModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data Pre-Order Restaurant ini: $e');
    }
  }

  Future<PreOrderModel> createPreOrder(PreOrderModel preOrder) async {
    try {
      final data = preOrder.toJson();
      // Remove ID so Supabase generates it
      data.remove('pre_orders_id');
      data.remove('preOrderId');

      final res = await _supabase
          .from('pre_orders')
          .insert(data)
          .select() // Select returns the full inserted row
          .single();

      return PreOrderModel.fromJson(res);
    } catch (e) {
      throw Exception("Failed to create PreOrder: $e");
    }
  }

  Future<List<String>> uploadPickupImages(List<XFile> images) async {
    List<String> uploadedUrls = [];

    for (var image in images) {
      try {
        final bytes = await image.readAsBytes();
        final fileExt = image.name.split('.').last;
        // Nama file unik: timestamp_random.jpg
        final fileName =
            'pickup_${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final path =
            'pickup_locations/$fileName'; // Simpan di folder pickup_locations

        final mimeType = image.mimeType ?? 'image/$fileExt';

        await _supabase.storage
            .from('preorder-images')
            .uploadBinary(
              path,
              bytes,
              fileOptions: FileOptions(
                cacheControl: '3600',
                upsert: false,
                contentType: mimeType,
              ),
            );

        final imageUrl = _supabase.storage
            .from('preorder-images')
            .getPublicUrl(path);
        uploadedUrls.add(imageUrl);
      } catch (e) {
        debugPrint("Gagal upload salah satu gambar pickup: $e");
        // Kita lanjut ke gambar berikutnya meskipun satu gagal
      }
    }
    return uploadedUrls;
  }

  Future<void> createPoPickup(PoPickupModel pickup) async {
    try {
      final data = pickup.toJson();
      // Remove Child ID
      data.remove('po_pickup_id');
      data.remove('poPickupId');

      // Ensure Foreign Key is present (ViewModel should have added it)
      if (data['pre_order_id'] == null) {
        throw Exception("PreOrder ID is missing for Pickup");
      }

      await _supabase.from('po_pickup').insert(data);
    } catch (e) {
      throw Exception("Failed to create Pickup: $e");
    }
  }

  // --- [PERBAIKAN] UPLOAD IMAGE (WEB & MOBILE SUPPORT) ---
  Future<String?> uploadPreOrderImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      // [FIX 1] Gunakan 'name' untuk ambil ekstensi (aman untuk Web & Mobile)
      final fileExt = imageFile.name.split('.').last;

      final fileName = 'po_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = 'covers/$fileName';

      // [FIX 2] Gunakan mimeType bawaan XFile, atau fallback manual
      final mimeType = imageFile.mimeType ?? 'image/$fileExt';

      await _supabase.storage
          .from('preorder-images')
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: mimeType, // Pastikan content-type valid
            ),
          );

      final imageUrl = _supabase.storage
          .from('preorder-images')
          .getPublicUrl(path);
      return imageUrl;
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return null;
    }
  }

  Future<void> createPreOrderMenu(PreOrderMenuModel poMenu) async {
    try {
      // Manual map creation is often safer for simple join tables
      final data = {
        'pre_order_id': poMenu.preOrderId,
        'menu_id': poMenu.menuId,
        'stock': poMenu.stock,
      };

      await _supabase.from('pre_order_menu').insert(data);
    } catch (e) {
      throw Exception("Failed to link Menu: $e");
    }
  }

  Future<List<PreOrderModel>> getClosingSoonPreOrders() async {
    final now = DateTime.now().toIso8601String(); // Ambil waktu sekarang

    final response = await _supabase
        .from('pre_orders')
        .select()
        .eq('status', 'OPEN')
        .gte(
          'close_order_date',
          now,
        ) // Hanya ambil yang belum lewat tanggal tutupnya
        .order(
          'close_order_date',
          ascending: true,
        ) // Yang paling cepat tutup di atas
        .limit(5); // Ambil 5 saja

    return (response as List).map((e) => PreOrderModel.fromJson(e)).toList();
  }

  // 2. Logic "Bantu Larisin" (Hidden Gems/Upscale)
  // Ambil yang status OPEN, tapi current_quota masih sedikit (misal di bawah 5)
  Future<List<PreOrderModel>> getHiddenGemsPreOrders() async {
    final response = await _supabase
        .from('pre_orders')
        .select()
        .eq('status', 'OPEN')
        .lt('current_quota', 5) // Kurang dari 5 pesanan (Masih sepi)
        .order('created_at', ascending: false) // Tetap yang terbaru
        .limit(10);

    return (response as List).map((e) => PreOrderModel.fromJson(e)).toList();
  }

  // 3. Logic "Popular" (Yang paling laris)
  Future<List<PreOrderModel>> getPopularPreOrders() async {
    final response = await _supabase
        .from('pre_orders')
        .select()
        .eq('status', 'OPEN')
        .gt('current_quota', 5) // Yang sudah laku lebih dari 5
        .order('current_quota', ascending: false) // Urutkan dari yang terbanyak
        .limit(5);

    return (response as List).map((e) => PreOrderModel.fromJson(e)).toList();
  }

  // Ambil PO yang OPEN beserta data Pickup-nya (untuk ambil latitude/longitude)
  
  // file: repository/po_repository.dart

  Future<List<Map<String, dynamic>>> getWeeklySalesData(
    int restaurantId,
  ) async {
    try {
      // 1. Tentukan rentang waktu (7 hari lalu s/d sekarang)
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(
        const Duration(days: 6),
      ); // 6 hari lalu + hari ini = 7 hari

      // Format tanggal ke string ISO agar bisa dibaca Supabase
      // Mengambil awal hari (00:00:00) dari 7 hari lalu
      final startDate = DateTime(
        sevenDaysAgo.year,
        sevenDaysAgo.month,
        sevenDaysAgo.day,
      );

      // 2. Query ke Supabase
      final response = await _supabase
          .from('pre_orders')
          .select('order_date, total_amount')
          .eq('restaurant_id', restaurantId)
          .gte('order_date', startDate.toIso8601String())
          // Opsional: Filter hanya status tertentu
          // .eq('status', 'completed')
          .order('order_date', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching sales data: $e");
      return [];
    }
  }
  Future<List<PreOrderModel>> fetchPoByOwner(String ownerUuid) async {
    try {
      // Join ke tabel restaurants untuk filter by owner_id
      final response = await _supabase
          .from('pre_orders')
          .select('*, restaurants!inner(owner_id)')
          .eq('restaurants.owner_id', ownerUuid)
          .order('created_at', ascending: false);

      return (response as List).map((e) => PreOrderModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetching Owner POs: $e");
      return [];
    }
  }
}
