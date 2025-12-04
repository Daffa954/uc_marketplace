part of 'pages.dart';

class BuyerChatPage extends StatelessWidget {
  const BuyerChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data based on the screenshot
    final List<Map<String, String>> chatData = [
      {
        "name": "Pansi Restaurant",
        "message": "Mohon konfirmasi penerima......",
        "date": "Tue",
      },
      {
        "name": "Richard - Pengantar",
        "message": "Halo, ini sesuai di ruangan 3......",
        "date": "Mon",
      },
      {
        "name": "Warung Enak",
        "message": "Mohon konfirmasi penerima......",
        "date": "25 Nov",
      },
      {
        "name": "Lily - Pengantar",
        "message": "Sori ada delay di lift, bisa di.....",
        "date": "12 Nov",
      },
      {
        "name": "Spicy Restaurant",
        "message": "Mohon konfirmasi penerima......",
        "date": "1 Nov",
      },
      {
        "name": "Cafenio Coffee Club",
        "message": "Mohon konfirmasi penerima......",
        "date": "28 Oct",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MyApp.textDark),
          onPressed: () {
            // Logic to go back to Home tab if needed, 
            // or let the bottom nav handle navigation.
            // For now, we can just pop context or do nothing since it's a main tab.
          },
        ),
        title: const Text(
          "Chats",
          style: TextStyle(
            color: MyApp.primaryOrange,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: chatData.length,
        itemBuilder: (context, index) {
          final chat = chatData[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Box (Orange background with white icon)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: MyApp.primaryOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                const SizedBox(width: 12),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            chat["name"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: MyApp.textDark,
                            ),
                          ),
                          Text(
                            chat["date"]!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: MyApp.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        chat["message"]!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: MyApp.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}