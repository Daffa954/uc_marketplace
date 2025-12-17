import 'package:flutter/material.dart';
import 'package:uc_marketplace/model/model.dart';

class PreOrderMenuCard extends StatelessWidget {
  final MenuModel menu;
  final VoidCallback? onTap;

  const PreOrderMenuCard({
    super.key,
    required this.menu,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Menu
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      menu.image ?? "https://placehold.co/300x300/png?text=Menu",
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                        Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                    ),
                  ),
                  // Tag Tipe (Food/Drink)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        menu.type.toString().split('.').last, // FOOD / DRINK
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Detail Menu
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rp ${menu.price}",
                    style: const TextStyle(
                      color: Color(0xFFFF7F27), // Warna Orange Utama
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Tombol Add (Visual Saja)
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: OutlinedButton(
                      onPressed: () {}, 
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF7F27)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        "Pesan",
                        style: TextStyle(fontSize: 12, color: Color(0xFFFF7F27)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}