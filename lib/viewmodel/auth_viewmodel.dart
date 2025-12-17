import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/enums.dart';
import 'package:uc_marketplace/model/model.dart';
import 'package:uc_marketplace/repository/auth_repository.dart';

class AuthViewModel with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _authRepo = AuthRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
AuthViewModel() {
    // Panggil fungsi load session
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    try {
      final user = await _authRepo.getCurrentSession();
      if (user != null) {
        _currentUser = user;
        notifyListeners(); // <--- TAMBAHAN WAJIB: Kabari UI bahwa user sudah dimuat ulang
      }
    } catch (e) {
      debugPrint("Gagal load session: $e");
    }
  }
  
  // --- FUNGSI LOGIN ---
  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    setLoading(true);
    try {
      final user = await _authRepo.login(email, password);
      _currentUser = user;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Selamat datang, ${user.name}!"),
            backgroundColor: Colors.green,
          ),
        );

        // NAVIGASI BERDASARKAN ROLE
        if (user.role == UserRole.SELLER) {
          context.go('/seller/home');
        } else {
          context.go('/buyer/home');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      setLoading(false);
    }
  }

  // --- FUNGSI REGISTER ---
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    required BuildContext context,
  }) async {
    setLoading(true);
    try {
      await _authRepo.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
      );

      // SUKSES REGISTER -> TAMPILKAN DIALOG CEK EMAIL
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("Registrasi Berhasil"),
            content: Text(
              "Link verifikasi telah dikirim ke $email.\n\n"
              "Mohon cek email Anda dan klik link tersebut untuk mengaktifkan akun sebelum Login.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Tutup Dialog
                  context.pop(); // Kembali ke Halaman Login
                },
                child: const Text("OK, SIAP"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      setLoading(false);
    }
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    // Beri delay sedikit agar Splash Screen terlihat (estetika)
    await Future.delayed(const Duration(seconds: 2));

    try {
      final user = await _authRepo.getCurrentSession();

      if (user != null) {
        // --- SESI DITEMUKAN ---
        _currentUser = user; // Simpan ke state
        notifyListeners();

        if (context.mounted) {
          // Redirect sesuai Role
          if (user.role == UserRole.SELLER) {
            context.go('/seller/home');
          } else {
            context.go('/buyer/home');
          }
        }
      } else {
        // --- TIDAK ADA SESI ---
        if (context.mounted) {
          context.go('/login');
        }
      }
    } catch (e) {
      // Jika error, lempar ke login
      if (context.mounted) context.go('/login');
    }
  }

 Future<void> logout(BuildContext context) async {
    setLoading(true);
    try {
      await _authRepo.logout(); // Hapus sesi Supabase
      _currentUser = null;      // Hapus data di RAM
      notifyListeners();        // Kabari UI
      
      if (context.mounted) {
        context.go('/login');   // Pindah ke halaman login
      }
    } catch (e) {
      debugPrint("Logout error: $e");
    } finally {
      setLoading(false);
    }
  }
}
