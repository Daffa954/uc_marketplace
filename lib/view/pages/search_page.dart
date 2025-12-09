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
    // Panggil ViewModel
    final searchVM = Provider.of<SearchViewModel>(context);

    // Sinkronisasi controller jika user klik keyword history
    if (_searchController.text != searchVM.searchQuery && searchVM.isSearching) {
      _searchController.text = searchVM.searchQuery;
      _searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: _searchController.text.length));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () {
            searchVM.clearSearch(); // Reset saat kembali
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
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) => searchVM.onSearch(value),
                onChanged: (value) {
                  // Opsional: Realtime search jika diinginkan
                  // searchVM.onSearch(value); 
                  if (value.isEmpty) searchVM.clearSearch();
                },
                decoration: InputDecoration(
                  hintText: "Cari restoran...",
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

            // 2. SWITCH VIEW (Searching vs Default)
            if (searchVM.isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: CircularProgressIndicator(color: Color(0xFFFF7F27)),
              ))
            else if (searchVM.isSearching)
              _buildSearchResults(searchVM)
            else
              _buildInitialContent(searchVM),
          ],
        ),
      ),
    );
  }

  // --- VIEW: INITIAL (History & Suggestion) ---
  Widget _buildInitialContent(SearchViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent Keywords
        if (vm.recentKeywords.isNotEmpty) ...[
          const Text(
            "Recent Keywords",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
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

        // Suggested Restaurants
        const Text(
          "Suggested Restaurants",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (vm.suggestedRestaurants.isEmpty)
           const Text("Tidak ada saran saat ini.", style: TextStyle(color: Colors.grey))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vm.suggestedRestaurants.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final item = vm.suggestedRestaurants[index];
              return _buildSuggestedItem(item);
            },
          ),

        const SizedBox(height: 24),

        // New Items (Menus)
        const Text(
          "New Items",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: vm.newItems.map((menu) {
              return PopularItemCard(
                foodName: menu.name,
                restaurantName: "Resto #${menu.restaurantId}", // Perlu Join utk nama asli
                price: "Rp ${menu.price}",
                rating: "4.5", // Placeholder
                imageUrl: menu.image ?? "https://placehold.co/400x400/png?text=Menu",
                tagLabel: menu.type.toString().split('.').last,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Widget Kecil untuk Suggested List
  Widget _buildSuggestedItem(RestaurantModel item) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          // Menggunakan placeholder image generator dengan nama resto
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
              Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text("4.5", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(width: 8),
                  Text(item.city ?? "", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- VIEW: SEARCH RESULTS ---
  Widget _buildSearchResults(SearchViewModel vm) {
    if (vm.searchResults.isEmpty) {
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
            text: "Result for ",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF7F27)),
            children: [
              TextSpan(text: '"${vm.searchQuery}"', style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vm.searchResults.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final resto = vm.searchResults[index];
            return _buildResultCard(resto);
          },
        ),
      ],
    );
  }

  Widget _buildResultCard(RestaurantModel item) {
    return Container(
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
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
            child: Image.network(
              "https://placehold.co/200x200/png?text=${Uri.encodeComponent(item.name)}",
              width: 100, height: 100, fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      const Text("4.5", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item.address ?? "Surabaya",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    "08.00 - 22.00 WIB",
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}