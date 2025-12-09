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

  // --- 2. AMBIL MENU SPESIFIK UNTUK PO TERTENTU (JOIN QUERY) ---
  // Kita perlu join tabel 'pre_order_menu' dengan tabel 'menus'
  Future<List<MenuModel>> getMenusByPreOrder(int preOrderId) async {
    try {
      final data = await _supabase
          .from('pre_order_menu')
          // Syntax Join Supabase: ambil kolom menu, lalu expand detail menu-nya
          .select('menus(*)')
          .eq('pre_order_id', preOrderId);

      // Data yang kembali bentuknya List of Map:
      // [ { "menus": { "name": "Nasi", ... } }, { "menus": { ... } } ]

      return (data as List).map((e) {
        // Kita ambil object 'menus' di dalamnya
        return MenuModel.fromJson(e['menus']);
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil menu PO: $e');
    }
  }

  Future<List<MenuModel>> getAllPreOrderMenus() async {
    try {
      final data = await _supabase
          .from('pre_order_menu')
          .select('menus(*)'); // Ambil detail menu
      // .limit(20); // Opsional: Batasi jika datanya ribuan

      // Hasil data mentah: [{menus: {id: 1, name: A}}, {menus: {id: 1, name: A}}, {menus: {id: 2, name: B}}]

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
}
