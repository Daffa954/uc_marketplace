part of 'pages.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    // Panggil fungsi cek login setelah widget selesai dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthViewModel>(context, listen: false).checkLoginStatus(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ganti dengan Logo Aplikasi Anda
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              "UC Marketplace",
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.green), // Indikator loading
          ],
        ),
      ),
    );
  }
}