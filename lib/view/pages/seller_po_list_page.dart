import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uc_marketplace/viewmodel/seller_order_viewmodel.dart';
import 'package:uc_marketplace/view/pages/seller_order_management_page.dart';

class SellerPoListPage extends StatefulWidget {
  const SellerPoListPage({super.key});

  @override
  State<SellerPoListPage> createState() => _SellerPoListPageState();
}

class _SellerPoListPageState extends State<SellerPoListPage> {
  @override
  void initState() {
    super.initState();
    // Load data PO saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerOrderViewModel>().fetchMyPOs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SellerOrderViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Pre-Order", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7F27)))
          : vm.myPOs.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => vm.fetchMyPOs(),
                  color: const Color(0xFFFF7F27),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.myPOs.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final po = vm.myPOs[index];
                      // Kartu PO Sederhana
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: po.image != null
                                ? Image.network(po.image!, width: 60, height: 60, fit: BoxFit.cover)
                                : Container(
                                    width: 60, height: 60, color: Colors.orange.shade100,
                                    child: const Icon(Icons.shopping_bag, color: Colors.orange),
                                  ),
                          ),
                          title: Text(po.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text("Tutup: ${po.closeOrderDate ?? '-'}"),
                              Text(
                                "Terjual: ${po.currentQuota}/${po.targetQuota}",
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          onTap: () {
                            // Navigasi ke Detail Order PO ini
                           context.go('/seller/orders/manage/${po.preOrderId}', extra: po);
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Belum ada Pre-Order dibuat", style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}