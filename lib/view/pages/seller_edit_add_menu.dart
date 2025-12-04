import 'package:flutter/material.dart';

// 1. DUMMY MODEL (Replace this with your actual Menu/Product model)
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

class AddEditMenuPage extends StatefulWidget {
  // If item is null, we are in "Add Mode". If provided, we are in "View/Edit Mode".
  final MenuItem? item;

  const AddEditMenuPage({super.key, this.item});

  @override
  State<AddEditMenuPage> createState() => _AddEditMenuPageState();
}

class _AddEditMenuPageState extends State<AddEditMenuPage> {
  // Controllers to manage text input
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;

  // State variables
  bool _isEditing = false;
  bool _isNewItem = false;

  final Color _primaryOrange = const Color(0xFFffa652);
  final Color _textBrown = const Color(0xFF593A1D);

  @override
  void initState() {
    super.initState();
    _isNewItem = widget.item == null;

    // If it's a new item, we start in editing mode immediately.
    // If it's an existing item, we start in view mode (editing = false).
    _isEditing = _isNewItem;

    // Initialize controllers with existing data or empty strings
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descController = TextEditingController(text: widget.item?.description ?? '');
    _priceController = TextEditingController(
        text: widget.item != null ? widget.item!.price.toStringAsFixed(0) : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // --- LOGIC FUNCTIONS ---

  void _toggleEdit() {
    setState(() {
      _isEditing = true;
    });
  }

  Future<void> _handleSave() async {
    // Show Confirmation Dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Save Changes?"),
        content: const Text("Are you sure you want to save this menu item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryOrange),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // TODO: Perform your API Call / Database Update here
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item Saved Successfully!")),
      );
      
      // Go back
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _handleDelete() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // TODO: Perform your Delete API Call here
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Stack(
        children: [
          // --- SCROLLABLE CONTENT ---
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. IMAGE SECTION
                Center(
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(24),
                      image: const DecorationImage(
                        // Placeholder image logic
                        image: NetworkImage('https://via.placeholder.com/300'), 
                        fit: BoxFit.cover,
                      ),
                    ),
                    // If editing, show an icon to suggest changing image
                    child: _isEditing
                        ? Center(
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 40, color: Colors.white54),
                              onPressed: () {
                                // TODO: Implement Image Picker
                              },
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                // 2. NAME FIELD
                _buildLabel("Food Name"),
                TextFormField(
                  controller: _nameController,
                  enabled: _isEditing, // Only editable if editing mode is on
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _textBrown,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter food name",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),

                // 3. DESCRIPTION FIELD
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  enabled: _isEditing,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter description...",
                  ),
                ),

                // 4. PRICE FIELD
                const SizedBox(height: 16),
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
                    prefixText: "Rp. ",
                    border: InputBorder.none,
                    hintText: "0",
                  ),
                ),
              ],
            ),
          ),

          // --- BOTTOM BUTTONS (Floating) ---
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // DELETE BUTTON (Left)
                // Only show delete if it's not a brand new item
                if (!_isNewItem)
                  GestureDetector(
                    onTap: _handleDelete,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE0CC), // Light orange/pink
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  )
                else
                  const SizedBox(width: 60), // Spacer to keep layout balanced

                // EDIT / SAVE BUTTON (Right)
                GestureDetector(
                  // Logic: If Editing -> Save. If View -> Toggle Edit.
                  onTap: _isEditing ? _handleSave : _toggleEdit,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE0CC), // Light beige/orange from screenshot
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      // Icon Changes logic:
                      _isEditing ? Icons.check : Icons.edit,
                      color: _textBrown,
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

  // Helper for consistent labels
  Widget _buildLabel(String text) {
    if (!_isEditing) return const SizedBox.shrink(); // Hide labels in view mode for cleaner look
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
    );
  }
}