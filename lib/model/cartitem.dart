part of 'model.dart';
class CartItem {
  final MenuModel menu;
  final PreOrderMenuModel? preOrderMenu;
  int quantity;

  CartItem({required this.menu,this.preOrderMenu, this.quantity = 1});
}