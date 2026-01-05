import 'package:flutter/material.dart';
import 'package:uc_marketplace/model/model.dart';

class PreOrderCard extends StatelessWidget {
  final PreOrderModel preOrder;
  final VoidCallback? onTap;
  final String? distanceInfo; // [BARU] Parameter jarak
  const PreOrderCard({
    super.key,
    required this.preOrder,
    this.onTap,
    this.distanceInfo, // [BARU] Parameter jarak
  });

  @override
  Widget build(BuildContext context) {
    // Logic sederhana untuk Cek Status (Open/Close)
    bool isOpen = false;
    if (preOrder.closeOrderDate != null) {
      final closeDate = DateTime.parse(
        "${preOrder.closeOrderDate} ${preOrder.closeOrderTime ?? '00:00:00'}",
      );
      isOpen = DateTime.now().isBefore(closeDate);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280, // Lebar fixed untuk Horizontal Scroll
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Cover (Placeholder)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    "https://placehold.co/600x300/png?text=${Uri.encodeComponent(preOrder.name)}",
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Badge Status
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOpen ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
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

            // 2. Detail Info
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Close: ${preOrder.closeOrderDate ?? '-'}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${preOrder.orderTime?.substring(0, 5)} - ${preOrder.closeOrderTime?.substring(0, 5)} WIB",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (distanceInfo != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            distanceInfo!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
