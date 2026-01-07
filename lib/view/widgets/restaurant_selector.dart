import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/viewmodel/addRestaurant_viewmodel.dart';
import 'package:uc_marketplace/view/pages/seller_addresto.dart'; // Sesuaikan import

class RestaurantSelectorSheet extends StatelessWidget {
  final List<RestaurantModel> ownedRestaurants;
  final RestaurantModel? currentRestaurant;
  final Function(RestaurantModel) onSelect;
  final VoidCallback onAddSuccess;

  const RestaurantSelectorSheet({
    super.key,
    required this.ownedRestaurants,
    required this.currentRestaurant,
    required this.onSelect,
    required this.onAddSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 450,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Pilih Cabang Restoran",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),
          Expanded(
            child: ownedRestaurants.isEmpty
                ? const Center(
                    child: Text(
                      "Kamu belum punya restoran.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: ownedRestaurants.length,
                    itemBuilder: (context, index) {
                      final resto = ownedRestaurants[index];
                      final bool isSelected = resto.id == currentRestaurant?.id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFffe3c9) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: const Color(0xFFFF8C42))
                              : Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFFF8C42),
                            child: Text(
                              resto.name.isNotEmpty ? resto.name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            resto.name,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: Color(0xFFFF8C42))
                              : null,
                          onTap: () {
                            onSelect(resto);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                Navigator.pop(context); // Tutup sheet sebelum navigasi
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => AddRestaurantViewModel(),
                      child: const AddRestaurantPage(),
                    ),
                  ),
                );
                if (result == true) onAddSuccess();
              },
              icon: const Icon(Icons.add_business, color: Color(0xFFFF8C42)),
              label: const Text(
                "Tambah Restoran Baru",
                style: TextStyle(color: Color(0xFFFF8C42)),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Color(0xFFFF8C42)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}