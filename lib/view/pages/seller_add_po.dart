part of 'pages.dart';

// PASTIKAN IMPORT INI ADA
// import 'dart:io';
// import 'package:flutter/foundation.dart'; // Untuk kIsWeb
// import 'package:image_picker/image_picker.dart';

// --- HELPER CLASS ---
class PickupFormController {
  final TextEditingController placeName = TextEditingController();
  final TextEditingController desc = TextEditingController();
  final TextEditingController date = TextEditingController();
  final TextEditingController start = TextEditingController();
  final TextEditingController end = TextEditingController();
  final TextEditingController lat = TextEditingController();
  final TextEditingController lng = TextEditingController();

  void dispose() {
    placeName.dispose();
    desc.dispose();
    date.dispose();
    start.dispose();
    end.dispose();
    lat.dispose();
    lng.dispose();
  }
}

class SellerAddPreOrderPage extends StatefulWidget {
  const SellerAddPreOrderPage({super.key});

  @override
  State<SellerAddPreOrderPage> createState() => _SellerAddPreOrderPageState();
}

class _SellerAddPreOrderPageState extends State<SellerAddPreOrderPage> {
  final _formKey = GlobalKey<FormState>();

  // --- STYLE ---
  final Color primaryOrange = const Color(0xFFFF8A65);
  final Color fieldBackground = const Color(0xFFF5F5F5);
  final Color textGrey = const Color(0xFF757575);

  // --- CONTROLLERS ---
  final TextEditingController _poNameController = TextEditingController();
  final TextEditingController _openDateController = TextEditingController();
  final TextEditingController _openTimeController = TextEditingController();
  final TextEditingController _closeDateController = TextEditingController();
  final TextEditingController _closeTimeController = TextEditingController();

  final List<PickupFormController> _pickupForms = [PickupFormController()];
  final Map<int, TextEditingController> _menuStockControllers = {};

  // --- [PERBAIKAN 1] GUNAKAN XFILE (BUKAN FILE) ---
  XFile? _selectedImage;

  @override
  void dispose() {
    _poNameController.dispose();
    _openDateController.dispose();
    _openTimeController.dispose();
    _closeDateController.dispose();
    _closeTimeController.dispose();
    for (var form in _pickupForms) form.dispose();
    for (var controller in _menuStockControllers.values) controller.dispose();
    super.dispose();
  }

  // --- [PERBAIKAN 2] LOGIC PICK IMAGE ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Langsung terima XFile, tidak perlu cast ke File
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  // --- LOGIC: ADD/REMOVE FORMS ---
  void _addPickupForm() {
    setState(() {
      _pickupForms.add(PickupFormController());
    });
  }

  void _removePickupForm(int index) {
    if (_pickupForms.length > 1) {
      setState(() {
        _pickupForms[index].dispose();
        _pickupForms.removeAt(index);
      });
    }
  }

