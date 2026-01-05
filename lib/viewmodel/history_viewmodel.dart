import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/order_repository.dart';
import '../model/model.dart';

class HistoryViewModel with ChangeNotifier {
  final _repo = OrderRepository();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<OrderModel> _allOrders = [];
  
  // Getter untuk Tab "Berlangsung" (Pending, Paid, Process, Shipping)
  List<OrderModel> get activeOrders => _allOrders.where((o) {
    return o.status == 'PENDING' || 
           o.status == 'PAID' || 
           o.status == 'PROCESS' ||
           o.status == 'SHIPPING';
  }).toList();

  // Getter untuk Tab "Riwayat" (Completed, Cancelled)
  List<OrderModel> get pastOrders => _allOrders.where((o) {
    return o.status == 'COMPLETED' || 
           o.status == 'CANCELLED';
  }).toList();

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Ambil UUID langsung dari Session
      final user = Supabase.instance.client.auth.currentUser;
      
      if (user != null) {
        // 2. Langsung panggil Repo pakai UUID
        // Tidak perlu cari Integer ID lagi!
        _allOrders = await _repo.fetchOrdersByAuthId(user.id);
      }
    } catch (e) {
      debugPrint("Error Fetch History: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}