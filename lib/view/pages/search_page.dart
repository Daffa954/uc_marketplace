part of 'pages.dart';

// class SearchPage extends StatefulWidget {
//   const SearchPage({super.key});

//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   final TextEditingController _searchController = TextEditingController();

//   // Data Dummy untuk Recent Keywords
//   final List<String> recentKeywords = ["Burger", "Sandwich", "Pizza", "Sanwich"];

//   // Data Dummy untuk Suggested Restaurants
//   final List<Map<String, dynamic>> suggestedRestos = [
//     {
//       "name": "Pansi Restaurant",
//       "rating": "4.7",
//       "image": "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=100&auto=format&fit=crop"
//     },
//     {
//       "name": "American Spicy Burger Shop",
//       "rating": "4.3",
//       "image": "https://images.unsplash.com/photo-1550547660-d9450f859349?q=80&w=100&auto=format&fit=crop"
//     },
//     {
//       "name": "Cafenio Coffee Club",
//       "rating": "4.0",
//       "image": "https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=100&auto=format&fit=crop"
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: MyApp.textDark),
//           onPressed: () => context.pop(), // Kembali ke Home
//         ),
//         title: const Text(
//           "Search",
//           style: TextStyle(
//               color: MyApp.primaryOrange, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.favorite_border, color: MyApp.primaryOrange),
//             onPressed: () {},
//           ),
//           IconButton(
//             icon: const Icon(Icons.assignment_outlined, color: MyApp.primaryOrange), // Icon Clipboard
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 1. INPUT PENCARIAN
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: TextField(
//                 controller: _searchController,
//                 autofocus: true, // Langsung fokus keyboard muncul
//                 decoration: InputDecoration(
//                   hintText: "Pizza",
//                   prefixIcon: const Icon(Icons.search, color: Colors.black87),
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.cancel, color: Colors.grey),
//                     onPressed: () => _searchController.clear(),
//                   ),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),

//             // 2. RECENT KEYWORDS
//             const Text(
//               "Recent Keywords",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: MyApp.textDark),
//             ),
//             const SizedBox(height: 12),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: recentKeywords.map((keyword) {
//                   return Container(
//                     margin: const EdgeInsets.only(right: 10),
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(keyword, style: const TextStyle(color: MyApp.textDark)),
//                   );
//                 }).toList(),
//               ),
//             ),
//             const SizedBox(height: 24),

//             // 3. SUGGESTED RESTAURANTS
//             const Text(
//               "Suggested Restaurants",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: MyApp.textDark),
//             ),
//             const SizedBox(height: 12),
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: suggestedRestos.length,
//               separatorBuilder: (context, index) => const Divider(height: 24),
//               itemBuilder: (context, index) {
//                 final item = suggestedRestos[index];
//                 return Row(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.network(item['image'], width: 60, height: 60, fit: BoxFit.cover),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               const Icon(Icons.star_border_rounded, size: 18, color: MyApp.primaryOrange),
//                               const SizedBox(width: 4),
//                               Text(item['rating'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
//                             ],
//                           )
//                         ],
//                       ),
//                     )
//                   ],
//                 );
//               },
//             ),
//             const SizedBox(height: 24),

