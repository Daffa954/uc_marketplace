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
    setLoading(true);
    try {
      // 1. Get Restaurant ID for this user
      final restaurant = await _restaurantRepo.getRestaurantByOwnerId(userId);
      if (restaurant == null || restaurant.id == null) {
        _chatList = [];
        notifyListeners();
        return;
      }

      // 2. Get Chats for this restaurant
      final chats = await _chatRepo.getSellerChats(restaurant.id!);
      _chatList = chats;
    } catch (e) {
      debugPrint("Error fetching seller chats: $e");
    } finally {
      setLoading(false);
    }
  }

  // Fetch messages for a specific chat room
  Future<void> fetchMessages(int chatId) async {
    setLoading(true);
    try {
      final msgs = await _chatRepo.getMessages(chatId);
      _messages = msgs;
    } catch (e) {
      debugPrint("Error fetching messages: $e");
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
      rethrow;
    }
  }
}
