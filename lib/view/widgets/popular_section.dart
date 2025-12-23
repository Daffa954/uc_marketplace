part of 'widgets.dart';

class PopularSection extends StatelessWidget {
  final String title;
  // 1. Terima Data List Menu dari Parent
  final List<MenuModel> menus;

  const PopularSection({
    super.key,
    required this.title,
    required this.menus, // Wajib diisi
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: title,
          onSeeAllTap: () {
            print("See All $title tapped");
          },
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            // 2. Mapping data MenuModel ke Widget Card
            children: menus.map((menu) {
              return PopularItemCard(
                foodName: menu.name,
                
                // Karena MenuModel saat ini belum join ke tabel Restaurant,
                // kita pakai placeholder atau teks generik dulu.
                restaurantName: "Restaurant ID: ${menu.restaurantId}", 
                
                // Format Harga sederhana
                price: "Rp ${menu.price}", 
                
                // Data Placeholder (Belum ada di DB)
                rating: "4.5", 
                
                // Mengambil tipe menu (FOOD/DRINK) sebagai Tag
                tagLabel: menu.type.toString().split('.').last, 
                
                // Ambil gambar dari DB (URL), jika null pakai placeholder
                imageUrl: menu.image ?? "https://placehold.co/400x400/png?text=No+Image",
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}