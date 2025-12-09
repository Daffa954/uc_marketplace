import 'package:flutter/material.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/repository/search_repository.dart';

class SearchViewModel with ChangeNotifier {
  final _searchRepo = SearchRepository();

  // --- STATE ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  // Data Lists
  List<RestaurantModel> _searchResults = [];
  List<RestaurantModel> get searchResults => _searchResults;

  List<RestaurantModel> _suggestedRestaurants = [];
  List<RestaurantModel> get suggestedRestaurants => _suggestedRestaurants;

  List<MenuModel> _newItems = [];
  List<MenuModel> get newItems => _newItems;

  // History Keyword (Sementara disimpan di memori, bisa pakai SharedPrefs jika mau permanen)
  final List<String> _recentKeywords = ["Ayam", "Kopi", "Soto", "Burger"];
  List<String> get recentKeywords => _recentKeywords;

  // --- INIT ---
  SearchViewModel() {
    loadInitialData();
  }

  // Load data awal (Suggested & New Items)
  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _searchRepo.getSuggestedRestaurants(),
        _searchRepo.getNewItems(),
      ]);

      _suggestedRestaurants = results[0] as List<RestaurantModel>;
      _newItems = results[1] as List<MenuModel>;
    } catch (e) {
      debugPrint("Error loading search init data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- ACTIONS ---

  // Fungsi saat user mengetik atau menekan enter
  void onSearch(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    _isSearching = true;
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();

    // Tambahkan ke history jika belum ada
    if (!_recentKeywords.contains(query)) {
      _recentKeywords.insert(0, query);
      if (_recentKeywords.length > 5) _recentKeywords.removeLast(); // Batasi 5
    }

    try {
      _searchResults = await _searchRepo.searchRestaurants(query);
    } catch (e) {
      debugPrint("Error searching: $e");
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset pencarian
  void clearSearch() {
    _isSearching = false;
    _searchQuery = "";
    _searchResults = [];
    notifyListeners();
  }

  void setKeyword(String keyword) {
    onSearch(keyword);
  }
}