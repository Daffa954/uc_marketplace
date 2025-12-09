part of 'pages.dart';

class HomeBuyer extends StatelessWidget {
  const HomeBuyer({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita hapus BottomNavigationBar dari sini karena sudah ditangani oleh BuyerMainWrapper
    return const Scaffold(body: SafeArea(child: HomeBodyContent()));
  }
}

class HomeBodyContent extends StatelessWidget {
  const HomeBodyContent({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Panggil HomeViewModel
    final homeVM = Provider.of<HomeViewModel>(context);

    // 2. Tambahkan RefreshIndicator agar bisa ditarik untuk refresh
    return RefreshIndicator(
      onRefresh: () => homeVM.fetchHomeData(),
      color: const Color(0xFFFF7F27), // Warna Orange
      child: SingleChildScrollView(
        // Physics agar scroll tetap bisa ditarik meskipun konten sedikit
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header (User Info) ---
            const HomeAppBar(),

            const SizedBox(height: 20),

            // --- Promo & Search ---
            const PromoCarousel(),
            const SizedBox(height: 20),
            const SearchBarWidget(),

            const SizedBox(height: 24),

            // --- Kategori ---
            const CategorySection(),

            const SizedBox(height: 24),

            // --- SECTION 1: RESTORAN ---
            if (homeVM.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (homeVM.preOrders.isEmpty)
              const Center(child: Text("PO Tidak Tersedia"))
            else
              PoSection(
                title: "Pre Order Tersedia",
                pre_orders: homeVM.preOrders,
              ),

            const SizedBox(height: 24),

            // --- SECTION 2: POPULAR FOODS ---
            if (homeVM.isLoading)
              const SizedBox.shrink() // Loading sudah dicover di atas
            else if (homeVM.menus.isEmpty)
              const Center(child: Text("Belum ada menu populer."))
            else
              PopularSection(
                title: "Popular Foods",
                menus: homeVM.menus, // Kirim data dari ViewModel
              ),

            const SizedBox(height: 20),

            // --- SECTION 3: NEW FOODS (Bisa pakai list menu yang sama atau beda) ---
            // Disini saya pakai list yang sama untuk contoh
            if (!homeVM.isLoading && homeVM.menus.isNotEmpty)
              PopularSection(
                title: "New Foods",
                menus: homeVM.menus.reversed
                    .toList(), // Contoh: dibalik urutannya
              ),

            // Tambahan space bawah agar tidak tertutup bottom bar wrapper
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
