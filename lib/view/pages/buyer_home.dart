part of 'pages.dart';
class HomeBuyer extends StatefulWidget {
  const HomeBuyer({super.key});

  @override
  State<HomeBuyer> createState() => _HomeBuyerState();
}

class _HomeBuyerState extends State<HomeBuyer> {
  int _selectedIndex = 0;

  
  // static const List<Widget> _widgetOptions = <Widget>[
  //   HomeBodyContent(),
  //   Center(child: Text('Tried Page')),
  //   Center(child: Text('Chat Page')),
  //   Center(child: Text('Profile Page')),
  // ];

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
        child: HomeBodyContent(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_outlined),
             activeIcon: Icon(Icons.access_time_filled),
            label: 'Tried',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: MyApp.primaryOrange,
        unselectedItemColor: MyApp.textGrey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeBodyContent extends StatelessWidget {
  const HomeBodyContent({super.key});

  @override
  Widget build(BuildContext context) {
    // SingleChildScrollView agar halaman bisa di-scroll
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeAppBar(),
            SizedBox(height: 20),
            PromoCarousel(),
            SizedBox(height: 20),
            SearchBarWidget(),
            SizedBox(height: 24),
            CategorySection(),
            SizedBox(height: 24),
            RestaurantSection(title: "Open Restaurants"),
            SizedBox(height: 24),
            
            RestaurantSection(title: "Popular Items"),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}