  // --- LOGIC: DATE & TIME PICKER ---
  Future<void> _selectDate(TextEditingController controller) async {
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
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
      final String formattedTime =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00";
      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  // --- LOGIC: MAP PICKER ---
  Future<void> _pickLocation(PickupFormController form) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerPage()),
    );

    if (result != null && result is LatLng) {
      setState(() {
        form.lat.text = result.latitude.toStringAsFixed(6);
        form.lng.text = result.longitude.toStringAsFixed(6);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lokasi dipilih: ${form.lat.text}, ${form.lng.text}")),
      );
    }
  }

  // --- LOGIC: MENU CHECKBOX ---
  void _toggleMenu(int menuId, bool? value) {
    setState(() {
      if (value == true) {
        _menuStockControllers[menuId] = TextEditingController();
      } else {
        _menuStockControllers[menuId]?.dispose();
        _menuStockControllers.remove(menuId);
      }
    });
  }

  // --- SUBMIT LOGIC ---
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_menuStockControllers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih minimal satu menu')),
      );
      return;
    }

    Map<int, int> menuStocksData = {};
    for (var entry in _menuStockControllers.entries) {
      final stockText = entry.value.text;
      if (stockText.isEmpty ||
          int.tryParse(stockText) == null ||
          int.parse(stockText) <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stok menu tidak boleh kosong atau 0')),
        );
        return;
      }
      menuStocksData[entry.key] = int.parse(stockText);
    }

    for (var form in _pickupForms) {
      if (form.lat.text.isEmpty || form.lng.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap pilih lokasi pada peta untuk semua titik pickup'),
          ),
        );
        return;
      }
    }

    try {
      final newPO = PreOrderModel(
        name: _poNameController.text,
        orderDate: _openDateController.text,
        orderTime: _openTimeController.text,
        closeOrderDate: _closeDateController.text,
        closeOrderTime: _closeTimeController.text,
        status: 'OPEN',
        currentQuota: 0,
        targetQuota: 100,
      );

      List<PoPickupModel> pickups = _pickupForms.map((form) {
        return PoPickupModel(
          preOrderId: 0,
          address: form.placeName.text,
          detailAddress: form.desc.text,
          date: form.date.text,
          startTime: form.start.text,
          endTime: form.end.text,
          latitude: double.tryParse(form.lat.text) ?? 0.0,
          longitude: double.tryParse(form.lng.text) ?? 0.0,
        );
      }).toList();

      final vm = context.read<PreOrderViewModel>();

      // [PERBAIKAN 3] LANGSUNG KIRIM XFILE KE VIEWMODEL
      // Tidak perlu konversi ke File() lagi karena ViewModel sudah diperbarui menerima XFile
      final success = await vm.createFullPreOrder(
        preOrder: newPO,
        pickups: pickups,
        menuStocks: menuStocksData,
        imageFile: _selectedImage, // Ini tipe datanya XFile? (Cocok!)
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pre-Order Berhasil Dibuat!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuat Pre-Order. Cek koneksi.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PreOrderViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Buat Jadwal Pre-Order",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- IMAGE PICKER UI ---
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[400]!),
                      // [PERBAIKAN 4] PREVIEW LOGIC
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: kIsWeb
                                  ? NetworkImage(_selectedImage!.path) // Web: Blob URL
                                  : FileImage(File(_selectedImage!.path)) as ImageProvider, // Mobile: File Path
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Upload Poster PO",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "(Wajib agar menarik)",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            children: [
                              Positioned(
                                right: 10,
                                top: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // ... SISA UI TETAP SAMA ...
              _buildSectionTitle("1. Detail Pre-Order"),
              _buildTextField("Nama Batch PO", _poNameController, Icons.bookmark_border),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildDateField("Tgl Buka", _openDateController)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTimeField("Jam Buka", _openTimeController)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildDateField("Tgl Tutup", _closeDateController)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTimeField("Jam Tutup", _closeTimeController)),
                ],
              ),
              const SizedBox(height: 30),

              _buildSectionTitle("2. Lokasi Pengambilan"),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pickupForms.length,
                separatorBuilder: (c, i) => const SizedBox(height: 20),
                itemBuilder: (context, index) => _buildPickupCard(index),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: TextButton.icon(
                    onPressed: _addPickupForm,
                    icon: Icon(Icons.add_circle, color: primaryOrange),
                    label: Text(
                      "Tambah Lokasi Lain",
                      style: TextStyle(color: primaryOrange),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              _buildSectionTitle("3. Pilih Menu & Stok"),
              const Text(
                "Centang menu dan isi jumlah stock yang tersedia:",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 15),

              viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : viewModel.menus.isEmpty
                  ? const Text(
                      "Belum ada menu.",
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: viewModel.menus.length,
                        separatorBuilder: (c, i) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final menu = viewModel.menus[index];
                          final isSelected = _menuStockControllers.containsKey(
                            menu.menuId,
                          );
                          return Container(
                            color: isSelected
                                ? primaryOrange.withOpacity(0.05)
                                : Colors.transparent,
                            child: Column(
                              children: [
                                CheckboxListTile(
                                  activeColor: primaryOrange,
                                  title: Text(
                                    menu.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text("Rp ${menu.price}"),
                                  value: isSelected,
                                  onChanged: (val) =>
                                      _toggleMenu(menu.menuId!, val),
                                ),
                                if (isSelected)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      50,
                                      0,
                                      20,
                                      15,
                                    ),
                                    child: Row(
                                      children: [
                                        const Text(
                                          "Stok: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                _menuStockControllers[menu
                                                    .menuId],
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              hintText: "0",
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 8,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            validator: (val) =>
                                                isSelected &&
                                                    (val == null || val.isEmpty)
                                                ? "Wajib isi"
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          "Porsi",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Buat Jadwal Pre-Order",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER METHODS ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textGrey, fontSize: 13),
        prefixIcon: Icon(icon, color: primaryOrange, size: 20),
        filled: true,
        fillColor: fieldBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) =>
      _buildTextField(
        label,
        controller,
        Icons.calendar_today,
        readOnly: true,
        onTap: () => _selectDate(controller),
      );

  Widget _buildTimeField(String label, TextEditingController controller) =>
      _buildTextField(
        label,
        controller,
        Icons.access_time,
        readOnly: true,
        onTap: () => _selectTime(controller),
      );

  Widget _buildPickupCard(int index) {
    final form = _pickupForms[index];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryOrange.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField("Nama Tempat", form.placeName, Icons.storefront),
          const SizedBox(height: 10),
          _buildTextField("Detail Alamat", form.desc, Icons.description),
          const SizedBox(height: 10),
          _buildDateField("Tgl Pickup", form.date),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildTimeField("Mulai", form.start)),
              const SizedBox(width: 8),
              Expanded(child: _buildTimeField("Selesai", form.end)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "Lat",
                  form.lat,
                  Icons.location_on,
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  "Lng",
                  form.lng,
                  Icons.location_on,
                  readOnly: true,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.map, color: Colors.blue),
                onPressed: () => _pickLocation(form),
              ),
            ],
          ),
        ],
      ),
    );
  }
}