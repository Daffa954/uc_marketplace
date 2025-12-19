part of 'pages.dart';

class AddEditMenuPage extends StatefulWidget {
  final MenuModel? item;

  const AddEditMenuPage({super.key, this.item});

  @override
  State<AddEditMenuPage> createState() => _AddEditMenuPageState();
}

class _AddEditMenuPageState extends State<AddEditMenuPage> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;

  // [BARU] State untuk menyimpan tipe menu
  MenuType _selectedType = MenuType.FOOD; 

  bool _isEditing = false;
  bool _isNewItem = false;

  final Color _primaryOrange = const Color(0xFFffa652);
  final Color _textBrown = const Color(0xFF593A1D);

  @override
  void initState() {
    super.initState();
    _isNewItem = widget.item == null;
    _isEditing = _isNewItem;

    // [BARU] Inisialisasi tipe jika edit mode
    if (widget.item != null) {
      _selectedType = widget.item!.type;
    }

    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descController = TextEditingController(text: widget.item?.description ?? '');
    _priceController = TextEditingController(
        text: widget.item != null ? widget.item!.price.toString() : '');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<AddEditMenuViewModel>().setImage(null);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      context.read<AddEditMenuViewModel>().setImage(image);
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = true;
    });
  }

  Future<void> _handleSave() async {
    // 1. VALIDASI RESTORAN (Ambil dari PreOrderViewModel)
    // Kita akses viewmodel dashboard untuk tahu resto mana yang sedang aktif
    final dashboardVM = context.read<PreOrderViewModel>();
    final currentResto = dashboardVM.currentRestaurant;

    // Cek apakah data restoran ada
    if (currentResto == null || currentResto.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Tidak ada restoran yang dipilih."), 
          backgroundColor: Colors.red
        )
      );
      return;
    }

    // 2. PROSES SIMPAN
    final vm = context.read<AddEditMenuViewModel>();
    
    // Ambil ID asli dari object currentResto
    int currentSellerRestoId = currentResto.id!; 

    final String? error = await vm.saveMenu(
      isNewItem: _isNewItem,
      currentMenuId: widget.item?.menuId,
      name: _nameController.text,
      description: _descController.text,
      priceStr: _priceController.text,
      oldImageUrl: widget.item?.image,
      type: _selectedType, 
      restaurantId: currentSellerRestoId, // <--- ID SUDAH DINAMIS
    );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil disimpan!"))
      );
      Navigator.pop(context, true); // Kembali ke dashboard & refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red)
      );
    }
  }
  // ... (Fungsi _handleDelete tetap sama)
  Future<void> _handleDelete() async {
     // Gunakan logic delete sebelumnya...
     // (Disederhanakan agar jawaban tidak terlalu panjang)
     if (widget.item?.menuId == null) return;
     // ... confirm dialog ...
     final error = await context.read<AddEditMenuViewModel>().deleteMenu(widget.item!.menuId!);
     if(!mounted) return;
     if(error == null) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddEditMenuViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _textBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isNewItem ? "Add Menu" : (_isEditing ? "Edit Menu" : "Menu Detail"),
          style: TextStyle(color: _textBrown, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
           if (vm.isLoading) 
            const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. IMAGE SECTION
                Center(
                  child: GestureDetector(
                    onTap: _isEditing ? _pickImage : null,
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(24),
                      ),
                       // Helper widget untuk menampilkan gambar (sama seperti sebelumnya)
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: _buildDisplayImage(vm),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. NAME FIELD
                _buildLabel("Food Name"),
                TextFormField(
                  controller: _nameController,
                  enabled: _isEditing,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textBrown),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: "Enter food name"),
                ),

                // [BARU] 3. TYPE DROPDOWN
                const SizedBox(height: 12),
                _buildLabel("Category"),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isEditing ? Colors.grey[100] : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<MenuType>(
                      value: _selectedType,
                      isExpanded: true,
                      icon: _isEditing ? const Icon(Icons.arrow_drop_down) : const SizedBox.shrink(),
                      onChanged: _isEditing
                          ? (MenuType? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedType = newValue;
                                });
                              }
                            }
                          : null, // Disable dropdown jika tidak editing
                      items: MenuType.values.map<DropdownMenuItem<MenuType>>((MenuType value) {
                        return DropdownMenuItem<MenuType>(
                          value: value,
                          child: Text(
                            value.toString().split('.').last, // Mengambil teks setelah titik (FOOD, DRINK)
                            style: TextStyle(
                              fontSize: 16,
                              color: _textBrown,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // 4. DESCRIPTION FIELD
                const SizedBox(height: 12),
                _buildLabel("Description"),
                TextFormField(
                  controller: _descController,
                  enabled: _isEditing,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  decoration: const InputDecoration(
                    border: InputBorder.none, 
                    hintText: "Enter description..."
                  ),
                ),

                // 5. PRICE FIELD
                const SizedBox(height: 16),
                _buildLabel("Price"),
                TextFormField(
                  controller: _priceController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _textBrown),
                  decoration: const InputDecoration(prefixText: "Rp. ", border: InputBorder.none, hintText: "0"),
                ),
              ],
            ),
          ),

          // --- BOTTOM BUTTONS ---
          Positioned(
            bottom: 30, left: 24, right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!_isNewItem)
                  GestureDetector(
                    onTap: _handleDelete,
                    child: Container(
                      width: 60, height: 60,
                      decoration: const BoxDecoration(color: Color(0xFFFFE0CC), shape: BoxShape.circle),
                      child: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  )
                else
                  const SizedBox(width: 60),

                GestureDetector(
                  onTap: _isEditing ? _handleSave : _toggleEdit,
                  child: Container(
                    width: 60, height: 60,
                    decoration: const BoxDecoration(color: Color(0xFFFFE0CC), shape: BoxShape.circle),
                    child: Icon(_isEditing ? Icons.check : Icons.edit, color: _textBrown, size: 28),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    if (!_isEditing) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
    );
  }

  Widget _buildDisplayImage(AddEditMenuViewModel vm) {
    if (vm.selectedImage != null) {
      if (kIsWeb) return Image.network(vm.selectedImage!.path, fit: BoxFit.cover);
      return Image.file(File(vm.selectedImage!.path), fit: BoxFit.cover);
    } else if (widget.item?.image != null && widget.item!.image!.isNotEmpty) {
      return Image.network(widget.item!.image!, fit: BoxFit.cover);
    } else {
      return Icon(Icons.add_a_photo, size: 50, color: Colors.grey[400]);
    }
  }
}