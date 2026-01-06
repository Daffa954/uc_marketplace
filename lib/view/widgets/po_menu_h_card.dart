import 'package:flutter/material.dart';
import 'package:uc_marketplace/model/model.dart';

class PreOrderMenuHorizontalCard extends StatelessWidget {
  final MenuModel menu;
  final VoidCallback onTap;       // Aksi klik seluruh card (ke detail)
  final VoidCallback onAddTap;    // Aksi klik tombol +

  const PreOrderMenuHorizontalCard({
    super.key,
    required this.menu,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110, // Tinggi fixed agar rapi
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 1. GAMBAR (KIRI)
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Image.network(
                menu.image ?? "https://placehold.co/200x200/png?text=Menu",
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(width: 110, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
              ),
            ),

            // 2. INFO (TENGAH)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nama Menu
                    Text(
                      "${menu.name}id po menu : ${menu.preOrderMenuId}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Tipe (Food/Drink)
                    Text(
                      menu.type.toString().split('.').last,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const Spacer(),
                    
                    // Harga
                    Text(
                      "Rp ${menu.price}",
                      style: const TextStyle(
                        color: Color(0xFFFF7F27),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. TOMBOL PLUS (KANAN)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: onAddTap, // Aksi tambah keranjang
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7F27),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}