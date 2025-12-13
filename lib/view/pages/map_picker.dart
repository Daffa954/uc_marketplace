part of 'pages.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  // Koordinat default (misal: Jakarta) jika GPS belum aktif
  LatLng _currentCenter = const LatLng(-6.1754, 106.8272);
  LatLng? _pickedLocation; // Lokasi yang dipilih user
  final MapController _mapController = MapController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Fungsi untuk mendapatkan lokasi GPS user saat ini
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek servis GPS nyala/tidak
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Jika mati, pakai default location saja
      setState(() => _isLoading = false);
      return;
    }

    // Cek izin aplikasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    // // Ambil posisi
    // Position position = await Geolocator.getCurrentPosition();
    // setState(() {
    //   _currentCenter = LatLng(position.latitude, position.longitude);
    //   _isLoading = false;
    // });
    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
      setState(() {
        _currentCenter = LatLng(position.latitude, position.longitude);
        _isLoading = false; 
        // HAPUS BARIS INI: _mapController.move(...) 
        // Tidak perlu move manual, karena initialCenter di bawah akan menangani ini.
      });
    }
    } catch (e) {
      setState(() => _isLoading = false);
    }
    // // Pindahkan kamera peta ke lokasi user
    // _mapController.move(_currentCenter, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Lokasi Pengiriman")),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    // KUNCI PERBAIKAN:
                    // Saat _isLoading jadi false, widget ini baru dibuat.
                    // initialCenter akan otomatis memakai nilai _currentCenter terbaru.
                    initialCenter: _currentCenter, 
                    initialZoom: 15.0,
                    onTap: (_, point) => setState(() => _pickedLocation = point),
                  ),
                  children: [
                    // Layer 1: Gambar Peta dari OpenStreetMap
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.uc_marketplace',
                    ),

                    // Layer 2: Marker (Pin Merah)
                    MarkerLayer(
                      markers: [
                        // Tampilkan marker hanya jika user sudah memilih titik
                        if (_pickedLocation != null)
                          Marker(
                            point: _pickedLocation!,
                            width: 80,
                            height: 80,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

          // Tombol Konfirmasi di bagian bawah
          if (_pickedLocation != null)
            Positioned(
              left: 20,
              right: 20,
              bottom: 30,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Kirim data koordinat kembali ke halaman sebelumnya
                  Navigator.pop(context, _pickedLocation);
                },
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text(
                  "Pilih Lokasi Ini",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Sesuaikan warna tema Anda
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
        ],
      ),
      // Tombol untuk kembali ke lokasi saya (GPS)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            // Kita bungkus move() untuk memastikan peta sudah siap
             _mapController.move(_currentCenter, 15.0);
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
