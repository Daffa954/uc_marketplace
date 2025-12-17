part of 'pages.dart';

class BroadcastDetailPage extends StatelessWidget {
  final String title;

  const BroadcastDetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // --- Dummy Data Messages untuk Broadcast ---
    // Karena ini broadcast, pengirimnya biasanya Admin/Seller (kiri/aligned start)
    final List<Map<String, dynamic>> messages = [
      {
        "message": "Selamat datang di channel Info Promo UC!",
        "time": "10:00",
        "date": "20 Nov 2024"
      },
      {
        "message": "Dapatkan diskon ongkir 50% khusus hari ini jam 12-1 siang.",
        "time": "10:05",
        "date": "20 Nov 2024"
      },
      {
        "message": "Flash Sale Alert! ⚡\nNasi Goreng Spesial hanya Rp 10.000 (Normal Rp 18.000). Stok terbatas!",
        "time": "09:00",
        "date": "Hari Ini"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MyApp.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.campaign, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: MyApp.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Banner Info "View Only"
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 5),
                Text(
                  "Hanya admin yang dapat mengirim pesan di sini",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          
          // List Chat Bubble
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _buildBroadcastBubble(
                  message: msg['message'],
                  time: msg['time'],
                  date: msg['date'],
                );
              },
            ),
          ),
          
          // Area input dihilangkan untuk Buyer (View Only)
        ],
      ),
    );
  }

  Widget _buildBroadcastBubble({
    required String message,
    required String time,
    required String date,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Broadcast selalu dari kiri (incoming)
        children: [
          // Bubble
          Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50, // Warna background bubble abu2 muda
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
                bottomLeft: Radius.circular(0),
              ),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: MyApp.textDark,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 5),
          // Time & Date
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              "$time • $date",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}