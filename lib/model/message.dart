part of 'model.dart';
class MessageModel {
  final int? messageId;
  final int? chatId;
  final int? senderId;
  final String content;
  final String? dateSend;
  final String? timeSend;

  MessageModel({
    this.messageId,
    this.chatId,
    this.senderId,
    required this.content,
    this.dateSend,
    this.timeSend,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['message_id'],
      chatId: json['chat_id'],
      senderId: json['sender_id'],
      content: json['content'] ?? '',
      dateSend: json['date_send'],
      timeSend: json['time_send'],
    );
  }

  Map<String, dynamic> toJson() => {
    'chat_id': chatId,
    'sender_id': senderId,
    'content': content,
    // Date & Time biasanya auto generate di DB, tapi bisa dikirim jika perlu
  };
}