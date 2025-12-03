part of 'pages.dart';
class HomePagev2 extends StatefulWidget {
  const HomePagev2({super.key});

  @override
  State<HomePagev2> createState() => _HomePageStatev2();
}

class _HomePageStatev2 extends State<HomePagev2> {
  var isLiked = false;
  Color favColor = Colors.grey;

  @override
  Widget build(BuildContext context) {
    // biar responsif di semua layar
    // final double imageSize = MediaQuery.of(context).size.width * 0.25;
    //setLiked function

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: const Color.fromARGB(255, 231, 231, 231),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 16,
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Hi Daffa 👋",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  Text(
                    "Mau Menginap?",
                    style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFF535353),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(9999)),
                child: Image.asset(
                  "assets/images/image1.png",
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          Container(
            child: Container(
              padding: EdgeInsets.all(15),
              // color: Colors.blue,
              height: 70,
              width: double.infinity,
              // color: Colors.blueGrey,
              child: SearchBar(
                trailing: const [Icon(Icons.search)],
                hintText: 'Cari tempat wisata...',
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 12),
                ),
                elevation: const WidgetStatePropertyAll(1),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(
                      color: Color.fromARGB(
                        255,
                        154,
                        154,
                        154,
                      ), // warna border abu-abu
                      width: 0.7,
                    ),
                  ),
                ),
                backgroundColor: const WidgetStatePropertyAll(
                  Color.fromARGB(255, 255, 255, 255),
                ),
                constraints: const BoxConstraints(minHeight: 38, maxHeight: 38),
                onChanged: (value) {},
              ),
            ),
          ),
          Container(
            child: Container(
              // color: Colors.red,
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 12,
                  children: [
                    CategoryItem(label: "Hotel", emoji: "🏨"),
                    CategoryItem(label: "Villa", emoji: "🏡"),
                    CategoryItem(label: "Camping", emoji: "🏕️"),
                    CategoryItem(label: "Pantai", emoji: "🏖️"),
                    CategoryItem(label: "Gunung", emoji: "🏔️"),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    left: 15,
                    right: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      const Text(
                        "Popular Hotel",
                        style: TextStyle(fontSize: 20),
                      ),

                      // ✅ Scroll horizontal tetap bisa
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          spacing: 12,
                          children: [
                            CustomCard(
                              imagePath: 'assets/images/image1.png',
                              title: 'Hotel Mewah',
                              location: "Surabaya Jawa Timur Indonesia ",
                            ),
                            CustomCard(
                              imagePath: 'assets/images/image2.png',
                              title: 'Hotel Mewah',
                              location: "Surabaya Indonesia",
                            ),
                            CustomCard(
                              imagePath: 'assets/images/image3.png',
                              title: 'Hotel Mewah',
                              location: "Surabaya Indonesia",
                            ),
                            CustomCard(
                              imagePath: 'assets/images/image4.png',
                              title: 'Hotel Mewah',
                              location: "Surabaya Indonesia",
                            ),
                          ],
                        ),
                      ),

                      const Text("Nearby Me", style: TextStyle(fontSize: 20)),

                      // ✅ Bagian ini saja yang bisa discroll ke bawah
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            spacing: 15,
                            children: [
                              CustomCardH(
                                imagePath: 'assets/images/image1.png',
                                title: 'Hotel Mewah',
                                location: "Surabaya Indonesia",
                              ),
                              CustomCardH(
                                imagePath: 'assets/images/image2.png',
                                title: 'Villa Cantik',
                                location: "Malang Indonesia",
                              ),
                              CustomCardH(
                                imagePath: 'assets/images/image3.png',
                                title: 'Resort Puncak',
                                location: "Bogor Indonesia",
                              ),
                              CustomCardH(
                                imagePath: 'assets/images/image4.png',
                                title: 'Pantai Indah',
                                location: "Bali Indonesia",
                              ),
                              CustomCardH(
                                imagePath: 'assets/images/image1.png',
                                title: 'Hotel Lainnya',
                                location: "Jakarta Indonesia",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    
                    child: ElevatedButton(
                      onPressed: () => context.push('/form'),
                      style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.blue)),
                      child: Text("Booking Sekarang", style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Expanded(
          //   child: Container(
          //     padding: EdgeInsets.only(bottom: 15, left: 15, right: 15),
          //     width: double.infinity,
          //     height: double.infinity,
          //     // color: Colors.blue,
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       mainAxisAlignment: MainAxisAlignment.start,
          //       spacing: 8,
          //       children: [
          //         Text("Popular Destination", style: TextStyle(fontSize: 20)),
          //         SingleChildScrollView(
          //           scrollDirection: Axis.horizontal,
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             spacing: 12,
          //             children: [
          //               CustomCard(
          //                 imagePath: 'assets/images/image1.png',
          //                 title: 'Hotel Mewah',
          //                 location: "Surabaya Jawa Timur Indonesia ",
          //               ),
          //               CustomCard(
          //                 imagePath: 'assets/images/image2.png',
          //                 title: 'Hotel Mewah',
          //                 location: "Surabaya Indonesia",
          //               ),
          //               CustomCard(
          //                 imagePath: 'assets/images/image3.png',
          //                 title: 'Hotel Mewah',
          //                 location: "Surabaya Indonesia",
          //               ),
          //               CustomCard(
          //                 imagePath: 'assets/images/image4.png',
          //                 title: 'Hotel Mewah',
          //                 location: "Surabaya Indonesia",
          //               ),
          //             ],
          //           ),
          //         ),
          //         Text(
          //           "Nearby Me",
          //           style: TextStyle(fontSize: 20),
          //         ),
          //         Expanded(
          //           child: SingleChildScrollView(
          //             scrollDirection: Axis.vertical,

          //             child: Column(
          //               spacing: 15,
          //               children: [
          //                 CustomCardH(
          //                   imagePath: 'assets/images/image1.png',
          //                   title: 'Hotel Mewah',
          //                   location: "Surabaya Indonesia",
          //                 ),
          //                  CustomCardH(
          //                   imagePath: 'assets/images/image3.png',
          //                   title: 'Hotel Mewah',
          //                   location: "Surabaya Indonesia",
          //                 ),
          //                  CustomCardH(
          //                   imagePath: 'assets/images/image3.png',
          //                   title: 'Hotel Mewah',
          //                   location: "Surabaya Indonesia",
          //                 ),
          //                  CustomCardH(
          //                   imagePath: 'assets/images/image3.png',
          //                   title: 'Hotel Mewah',
          //                   location: "Surabaya Indonesia",
          //                 ),
          //                  CustomCardH(
          //                   imagePath: 'assets/images/image3.png',
          //                   title: 'Hotel Mewah',
          //                   location: "Surabaya Indonesia",
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
