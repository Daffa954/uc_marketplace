// --- 9. BroadcastModel MODEL ---
part of 'model.dart';

class BroadcastModel {
  final int? broadcastId;
  final int? preOrderId;
  final String message;
  final DateTime? createdAt;

  BroadcastModel({
    this.broadcastId,
    this.preOrderId,
    required this.message,
    this.createdAt,
  });

  factory BroadcastModel.fromJson(Map<String, dynamic> json) {
    return BroadcastModel(
      broadcastId: json['broadcast_id'],
      preOrderId: json['pre_order_id'],
      message: json['message'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    // broadcast_id biasanya auto-increment, jadi tidak perlu dikirim saat insert
    'pre_order_id': preOrderId,
    'message': message,
    // created_at biasanya default NOW() di database
  };
}