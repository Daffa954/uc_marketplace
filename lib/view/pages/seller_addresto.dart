import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uc_marketplace/viewmodel/addRestaurant_viewmodel.dart';

class AddRestaurantPage extends StatefulWidget {
  const AddRestaurantPage({super.key});

  @override
  State<AddRestaurantPage> createState() => _AddRestaurantPageState();
}

class _AddRestaurantPageState extends State<AddRestaurantPage> {
  // Controller untuk semua field
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _bankController = TextEditingController();

  Future<void> _handleSubmit() async {
    final vm = context.read<AddRestaurantViewModel>();
    
    final error = await vm.saveRestaurant(
      name: _nameController.text,
      description: _descController.text,
      address: _addressController.text,
      city: _cityController.text,
      province: _provinceController.text,
      bankAccount: _bankController.text,
    );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Restoran berhasil dibuat!")),
      );
      Navigator.pop(context, true); // Kembali ke dashboard dengan sinyal refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddRestaurantViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Restoran Baru", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Informasi Dasar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // FORM FIELDS
            _buildTextField(
              controller: _nameController, 
              label: "Nama Restoran", 
              icon: Icons.store
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _descController, 
              label: "Deskripsi", 
              icon: Icons.description,
              maxLines: 2
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _addressController, 
              label: "Alamat Jalan", 
              icon: Icons.location_on
            ),
            const SizedBox(height: 16),

            // Row untuk Kota & Provinsi
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _cityController, 
                    label: "Kota", 
                    icon: Icons.location_city
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _provinceController, 
                    label: "Provinsi", 
                    icon: Icons.map
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _bankController, 
              label: "Nomor Rekening", 
              icon: Icons.account_balance_wallet,
              keyboardType: TextInputType.number
            ),
            
            const SizedBox(height: 32),

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: vm.isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C42),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: vm.isLoading
                    ? const SizedBox(
                        height: 24, width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text(
                        "Simpan Restoran", 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}