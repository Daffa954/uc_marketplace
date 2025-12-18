import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/model.dart';

class ChatRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get chats for a specific seller
  Future<List<Map<String, dynamic>>> getSellerChats(int sellerId) async {
    print("ChatRepository: Fetching chats for sellerId: $sellerId");
    try {
      // Fetch chats where seller_id matches
      // We also want to know the name of the buyer (user_id)
      final response = await _supabase
          .from('chats')
          .select('*, users:user_id(name)')
          .eq('seller_id', sellerId);

      print("ChatRepository: Raw response for sellerId $sellerId: $response");
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("ChatRepository: Error fetching chats: $e");
      throw Exception("Gagal mengambil data chat: $e");
    }
  }

  // Get messages for a specific chat room
  Future<List<MessageModel>> getMessages(int chatId) async {
    print("ChatRepository: Fetching messages for chatId: $chatId");
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('chat_id', chatId)
          .order('message_id', ascending: true);

      print(
        "ChatRepository: Raw messages response for chatId $chatId: $response",
      );
      return (response as List).map((e) => MessageModel.fromJson(e)).toList();
    } catch (e) {
      print("ChatRepository: Error fetching messages: $e");
      throw Exception("Gagal mengambil pesan: $e");
    }
  }

  // Send a message
  Future<void> sendMessage({
    required int chatId,
    required int senderId,
    required String content,
  }) async {
    print(
      "ChatRepository: Sending message. ChatId: $chatId, SenderId: $senderId, Content: $content",
    );
    try {
      final now = DateTime.now();
      final dateSend = now.toIso8601String().split('T')[0];
      final timeSend =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      await _supabase.from('messages').insert({
        'chat_id': chatId,
        'sender_id': senderId,
        'content': content,
        'date_send': dateSend,
        'time_send': timeSend,
      });
      print("ChatRepository: Message sent successfully");
    } catch (e) {
      print("ChatRepository: Error sending message: $e");
      throw Exception("Gagal mengirim pesan: $e");
    }
  }

  // Create or get existing chat
  Future<int> createChat({required int sellerId, required int userId}) async {
    print(
      "ChatRepository: Creating chat for sellerId: $sellerId, userId: $userId",
    );
    try {
      // Check if chat exists
      final existing = await _supabase
          .from('chats')
          .select()
          .eq('seller_id', sellerId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        print("ChatRepository: Chat already exists: ${existing['payment_id']}");
        return existing['payment_id'] ?? existing['chat_id'];
      }

      // Create new chat
      final response = await _supabase
          .from('chats')
          .insert({'seller_id': sellerId, 'user_id': userId})
          .select()
          .single();

      print("ChatRepository: Chat created: $response");
      return response['payment_id'] ?? response['chat_id'];
    } catch (e) {
      print("ChatRepository: Error creating chat: $e");
      throw Exception("Gagal membuat chat: $e");
    }
  }
}
