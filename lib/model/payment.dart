// --- 10. PAYMENT MODEL ---
part of 'model.dart';

class PaymentModel {
  final int? paymentId;
  final int? orderId;
  final DateTime? paidAt;
  final PaymentMethod? method;
  final PaymentStatus status;
  final String? paymentProof; 

  PaymentModel({
    this.paymentId,
    this.orderId,
    this.paidAt,
    this.method,
    this.status = PaymentStatus.PENDING,
    this.paymentProof, // Default value sesuai DB
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentId: json['payment_id'],
      orderId: json['order_id'],
      paidAt: json['paid_at'] != null 
          ? DateTime.parse(json['paid_at']) 
          : null,
      // Menggunakan helper enumFromString yang ada di enums.dart
      method: json['method'] != null 
          ? enumFromString(PaymentMethod.values, json['method']) 
          : null,
      status: json['status'] != null 
          ? enumFromString(PaymentStatus.values, json['status']) 
          : PaymentStatus.PENDING,
    );
  }

  Map<String, dynamic> toJson() => {
    'order_id': orderId,
    'paid_at': paidAt?.toIso8601String(),
    // Mengirim string ENUM ke Supabase (misal: 'QRIS', 'PAID')
    'method': method?.toString().split('.').last,
    'status': status.toString().split('.').last,
    'payment_proof': paymentProof,
  };
}