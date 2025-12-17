part of 'pages.dart';

class BuyerChatPage extends StatefulWidget {
  const BuyerChatPage({super.key});

  @override
  State<BuyerChatPage> createState() => _BuyerChatPageState();
}

class _BuyerChatPageState extends State<BuyerChatPage> {
  @override
  void initState() {
    super.initState();
    // Memanggil data broadcast saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BroadcastViewModel>(context, listen: false).fetchBroadcasts();
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- Dummy Data Existing (Personal Chat) - Tetap digunakan untuk Tab 1 ---
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

    return DefaultTabController(
      length: 2, // Dua Tab: Personal & Broadcast
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: MyApp.textDark),
            onPressed: () {
              // Logic back (sesuaikan jika perlu navigasi khusus)
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
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
          bottom: const TabBar(
            labelColor: MyApp.primaryOrange,
            unselectedLabelColor: Colors.grey,
            indicatorColor: MyApp.primaryOrange,
            tabs: [
              Tab(text: "Personal"),
              Tab(text: "Broadcast"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ------------------------------------------------
            // TAB 1: PERSONAL CHAT (Manual / Dummy List)
            // ------------------------------------------------
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: chatData.length,
              itemBuilder: (context, index) {
                final chat = chatData[index];
                return _buildChatCard(
                  context: context,
                  name: chat["name"]!,
                  message: chat["message"]!,
                  date: chat["date"]!,
                  isBroadcast: false,
                  // Personal chat belum ada halaman detailnya di kode ini
                  onTap: () {}, 
                );
              },
            ),

            // ------------------------------------------------
            // TAB 2: BROADCAST LIST (Dinamis via ViewModel)
            // ------------------------------------------------
            Consumer<BroadcastViewModel>(
              builder: (context, viewModel, child) {
                switch (viewModel.broadcastList.status) {
                  case Status.loading:
                    return const Center(child: CircularProgressIndicator());
                  
                  case Status.error:
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Gagal memuat: ${viewModel.broadcastList.message}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  
                  case Status.completed:
                    final broadcasts = viewModel.broadcastList.data ?? [];

                    if (broadcasts.isEmpty) {
                      return const Center(
                        child: Text("Belum ada pesan broadcast."),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: broadcasts.length,
                      itemBuilder: (context, index) {
                        final item = broadcasts[index];
                        
                        // Format Tanggal (Helper simple)
                        final dateStr = item.createdAt != null 
                            ? "${item.createdAt!.day}/${item.createdAt!.month}" 
                            : "-";

                        // Logic Judul: Jika terkait PO, tampilkan No PO. Jika tidak, Info Kampus.
                        final title = item.preOrderId != null 
                            ? "Info Order #${item.preOrderId}" 
                            : "Info Kampus";

                        return _buildChatCard(
                          context: context,
                          name: title,
                          message: item.message,
                          date: dateStr,
                          isBroadcast: true,
                          onTap: () {
                            // Navigasi ke Detail Broadcast
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BroadcastDetailPage(
                                  title: title,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                    
                  default:
                    return const SizedBox();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Reusable Widget untuk Item Chat ---
  Widget _buildChatCard({
    required BuildContext context,
    required String name,
    required String message,
    required String date,
    required bool isBroadcast,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Avatar Box
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isBroadcast ? Colors.blueAccent : MyApp.primaryOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isBroadcast ? Icons.campaign : Icons.person, // Ikon beda
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
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: MyApp.textDark,
                        ),
                      ),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: MyApp.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
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
      ),
    );
  }
}