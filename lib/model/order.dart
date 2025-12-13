// --- 6. ORDER MODEL ---
part of 'model.dart';

class OrderModel {
  final int? orderId;
  final int? userId;
  final int? preOrderId;
  final int? poPickupId;
  final int total;
  final String? note;
  final List<OrderItemModel>? items;


  OrderModel({
    this.orderId,
    this.userId,
    this.preOrderId,
    this.poPickupId,
    required this.total,
    this.note,
    this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'],
      userId: json['user_id'],
      preOrderId: json['pre_order_id'],
      poPickupId: json['po_pickup_id'], // Parse dari JSON
      total: json['total'] ?? 0,
      note: json['note'],
      // Logic untuk parsing items jika di-include dalam query supabase
      items: json['order_items'] != null 
          ? (json['order_items'] as List).map((i) => OrderItemModel.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'order_id': orderId,
    'user_id': userId,
    'pre_order_id': preOrderId,
    'po_pickup_id': poPickupId,
    'total': total,
    'note': note,
  };
}