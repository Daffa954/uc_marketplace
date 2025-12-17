import 'package:flutter/material.dart';
import 'package:uc_marketplace/data/response/api_response.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/repository/BroadcastRepository.dart';

class BroadcastViewModel with ChangeNotifier {
  final BroadcastRepository _repo = BroadcastRepository();

  // State untuk menyimpan list broadcast
  ApiResponse<List<BroadcastModel>> _broadcastList = ApiResponse.loading();

  ApiResponse<List<BroadcastModel>> get broadcastList => _broadcastList;

  // Fungsi untuk memanggil data
  Future<void> fetchBroadcasts() async {
    _setBroadcastList(ApiResponse.loading());

    try {
      // Panggil repo (saat ini akan return dummy)
      final data = await _repo.getBroadcasts();
      _setBroadcastList(ApiResponse.completed(data));
    } catch (e) {
      _setBroadcastList(ApiResponse.error(e.toString()));
    }
  }

  void _setBroadcastList(ApiResponse<List<BroadcastModel>> response) {
    _broadcastList = response;
    notifyListeners();
  }
}