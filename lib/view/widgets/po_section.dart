import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uc_marketplace/model/model.dart'; // Pastikan path import benar (model/models.dart biasanya)
import 'package:uc_marketplace/view/widgets/po_card.dart'; // Sesuaikan nama file widget Anda (pre_order_card.dart)
import 'package:uc_marketplace/view/widgets/section_header.dart';

class PoSection extends StatelessWidget {
  final String title;
  final List<PreOrderModel> pre_orders; 

  const PoSection({
    super.key,
    required this.title,
    required this.pre_orders,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: title,
          onSeeAllTap: () {
            print("See All $title tapped");
          },
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: pre_orders.map((preOrder) {
              return PreOrderCard(
                preOrder: preOrder,
                onTap: () {
                  context.push('/buyer/po-detail', extra: preOrder);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}