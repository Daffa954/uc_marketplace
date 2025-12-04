part of 'pages.dart';

class HomeBuyer extends StatefulWidget {
  const HomeBuyer({super.key});

  @override
  State<HomeBuyer> createState() => _HomeBuyerState();
}

class _HomeBuyerState extends State<HomeBuyer> {
  int _selectedIndex = 0;
 final List<Widget> _pages = const [
    HomeBodyContent(),
    BuyerProfilePage(), // Ganti sesuai nama halaman profil kamu
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SafeArea memastikan konten tidak tertutup notch/status bar
       body: SafeArea(
        child: _pages[_selectedIndex], // <<< PENTING
      ),

      bottomNavigationBar: SizedBox(
        height: 80,
        child: BottomNavigationBar(
          backgroundColor: MyApp.primaryOrange,
          selectedItemColor: Colors.white, // warna label aktif
          unselectedItemColor: Colors.white,
          
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, color: Colors.white),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.access_time_outlined, color: Colors.white),
            //   activeIcon: Icon(Icons.access_time_filled),
            //   label: 'Tried',
            // ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.chat_bubble_outline, color: Colors.white),
            //   activeIcon: Icon(Icons.chat_bubble),
            //   label: 'Chat',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, color: Colors.white),
              activeIcon: Icon(Icons.person),
              
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,

          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class HomeBodyContent extends StatelessWidget {
  const HomeBodyContent({super.key});

  @override
  Widget build(BuildContext context) {
    // SingleChildScrollView agar halaman bisa di-scroll
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeAppBar(),
            const SizedBox(height: 20),
            const PromoCarousel(),
            const SizedBox(height: 20),
            const SearchBarWidget(),
            const SizedBox(height: 24),
            const CategorySection(),
            const SizedBox(height: 24),
            const RestaurantSection(title: "Open Restaurants"),
            const SizedBox(height: 24),

            const PopularSection(title:"Popular Foods"),
            const SizedBox(height: 20),
             const PopularSection(title:"New Foods"),
          ],
        ),
      ),
    );
  }
}
