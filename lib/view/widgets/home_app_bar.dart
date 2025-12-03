import 'package:flutter/material.dart';
import 'package:uc_marketplace/main.dart';


class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar Pengguna
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'), // Gambar placeholder
        ),
        const SizedBox(width: 12),
        // Teks Sapaan
         Expanded(
           child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 "Hi, Daffa K",
                 style: TextStyle(
                   fontSize: 22,
                   fontWeight: FontWeight.bold,
                   color: MyApp.primaryOrange,
                 ),
               ),
             ],
           ),
         ),
        // Tombol Aksi (Favorite & Orders)
        _buildIconButton(Icons.favorite_border_rounded),
        const SizedBox(width: 8),
        _buildIconButton(Icons.assignment_outlined),
      ],
    );
  }

  // Helper widget untuk tombol ikon bulat
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
        icon: Icon(icon, color: MyApp.textGrey),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }
}