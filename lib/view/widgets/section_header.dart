import 'package:flutter/material.dart';
import 'package:uc_marketplace/main.dart';


class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: MyApp.textDark,
          ),
        ),
        if (onSeeAllTap != null)
          TextButton(
            onPressed: onSeeAllTap,
            child: Text(
              "See All",
              style: TextStyle(
                color: Colors.blue.shade400, // Warna biru muda sesuai gambar
                fontWeight: FontWeight.w500,
              ),
            ),
          )
      ],
    );
  }
}