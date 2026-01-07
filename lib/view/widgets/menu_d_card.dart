import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uc_marketplace/model/model.dart'; // Sesuaikan import model Anda

class MenuItemDCard extends StatelessWidget {
  final MenuModel menu;
  final VoidCallback? onEdit;

  const MenuItemDCard({
    super.key,
    required this.menu,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Gambar Produk
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: (menu.image != null && menu.image!.isNotEmpty)
                    ? Image.network(
                        menu.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(width: 16),

            // Detail Produk
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    menu.description ?? 'Tidak ada deskripsi',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(menu.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFF8C42),
                    ),
                  ),
                ],
              ),
            ),

            // Tombol Edit
            if (onEdit != null)
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_note, color: Colors.grey),
                tooltip: 'Edit Menu',
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[100],
      child: const Icon(Icons.fastfood, color: Colors.grey, size: 30),
    );
  }
}