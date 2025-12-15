import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/model.dart';

class OrderRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createOrder({
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
        json.remove('order_item_id'); // Sesuaikan nama kolom PK tabel detail Anda
        json.remove('id'); // Jaga-jaga jika nama kolomnya id
        
        return json;
      }).toList();

      // 4. Insert Detail Items
      if (itemsData.isNotEmpty) {
        await _supabase.from('order_items').insert(itemsData);
      }
      
    } catch (e) {
      // Lempar error agar bisa ditangkap ViewModel
      throw Exception("Repository Error: $e");
    }
  }
}