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
                final chatId = chat['chat_id'];

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
