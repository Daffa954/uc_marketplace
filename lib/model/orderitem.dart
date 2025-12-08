part of 'model.dart';
class OrderItemModel {
  final int? orderItemId;
  final int? orderId;
  final int? menuId;
  final int quantity;
  final double price; // Decimal di DB
  final String? note;

  // Optional: untuk menampilkan nama menu saat UI render (hasil join)
  final MenuModel? menu; 

  OrderItemModel({
    this.orderItemId,
    this.orderId,
    this.menuId,
    required this.quantity,
    required this.price,
    this.note,
    this.menu,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      orderItemId: json['order_item_id'],
      orderId: json['order_id'],
      menuId: json['menu_id'],
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      note: json['note'],
      // Jika melakukan join table menus: select(*, menus(*))
      menu: json['menus'] != null ? MenuModel.fromJson(json['menus']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'order_id': orderId,
    'menu_id': menuId,
    'quantity': quantity,
    'price': price,
    'note': note,
  };
}