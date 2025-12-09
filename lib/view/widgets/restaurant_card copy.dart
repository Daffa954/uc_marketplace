import 'package:flutter/material.dart';
import 'package:uc_marketplace/main.dart';


class RestaurantCard extends StatelessWidget {
  final String name;
  final String location;
  final String time;
  final double rating;
  final String imageUrl;

  const RestaurantCard({
    super.key,
    required this.name,
    required this.location,
    required this.time,
    required this.rating,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, // Lebar tetap untuk kartu dalam list horizontal
      margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8), // Margin untuk bayangan
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Gambar dan Ikon Overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Overlay Ikon (Toko, Truk, Jam)
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    _buildIconTag(Icons.storefront_outlined),
                    const SizedBox(width: 8),
                    _buildIconTag(Icons.local_shipping_outlined),
                     const SizedBox(width: 8),
                    _buildIconTag(Icons.access_time),
                  ],
                ),
              )
            ],
          ),
          // Bagian Informasi Teks
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MyApp.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: TextStyle(color: MyApp.textGrey, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(color: Colors.blue.shade400, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: MyApp.textDark,
                      ),
                    ),
                    Text("+", style: TextStyle(color: MyApp.textGrey)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk ikon kecil di atas gambar
  Widget _buildIconTag(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: MyApp.primaryOrange),
    );
  }
}