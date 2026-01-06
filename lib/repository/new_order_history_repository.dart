import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/new_order_history.dart';

class NewOrderHistoryRepository {
  final _supabase = Supabase.instance.client;

  Future<List<NewOrderHistoryModel>> fetchAllOrders(int userId) async {
    final response = await _supabase
        .from('orders')
        .select('''
          *,
          pre_orders (
            seller:sellers (name, logo_url)
          ),
          order_items (id)
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => NewOrderHistoryModel.fromSupabase(e)).toList();
  }
}