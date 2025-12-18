
part of 'widgets.dart';
class PreOrderItemCard extends StatelessWidget {
  final PreOrderModel preOrder;
  final VoidCallback? onTap;

  const PreOrderItemCard({
    super.key,
    required this.preOrder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Logic Status Sederhana (Bisa diperbaiki dengan compare DateTime)
    bool isOpen = true;
    if (preOrder.closeOrderDate != null) {
      try {
        final closeDate = DateTime.parse("${preOrder.closeOrderDate} ${preOrder.closeOrderTime ?? '23:59:00'}");
        isOpen = DateTime.now().isBefore(closeDate);
      } catch (e) {
        // Fallback jika parsing error
        isOpen = true; 
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      preOrder.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOpen ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isOpen ? "OPEN" : "CLOSED",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isOpen ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              
              // Info Tanggal
              _buildDateRow(Icons.login, "Buka:", preOrder.orderDate, preOrder.orderTime),
              const SizedBox(height: 8),
              _buildDateRow(Icons.logout, "Tutup:", preOrder.closeOrderDate, preOrder.closeOrderTime),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow(IconData icon, String label, String? dateStr, String? timeStr) {
    String displayDate = '-';
    if (dateStr != null) {
      try {
        final date = DateTime.parse(dateStr);
        displayDate = DateFormat('dd MMM yyyy', 'id_ID').format(date);
      } catch (_) {
        displayDate = dateStr;
      }
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        SizedBox(
          width: 45,
          child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        Text(
          "$displayDate ${timeStr != null ? '• $timeStr' : ''}",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}