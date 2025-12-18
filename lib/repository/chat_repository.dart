import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/model.dart';

class ChatRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get chats for a specific seller
  Future<List<Map<String, dynamic>>> getSellerChats(int sellerId) async {
    try {
      // Fetch chats where seller_id matches
      // We also want to know the name of the buyer (user_id)
      final response = await _supabase
          .from('chats')
          .select('*, users:user_id(name)')
          .eq('seller_id', sellerId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception("Gagal mengambil data chat: $e");
    }
  }

  // Get messages for a specific chat room
  Future<List<MessageModel>> getMessages(int chatId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('chat_id', chatId)
          .order(
            'message_id',
            ascending: true,
          ); // Assuming message_id is auto-increment or use created_at

      return (response as List).map((e) => MessageModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Gagal mengambil pesan: $e");
    }
  }

  // Send a message
  Future<void> sendMessage({
    required int chatId,
    required int senderId,
    required String content,
  }) async {
    try {
      await _supabase.from('messages').insert({
        'chat_id': chatId,
        'sender_id': senderId,
        'content': content,
        // 'date_send': ... // If DB requires manual date/time, add here.
        // Usually Supabase handles created_at.
        // If the table strictly requires date_send/time_send strings:
        'date_send': DateTime.now().toIso8601String().split('T')[0],
        'time_send': "${DateTime.now().hour}:${DateTime.now().minute}",
      });
    } catch (e) {
      throw Exception("Gagal mengirim pesan: $e");
    }
  }

  // Create a new chat room (if needed, e.g. when buyer starts chat)
  // For seller feature, usually they just respond, but good to have.
}
