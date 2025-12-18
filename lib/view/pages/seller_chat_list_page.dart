part of 'pages.dart';

class SellerChatListPage extends StatefulWidget {
  const SellerChatListPage({super.key});

  @override
  State<SellerChatListPage> createState() => _SellerChatListPageState();
}

class _SellerChatListPageState extends State<SellerChatListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthViewModel>(
        context,
        listen: false,
      ).currentUser;
      if (user != null && user.userId != null) {
        Provider.of<ChatViewModel>(
          context,
          listen: false,
        ).fetchSellerChats(user.userId!);
      }
    });
  }

  void _showAddChatDialog(BuildContext context, ChatViewModel chatVM) {
    final userIdController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Mulai Chat Baru"),
        content: TextField(
          controller: userIdController,
          decoration: const InputDecoration(
            labelText: "User ID Pelanggan",
            hintText: "Masukkan ID User",
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final userIdStr = userIdController.text.trim();
              if (userIdStr.isEmpty) return;

              final userId = int.tryParse(userIdStr);
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("ID User harus angka")),
                );
                return;
              }

              final currentUser = Provider.of<AuthViewModel>(
                context,
                listen: false,
              ).currentUser;
              if (currentUser == null || currentUser.userId == null) return;

              try {
                // Using currentUser.userId as sellerId based on previous bypass
                await chatVM.createChat(currentUser.userId!, userId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Chat berhasil dibuat")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal membuat chat: $e")),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7F27),
              foregroundColor: Colors.white,
            ),
            child: const Text("Tambah"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatVM = Provider.of<ChatViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Pelanggan"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddChatDialog(context, chatVM),
        backgroundColor: const Color(0xFFFF7F27),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: chatVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatVM.chatList.isEmpty
          ? const Center(child: Text("Belum ada chat dari pelanggan"))
          : ListView.builder(
              itemCount: chatVM.chatList.length,
              itemBuilder: (context, index) {
                final chat = chatVM.chatList[index];
                // chat['users'] is the joined user data (buyer)
                final buyerName = chat['users'] != null
                    ? chat['users']['name']
                    : "Pelanggan";
                // Handle potential different ID column names (chat_id vs payment_id)
                final chatId = chat['chat_id'] ?? chat['payment_id'];

                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(buyerName),
                  subtitle: const Text("Ketuk untuk melihat pesan"),
                  onTap: () {
                    context.push(
                      '/seller/chat/detail',
                      extra: {'chatId': chatId, 'title': buyerName},
                    );
                  },
                );
              },
            ),
    );
  }
}
