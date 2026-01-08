
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

  MenuType _selectedType = MenuType.FOOD;
  int? _selectedGeneralCategoryId;

  bool _isEditing = false;
  bool _isNewItem = false;
  bool _isLoadingCategories = true;

  final Color _primaryColor = const Color(0xFFffa652);
  final Color _textBrown = const Color(0xFF593A1D);
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _isNewItem = widget.item == null;
    _isEditing = _isNewItem;

    // Set initial values from existing item
    if (widget.item != null) {
    print("=== INIT STATE DEBUG ===");
    print("Item from widget: ${widget.item}");
    print("Item type: ${widget.item!.type}");
    print("Item category ID: ${widget.item!.generalCategoryId}");
    print("Item category ID type: ${widget.item!.generalCategoryId.runtimeType}");
    print("========================");
    
    _selectedType = widget.item!.type;
    _selectedGeneralCategoryId = widget.item!.generalCategoryId;
  }
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descController = TextEditingController(text: widget.item?.description ?? '');
    _priceController = TextEditingController(
      text: widget.item != null ? widget.item!.price.toString() : '',
    );

    // Load categories after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      final vm = context.read<AddEditMenuViewModel>();
      vm.setImage(null);
      
      try {
        await vm.loadCategories();
        if (mounted) {
          setState(() {
            _isLoadingCategories = false;
          });
        }
      } catch (e) {
        debugPrint("Error loading categories: $e");
        if (mounted) {
          setState(() {
            _isLoadingCategories = false;
          });
        }
      }
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
    final image = await _picker.pickImage(source: ImageSource.gallery);
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
    // 1. Validate restaurant
    final dashboardVM = context.read<PreOrderViewModel>();
    final currentResto = dashboardVM.currentRestaurant;

    if (currentResto == null || currentResto.id == null) {
      _showErrorSnackbar("Error: Tidak ada restoran yang dipilih.");
      return;
    }

    // 2. Validate input
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackbar("Nama menu wajib diisi.");
      return;
    }

    if (_priceController.text.trim().isEmpty) {
      _showErrorSnackbar("Harga wajib diisi.");
      return;
    }

    final price = int.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      _showErrorSnackbar("Harga harus berupa angka positif.");
      return;
    }

    // 3. Save to database
    final vm = context.read<AddEditMenuViewModel>();
    final currentSellerRestoId = currentResto.id!;

    final String? error = await vm.saveMenu(
      isNewItem: _isNewItem,
      currentMenuId: widget.item?.menuId,
      name: _nameController.text,
      description: _descController.text,
      priceStr: _priceController.text,
      oldImageUrl: widget.item?.image,
      type: _selectedType,
      restaurantId: currentSellerRestoId,
      generalCategoryId: _selectedGeneralCategoryId,
    );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Menu berhasil disimpan!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      _showErrorSnackbar(error);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleDelete() async {
    if (widget.item?.menuId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Menu"),
        content: const Text("Apakah Anda yakin ingin menghapus menu ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final error = await context
          .read<AddEditMenuViewModel>()
          .deleteMenu(widget.item!.menuId!);
      
      if (!mounted) return;
      
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Menu berhasil dihapus!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        _showErrorSnackbar(error);
      }
    }
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
          _isNewItem ? "Tambah Menu" : (_isEditing ? "Edit Menu" : "Detail Menu"),
          style: TextStyle(color: _textBrown, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (vm.isLoading && !vm.categoriesLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFffa652),
                ),
              ),
            ),
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
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: _buildDisplayImage(vm),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. NAME FIELD
                _buildLabel("Nama Menu"),
                TextFormField(
                  controller: _nameController,
                  enabled: _isEditing,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textBrown,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Masukkan nama menu",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),

                // 3. TYPE DROPDOWN
                const SizedBox(height: 16),
                _buildLabel("Tipe Menu"),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _isEditing ? Colors.grey[50] : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isEditing ? Colors.grey[300]! : Colors.transparent,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<MenuType>(
                      value: _selectedType,
                      isExpanded: true,
                      icon: _isEditing
                          ? const Icon(Icons.arrow_drop_down)
                          : const SizedBox.shrink(),
                      onChanged: _isEditing
                          ? (MenuType? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedType = newValue;
                                });
                              }
                            }
                          : null,
                      items: MenuType.values.map((MenuType value) {
                        return DropdownMenuItem<MenuType>(
                          value: value,
                          child: Text(
                            _getTypeDisplayName(value),
                            style: TextStyle(
                              fontSize: 16,
                              color: _textBrown,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // 4. GENERAL CATEGORY DROPDOWN (FIXED - NO ASSERTION ERROR)
                const SizedBox(height: 16),
                _buildLabel("Kategori Umum"),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _isEditing ? Colors.grey[50] : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isEditing ? Colors.grey[300]! : Colors.transparent,
                    ),
                  ),
                  child: _buildCategoryDropdown(vm),
                ),

                // 5. DESCRIPTION FIELD
                const SizedBox(height: 16),
                _buildLabel("Deskripsi"),
                TextFormField(
                  controller: _descController,
                  enabled: _isEditing,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Masukkan deskripsi menu (opsional)",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),

                // 6. PRICE FIELD
                const SizedBox(height: 16),
                _buildLabel("Harga"),
                TextFormField(
                  controller: _priceController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _textBrown,
                  ),
                  decoration: const InputDecoration(
                    prefixText: "Rp ",
                    border: InputBorder.none,
                    hintText: "0",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),

          // BOTTOM BUTTONS
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!_isNewItem)
                  GestureDetector(
                    onTap: _handleDelete,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 60),

                GestureDetector(
                  onTap: vm.isLoading ? null : (_isEditing ? _handleSave : _toggleEdit),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: vm.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            _isEditing ? Icons.check : Icons.edit,
                            color: Colors.white,
                            size: 28,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(AddEditMenuViewModel vm) {
  if (_isLoadingCategories || vm.categoriesLoading) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text("Memuat kategori..."),
        ],
      ),
    );
  }

  // DEBUG: Print data categories
  print("=== DEBUG CATEGORIES ===");
  print("Jumlah kategori: ${vm.categories.length}");
  print("Selected category ID: $_selectedGeneralCategoryId");
  print("Type of selected ID: ${_selectedGeneralCategoryId.runtimeType}");
  
  for (var i = 0; i < vm.categories.length; i++) {
    final cat = vm.categories[i];
    print("Category $i: id=${cat.generalCategoryId}, name=${cat.name}");
  }

  if (vm.categories.isEmpty) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(
        "Tidak ada kategori tersedia",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  // DEBUG: Check for duplicate values
  final ids = vm.categories.map((c) => c.generalCategoryId).toList();
  final duplicateIds = <int>[];
  final seenIds = <int>{};
  
  for (var id in ids) {
    if (id != null) {
      if (seenIds.contains(id)) {
        duplicateIds.add(id);
      } else {
        seenIds.add(id);
      }
    }
  }
  
  if (duplicateIds.isNotEmpty) {
    print("⚠️ WARNING: Ada ID duplikat: $duplicateIds");
  }

  // Create dropdown items with null option first
  final items = <DropdownMenuItem<int?>>[
    DropdownMenuItem<int?>(
      value: null,
      child: Text(
        "Pilih kategori",
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 16,
        ),
      ),
    ),
    ...vm.categories.map((category) {
      return DropdownMenuItem<int?>(
        value: category.generalCategoryId, // Pastikan ini int
        child: Text(
          category.name ?? "Tanpa Nama",
          style: TextStyle(
            fontSize: 16,
            color: _textBrown,
          ),
        ),
      );
    }).toList(),
  ];

  // DEBUG: Check if selected value exists in items
  final availableValues = items.map((item) => item.value).toList();
  print("Available values in dropdown: $availableValues");
  print("Selected value exists: ${availableValues.contains(_selectedGeneralCategoryId)}");
  print("=== END DEBUG ===");

  return DropdownButtonHideUnderline(
    child: DropdownButton<int?>(
      // FIX: Allow null value
      value: _selectedGeneralCategoryId,
      hint: const Text("Pilih kategori"),
      isExpanded: true,
      icon: _isEditing
          ? const Icon(Icons.arrow_drop_down)
          : const SizedBox.shrink(),
      onChanged: _isEditing
          ? (int? newValue) {
              print("Dropdown changed to: $newValue");
              setState(() {
                _selectedGeneralCategoryId = newValue;
              });
            }
          : null,
      items: items,
    ),
  );
}

  Widget _buildLabel(String text) {
    if (!_isEditing) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDisplayImage(AddEditMenuViewModel vm) {
    if (vm.selectedImage != null) {
      if (kIsWeb) {
        return Image.network(
          vm.selectedImage!.path,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage();
          },
        );
      }
      return Image.file(
        File(vm.selectedImage!.path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else if (widget.item?.image != null && widget.item!.image!.isNotEmpty) {
      return Image.network(
        widget.item!.image!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: _primaryColor,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo,
            size: 50,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            _isEditing ? "Tambahkan Gambar" : "Tidak ada gambar",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _getTypeDisplayName(MenuType type) {
    switch (type) {
      case MenuType.FOOD:
        return "Makanan";
      case MenuType.DRINK:
        return "Minuman";
     
      default:
        return "Makanan";
    }
  }
}