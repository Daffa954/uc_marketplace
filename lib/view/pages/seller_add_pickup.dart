part of 'pages.dart';

class AddPickupPage extends StatefulWidget {
  final int preOrderId;

  const AddPickupPage({super.key, required this.preOrderId});

  @override
  State<AddPickupPage> createState() => _AddPickupPageState();
}

class _AddPickupPageState extends State<AddPickupPage> {
  final _formKey = GlobalKey<FormState>();

  // Custom Color Palette
  final Color primaryOrange = const Color(0xFFFF8A65);
  final Color fieldBackground = const Color(0xFFF5F5F5);
  final Color textDark = const Color(0xFF2D2D2D);
  final Color textGrey = const Color(0xFF757575);
  final Color creamBg = const Color(0xFFFFF3E0);

  // Controllers
  final TextEditingController _placeNameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  @override
  void dispose() {
    _placeNameController.dispose();
    _descController.dispose();
    _dateController.dispose();
    _startController.dispose();
    _endController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  // --- LOGIC: CONNECT TO MAP ---
  Future<void> _pickLocationFromMap() async {
    // Navigate to MapPickerPage and wait for the LatLng result
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerPage()),
    );

    // If a location was selected, update the text fields
    if (result != null) {
      setState(() {
        _latController.text = result.latitude.toStringAsFixed(6);
        _lngController.text = result.longitude.toStringAsFixed(6);
      });
    }
  }

  // Date Picker Logic
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryOrange),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: textGrey, fontSize: 14),
      prefixIcon: icon != null ? Icon(icon, color: primaryOrange, size: 20) : null,
      filled: true,
      fillColor: fieldBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryOrange, width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PreOrderViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Add Pickup Place', style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Section
              GestureDetector(
                onTap: () {}, // Image Picker can be added here
                child: Container(
                  height: 160, width: double.infinity,
                  decoration: BoxDecoration(color: creamBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryOrange.withOpacity(0.2))),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add_a_photo_rounded, size: 40, color: primaryOrange),
                    const SizedBox(height: 8),
                    Text('Upload Place Photo', style: TextStyle(color: primaryOrange, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
              const SizedBox(height: 24),

              // Location Details
              Text('Location Details', style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _placeNameController,
                validator: (v) => v!.isEmpty ? 'Required' : null,
                decoration: _inputDecoration('Place Name', Icons.storefront_rounded),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: _inputDecoration('Description / Landmark', null),
              ),
              const SizedBox(height: 24),

              // Timing
              Text('Timing', style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                validator: (v) => v!.isEmpty ? 'Select Date' : null,
                decoration: _inputDecoration('Pickup Date', Icons.calendar_today_rounded),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextFormField(controller: _startController, decoration: _inputDecoration('Start Time', Icons.access_time_rounded))),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: _endController, decoration: _inputDecoration('End / Duration', Icons.timer_rounded))),
              ]),
              const SizedBox(height: 24),

              // Map Coordinates (Connected to Friend's Page)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Map Coordinates', style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton.icon(
                    onPressed: _pickLocationFromMap,
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text("Open Map"),
                    style: TextButton.styleFrom(foregroundColor: primaryOrange),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    readOnly: true, // User should use the map to pick
                    onTap: _pickLocationFromMap,
                    decoration: _inputDecoration('Latitude', Icons.location_on_rounded),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lngController,
                    readOnly: true, // User should use the map to pick
                    onTap: _pickLocationFromMap,
                    decoration: _inputDecoration('Longitude', Icons.location_on_rounded),
                  ),
                ),
              ]),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      final newPlace = PoPickupModel(
                        preOrderId: widget.preOrderId,
                        address: _placeNameController.text,
                        date: _dateController.text,
                        startTime: _startController.text,
                        endTime: _endController.text,
                        latitude: double.tryParse(_latController.text),
                        longitude: double.tryParse(_lngController.text),
                      );

                      bool success = await viewModel.createPoPickupPlaces(widget.preOrderId, [newPlace]);

                      if (success && mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save Pickup Location', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}