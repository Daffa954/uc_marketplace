part of 'widgets.dart';
class MenuItemCard extends StatelessWidget {
  final MenuModel menu;
  final VoidCallback? onEdit;

  const MenuItemCard({
    super.key,
    required this.menu,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // Format Currency
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
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
                  // Nama & Tipe
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          menu.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Opsional: Icon Tipe (Makanan/Minuman)
                      Icon(
                        menu.type.toString().contains('FOOD') 
                            ? Icons.restaurant 
                            : Icons.local_cafe,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Deskripsi
                  Text(
                    menu.description ?? 'Tidak ada deskripsi',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Harga
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
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.fastfood, color: Colors.grey, size: 30),
    );
  }
}