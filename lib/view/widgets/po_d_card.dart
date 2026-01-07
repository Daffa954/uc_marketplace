import 'package:flutter/material.dart';
import 'package:uc_marketplace/model/model.dart';

class PreOrderDCard extends StatelessWidget {
  final PreOrderModel preOrder;
  final VoidCallback? onTap;

  const PreOrderDCard({
    super.key,
    required this.preOrder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Logic Cek Status (Open/Close)
    bool isOpen = false;
    if (preOrder.closeOrderDate != null) {
      // Gabungkan tanggal dan waktu tutup jika ada, default jam 23:59
      final closeDateTimeStr = "${preOrder.closeOrderDate} ${preOrder.closeOrderTime ?? '23:59:00'}";
      try {
        final closeDate = DateTime.parse(closeDateTimeStr);
        isOpen = DateTime.now().isBefore(closeDate);
      } catch (e) {
        isOpen = true; // Fallback jika parsing gagal
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Hapus width fixed agar responsif di ListView vertical
        width: double.infinity, 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. GAMBAR COVER (Updated) ---
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: (preOrder.image != null && preOrder.image!.isNotEmpty)
                        ? Image.network(
                            preOrder.image!, // [PENTING] Ambil dari URL Supabase
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder();
                            },
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                // Badge Status
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isOpen ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isOpen ? "OPEN PO" : "CLOSED",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // --- 2. DETAIL INFO ---
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preOrder.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Info Tanggal
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "Tutup: ${preOrder.closeOrderDate ?? '-'}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Info Kuota
                  Row(
                    children: [
                      const Icon(Icons.pie_chart_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "Kuota: ${preOrder.currentQuota} / ${preOrder.targetQuota}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Image.network(
      "https://placehold.co/600x300/png?text=${Uri.encodeComponent(preOrder.name)}",
      fit: BoxFit.cover,
    );
  }
}