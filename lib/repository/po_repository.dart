import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/model.dart';

class PreOrderRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

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

      

      return (data as List).map((e) {
        if (e['menus'] == null) return null;

      
        final Map<String, dynamic> menuData = Map<String, dynamic>.from(e['menus']);
        
        // Inject ID Relasi agar tidak NULL
        menuData['pre_order_menu_id'] = e['pre_order_menu_id']; 
        
      
        return MenuModel.fromJson(menuData);
      }).whereType<MenuModel>().toList(); // Filter null jika ada data kotor

    } catch (e) {
      throw Exception('Gagal mengambil menu PO: $e');
    }
  }

  Future<List<MenuModel>> getAllPreOrderMenus() async {
    try {
      final data = await _supabase
          .from('pre_order_menu')
          .select('menus(*)'); 

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
}
