import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uc_marketplace/model/enums.dart';
import 'package:uc_marketplace/model/model.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- LOGIN ---
  Future<UserModel> login(String email, String password) async {
    try {
      // 1. Login ke Supabase Auth
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception("Login gagal, user tidak ditemukan.");
      }

      // 2. Ambil Data Profil dari tabel 'users' untuk cek Role & Nama
      // Asumsi: user_id di tabel users adalah UUID yang sama dengan Auth UID
      // Jika di tabel users user_id adalah INT (Auto Inc), Anda perlu kolom tambahan 'auth_id' (UUID)
      // TAPI, berdasarkan skrip SQL sebelumnya, user_id adalah BIGINT. 
      // Supaya aman, kita cari berdasarkan EMAIL karena email unik.
      final userData = await _supabase
          .from('users')
          .select()
          .eq('email', email) 
          .single();

      // 3. Kembalikan sebagai UserModel
      return UserModel.fromJson(userData);
      
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains("email not confirmed")) {
        throw Exception("Email belum diverifikasi. Cek inbox Anda.");
      } else if (e.message.toLowerCase().contains("invalid login")) {
        throw Exception("Email atau password salah.");
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Terjadi kesalahan saat login: $e");
    }
  }

  // --- REGISTER ---
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    try {
      // 1. Buat User di Supabase Auth (Trigger kirim email verifikasi)
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception("Registrasi gagal.");
      }

      // 2. Simpan Data Profil ke tabel 'users' (Public Table)
      // Ingat: Jangan simpan password di sini!
      final newUser = UserModel(
        userId: null, // Biarkan null, DB akan auto-increment
        name: name,
        email: email,
        phone: phone,
        role: role,
        isVerified: false, // Default false sampai email diklik (logic backend)
        token: null,
      );

      await _supabase.from('users').insert(newUser.toJson());

    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Gagal mendaftar: $e");
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}