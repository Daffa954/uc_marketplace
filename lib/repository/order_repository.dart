import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/model.dart';

class OrderRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': newStatus})
          .eq('order_id', orderId);
    } catch (e) {
      throw Exception("Gagal update status: $e");
    }
  }
  // ... fungsi yang sudah ada ...

  // [BARU] Ambil pesanan berdasarkan ID Pre-Order tertentu
  Future<List<OrderModel>> fetchOrdersByPoId(int preOrderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            order_items (
              *,
              menus (name, image)
            ),
            users (name, email, phone) 
          ''') // Kita ambil data pembeli juga (nama, hp)
          .eq('pre_order_id', preOrderId)
          // Hanya ambil yang sudah dibayar ke atas (abaikan PENDING)
          .neq('status', 'PENDING')
          .order('created_at', ascending: false);

      final List<dynamic> data = response;
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil pesanan PO: $e');
    }
  }

  Future<int> createOrder({
    required OrderModel order,
    required List<OrderItemModel> items,
  }) async {
    try {
      // 1. Convert object ke Map/JSON
      final Map<String, dynamic> orderData = order.toJson();

      // [PERBAIKAN UTAMA]
      // Kita harus menghapus key 'order_id' agar Supabase tahu dia harus auto-generate ID-nya.
      // Jika key ini tetap ada (meskipun nilainya null), Supabase akan error.
      orderData.remove('order_id');

      // 2. Insert Header Order -> Ambil ID Baru
      final res = await _supabase
          .from('orders')
          .insert(orderData) // Kirim data yang sudah bersih (tanpa order_id)
          .select('order_id')
          .single();

      final newOrderId = res['order_id'] as int;

      // 3. Siapkan data items
      final List<Map<String, dynamic>> itemsData = items.map((item) {
        final json = item.toJson();

        // Masukkan ID order yang baru dibuat
        json['order_id'] = newOrderId;

        // [OPSIONAL TAPI DISARANKAN]
        // Jika di tabel order_items ada primary key auto-increment (misal: order_item_id)
        // Hapus juga key-nya agar tidak error sama seperti di atas.
        json.remove(
          'order_item_id',
        ); // Sesuaikan nama kolom PK tabel detail Anda
        json.remove('id'); // Jaga-jaga jika nama kolomnya id

        return json;
      }).toList();

      // 4. Insert Detail Items
      if (itemsData.isNotEmpty) {
        await _supabase.from('order_items').insert(itemsData);
      }
      return newOrderId;
    } catch (e) {
      // Lempar error agar bisa ditangkap ViewModel
      throw Exception("Repository Error: $e");
    }
  }

  Future<List<OrderModel>> fetchOrdersByAuthId(String authUuid) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            order_items (
              *,
              menus (name, image)
            ),
            users!inner ( auth_id ) 
          ''')
          // [KUNCI RAHASIANYA DISINI]
          // Kita filter berdasarkan kolom 'auth_id' milik tabel 'users' yang di-join
          .eq('users.auth_id', authUuid)
          .order('created_at', ascending: false);

      final List<dynamic> data = response;
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil history: $e');
    }
  }

  Future<List<OrderModel>> fetchOrders(String userId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            order_items (
              *,
              menus (name, image, price)
            ),
            po_pickup (*)  
          ''') // [PENTING] Tambahkan po_pickup (*) agar data lokasi terambil
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response;
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil history: $e');
    }
  }

  // 2. [BARU] Fungsi Konfirmasi Selesai
  Future<void> completeOrder(int orderId) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': 'COMPLETED'}) // Ubah status jadi Selesai
          .eq('order_id', orderId);
    } catch (e) {
      throw Exception("Gagal menyelesaikan pesanan: $e");
    }
  }
}
