import 'package:flutter/material.dart';
import 'package:uc_marketplace/view/widgets/section_header.dart';
import 'restaurant_card.dart';

class RestaurantSection extends StatelessWidget {
  final String title;

  const RestaurantSection({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk contoh
    final List<Map<String, dynamic>> restaurants = [
      {
        'name': 'Warung A',
        'location': 'UC Walk - Surabaya',
        'time': '07.00 - 19.00 WIB',
        'rating': 4.5,
        'image': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=1374&auto=format&fit=crop'
      },
      {
        'name': 'Cafe B',
        'location': 'UC Walk - Surabaya',
        'time': '08.00 - 22.00 WIB',
        'rating': 4.8,
        'image': 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?q=80&w=1349&auto=format&fit=crop'
      },
       {
        'name': 'Resto C',
        'location': 'Jalan Raya Darmo',
        'time': '10.00 - 23.00 WIB',
        'rating': 4.2,
        'image': 'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?q=80&w=1470&auto=format&fit=crop'
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
          clipBehavior: Clip.none, // Penting agar bayangan card tidak terpotong
          child: Row(
            children: restaurants.map((data) {
              return RestaurantCard(
                name: data['name'],
                location: data['location'],
                time: data['time'],
                rating: data['rating'],
                imageUrl: data['image'],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}