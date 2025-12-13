part of 'pages.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final MapController _mapController = MapController();
  
  // Posisi default (Jakarta)
  LatLng _currentCenter = const LatLng(-6.1754, 106.8272);
  LatLng? _pickedLocation;
  
  // [PERBAIKAN 1] Tambahkan variabel ini agar tidak error
  bool _isLoading = true; 
  
  // Controller untuk Text Search
  final TextEditingController _searchController = TextEditingController();

  String _liveLat = "-6.1754";
  String _liveLong = "106.8272";

  // [PERBAIKAN 2] Tambahkan initState agar otomatis cari lokasi saat dibuka
  @override
  void initState() {
    super.initState();
    _getCurrentLocation(isButtonClick: false);
  }

  // [PERBAIKAN 3] Tambahkan parameter isButtonClick
  Future<void> _getCurrentLocation({bool isButtonClick = false}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    
    if (!serviceEnabled) {
      if(mounted) setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Lokasi (GPS) belum aktif"),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: "AKTIFKAN",
              textColor: Colors.white,
              onPressed: () async {
                await Geolocator.openLocationSettings();
                _getCurrentLocation(isButtonClick: true);
              },
            ),
          ),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if(mounted) setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if(mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (mounted) {
        setState(() {
          // 1. Update Pusat Peta
          _currentCenter = LatLng(position.latitude, position.longitude);
          
          // 2. Update Teks Koordinat
          _liveLat = position.latitude.toStringAsFixed(5);
          _liveLong = position.longitude.toStringAsFixed(5);
          
          _isLoading = false;

          // [PERBAIKAN UTAMA DISINI]
          // Jika ini dipanggil dari tombol, update _pickedLocation agar marker merah muncul
          if (isButtonClick) {
            _pickedLocation = LatLng(position.latitude, position.longitude);
            
            // (Opsional) Kosongkan search bar karena kita pakai GPS, bukan hasil search
            _searchController.clear(); 
          }
        });

        // Pindahkan Kamera
        if (isButtonClick) {
          _mapController.move(_currentCenter, 15.0);
        }
      }
    } catch (e) {
      debugPrint("Error location: $e");
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _searchPlaces(String query) async {
    if (query.isEmpty) return [];
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5');
    
    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'com.example.app'}, 
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((item) => {
          'display_name': item['display_name'],
          'lat': double.parse(item['lat']),
          'lon': double.parse(item['lon']),
        }).toList();
      }
    } catch (e) {
      debugPrint("Error searching: $e");
    }
    return [];
  }

  void _moveToLocation(double lat, double lon, String name) {
    _mapController.move(LatLng(lat, lon), 15.0);
    setState(() {
      _pickedLocation = LatLng(lat, lon);
      _searchController.text = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, 
      appBar: AppBar(title: const Text("Pilih Lokasi")),
      body: Stack(
        children: [
          // Tampilkan Loading jika sedang inisialisasi awal
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentCenter,
                    initialZoom: 15.0,
                    onTap: (_, point) {
                      setState(() => _pickedLocation = point);
                    },
                    onPositionChanged: (camera, hasGesture) {
                      setState(() {
                        // Gunakan ! karena center pasti ada
                        _liveLat = camera.center!.latitude.toStringAsFixed(5);
                        _liveLong = camera.center!.longitude.toStringAsFixed(5);
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        if (_pickedLocation != null)
                          Marker(
                            point: _pickedLocation!,
                            width: 80,
                            height: 80,
                            child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                          ),
                      ],
                    ),
                  ],
                ),

          // --- SEARCH BAR ---
          Positioned(
            top: 10, left: 15, right: 15,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: TypeAheadField<Map<String, dynamic>>(
                controller: _searchController,
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      hintText: "Cari lokasi...",
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  );
                },
                suggestionsCallback: (pattern) async {
                  return await _searchPlaces(pattern);
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    leading: const Icon(Icons.place, color: Colors.grey),
                    title: Text(suggestion['display_name'], maxLines: 2, overflow: TextOverflow.ellipsis),
                  );
                },
                onSelected: (suggestion) {
                  _moveToLocation(suggestion['lat'], suggestion['lon'], suggestion['display_name']);
                },
              ),
            ),
          ),

          // --- INFO KOORDINAT ---
          Positioned(
            bottom: 90, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.explore, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "Lat: $_liveLat   Long: $_liveLong",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // --- TOMBOL PILIH ---
          if (_pickedLocation != null)
            Positioned(
              bottom: 30, left: 20, right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7F27)),
                onPressed: () => Navigator.pop(context, _pickedLocation),
                child: const Text("Pilih Lokasi Ini", style: TextStyle(color: Colors.white)),
              ),
            ),

          // --- TOMBOL MY LOCATION ---
          Positioned(
            bottom: 150, 
            right: 20,
            child: FloatingActionButton(
              heroTag: "btn_my_location", 
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blue),
              onPressed: () {
                // Di sini kita set true, agar kamera bergerak ke lokasi user
                _getCurrentLocation(isButtonClick: true); 
              },
            ),
          ),
        ],
      ),
    );
  }
}