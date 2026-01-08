part of 'pages.dart';

class HomeBuyer extends StatelessWidget {
  const HomeBuyer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: HomeBodyContent()));
  }
}

class HomeBodyContent extends StatelessWidget {
  const HomeBodyContent({super.key});

  @override
  Widget build(BuildContext context) {
    final homeVM = Provider.of<HomeViewModel>(context);

    return RefreshIndicator(
      onRefresh: () => homeVM.fetchHomeData(),
      color: const Color(0xFFFF7F27),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header (User Info) ---
            const HomeAppBar(),

            const SizedBox(height: 20),

            const HeroSection(),

            const SizedBox(height: 20),

            // --- Search Bar ---
            const SearchBarWidget(),

            const SizedBox(height: 24),

            // --- Kategori ---
            // const CategorySection(),

            const SizedBox(height: 24),

            // --- SECTION 1: PO Mau Tutup ---
            if (homeVM.isLoading)
              const SizedBox.shrink()
            else if (homeVM.preOrders.isEmpty)
              const Center(child: Text("PO Tidak Tersedia"))
            else
              PoSection(title: "Segera Tutup", pre_orders: homeVM.preOrders),

            const SizedBox(height: 24),
            // --- SECTION: DEKAT SAYA (NEAR ME) ---
            // Logika: Tampilkan list jika ada data, Tampilkan pesan jika kosong
            if (homeVM.nearbyPOs.isNotEmpty) ...[
              // KONDISI 1: ADA DATA
              PoSection(
                title: "Dekat Lokasi Kamu 📍",
                pre_orders: homeVM.nearbyPOs,
                extraInfoMap: homeVM.poDistances,
              ),
            ] else ...[
              // KONDISI 2: DATA KOSONG (Tampilkan Keterangan)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tetap tampilkan Judul agar user tahu fitur ini ada
                    const Text(
                      "Dekat Lokasi Kamu 📍",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Card Keterangan Kosong
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50], // Warna abu sangat muda
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off_outlined,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Yah, belum ada PO di sekitarmu",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Coba aktifkan GPS atau cari di area lain ya!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            // --- SECTION 2: PO Hidden Gem---
            if (homeVM.isLoading)
              const SizedBox.shrink()
            else if (homeVM.hiddenGemsPreOrders.isEmpty)
              const Center(child: Text("Belum PO."))
            else
              PoSection(
                title: "Bantu Larisin",
                pre_orders: homeVM.hiddenGemsPreOrders,
              ),

            const SizedBox(height: 20),

            // --- SECTION 3: PO Populer  ---
            if (homeVM.isLoading)
              const SizedBox.shrink()
            else if (homeVM.popularPreOrders.isEmpty)
              const Center(child: Text("Belum PO."))
            else
              PoSection(
                title: "Populer Pre Order",
                pre_orders: homeVM.popularPreOrders,
              ),

            // Tambahan space bawah agar tidak tertutup bottom bar wrapper
            const SizedBox(height: 20),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
