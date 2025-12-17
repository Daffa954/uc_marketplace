import 'package:flutter/material.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/repository/order_repository.dart';
import 'package:uc_marketplace/viewmodel/auth_viewmodel.dart';

class OrderViewModel with ChangeNotifier {
  final _repo = OrderRepository();

  final AuthViewModel _authVM;

  // Constructor menerima AuthVM
  OrderViewModel({required AuthViewModel authVM}) : _authVM = authVM;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<int?> submitOrder({
    required int preOrderId,
    required List<CartItem> cartItems, // Item di keranjang
    required String deliveryMode, // "Pick up" atau "Delivery"
    PoPickupModel? pickupLocation, // Objek lokasi (bisa null)
    String? userNote, // Catatan dari textfield
  }) async {
    // --- 1. VALIDASI USER LANGSUNG DARI SUMBERNYA ---
    final user = _authVM.currentUser;
    if (user == null || user.userId == null) {
      throw "User belum login atau sesi habis.";
    }
    if (cartItems.isEmpty) {
      throw "Keranjang kosong.";
    }

    if (deliveryMode == "Pick up" && pickupLocation == null) {
      throw "Harap pilih lokasi pengambilan terlebih dahulu.";
    }

    _isLoading = true;
    notifyListeners();

    try {
      // --- 2. FORMATTING LOGIC (CATATAN) ---
      String finalNote = "";
      if (userNote != null && userNote.isNotEmpty) {
        finalNote += "Note: $userNote | ";
      }
      finalNote += "Mode: $deliveryMode";

      if (deliveryMode == "Pick up" && pickupLocation != null) {
        finalNote +=
            " @ ${pickupLocation.address} (${pickupLocation.startTime})";
      }

      // --- 3. CALCULATION LOGIC (TOTAL HARGA) ---
      double totalPrice = 0;
      for (var item in cartItems) {
        double price = double.tryParse(item.menu.price.toString()) ?? 0;
        totalPrice += price * item.quantity;
      }

      // --- 4. MAPPING DATA (CART -> MODEL DB) ---
      // Siapkan Header
      final orderHeader = OrderModel(
        userId: int.tryParse(user.userId.toString()) ?? 0,
        preOrderId: preOrderId,
        total: totalPrice.toInt(),
        note: finalNote,
        poPickupId: pickupLocation!.poPickupId ?? 0,
        // status: 'Pending' // Jika ada field status default
      );

      // Siapkan Items
      final List<OrderItemModel> dbItems = cartItems.map((c) {
        return OrderItemModel(
          menuId: c.menu.menuId,
          preOrderMenuId: c.menu.preOrderMenuId,
          quantity: c.quantity,
          price: double.tryParse(c.menu.price.toString()) ?? 0,
        );
      }).toList();

      // --- 5. CALL REPOSITORY ---
      // await _repo.createOrder(order: orderHeader, items: dbItems);
      int newOrderId = await _repo.createOrder(
        order: orderHeader,
        items: dbItems,
      );

      return newOrderId; // SUKSES: Return ID
     
    } catch (e) {
      debugPrint("Checkout Error: $e");
      throw "Gagal membuat pesanan: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
