import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/repository/home_repository.dart';
import 'package:uc_marketplace/repository/po_repository.dart';

class HomeViewModel with ChangeNotifier {
  final _homeRepo = HomeRepository();
  final _poRepo = PreOrderRepository();
  // [BARU] State General Categories
  List<GeneralCategoryModel> _categories = [];
  List<GeneralCategoryModel> get categories => _categories;

  // State untuk Restaurant
  List<RestaurantModel> _restaurants = [];
  List<RestaurantModel> get restaurants => _restaurants;

  // State untuk Menu
  List<MenuModel> _menus = [];
  List<MenuModel> get menus => _menus;

  // --- STATE LIST PO (Untuk Home Page) ---
  List<PreOrderModel> _preOrders = [];
  List<PreOrderModel> get preOrders => _preOrders;

  // --- STATE MENU PO (Untuk Halaman Detail PO) ---
  List<MenuModel> _pOMenus = [];
  List<MenuModel> get pOMenus => _pOMenus;

  List<PreOrderModel> _closingSoonPreOrders = [];
  List<PreOrderModel> get closingSoonPreOrders => _closingSoonPreOrders;

  List<PreOrderModel> _hiddenGemsPreOrders = [];
  List<PreOrderModel> get hiddenGemsPreOrders => _hiddenGemsPreOrders;

  List<PreOrderModel> _popularPreOrders = [];
  List<PreOrderModel> get popularPreOrders => _popularPreOrders;

  // State Loading & Error
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  int _selectedCategoryId = 0;
  int get selectedCategoryId => _selectedCategoryId;
  // Constructor langsung panggil fetch data

  // [BARU] State untuk PO Dekat Saya
  List<PreOrderModel> _nearbyPOs = [];
  List<PreOrderModel> get nearbyPOs => _nearbyPOs;

  // Menyimpan jarak untuk ditampilkan di UI (misal: "1.2 km")
  Map<int, String> _poDistances = {};
  Map<int, String> get poDistances => _poDistances;

  bool _isLocationPermissionGranted = false;

  HomeViewModel() {
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Jalankan request secara paralel agar lebih cepat
      final results = await Future.wait([
        _homeRepo.getRestaurants(),
        _homeRepo.getMenus(),
        _poRepo.getActivePreOrders(),
        _poRepo.getAllPreOrderMenus(),
        _homeRepo.getCategories(), // Index 4 [BARU]
        _poRepo.getClosingSoonPreOrders(), // [BARU]
        _poRepo.getHiddenGemsPreOrders(), // [BARU]
        _poRepo.getPopularPreOrders(), // [BARU]
      ]);

      _restaurants = results[0] as List<RestaurantModel>;
      _menus = results[1] as List<MenuModel>;
      _preOrders = results[2] as List<PreOrderModel>;
      _pOMenus = results[3] as List<MenuModel>;
      _categories = results[4] as List<GeneralCategoryModel>; // [BARU]
      _closingSoonPreOrders = results[5] as List<PreOrderModel>; // [BARU]
      _hiddenGemsPreOrders = results[6] as List<PreOrderModel>; // [BARU]
      _popularPreOrders = results[7] as List<PreOrderModel>; // [BARU]

      await _fetchNearbyPOs();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchNearbyPOs() async {
    try {
      // A. Cek Permission & Ambil Lokasi
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      _isLocationPermissionGranted = true;

      // Ambil posisi user saat ini
      Position userPosition = await Geolocator.getCurrentPosition();

      // B. Ambil Data PO Raw (yang ada data pickup-nya)
      final rawData = await _poRepo.getActivePreOrdersWithLocation();

      List<Map<String, dynamic>> processedList = [];

      // C. Hitung Jarak
      for (var item in rawData) {
        // Convert ke Model
        final po = PreOrderModel.fromJson(item);

        // Cek Pickup Points di dalam PO ini
        // Asumsi response supabse: item['po_pickups'] adalah List
        List pickups = item['po_pickups'] ?? [];

        if (pickups.isEmpty) continue; // Skip kalau gak ada lokasi pickup

        double minDistance = double.infinity;

        // Cari pickup point terdekat dari user untuk PO ini
        for (var p in pickups) {
          double? lat = (p['altitude'] as num?)
              ?.toDouble(); // Ingat mapping latitude Anda 'altitude'
          double? long = (p['longitude'] as num?)?.toDouble();

          if (lat != null && long != null) {
            double dist = Geolocator.distanceBetween(
              userPosition.latitude,
              userPosition.longitude,
              lat,
              long,
            );
            if (dist < minDistance) minDistance = dist;
          }
        }

        // Simpan PO ini jika jaraknya valid (misal radius max 20km)
        if (minDistance != double.infinity && minDistance < 20000) {
          processedList.add({'po': po, 'distance_meter': minDistance});
        }
      }

      // D. Urutkan (Terdekat ke Terjauh)
      processedList.sort(
        (a, b) => (a['distance_meter'] as double).compareTo(
          b['distance_meter'] as double,
        ),
      );

      // E. Simpan ke State
      _nearbyPOs = processedList
          .map((e) => e['po'] as PreOrderModel)
          .take(5)
          .toList();

      // Simpan format teks jaraknya (biar gampang dipanggil di UI)
      _poDistances = {};
      for (var item in processedList) {
        final po = item['po'] as PreOrderModel;
        final dist = item['distance_meter'] as double;
        _poDistances[po.preOrderId!] = "${(dist / 1000).toStringAsFixed(1)} km";
      }
    } catch (e) {
      debugPrint("Error fetching nearby: $e");
    }
  }

  void selectCategory(int id) {
    _selectedCategoryId = id;
    notifyListeners();

    // Nanti di sini bisa ditambahkan logika filtering list Menu/PO
    // filterDataByCategoryId(id);
  }
}
