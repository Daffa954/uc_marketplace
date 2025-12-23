part of 'widgets.dart';
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Hubungkan ke AuthViewModel untuk nama user dinamis
    return Consumer<AuthViewModel>(
      builder: (context, authVM, child) {
        final user = authVM.currentUser;
        final name = user?.name ?? "Guest";

        return Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
              backgroundColor: Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, $name", // Nama dinamis
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF7F27),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Lapar? Pesan makan yuk!",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            _buildIconButton(Icons.favorite_border_rounded),
            const SizedBox(width: 8),
            _buildIconButton(Icons.assignment_outlined),
          ],
        );
      },
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: const Color(0xFF9CA3AF)),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }
}