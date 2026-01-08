part of 'model.dart';

class OrderModel {
  final int? orderId;
  final int? userId; // Tetap int? sesuai permintaan
  final int? preOrderId;
  final int? poPickupId;
  final int total;
  final String? note;
  final List<OrderItemModel>? items;
  final String status;
  final String? createdAt;
  final PoPickupModel? pickup;

  // Midtrans Fields
  final String? paymentUrl;
  final String? snapToken;
  final String deliveryMethod;
  final int shippingCost;
  final String? shippingAddress;
  final String? shippingCourier;

  OrderModel({
    this.orderId,
    this.userId,
    this.preOrderId,
    this.poPickupId,
    required this.total,
    this.note,
    this.items,
    this.status = 'PENDING',
    this.createdAt,
    this.paymentUrl,
    this.snapToken,
    this.deliveryMethod = 'PICKUP',
    this.shippingCost = 0,
    this.shippingAddress,
    this.shippingCourier,
    this.pickup,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'],
      userId: json['user_id'],
      preOrderId: json['pre_order_id'],
      poPickupId: json['po_pickup_id'],
      total: json['total'] ?? 0,
      note: json['note'],
      status: json['status'] ?? 'PENDING',
      createdAt: json['created_at'],
      items: json['order_items'] != null 
          ? (json['order_items'] as List).map((i) => OrderItemModel.fromJson(i)).toList()
          : null,
      paymentUrl: json['payment_url'],
      snapToken: json['snap_token'],
      deliveryMethod: json['delivery_method'] ?? 'PICKUP',
      shippingCost: json['shipping_cost'] ?? 0,
      shippingAddress: json['shipping_address'],
      shippingCourier: json['shipping_courier'],
      // Mapping JOIN (Read Only)
      pickup: json['po_pickup'] != null ? PoPickupModel.fromJson(json['po_pickup']) : null,
    );
  }

  // [PERBAIKAN DISINI]
  // toJson() digunakan untuk INSERT ke Database.
  // Jangan kirim objek 'po_pickup' karena tabel orders tidak punya kolom itu.
  // Cukup kirim 'po_pickup_id'.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'pre_order_id': preOrderId,
      'po_pickup_id': poPickupId, // Ini yang benar (Foreign Key)
      'total': total,
      'note': note,
      'status': status,
      // 'created_at' biasanya auto-generated, boleh dihapus atau dibiarkan jika manual
      // 'created_at': createdAt, 
      'payment_url': paymentUrl,
      'snap_token': snapToken,
      'delivery_method': deliveryMethod,
      'shipping_cost': shippingCost,
      'shipping_address': shippingAddress,
      'shipping_courier': shippingCourier,
    };

    // Hapus null values agar tidak menimpa default value di DB (opsional tapi disarankan)
    data.removeWhere((key, value) => value == null);
    
    return data;
  }
}