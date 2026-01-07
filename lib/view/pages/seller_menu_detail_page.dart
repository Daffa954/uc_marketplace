import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/viewmodel/detail_viewmodel.dart'; // Sesuaikan import

class MenuDetailPageD extends StatelessWidget {
  final MenuModel menu;

  const MenuDetailPageD({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    // Format Currency
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return ChangeNotifierProvider(
      create: (_) => DetailViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            // 1. App Bar dengan Gambar Background
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: const Color(0xFFFF8C42),
              flexibleSpace: FlexibleSpaceBar(
                background: (menu.image != null && menu.image!.isNotEmpty)
                    ? Image.network(
                        menu.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey[200]),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.fastfood,
                            size: 80, color: Colors.grey),
                      ),
              ),
              leading: IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.arrow_back, color: Colors.black),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // 2. Konten Detail
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori & Nama
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8C42).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            menu.type.toString().split('.').last,
                            style: const TextStyle(
                              color: Color(0xFFFF8C42),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Harga
                        Text(
                          currencyFormat.format(menu.price),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF8C42),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Nama Menu
                    Text(
                      menu.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Divider(),
                    const SizedBox(height: 16),

                    // Deskripsi
                    const Text(
                      "Deskripsi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      menu.description ?? "Tidak ada deskripsi tersedia.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Tombol Aksi (Edit/Hapus) - Opsional
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              // Navigasi ke Edit Page
              // context.push('/edit-menu', extra: menu);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C42),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              "Edit Menu",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}