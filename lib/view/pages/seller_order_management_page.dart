import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/viewmodel/seller_order_viewmodel.dart';

class SellerOrderManagementPage extends StatefulWidget {
  final PreOrderModel preOrder;

  const SellerOrderManagementPage({super.key, required this.preOrder});

  @override
  State<SellerOrderManagementPage> createState() => _SellerOrderManagementPageState();
}

class _SellerOrderManagementPageState extends State<SellerOrderManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.preOrder.preOrderId != null) {
        context.read<SellerOrderViewModel>().fetchOrdersInPO(widget.preOrder.preOrderId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SellerOrderViewModel>();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.preOrder.name, style: const TextStyle(fontSize: 16, color: Colors.black)),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Color(0xFFFF7F27),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFFF7F27),
            tabs: [
              Tab(text: "Baru"),
              Tab(text: "Diproses"),
              Tab(text: "Siap Ambil"),
              Tab(text: "Selesai"),
            ],
          ),
        ),
        body: vm.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7F27)))
            : TabBarView(
                children: [
                  _buildList(vm.newOrders, "Belum ada pesanan baru", true),
                  _buildList(vm.processOrders, "Tidak ada pesanan diproses", true),
                  _buildList(vm.shippingOrders, "Tidak ada pesanan siap ambil", true),
                  _buildList(vm.completedOrders, "Riwayat kosong", false),
                ],
              ),
      ),
    );
  }

  Widget _buildList(List<OrderModel> orders, String emptyMsg, bool showAction) {
    if (orders.isEmpty) return Center(child: Text(emptyMsg, style: TextStyle(color: Colors.grey[400])));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
      itemBuilder: (ctx, index) {
        return _SellerActionCard(
          order: orders[index],
          preOrderId: widget.preOrder.preOrderId!,
          showAction: showAction,
        );
      },
    );
  }
}

class _SellerActionCard extends StatelessWidget {
  final OrderModel order;
  final int preOrderId;
  final bool showAction;

  const _SellerActionCard({
    required this.order,
    required this.preOrderId,
    required this.showAction,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.read<SellerOrderViewModel>();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order #${order.orderId}", style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                  child: Text(order.status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(),
            
            // List Item
            if (order.items != null)
              ...order.items!.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text("${item.quantity}x ", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(item.menu?.name ?? "Menu")),
                  ],
                ),
              )),
            
            const SizedBox(height: 12),
            Text("Total: ${currency.format(order.total)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF7F27))),

            // Tombol Aksi
            if (showAction) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: _buildButton(context, vm),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, SellerOrderViewModel vm) {
    if (order.status == 'PAID') {
      return ElevatedButton(
        onPressed: () => vm.updateOrderStatus(order.orderId!, 'PROCESS', preOrderId),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        child: const Text("Proses Pesanan", style: TextStyle(color: Colors.white)),
      );
    }
    if (order.status == 'PROCESS') {
      return ElevatedButton(
        onPressed: () => vm.updateOrderStatus(order.orderId!, 'SHIPPING', preOrderId),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7F27)),
        child: const Text("Siap Diambil", style: TextStyle(color: Colors.white)),
      );
    }
    if (order.status == 'SHIPPING') {
      return ElevatedButton(
        onPressed: () => vm.updateOrderStatus(order.orderId!, 'COMPLETED', preOrderId),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: const Text("Selesaikan", style: TextStyle(color: Colors.white)),
      );
    }
    return const SizedBox.shrink();
  }
}