//             // 4. NEW ITEMS (Menggunakan PopularItemCard yang sudah dibuat sebelumnya)
//             const Text(
//               "New Items",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: MyApp.textDark),
//             ),
//             const SizedBox(height: 12),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               clipBehavior: Clip.none,
//               child: Row(
//                 children: [
//                   PopularItemCard(
//                     foodName: "Choco chip cookies",
//                     restaurantName: "Bakery Wenak",
//                     price: "Rp. 20.000",
//                     rating: "4+",
//                     imageUrl: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=100&auto=format&fit=crop",
//                     tagLabel: "Pick Up",
//                   ),
//                    PopularItemCard(
//                     foodName: "Choco chip cookies",
//                     restaurantName: "Bakery Wenak",
//                     price: "Rp. 20.000",
//                     rating: "4+",
//                     imageUrl: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=100&auto=format&fit=crop",
//                     tagLabel: "Pick Up",
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  // State untuk mengecek apakah user sedang mencari
  bool _isSearching = false;
  String _searchQuery = "";

  // Data Dummy untuk Recent Keywords
  final List<String> recentKeywords = [
    "Burger",
    "Sandwich",
    "Pizza",
    "Sanwich",
  ];
  final List<Map<String, dynamic>> suggestedRestos = [
    {
      "name": "Pansi Restaurant",
      "rating": "4.7",
      "image":
          "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=100&auto=format&fit=crop",
    },
    {
      "name": "American Spicy Burger Shop",
      "rating": "4.3",
      "image":
          "https://images.unsplash.com/photo-1550547660-d9450f859349?q=80&w=100&auto=format&fit=crop",
    },
    {
      "name": "Cafenio Coffee Club",
      "rating": "4.0",
      "image":
          "https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=100&auto=format&fit=crop",
    },
  ];
  // Data Dummy Hasil Pencarian (Bisa diganti dengan data API nanti)
  final List<Map<String, dynamic>> searchResults = [
    {
      "name": "Warung Enak",
      "location": "UC Walk - Surabaya",
      "time": "07.00 - 19.00 WIB",
      "rating": "4.5",
      "image":
          "https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=300&auto=format&fit=crop",
    },
    {
      "name": "Warung Enak",
      "location": "UC Walk - Surabaya",
      "time": "07.00 - 19.00 WIB",
      "rating": "4.5",
      "image":
          "https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=300&auto=format&fit=crop",
    },
    {
      "name": "Warung Enak",
      "location": "UC Walk - Surabaya",
      "time": "07.00 - 19.00 WIB",
      "rating": "4.5",
      "image":
          "https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=300&auto=format&fit=crop",
    },
  ];

  @override
  void initState() {
    super.initState();
    // Mendengarkan perubahan teks untuk update UI real-time (opsional)
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _isSearching = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Sesuaikan background putih polos
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MyApp.textDark),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Search",
          style: TextStyle(
            color: MyApp.primaryOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Ikon Heart hanya muncul di hasil pencarian sesuai desain
          IconButton(
            icon: const Icon(Icons.favorite_border, color: MyApp.textGrey),
            onPressed: () {},
          ),
        ],
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
                onSubmitted: (value) {
                  // Aksi ketika tombol Enter ditekan
                  setState(() {
                    _isSearching = true;
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Pizza",
                  hintStyle: const TextStyle(
                    color: Colors.grey, // ubah warna placeholder di sini
                    fontSize: 16, // opsional
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.black87),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            // Keyboard dismiss
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

            // 2. LOGIKA TAMPILAN (SWITCH VIEW)
            // Jika sedang mencari (_isSearching = true), tampilkan Hasil.
            // Jika tidak, tampilkan Default (Recent Keywords, Suggested).
            _isSearching ? _buildSearchResults() : _buildInitialContent(),
          ],
        ),
      ),
    );
  }

  // WIDGET: Tampilan Awal (Recent & Suggested)
  Widget _buildInitialContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent Keywords
        const Text(
          "Recent Keywords",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: MyApp.textDark,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: recentKeywords.map((keyword) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = keyword;
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    keyword,
                    style: const TextStyle(color: MyApp.textDark),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Suggested Restaurants

        // ... (Kode ListView Suggested Restaurant sebelumnya bisa ditaruh sini)
        const Text(
          "Suggested Restaurants",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: MyApp.textDark,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: suggestedRestos.length,
          separatorBuilder: (context, index) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final item = suggestedRestos[index];
            return Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item['image'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_border_rounded,
                            size: 18,
                            color: MyApp.primaryOrange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item['rating'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        // New Items
        const Text(
          "New Items",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: MyApp.textDark,
          ),
        ),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              PopularItemCard(
                foodName: "Choco chip cookies",
                restaurantName: "Bakery Wenak",
                price: "Rp. 20.000",
                rating: "4+",
                imageUrl:
                    "https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=100&auto=format&fit=crop",
                tagLabel: "Pick Up",
              ),
              PopularItemCard(
                foodName: "Choco chip cookies",
                restaurantName: "Bakery Wenak",
                price: "Rp. 20.000",
                rating: "4+",
                imageUrl:
                    "https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=100&auto=format&fit=crop",
                tagLabel: "Pick Up",
              ),
            ],
          ),
        ),
      ],
    );
  }

  // WIDGET: Tampilan Hasil Pencarian
  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header "Result for ..."
        Text.rich(
          TextSpan(
            text: "Result for ",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MyApp.primaryOrange,
            ),
            children: [
              TextSpan(
                text: '"$_searchQuery"',
                style: const TextStyle(color: MyApp.primaryOrange),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // List Result Cards
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: searchResults.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = searchResults[index];
            return _buildResultCard(item);
          },
        ),
      ],
    );
  }

  // WIDGET: Kartu Item Hasil Pencarian (Sesuai Desain Screenshot)
  Widget _buildResultCard(Map<String, dynamic> item) {
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
          // Gambar di Kiri
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(
              item['image'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          // Info di Tengah
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating Star
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        item['rating'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Nama Resto
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MyApp.textDark,
                    ),
                  ),

                  // Lokasi
                  Text(
                    item['location'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  // Jam Buka
                  Text(
                    item['time'],
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade400),
                  ),
                ],
              ),
            ),
          ),

          // Tombol Love di Kanan
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                // Catatan: Di desain ikonnya putih tapi background abu,
                // jika ingin persis ganti color: Colors.white
                onPressed: () {},
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
