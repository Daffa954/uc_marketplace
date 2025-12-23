part of 'widgets.dart';
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendapatkan lebar layar untuk penyesuaian responsif
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      // Margin horizontal agar tidak menempel ke tepi layar
      margin: const EdgeInsets.symmetric(horizontal: 0.0), 
      // Membatasi tinggi maksimal agar tidak terlalu besar di tablet
      constraints: const BoxConstraints(
        maxHeight: 200, // Tinggi maksimal banner
        minHeight: 160, // Tinggi minimal
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        // Gradient warna orange khas brand
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF7F27), // Warna utama
            Color(0xFFFFA060), // Warna sedikit lebih terang
          ],
        ),
        borderRadius: BorderRadius.circular(24), // Sudut membulat
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7F27).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // --- Layer 1: Dekorasi Latar Belakang (Opsional) ---
          Positioned(
            top: -20,
            right: -20,
            child: Icon(
              Icons.fastfood_rounded,
              size: 150,
              color: Colors.white.withOpacity(0.1),
            ),
          ),

          // --- Layer 2: Teks Konten (Kiri) ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Headline
                 Text(
                  "Lapar Melanda?",
                  style: TextStyle(
                    fontSize: screenWidth < 360 ? 18 : 22, // Responsif font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Sub-headline
                SizedBox(
                  width: screenWidth * 0.55, // Batasi lebar teks agar tidak menabrak gambar
                  child: Text(
                    "Temukan Jajanan & PO Viral di UC Marketplace!",
                    style: TextStyle(
                      fontSize: screenWidth < 360 ? 12 : 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.2,
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 16),
                // Tombol Aksi Kecil
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Pesan Sekarang",
                    style: TextStyle(
                      color: Color(0xFFFF7F27),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
          ),

          // --- Layer 3: Gambar Ilustrasi (Kanan Bawah) ---
          // CATATAN: Ganti ini dengan Image.asset milik Anda untuk hasil terbaik.
          Positioned(
            bottom: 10, // Sedikit menonjol dari bawah
            right: 10,
            child: SizedBox(
              height: 140, // Tinggi gambar
              width: 140,
              // Gunakan Placeholder Ikon jika belum ada gambar aset
              // Nanti ganti dengan: Image.asset('assets/images/hero_food.png')
              child: const Icon(
                Icons.lunch_dining_rounded, 
                size: 120, 
                color: Colors.white
              ),
              // Contoh jika menggunakan gambar dari internet (Hapus Icon di atas jika pakai ini):
              /*
              child: Image.network(
                'https://ouch-cdn2.icons8.com/fvLgP0zM4g5u6w5X9z1Q7Z6c4t3v8b2n1m0k9l8j7h/rs:fit:256:256/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9wbmcvMTcy/LzY1YjY4YzY0LTQ4/YjUtNDM0Mi04YjE2/LWUxNDliZDI5NzFl/OC5wbmc.png',
                fit: BoxFit.contain,
              ),
              */
            ),
          ),
        ],
      ),
    );
  }
}