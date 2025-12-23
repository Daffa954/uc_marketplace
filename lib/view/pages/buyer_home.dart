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
            const CategorySection(),

            const SizedBox(height: 24),

            // --- SECTION 1: PO Mau Tutup ---
            if (homeVM.isLoading)
              const SizedBox.shrink()
            else if (homeVM.preOrders.isEmpty)
              const Center(child: Text("PO Tidak Tersedia"))
            else
              PoSection(title: "Segera Tutup", pre_orders: homeVM.preOrders),

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
