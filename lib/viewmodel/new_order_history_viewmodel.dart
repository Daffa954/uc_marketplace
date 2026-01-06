import 'package:flutter/material.dart';
import '../model/new_order_history.dart';
import '../repository/new_order_history_repository.dart';
import 'auth_viewmodel.dart';

class NewOrderHistoryViewModel extends ChangeNotifier {
  final _repo = NewOrderHistoryRepository();
  final AuthViewModel _authVM;

  NewOrderHistoryViewModel({required AuthViewModel authVM}) : _authVM = authVM;

  List<NewOrderHistoryModel> _orders = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<NewOrderHistoryModel> get ongoing => _orders
      .where((o) => o.status == 'PENDING' || o.status == 'PAID')
      .toList();

  List<NewOrderHistoryModel> get history => _orders
      .where((o) => o.status == 'COMPLETED' || o.status == 'CANCELLED')
      .toList();

  Future<void> loadOrders() async {
    final user = _authVM.currentUser;
    if (user == null) return;
    
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _repo.fetchAllOrders(int.parse(user.userId.toString()));
    } catch (e) {
      debugPrint("Error loading orders: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}