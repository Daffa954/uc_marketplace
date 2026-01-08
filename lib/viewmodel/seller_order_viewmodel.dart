import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/repository/order_repository.dart';
import 'package:uc_marketplace/repository/po_repository.dart'; // Pastikan path benar

class SellerOrderViewModel with ChangeNotifier {
  final _orderRepo = OrderRepository();
  final _poRepo = PreOrderRepository(); 

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- STATE LIST PO (HALAMAN DEPAN) ---
  List<PreOrderModel> _myPOs = [];
  List<PreOrderModel> get myPOs => _myPOs;

  // --- STATE LIST PESANAN (HALAMAN DETAIL) ---
  List<OrderModel> _poOrders = [];
  
  // Getter Order berdasarkan Status untuk TabView
  List<OrderModel> get newOrders => _poOrders.where((o) => o.status == 'PAID').toList();
  List<OrderModel> get processOrders => _poOrders.where((o) => o.status == 'PROCESS').toList();
  List<OrderModel> get shippingOrders => _poOrders.where((o) => o.status == 'SHIPPING').toList();
  List<OrderModel> get completedOrders => _poOrders.where((o) => o.status == 'COMPLETED' || o.status == 'CANCELLED').toList();

  // 1. Ambil Semua PO milik Seller (Login User)
  Future<void> fetchMyPOs() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Kita gunakan fungsi fetchPoByOwner yang ada di PoRepository
        _myPOs = await _poRepo.fetchPoByOwner(user.id);
      }
    } catch (e) {
      debugPrint("Error fetch PO List: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Ambil Order di dalam satu PO
  Future<void> fetchOrdersInPO(int preOrderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _poOrders = await _orderRepo.fetchOrdersByPoId(preOrderId);
    } catch (e) {
      debugPrint("Error fetch Orders in PO: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Update Status Order
  Future<void> updateOrderStatus(int orderId, String newStatus, int preOrderId) async {
    try {
      await _orderRepo.updateOrderStatus(orderId, newStatus);
      // Refresh data setelah update
      await fetchOrdersInPO(preOrderId); 
    } catch (e) {
      rethrow;
    }
  }
}