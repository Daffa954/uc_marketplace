import 'package:uc_marketplace/model/model.dart'; // Sesuaikan import user model jika perlu

class RatingModel {
  final int? ratingId;
  final String userId;
  final int menuId;
  final int? orderId;
  final int? preOrderId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  
  // Opsional: Data user untuk menampilkan nama pereview
  final UserModel? user; 

  RatingModel({
    this.ratingId,
    required this.userId,
    required this.menuId,
    this.orderId,
    this.preOrderId,
    required this.rating,
    this.comment,
    this.createdAt,
    this.user,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      ratingId: json['rating_id'],
      userId: json['user_id'],
      menuId: json['menu_id'],
      orderId: json['order_id'],
      preOrderId: json['pre_order_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      // Mapping relasi user (jika di-join query)
      user: json['users'] != null ? UserModel.fromJson(json['users']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    // rating_id biasanya auto-gen, tidak perlu dikirim saat insert
    'user_id': userId,
    'menu_id': menuId,
    'order_id': orderId,
    'pre_order_id': preOrderId,
    'rating': rating,
    'comment': comment,
  };
}