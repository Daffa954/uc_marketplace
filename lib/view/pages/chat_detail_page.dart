part of 'pages.dart';

class ChatDetailPage extends StatefulWidget {
  final int chatId;
  final String title;

  const ChatDetailPage({super.key, required this.chatId, required this.title});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
<<<<<<< Updated upstream
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
=======
  final _messageController = TextEditingController();
>>>>>>> Stashed changes

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatViewModel>(
        context,
        listen: false,
      ).fetchMessages(widget.chatId);
    });
  }

<<<<<<< Updated upstream
  void _sendMessage() {
    final content = _msgController.text.trim();
    if (content.isEmpty) return;

    final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
    if (user == null || user.userId == null) return;

    Provider.of<ChatViewModel>(context, listen: false)
        .sendMessage(
          chatId: widget.chatId,
          senderId: user.userId!,
          content: content,
        )
        .then((_) {
          _msgController.clear();
          _scrollToBottom();
        });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

=======
>>>>>>> Stashed changes
  @override
  Widget build(BuildContext context) {
    final chatVM = Provider.of<ChatViewModel>(context);
    final currentUser = Provider.of<AuthViewModel>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: chatVM.isLoading
                ? const Center(child: CircularProgressIndicator())
<<<<<<< Updated upstream
                : ListView.builder(
                    controller: _scrollController,
=======
                : chatVM.messages.isEmpty
                ? const Center(child: Text("Belum ada pesan"))
                : ListView.builder(
>>>>>>> Stashed changes
                    padding: const EdgeInsets.all(16),
                    itemCount: chatVM.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chatVM.messages[index];
                      final isMe = msg.senderId == currentUser?.userId;
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
<<<<<<< Updated upstream
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
=======
                          padding: const EdgeInsets.all(12),
>>>>>>> Stashed changes
                          decoration: BoxDecoration(
                            color: isMe
                                ? const Color(0xFFFF7F27)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
<<<<<<< Updated upstream
                                msg.content,
=======
                                msg.content ?? "",
>>>>>>> Stashed changes
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg.timeSend ?? "",
                                style: TextStyle(
                                  fontSize: 10,
<<<<<<< Updated upstream
                                  color: isMe ? Colors.white70 : Colors.grey,
=======
                                  color: isMe ? Colors.white70 : Colors.black54,
>>>>>>> Stashed changes
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
<<<<<<< Updated upstream
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
=======
          Padding(
            padding: const EdgeInsets.all(8.0),
>>>>>>> Stashed changes
            child: Row(
              children: [
                Expanded(
                  child: TextField(
<<<<<<< Updated upstream
                    controller: _msgController,
                    decoration: const InputDecoration(
                      hintText: "Tulis pesan...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFF7F27)),
                  onPressed: _sendMessage,
=======
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Tulis pesan...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFF7F27)),
                  onPressed: () {
                    if (currentUser?.userId != null) {
                      chatVM.sendMessage(
                        chatId: widget.chatId,
                        senderId: currentUser!.userId!,
                        content: _messageController.text,
                      );
                      _messageController.clear();
                    }
                  },
>>>>>>> Stashed changes
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
