part of 'model.dart';
class ChatModel {
  final int? chatId;
  final int? userId;
  final int? sellerId;
  final int? rating;
  final String? reviewText;

  ChatModel({
    this.chatId,
    this.userId,
    this.sellerId,
    this.rating,
    this.reviewText,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      chatId: json['chat_id'],
      userId: json['user_id'],
      sellerId: json['seller_id'],
      rating: json['rating'],
      reviewText: json['review_text'],
    );
  }
}