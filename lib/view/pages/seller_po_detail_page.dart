import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/viewmodel/detail_viewmodel.dart';

class PreOrderDetailPageD extends StatefulWidget {
  final PreOrderModel preOrder;

  const PreOrderDetailPageD({super.key, required this.preOrder});

  @override
  State<PreOrderDetailPageD> createState() => _PreOrderDetailPageState();
}

class _PreOrderDetailPageState extends State<PreOrderDetailPageD> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.preOrder.preOrderId != null) {
        context
            .read<DetailViewModel>()
            .loadPoDetails(widget.preOrder.preOrderId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetailViewModel>();
    final po = widget.preOrder;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // 1. Header (Gambar & Judul) - (TIDAK BERUBAH)
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFFFF8C42),
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back, color: Colors.black),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  (po.image != null && po.image!.isNotEmpty)
                      ? Image.network(po.image!, fit: BoxFit.cover)
                      : Container(color: Colors.grey[300]),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7)
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: po.status == 'OPEN'
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            po.status,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          po.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Info Statistik - (TIDAK BERUBAH)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 10)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoItem(Icons.pie_chart, "Kuota",
                      "${po.currentQuota} / ${po.targetQuota}"),
                  Container(width: 1, height: 40, color: Colors.grey[300]),
                  _infoItem(Icons.calendar_today, "Tutup PO",
                      po.closeOrderDate ?? "-"),
                  Container(width: 1, height: 40, color: Colors.grey[300]),
                  _infoItem(Icons.access_time, "Jam", po.closeOrderTime ?? "-"),
                ],
              ),
            ),
          ),

          // 3. Loading Indicator
          if (vm.isLoading)
            const SliverFillRemaining(
              child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF8C42))),
            )
          else ...[
            // 4. List Lokasi Pickup (UPDATED UNTUK MENAMPILKAN FOTO)
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Text("Titik Penjemputan",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final pickup = vm.pickupList[index];
                  // Cek apakah ada foto lokasi
                  final bool hasPhotos = pickup.photoLocation != null &&
                      pickup.photoLocation!.isNotEmpty;

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // A. Detail Teks Alamat
                        ListTile(
                          leading: const Icon(Icons.location_on,
                              color: Colors.red),
                          title: Text(pickup.address ?? "Lokasi"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (pickup.detailAddress != null)
                                Text(pickup.detailAddress!),
                              const SizedBox(height: 4),
                              Text(
                                  "${pickup.date ?? ''} • ${pickup.startTime} - ${pickup.endTime}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF8C42))),
                            ],
                          ),
                        ),

                        // B. List Foto Lokasi (Horizontal Scroll)
                        if (hasPhotos) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Divider(),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: SizedBox(
                              height: 100, // Tinggi area foto
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: pickup.photoLocation!.length,
                                separatorBuilder: (ctx, i) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, photoIndex) {
                                  final photoUrl =
                                      pickup.photoLocation![photoIndex];
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      photoUrl,
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.broken_image,
                                              color: Colors.grey),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  );
                },
                childCount: vm.pickupList.length,
              ),
            ),

            // 5. List Menu dalam PO Ini - (TIDAK BERUBAH)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: const Text("Menu Tersedia",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final menu = vm.poMenuList[index];
                  final price = NumberFormat.currency(
                          locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                      .format(menu.price);

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.05), blurRadius: 5)
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: (menu.image != null)
                                ? Image.network(menu.image!, fit: BoxFit.cover)
                                : Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.fastfood,
                                        color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(menu.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(price,
                                  style: const TextStyle(
                                      color: Color(0xFFFF8C42),
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: vm.poMenuList.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}