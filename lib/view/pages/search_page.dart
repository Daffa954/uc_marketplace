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

    // Sinkronisasi controller visual
    if (_searchController.text != searchVM.searchQuery &&
        searchVM.isSearching &&
        !searchVM.isLocationResult) { // Jangan update teks jika sedang mode lokasi
      _searchController.text = searchVM.searchQuery;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    } else if (searchVM.isLocationResult && _searchController.text.isEmpty) {
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
            // 1. INPUT PENCARIAN
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: false, // Ubah false agar tidak popup keyboard terus
                textInputAction: TextInputAction.search,
                onSubmitted: (value) => searchVM.onSearch(value),
                onChanged: (value) {
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
            
            // Tombol "Cari Terdekat" hanya muncul jika belum searching
            if (!searchVM.isSearching) _buildNearMeButton(searchVM),

            const SizedBox(height: 16),

            // 2. SWITCH VIEW
            if (searchVM.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: CircularProgressIndicator(color: Color(0xFFFF7F27)),
                ),
              )
            else if (searchVM.isSearching)
              _buildSearchResults(searchVM) // Logic Baru Ada Disini
            else
              _buildInitialContent(searchVM),
          ],
        ),
      ),
    );
  }

  // --- WIDGET TOMBOL CARI LOKASI ---
  Widget _buildNearMeButton(SearchViewModel vm) {
    return GestureDetector(
      onTap: () async {
        final LatLng? result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MapPickerPage()),
        );

        if (result != null) {
          vm.searchByLocation(result);
          _searchController.text = "📍 Lokasi: ${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}";
          FocusScope.of(context).unfocus();
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

  // --- VIEW 1: INITIAL CONTENT (Suggestion) ---
  Widget _buildInitialContent(SearchViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent Keywords
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

        // Suggested PreOrders
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

        const SizedBox(height: 24),

        // New Items (Menus)
        const Text("New Menu Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: vm.newItems.map((menu) {
              return PopularItemCard(
                foodName: menu.name,
                restaurantName: "Resto #${menu.restaurantId}", 
                price: "Rp ${menu.price}",
                rating: "4.5",
                imageUrl: menu.image ?? "https://placehold.co/400x400/png?text=Menu",
                tagLabel: menu.type.toString().split('.').last,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Widget Kecil Suggested (PreOrder)
  Widget _buildSuggestedItem(PreOrderModel item) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            "https://placehold.co/100x100/png?text=${Uri.encodeComponent(item.name)}",
            width: 60, height: 60, fit: BoxFit.cover,
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
    );
  }

  // --- VIEW 2: SEARCH RESULTS (LOGIC UTAMA) ---
  Widget _buildSearchResults(SearchViewModel vm) {
    // 1. Tentukan List mana yang dipakai (PreOrder atau Pickup)
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
            // SWITCH CARD: Tampilkan card sesuai tipe data
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

// --- CARD 1: UNTUK PRE-ORDER (Text Search) ---
  Widget _buildPreOrderCard(PreOrderModel item) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke detail PO dengan mengirim data model 'item'
        context.push('/buyer/home/po-detail', extra: item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                "https://placehold.co/200x200/png?text=${Uri.encodeComponent(item.name)}",
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text("4.5",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "PO Date: ${item.orderDate}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Time: ${item.orderTime ?? '-'}",
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
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

// --- CARD 2: UNTUK PO PICKUP (Location Search) ---
  // Tampilan dibuat IDENTIK dengan _buildPreOrderCard
  Widget _buildPickupCard(PoPickupModel item) {
    // Ambil foto pertama jika ada
    String imageUrl = (item.photoLocation != null && item.photoLocation!.isNotEmpty)
        ? item.photoLocation!.first
        : "https://placehold.co/200x200/png?text=Pickup";

    return GestureDetector(
      onTap: () {
        // NOTE: Pastikan Anda memiliki objek PreOrderModel yang terkait dengan item ini.
        // Jika route /po-detail memerlukan PreOrderModel, Anda mungkin perlu 
        // mengambilnya dari ViewModel berdasarkan item.preOrderId.
        // context.push('/buyer/home/po-detail', extra: associatedPreOrder);
        
        print("Tapped on Pickup Point #${item.preOrderId}");
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.location_on),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                        Text(
                          "Pickup Point",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Point #${item.preOrderId}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.address ?? "Lokasi Jemputan",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${item.startTime} - ${item.endTime}",
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
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