import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/repository/search_repository.dart';

class SearchViewModel with ChangeNotifier {
  final _searchRepo = SearchRepository();

  // --- STATE LOADING & STATUS ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  // [PENTING] Flag untuk membedakan mode tampilan di UI
  // false = Tampilkan list PreOrder (Hasil Text Search)
  // true  = Tampilkan list Pickup (Hasil Location Search)
  bool _isLocationResult = false;
  bool get isLocationResult => _isLocationResult;

  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  // --- DATA LISTS ---

  // 1. Hasil Text Search (PreOrder)
  List<PreOrderModel> _preOrderResults = [];
  List<PreOrderModel> get preOrderResults => _preOrderResults;

  // 2. Hasil Location Search (Pickup Points)
  List<PoPickupModel> _pickupResults = [];
  List<PoPickupModel> get pickupResults => _pickupResults;

  // 3. Data Awal (Saran & Menu Baru)
  List<PreOrderModel> _suggestedPreOrders = [];
  List<PreOrderModel> get suggestedPreOrders => _suggestedPreOrders;

  List<MenuModel> _newItems = [];
  List<MenuModel> get newItems => _newItems;

  // 4. Master Data Pickup (Untuk perhitungan jarak lokal)
  List<PoPickupModel> _allPoPickups = [];

  // History Keyword
  final List<String> _recentKeywords = ["Ayam", "Kopi", "Soto", "Burger"];
  List<String> get recentKeywords => _recentKeywords;

  // --- INIT ---
  SearchViewModel() {
    loadInitialData();
  }

  // Load data awal: Suggested PO, New Menu, dan Master Data Pickup
  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _searchRepo.getSuggestedPreOrders(), // Index 0
        _searchRepo.getNewItems(),           // Index 1
        _searchRepo.getAllPoPickups(),       // Index 2 (Simpan di memori)
      ]);

      _suggestedPreOrders = results[0] as List<PreOrderModel>;
      _newItems = results[1] as List<MenuModel>;
      _allPoPickups = results[2] as List<PoPickupModel>; 
      
    } catch (e) {
      debugPrint("Error loading search init data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- ACTIONS 1: TEXT SEARCH (PreOrder) ---
  void onSearch(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    _isSearching = true;
    _isLocationResult = false; // Tandai ini bukan hasil lokasi
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();

    // Update History
    if (!_recentKeywords.contains(query)) {
      _recentKeywords.insert(0, query);
      if (_recentKeywords.length > 5) _recentKeywords.removeLast();
    }

    try {
      // Panggil repo searchPreOrders
      _preOrderResults = await _searchRepo.searchPreOrders(query);
      
      // Kosongkan hasil pickup agar tidak bentrok
      _pickupResults = []; 
    } catch (e) {
      debugPrint("Error searching preorders: $e");
      _preOrderResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- ACTIONS 2: LOCATION SEARCH (PoPickup) ---
  Future<void> searchByLocation(LatLng userPickedLocation) async {
    _isSearching = true;
    _isLocationResult = true; // Tandai ini hasil lokasi
    _isLoading = true;
    _searchQuery = "📍 Lokasi Terpilih";
    notifyListeners();

    try {
      const Distance distanceCalculator = Distance();
      List<Map<String, dynamic>> tempResults = [];

      // Loop data master _allPoPickups yang sudah di-load di awal
      for (var pickup in _allPoPickups) {
        // Validasi koordinat (pastikan tidak null)
        if (pickup.latitude == null || pickup.longitude == null) continue;

        // Hitung jarak
        double distanceInMeters = distanceCalculator.as(
          LengthUnit.Meter,
          userPickedLocation,
          LatLng(pickup.latitude!, pickup.longitude!),
        );

        // Filter Radius 10KM
        if (distanceInMeters <= 10000) {
          tempResults.add({
            'data': pickup,
            'distance': distanceInMeters,
          });
        }
      }

      // Sorting berdasarkan jarak terdekat
      tempResults.sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
      );

      // Mapping kembali ke object model
      _pickupResults = tempResults.map((e) => e['data'] as PoPickupModel).toList();
      
      // Kosongkan hasil PreOrder text agar UI bersih
      _preOrderResults = [];

    } catch (e) {
      debugPrint("Error calculating nearest location: $e");
      _pickupResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset
  void clearSearch() {
    _isSearching = false;
    _isLocationResult = false;
    _searchQuery = "";
    _preOrderResults = [];
    _pickupResults = [];
    notifyListeners();
  }

  void setKeyword(String keyword) {
    onSearch(keyword);
  }
}