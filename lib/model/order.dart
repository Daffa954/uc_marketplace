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
// [TAMBAHAN PENTING]
  final String status; // 'PENDING', 'PAID', 'COMPLETED', 'CANCELLED'
  final String? createdAt; // Untuk history
final PoPickupModel? pickup; // [BARU] Tambahkan field ini

// --- [WAJIB TAMBAH UNTUK MIDTRANS] ---
  final String? paymentUrl;  // Menyimpan Link Redirect Midtrans
  final String? snapToken;   // Menyimpan Token Transaksi Midtrans
  
  // --- [WAJIB TAMBAH UNTUK PENGIRIMAN] ---
  // Midtrans butuh rincian ini agar user tidak bingung totalnya dari mana
  final String deliveryMethod; // 'PICKUP' atau 'DELIVERY'
  final int shippingCost;      // Biaya Ongkir
  final String? shippingAddress; // Alamat User (Dikirim ke Midtrans sebagai Customer Detail)
  final String? shippingCourier; // JNE/POS/GOSEND (Untuk record)

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
      poPickupId: json['po_pickup_id'], // Parse dari JSON
      total: json['total'] ?? 0,
      note: json['note'],
      status: json['status'] ?? 'PENDING',
      createdAt: json['created_at'],
      // Logic untuk parsing items jika di-include dalam query supabase
      items: json['order_items'] != null 
          ? (json['order_items'] as List).map((i) => OrderItemModel.fromJson(i)).toList()
          : null,
          paymentUrl: json['payment_url'],
      snapToken: json['snap_token'],
      deliveryMethod: json['delivery_method'] ?? 'PICKUP',
      shippingCost: json['shipping_cost'] ?? 0,
      shippingAddress: json['shipping_address'],
      shippingCourier: json['shipping_courier'],
      pickup: json['po_pickup'] != null ? PoPickupModel.fromJson(json['po_pickup']) : null,

    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'pre_order_id': preOrderId,
    'po_pickup_id': poPickupId,
    'total': total,
    'note': note,
    'status': status,
    'created_at': createdAt,
    'payment_url': paymentUrl,
    'snap_token': snapToken,
    'delivery_method': deliveryMethod,
    'shipping_cost': shippingCost,
    'shipping_address': shippingAddress,
    'shipping_courier': shippingCourier,
    'po_pickup': pickup?.toJson(),


  };
}