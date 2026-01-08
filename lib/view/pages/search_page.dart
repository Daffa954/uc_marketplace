part of 'pages.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchVM = Provider.of<SearchViewModel>(context);

    // Sinkronisasi teks controller dengan state searchVM
    if (_searchController.text != searchVM.searchQuery &&
        searchVM.isSearching &&
        !searchVM.isLocationResult) {
      _searchController.text = searchVM.searchQuery;
      // Pindahkan kursor ke akhir teks agar user tidak bingung saat ketik
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    } else if (searchVM.isLocationResult && _searchController.text.isEmpty) {
       // Jika hasil lokasi tapi text kosong, beri label
       _searchController.text = "📍 Lokasi Terpilih";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () {
            // Reset state saat keluar
            searchVM.clearSearch();
            _searchController.clear();
            context.pop();
          },
        ),
        title: const Text(
          "Search",
          style: TextStyle(
            color: Color(0xFFFF7F27),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. INPUT PENCARIAN (SEARCH BAR)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: false, 
                textInputAction: TextInputAction.search,
                // Trigger search saat tombol enter ditekan
                onSubmitted: (value) => searchVM.onSearch(value),
                onChanged: (value) {
                   // Reset jika user menghapus semua teks
                   if (value.isEmpty) searchVM.clearSearch();
                },
                decoration: InputDecoration(
                  hintText: "Cari Pre-Order...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                  prefixIcon: const Icon(Icons.search, color: Colors.black87),
                  suffixIcon: searchVM.isSearching
                      ? IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            searchVM.clearSearch();
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // TOMBOL "CARI TERDEKAT" (Hanya muncul jika belum mode searching)
            if (!searchVM.isSearching) _buildNearMeButton(searchVM),

            const SizedBox(height: 16),

            // 2. KONTEN (LOADING / HASIL / SUGGESTION)
            if (searchVM.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: CircularProgressIndicator(color: Color(0xFFFF7F27)),
                ),
              )
            else if (searchVM.isSearching)
              _buildSearchResults(searchVM) // Tampilkan Hasil
            else
              _buildInitialContent(searchVM), // Tampilkan Saran
          ],
        ),
      ),
    );
  }

  // --- WIDGET TOMBOL CARI LOKASI ---
  Widget _buildNearMeButton(SearchViewModel vm) {
    return GestureDetector(
      onTap: () async {
        // Buka halaman peta untuk pilih lokasi
        final LatLng? result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MapPickerPage()),
        );

        if (result != null) {
          // Panggil ViewModel untuk cari PO terdekat dari lokasi yang dipilih
          vm.searchByLocation(result);
          
          // Update text field agar user tahu lokasi terpilih
          _searchController.text = "📍 Lokasi: ${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}";
          FocusScope.of(context).unfocus(); // Tutup keyboard
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.near_me, color: Color(0xFFFF7F27)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cari PO Pickup di sekitar saya",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF7F27)),
                  ),
                  Text(
                    "Temukan titik jemput terdekat via Peta",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFFF7F27)),
          ],
        ),
      ),
    );
  }

  // --- VIEW 1: INITIAL CONTENT (Saran & Riwayat) ---
  Widget _buildInitialContent(SearchViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent Keywords (Riwayat Pencarian)
        if (vm.recentKeywords.isNotEmpty) ...[
          const Text("Recent Keywords", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: vm.recentKeywords.map((keyword) {
                return GestureDetector(
                  onTap: () => vm.setKeyword(keyword),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(keyword, style: const TextStyle(color: Colors.black87)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Suggested PreOrders (Rekomendasi)
        const Text("Suggested PO", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        if (vm.suggestedPreOrders.isEmpty)
          const Text("Tidak ada saran saat ini.", style: TextStyle(color: Colors.grey))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vm.suggestedPreOrders.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final item = vm.suggestedPreOrders[index];
              return _buildSuggestedItem(item);
            },
          ),
      ],
    );
  }

  // Widget Item Saran
  Widget _buildSuggestedItem(PreOrderModel item) {
    return InkWell(
      onTap: () => context.push('/buyer/home/po-detail', extra: item),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.image ?? "https://placehold.co/100x100/png?text=PO",
              width: 60, height: 60, fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(width: 60, height: 60, color: Colors.grey[200]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(item.orderDate ?? "-", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- VIEW 2: SEARCH RESULTS (Hasil Pencarian) ---
  Widget _buildSearchResults(SearchViewModel vm) {
    // Tentukan list mana yang ditampilkan: Pickup (Lokasi) atau PreOrder (Text)
    final bool isEmpty = vm.isLocationResult 
        ? vm.pickupResults.isEmpty 
        : vm.preOrderResults.isEmpty;
    
    final int count = vm.isLocationResult 
        ? vm.pickupResults.length 
        : vm.preOrderResults.length;

    if (isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Icon(Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Tidak ditemukan hasil untuk "${vm.searchQuery}"',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: vm.isLocationResult ? "Titik Jemput Terdekat" : "Hasil Pencarian ",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF7F27)),
            children: [
              if (!vm.isLocationResult)
              TextSpan(text: ' "${vm.searchQuery}"', style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (vm.isLocationResult) {
              return _buildPickupCard(vm.pickupResults[index]);
            } else {
              return _buildPreOrderCard(vm.preOrderResults[index]);
            }
          },
        ),
      ],
    );
  }

  // --- CARD 1: CARD UNTUK HASIL TEXT SEARCH (PreOrderModel) ---
  Widget _buildPreOrderCard(PreOrderModel item) {
    return GestureDetector(
      onTap: () {
        context.push('/buyer/home/po-detail', extra: item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Gambar PO
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              child: Image.network(
                item.image ?? "https://placehold.co/200x200/png?text=PO",
                width: 100, height: 100, fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(width: 100, height: 100, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
              ),
            ),
            const SizedBox(width: 12),
            // Info PO
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating (Dummy)
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text("4.5", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text("Tutup PO: ${item.closeOrderDate ?? '-'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("Target: ${item.targetQuota} porsi", style: const TextStyle(fontSize: 12, color: Colors.blue)),
                  ],
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  // --- CARD 2: CARD UNTUK HASIL LOCATION SEARCH (PoPickupModel) ---
  Widget _buildPickupCard(PoPickupModel item) {
    // Ambil gambar pertama pickup, atau placeholder
    String imageUrl = (item.photoLocation != null && item.photoLocation!.isNotEmpty)
        ? item.photoLocation!.first.toString()
        : "https://placehold.co/200x200/png?text=Pickup";

    return GestureDetector(
      onTap: () async {
        // [FIX NAVIGASI] Ambil detail PO Induk sebelum pindah halaman
        showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFFFF7F27))));
        
        try {
          // Cari PO Induk dari list active di Repo/ViewModel
          // Menggunakan repo instance baru atau existing provider
          // Disini kita pakai logic simpel: panggil repo langsung untuk cari by ID
          final repo = PreOrderRepository(); // Pastikan import repo
          final allPos = await repo.getActivePreOrders();
          
          if (context.mounted) {
            Navigator.pop(context); // Tutup Loading
            
            try {
              // Cari PO yang ID-nya cocok dengan preOrderId di pickup item
              final targetPO = allPos.firstWhere((po) => po.preOrderId == item.preOrderId);
              context.push('/buyer/home/po-detail', extra: targetPO);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Detail PO tidak ditemukan")));
            }
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal memuat data")));
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Gambar Pickup
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                width: 100, height: 100, fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(width: 100, height: 100, color: Colors.grey[200], child: const Icon(Icons.location_on)),
              ),
            ),
            const SizedBox(width: 12),
            // Info Pickup
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.map, color: Colors.orange, size: 16),
                        SizedBox(width: 4),
                        Text("Pickup Point", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Tampilkan Alamat
                    Text(item.address ?? "Lokasi Jemputan", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                    // Tampilkan Waktu
                    Text("${item.date} • ${item.startTime} - ${item.endTime}", style: const TextStyle(fontSize: 12, color: Colors.blue)),
                  ],
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}