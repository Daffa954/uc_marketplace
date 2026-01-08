import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uc_marketplace/model/model.dart';

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

    // DEBUG: Print image info
    print("=== DEBUG MENU IMAGE ===");
    print("Menu ID: ${menu.menuId}");
    print("Menu Name: ${menu.name}");
    print("Image URL: ${menu.image}");
    print("Image is null? ${menu.image == null}");
    print("Image is empty? ${menu.image?.isEmpty ?? true}");
    print("========================");

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
                child: _buildImageWidget(),
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
                  // Tampilkan URL gambar sebagai teks untuk debugging
                  if (menu.image != null && menu.image!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      // child: Text(
                      //   menu.image!.length > 30 
                      //     ? '${menu.image!.substring(0, 30)}...' 
                      //     : menu.image!,
                      //   style: const TextStyle(fontSize: 10, color: Colors.grey),
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      // ),
                    )
                  else
                    Text(
                      'Gambar: kosong',
                      style: TextStyle(fontSize: 12, color: Colors.red[300]),
                    ),
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

  Widget _buildImageWidget() {
    if (menu.image != null && menu.image!.isNotEmpty) {
      // Cek jika URL valid
      final imageUrl = menu.image!.trim();
      
      // DEBUG: Print URL yang akan digunakan
      print("Loading image from URL: $imageUrl");
      
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: const Color(0xFFFF8C42),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print("❌ ERROR loading image: $error");
          print("Stack trace: $stackTrace");
          return _placeholder(error: error.toString());
        },
      );
    } else {
      return _placeholder();
    }
  }

  Widget _placeholder({String? error}) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fastfood,
            color: error != null ? Colors.red : Colors.grey,
            size: 30,
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Error',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}