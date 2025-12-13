import 'package:flutter/material.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/repository/order_repository.dart';

class OrderViewModel with ChangeNotifier {
  final _repo = OrderRepository();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> placeOrder({
    required int userId,
    required int preOrderId,
    required List<CartItem> cartItems,
    required double totalPrice,
    String? note,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Siapkan Header
      final orderHeader = OrderModel(
        userId: userId,
        preOrderId: preOrderId,
        total: totalPrice.toInt(),
        note: note,
      );

      // 2. Siapkan Items (Convert CartItem ke OrderItemModel)
      final List<OrderItemModel> dbItems = cartItems.map((c) {
        return OrderItemModel(
          menuId: c.menu.menuId,
          quantity: c.quantity,
          price: double.tryParse(c.menu.price.toString()) ?? 0,
        );
      }).toList();

      // 3. Kirim ke Repo
      await _repo.createOrder(order: orderHeader, items: dbItems);
      return true;
    } catch (e) {
      debugPrint("Checkout Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}