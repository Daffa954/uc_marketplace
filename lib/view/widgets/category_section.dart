import 'package:flutter/material.dart';
import 'package:uc_marketplace/main.dart';
import 'section_header.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      
      children: [
        const SectionHeader(title: "Category"),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          
          clipBehavior: Clip.none,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategoryItem("All", null, isActive: true),
              const SizedBox(width: 50),
              _buildCategoryItem("Pick up", Icons.storefront_outlined),
              const SizedBox(width: 50),
              _buildCategoryItem("Delivery", Icons.local_shipping_outlined),
              const SizedBox(width: 50),
              _buildCategoryItem("Both", Icons.delivery_dining_outlined),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String label, IconData? icon, {bool isActive = false}) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: isActive ? MyApp.primaryOrange : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: isActive ? Colors.white : MyApp.primaryOrange,
              size: 28,
            ),
            const SizedBox(height: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : MyApp.textGrey,
              fontWeight: FontWeight.w500,
              fontSize: icon == null ? 16 : 12, // Ukuran font lebih besar jika tidak ada ikon (tombol "All")
            ),
          ),
        ],
      ),
    );
  }
}

