import 'package:flutter/material.dart';
import 'package:uc_marketplace/view/widgets/food_cad.dart';
import 'package:uc_marketplace/view/widgets/section_header.dart';

class PopularSection extends StatelessWidget {
  final String title;

  const PopularSection({
    super.key,
    required this.title,
  });
 

  @override
  Widget build(BuildContext context) {
    // Data Dummy sesuai gambar
    final List<Map<String, dynamic>> items = [
      {
        'foodName': 'Choco chip cookies',
        'restaurantName': 'Bakery Wenak',
        'price': 'Rp. 20.000',
        'rating': '4+',
        'tag': 'Pick Up',
        'image': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=1398&auto=format&fit=crop'
      },
      {
        'foodName': 'Beef Burger',
        'restaurantName': 'Burger King',
        'price': 'Rp. 45.000',
        'rating': '4.8',
        'tag': 'Delivery',
        'image': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=1398&auto=format&fit=crop'
      },
      {
        'foodName': 'Ice Matcha Latte',
        'restaurantName': 'Kopi Kenangan',
        'price': 'Rp. 28.000',
        'rating': '4.5',
        'tag': 'Pick Up',
        'image': 'https://images.unsplash.com/photo-1515823064-d6e0c04616a7?q=80&w=1471&auto=format&fit=crop'
      },
    ];

    return Column(
      children: [
        SectionHeader(
          title: title,
          onSeeAllTap: () {
            // Aksi ketika "See All" ditekan
            print("See All $title tapped");
          },
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: items.map((item) {
              return PopularItemCard(
                foodName: item['foodName'],
                restaurantName: item['restaurantName'],
                price: item['price'],
                rating: item['rating'],
                imageUrl: item['image'],
                tagLabel: item['tag'],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}