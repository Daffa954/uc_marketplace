import 'package:flutter/material.dart';
import 'package:uc_marketplace/model/model.dart';

class PreOrderCard extends StatelessWidget {
  final PreOrderModel preOrder;
  final VoidCallback? onTap;
  final String? distanceInfo;

  const PreOrderCard({
    super.key,
    required this.preOrder,
    this.onTap,
    this.distanceInfo,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Logic Cek Status (Open/Close)
    bool isOpen = false;
    // Cek status berdasarkan tanggal tutup
    if (preOrder.closeOrderDate != null) {
      try {
        final closeDateTimeStr = "${preOrder.closeOrderDate} ${preOrder.closeOrderTime ?? '23:59:00'}";
        final closeDate = DateTime.parse(closeDateTimeStr);
        isOpen = DateTime.now().isBefore(closeDate);
      } catch (e) {
        isOpen = true; // Fallback jika parsing gagal
      }
    }
    // Cek status berdasarkan kuota (Opsional, jika kuota penuh = closed)
    bool isFull = preOrder.targetQuota > 0 && preOrder.currentQuota >= preOrder.targetQuota;
    if (isFull) isOpen = false;

    // Hitung Persentase Kuota untuk Progress Bar
    double progress = 0.0;
    if (preOrder.targetQuota > 0) {
      progress = preOrder.currentQuota / preOrder.targetQuota;
      if (progress > 1.0) progress = 1.0;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280, // Fixed width untuk horizontal list
        margin: const EdgeInsets.only(right: 16, bottom: 8), // Margin bottom untuk bayangan
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN GAMBAR ---
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: (preOrder.image != null && preOrder.image!.isNotEmpty)
                        ? Image.network(
                            preOrder.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder();
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isOpen ? const Color(0xFF4CAF50) : const Color(0xFFE53935), // Hijau / Merah
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))
                      ],
                    ),
                    child: Text(
                      isOpen ? "OPEN PO" : (isFull ? "SOLD OUT" : "CLOSED"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                // Badge Jarak (Jika ada)
                if (distanceInfo != null)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            distanceInfo!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // --- BAGIAN DETAIL INFO ---
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama PO
                  Text(
                    preOrder.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Info Waktu Close
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Tutup: ${preOrder.closeOrderDate ?? '-'} • ${preOrder.closeOrderTime?.substring(0, 5) ?? ''}",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Progress Bar Kuota
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Terpesan",
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                          Text(
                            "${preOrder.currentQuota}/${preOrder.targetQuota}",
                            style: const TextStyle(
                              fontSize: 11, 
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8C42)
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0 ? Colors.red : const Color(0xFFFF8C42)
                          ),
                          minHeight: 6,
                        ),
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

  // Widget Placeholder jika gambar null/error
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey[400]),
          // Opsional: Tampilkan teks nama PO jika gambar tidak ada
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Text(
              preOrder.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}