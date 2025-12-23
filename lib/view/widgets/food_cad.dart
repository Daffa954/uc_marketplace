part of 'widgets.dart';
class PopularItemCard extends StatelessWidget {
  final String foodName;
  final String restaurantName;
  final String price;
  final String rating;
  final String imageUrl;
  final String tagLabel; // Contoh: "Pick Up" atau "Delivery"

  const PopularItemCard({
    super.key,
    required this.foodName,
    required this.restaurantName,
    required this.price,
    required this.rating,
    required this.imageUrl,
    this.tagLabel = "Pick Up",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, // Lebar kartu fixed
      margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4), // Efek bayangan ke bawah
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BAGIAN GAMBAR & TAG (STACK)
          Stack(
            children: [
              // Gambar Makanan
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  imageUrl,
                  height: 120, // Tinggi gambar
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Tag "Pick Up" / "Delivery"
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: tagLabel == "Pick Up" ? Colors.blue : Colors.green, // Logika warna sederhana
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tagLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // 2. BAGIAN INFORMASI (TEXT)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Makanan
                Text(
                  foodName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Agar teks tidak bablas jika kepanjangan
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MyApp.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Nama Restoran
                Text(
                  restaurantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: MyApp.textGrey,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Harga dan Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Harga
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: MyApp.textDark,
                      ),
                    ),
                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.redAccent, size: 18),
                        const SizedBox(width: 2),
                        Text(
                          rating,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: MyApp.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}