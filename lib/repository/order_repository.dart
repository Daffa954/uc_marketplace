import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/model.dart';

class OrderRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createOrder({
    required OrderModel order,
    required List<OrderItemModel> items,
  }) async {
    try {
      // 1. Insert Header Order -> Ambil ID Baru
      final res = await _supabase
          .from('orders')
          .insert(order.toJson())
          .select('order_id')
          .single();
      
      final newOrderId = res['order_id'] as int;

      // 2. Siapkan data items dengan order_id yang baru
      final List<Map<String, dynamic>> itemsData = items.map((item) {
        final json = item.toJson();
        json['order_id'] = newOrderId;
        return json;
      }).toList();

      // 3. Insert Detail Items
      await _supabase.from('order_items').insert(itemsData);
      
    } catch (e) {
      throw Exception("Gagal simpan order: $e");
    }
  }
}