import 'package:flutter/material.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/view/widgets/section_header.dart';
import 'restaurant_card.dart';

class RestaurantSection extends StatelessWidget {
  final String title;
  // 1. Terima data List<RestaurantModel> dari Parent
  final List<RestaurantModel> restaurants; 

  const RestaurantSection({
    super.key,
    required this.title,
    required this.restaurants, // Wajib diisi
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: title,
          onSeeAllTap: () {
            print("See All $title tapped");
          },
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            // 2. Mapping data dari Model ke Widget
            children: restaurants.map((restaurant) {
              return RestaurantCard(
                name: restaurant.name,
                location: restaurant.city ?? 'Unknown', // Ambil kota
                
                // --- DATA PLACEHOLDER (Karena belum ada di DB) ---
                time: "09.00 - 22.00 WIB", 
                rating: 4.5, 
                // Kita gunakan layanan placeholder image dengan nama resto
                imageUrl: "https://placehold.co/600x400/png?text=${Uri.encodeComponent(restaurant.name)}",
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}