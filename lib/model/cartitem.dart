part of 'model.dart';
class CartItem {
  final MenuModel menu;
  int quantity;

  CartItem({required this.menu, this.quantity = 1});
}