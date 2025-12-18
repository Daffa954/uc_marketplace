part of 'model.dart';

class PreOrderModel {
  final int? preOrderId;
  final int? restaurantId;
  final String name;
  final String? orderDate; // Gunakan String YYYY-MM-DD agar mudah
  final String? orderTime; // Gunakan String HH:mm:ss
  final String? closeOrderDate;
  final String? closeOrderTime;

  PreOrderModel({
    this.preOrderId,
    this.restaurantId,
    required this.name,
    this.orderDate,
    this.orderTime,
    this.closeOrderDate,
    this.closeOrderTime,
  });

  factory PreOrderModel.fromJson(Map<String, dynamic> json) {
    return PreOrderModel(
      preOrderId: json['pre_order_id'],
      restaurantId: json['restaurant_id'],
      name: json['name'] ?? '',
      orderDate: json['order_date'],
      orderTime: json['order_time'],
      closeOrderDate: json['close_order_date'],
      closeOrderTime: json['close_order_time'],
    );
  }

  Map<String, dynamic> toJson() => {
    'restaurant_id': restaurantId,
    'name': name,
    'order_date': orderDate,
    'order_time': orderTime,
    'close_order_date': closeOrderDate,
    'close_order_time': closeOrderTime,
  };

  PreOrderModel copyWith({
    int? preOrderId,
    int? restaurantId,
    String? name,
    String? orderDate,
    String? orderTime,
    String? closeOrderDate,
    String? closeOrderTime,
  }) {
    return PreOrderModel(
      preOrderId: preOrderId ?? this.preOrderId,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      orderDate: orderDate ?? this.orderDate,
      orderTime: orderTime ?? this.orderTime,
      closeOrderDate: closeOrderDate ?? this.closeOrderDate,
      closeOrderTime: closeOrderTime ?? this.closeOrderTime,
    );
  }
}
