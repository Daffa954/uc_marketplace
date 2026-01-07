import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardSummarySection extends StatelessWidget {
  final int todayOrders;
  final double todayRevenue;
  final double totalRevenue;

  const DashboardSummarySection({
    super.key,
    required this.todayOrders,
    required this.todayRevenue,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // KOTAK 3: Total Pendapatan (7 Hari)
          _SummaryCard(
            title: "Total\nPendapatan",
            value: "$totalRevenue",
            icon: Icons.account_balance_wallet,
            color: const Color(0xFFFF8C42), // Orange
            isCurrency: true,
          ),
          const SizedBox(height: 10),

          // KOTAK 2: Pesanan Hari Ini
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: "Pesanan\nHari Ini",
                  value: "$todayOrders",
                  icon: Icons.receipt_long,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  title: "Pendapatan\nHari Ini",
                  value: "$todayRevenue",
                  icon: Icons.today,
                  color: Colors.green,
                  isCurrency: true,
                ),
              ),
            ],
          ),

          // KOTAK 1: Pesanan Hari Ini
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isCurrency;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isCurrency = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ); // Format ringkas (misal 1.5jt) agar muat di kotak kecil

    String displayValue = value;
    if (isCurrency) {
      double val = double.tryParse(value) ?? 0;
      displayValue = currencyFormat.format(val);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Header
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),

          // Value
          Text(
            displayValue,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
