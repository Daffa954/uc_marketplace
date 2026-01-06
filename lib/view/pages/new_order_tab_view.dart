import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodel/new_order_history_viewmodel.dart';

class NewOrderTabView extends StatefulWidget {
  final int initialIndex; // 0 for Ongoing, 1 for History
  const NewOrderTabView({super.key, this.initialIndex = 0});

  @override
  State<NewOrderTabView> createState() => _NewOrderTabViewState();
}

class _NewOrderTabViewState extends State<NewOrderTabView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<NewOrderHistoryViewModel>().loadOrders());
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF7622);
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialIndex,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          title: const Text("Orders", style: TextStyle(color: orange, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: orange,
            labelColor: orange,
            unselectedLabelColor: Colors.grey,
            tabs: [Tab(text: "Ongoing"), Tab(text: "History")],
          ),
        ),
        body: Consumer<NewOrderHistoryViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) return const Center(child: CircularProgressIndicator(color: orange));
            return TabBarView(
              children: [
                _OrderList(orders: vm.ongoing, isOngoing: true),
                _OrderList(orders: vm.history, isOngoing: false),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<dynamic> orders;
  final bool isOngoing;
  const _OrderList({required this.orders, required this.isOngoing});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return const Center(child: Text("No orders found"));
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, i) {
        final order = orders[i];
        return Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(order.restaurantLogo, width: 70, height: 70, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: Colors.grey[200], width: 70, height: 70)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.restaurantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(isOngoing 
                        ? DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)
                        : "Rp ${order.total} | ${order.itemCount} Items", 
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7622), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: Text(isOngoing ? "Track" : "Reorder", style: const TextStyle(color: Colors.white)),
                )
              ],
            ),
            const Divider(height: 30),
          ],
        );
      },
    );
  }
}