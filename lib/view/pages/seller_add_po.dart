part of 'pages.dart';
// Import your MapPickerPage and other necessary files here

// --- HELPER CLASS ---
// This holds the controllers for A SINGLE pickup location card
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

  // --- 1. PRE-ORDER DETAILS CONTROLLERS ---
  final TextEditingController _poNameController = TextEditingController();
  final TextEditingController _openDateController = TextEditingController();
  final TextEditingController _openTimeController = TextEditingController();
  final TextEditingController _closeDateController = TextEditingController();
  final TextEditingController _closeTimeController = TextEditingController();

  // --- 2. DYNAMIC PICKUP LOCATIONS ---
  // Start with one empty form
  final List<PickupFormController> _pickupForms = [PickupFormController()];

  // --- 3. MENU SELECTION ---
  // Store the IDs of selected menus
  final Set<int> _selectedMenuIds = {};

  @override
  void initState() {
    super.initState();
    // Fetch menus when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PreOrderViewModel>().fetchMenus();
    });
  }

  @override
  void dispose() {
    _poNameController.dispose();
    _openDateController.dispose();
    _openTimeController.dispose();
    _closeDateController.dispose();
    _closeTimeController.dispose();
    for (var form in _pickupForms) {
      form.dispose();
    }
    super.dispose();
  }

  // --- LOGIC: ADD/REMOVE PICKUP FORMS ---
  void _addPickupForm() {
    setState(() {
      _pickupForms.add(PickupFormController());
    });
  }

  void _removePickupForm(int index) {
    if (_pickupForms.length > 1) {
      setState(() {
        _pickupForms[index].dispose(); // Clean up controllers
        _pickupForms.removeAt(index);
      });
    }
  }

  // --- LOGIC: DATE PICKERS ---
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
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // --- LOGIC: MAP PICKER ---
  // We pass the controller specific to the card that clicked the button
  Future<void> _pickLocation(PickupFormController form) async {
    // Navigate to MapPickerPage
    /* final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerPage()),
    );

    if (result != null) {
      setState(() {
        form.lat.text = result.latitude.toStringAsFixed(6);
        form.lng.text = result.longitude.toStringAsFixed(6);
      });
    }
    */
    // Placeholder logic for now:
    form.lat.text = "-7.2575";
    form.lng.text = "112.7521";
  }

  // --- SUBMIT LOGIC ---
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedMenuIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one menu')),
        );
        return;
      }

      // 1. Prepare PreOrder Model
      final newPO = PreOrderModel(
        name: _poNameController.text,
        orderDate: _openDateController.text,
        orderTime: _openTimeController.text,
        closeOrderDate: _closeDateController.text,
        closeOrderTime: _closeTimeController.text,
        // restaurantId handled in VM usually
      );

      // 2. Prepare List of Pickups
      List<PoPickupModel> pickups = _pickupForms.map((form) {
        return PoPickupModel(
          preOrderId: 0, // Temp ID, will be assigned by DB
          address: form.placeName.text,
          detailAddress: form.desc.text,
          date: form.date.text,
          startTime: form.start.text,
          endTime: form.end.text,
          latitude: double.tryParse(form.lat.text),
          longitude: double.tryParse(form.lng.text),
        );
      }).toList();

      // 3. Prepare List of Menu IDs
      List<int> menuIds = _selectedMenuIds.toList();

      // 4. Send to ViewModel
      final vm = context.read<PreOrderViewModel>();
      final success = await vm.createFullPreOrder(
        preOrder: newPO,
        pickups: pickups,
        menuIds: menuIds,
      );

      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PreOrderViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Create Pre-Order", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
              // --- SECTION 1: PRE-ORDER DETAILS ---
              _buildSectionTitle("1. Pre-Order Details"),
              _buildTextField("Pre-Order Name", _poNameController, Icons.bookmark_border),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildDateField("Open Date", _openDateController)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField("Time (HH:mm:ss)", _openTimeController, Icons.access_time)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildDateField("Close Date", _closeDateController)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField("Time (HH:mm:ss)", _closeTimeController, Icons.access_time)),
                ],
              ),

              const SizedBox(height: 30),

              // --- SECTION 2: DYNAMIC PICKUP LOCATIONS ---
              _buildSectionTitle("2. Pickup Locations"),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pickupForms.length,
                separatorBuilder: (c, i) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  return _buildPickupCard(index);
                },
              ),
              
              // Add New Pickup Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: TextButton.icon(
                    onPressed: _addPickupForm,
                    icon: Icon(Icons.add_circle, color: primaryOrange),
                    label: Text("Add Another Pickup Location", style: TextStyle(color: primaryOrange)),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // --- SECTION 3: MENU SELECTION ---
              _buildSectionTitle("3. Select Menus"),
              const Text("Select the menus available for this Pre-Order:", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              
              viewModel.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : viewModel.menus.isEmpty 
                  ? const Text("No menus found.")
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: viewModel.menus.map((menu) {
                          final isSelected = _selectedMenuIds.contains(menu.menuId);
                          return CheckboxListTile(
                            activeColor: primaryOrange,
                            title: Text(menu.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Rp ${menu.price}"),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedMenuIds.add(menu.menuId!);
                                } else {
                                  _selectedMenuIds.remove(menu.menuId);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),

              const SizedBox(height: 40),

              // --- SUBMIT BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: viewModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Pre-Order", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool readOnly = false, VoidCallback? onTap}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: (v) => v!.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textGrey, fontSize: 13),
        prefixIcon: Icon(icon, color: primaryOrange, size: 20),
        filled: true,
        fillColor: fieldBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return _buildTextField(
      label, 
      controller, 
      Icons.calendar_today, 
      readOnly: true, 
      onTap: () => _selectDate(controller)
    );
  }

  Widget _buildPickupCard(int index) {
    final form = _pickupForms[index];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryOrange.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0,3))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Location #${index + 1}", style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold)),
              if (_pickupForms.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () => _removePickupForm(index),
                )
            ],
          ),
          const SizedBox(height: 10),
          _buildTextField("Place Name", form.placeName, Icons.storefront),
          const SizedBox(height: 10),
          _buildTextField("Description", form.desc, Icons.description),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildDateField("Date", form.date)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField("Start", form.start, Icons.access_time)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField("End", form.end, Icons.timer)),
            ],
          ),
          const SizedBox(height: 10),
          // Coordinates Row
          Row(
            children: [
              Expanded(child: _buildTextField("Lat", form.lat, Icons.location_on, readOnly: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField("Lng", form.lng, Icons.location_on, readOnly: true)),
              IconButton(
                icon: const Icon(Icons.map, color: Colors.blue),
                onPressed: () => _pickLocation(form),
              )
            ],
          )
        ],
      ),
    );
  }
}