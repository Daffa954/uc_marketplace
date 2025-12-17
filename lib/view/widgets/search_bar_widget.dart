import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uc_marketplace/main.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
       
        context.push('/buyer/search');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.search, color: MyApp.textGrey),
            const SizedBox(width: 10),
            Text(
              'food, beverage, resto',
              style: TextStyle(color: MyApp.textGrey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}