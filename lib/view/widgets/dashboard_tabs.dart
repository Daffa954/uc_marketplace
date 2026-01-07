import 'package:flutter/material.dart';

class DashboardCategoryTabs extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const DashboardCategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTab('PRE-ORDER'),
          const SizedBox(width: 40),
          _buildTab('MENU'),
        ],
      ),
    );
  }

  Widget _buildTab(String category) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () => onCategoryChanged(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF8C42) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: isSelected
              ? null
              : Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Text(
          category,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}