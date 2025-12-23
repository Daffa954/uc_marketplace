part of 'model.dart';

class PreOrderModel {
  final int? preOrderId;
  final int? restaurantId;
  final String name;
  final String? orderDate; // Gunakan String YYYY-MM-DD agar mudah
  final String? orderTime; // Gunakan String HH:mm:ss
  final String? closeOrderDate;
  final String? closeOrderTime;

// [BARU] Field Wajib Tambahan
  final String status;        // 'OPEN', 'CLOSED', 'COMPLETED'
  final int currentQuota;     // Jumlah yang sudah dipesan (misal: 2)
  final int targetQuota;      // Target maksimal (misal: 20)
  final String? image;        // URL Gambar Banner PO
  PreOrderModel({
    this.preOrderId,
    this.restaurantId,
    required this.name,
    this.orderDate,
    this.orderTime,
    this.closeOrderDate,
    this.closeOrderTime,
    this.status = 'OPEN',
    this.currentQuota = 0,
    this.targetQuota = 0,
    this.image,

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
      // [BARU] Mapping dari Database
      status: json['status'] ?? 'OPEN',
      currentQuota: json['current_quota'] ?? 0,
      targetQuota: json['target_quota'] ?? 0,
      image: json['image'], // Pastikan di DB tipe text/varchar
    );
  }

  Map<String, dynamic> toJson() => {
    'restaurant_id': restaurantId,
    'name': name,
    'order_date': orderDate,
    'order_time': orderTime,
    'close_order_date': closeOrderDate,
    'close_order_time': closeOrderTime,

    'status': status,
    'current_quota': currentQuota,
    'target_quota': targetQuota,
    'image': image,
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
