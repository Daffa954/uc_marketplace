import 'package:flutter/material.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/repository/chat_repository.dart';
import 'package:uc_marketplace/repository/restaurant_repository.dart';

class ChatViewModel with ChangeNotifier {
  final _chatRepo = ChatRepository();
  final _restaurantRepo = RestaurantRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _chatList = [];
  List<Map<String, dynamic>> get chatList => _chatList;

  List<MessageModel> _messages = [];
  List<MessageModel> get messages => _messages;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Fetch chats for the seller (logged in user)
  Future<void> fetchSellerChats(int userId) async {
    print("ChatViewModel: fetchSellerChats called for userId: $userId");
    setLoading(true);
    try {
      // BYPASS: Use userId directly as sellerId
      print(
        "ChatViewModel: Bypassing restaurant check. Using userId $userId as sellerId.",
      );
      final chats = await _chatRepo.getSellerChats(userId);

      print("ChatViewModel: Fetched ${chats.length} chats");
      _chatList = chats;
    } catch (e) {
      debugPrint("Error fetching seller chats: $e");
      print("ChatViewModel: Error fetching seller chats: $e");
    } finally {
      setLoading(false);
    }
  }

  // Fetch messages for a specific chat room
  Future<void> fetchMessages(int chatId) async {
    print("ChatViewModel: fetchMessages called for chatId: $chatId");
    setLoading(true);
    try {
      final msgs = await _chatRepo.getMessages(chatId);
      print("ChatViewModel: Fetched ${msgs.length} messages");
      _messages = msgs;
    } catch (e) {
      debugPrint("Error fetching messages: $e");
      print("ChatViewModel: Error fetching messages: $e");
    } finally {
      setLoading(false);
    }
  }

  // Send a message
  Future<void> sendMessage({
    required int chatId,
    required int senderId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return;

    print(
      "ChatViewModel: sendMessage called. ChatId: $chatId, SenderId: $senderId",
    );
    try {
      await _chatRepo.sendMessage(
        chatId: chatId,
        senderId: senderId,
        content: content,
      );
      // Refresh messages
      await fetchMessages(chatId);
    } catch (e) {
      debugPrint("Error sending message: $e");
      print("ChatViewModel: Error sending message: $e");
      rethrow;
    }
  }

  // Create a new chat
  Future<void> createChat(int sellerId, int userId) async {
    setLoading(true);
    try {
      await _chatRepo.createChat(sellerId: sellerId, userId: userId);
      // Refresh the list
      await fetchSellerChats(sellerId);
    } catch (e) {
      debugPrint("Error creating chat: $e");
      print("ChatViewModel: Error creating chat: $e");
      rethrow;
    } finally {
      setLoading(false);
    }
  }
}
