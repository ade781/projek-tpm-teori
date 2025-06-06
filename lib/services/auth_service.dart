// lib/services/auth_service.dart
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final Box<User> _userBox = Hive.box<User>('users');

  // Fungsi untuk registrasi menggunakan Hive
  Future<bool> registerUser(String username, String password) async {
    // Cek jika username sudah ada
    if (_userBox.containsKey(username)) {
      print("Username sudah ada.");
      return false;
    }

    final user = User(username: username, password: password);
    await _userBox.put(username, user); // Gunakan username sebagai key unik
    print("Registrasi berhasil untuk user: $username");
    return true;
  }

  // Fungsi untuk login
  Future<bool> loginUser(String username, String password) async {
    // Cek jika user ada di Hive
    final user = _userBox.get(username);

    if (user != null && user.password == password) {
      // Jika kredensial benar, simpan status login di SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('loggedInUser', username);
      print("Login berhasil untuk user: $username");
      return true;
    }
    
    print("Login gagal: Username atau password salah.");
    return false;
  }

  // Fungsi untuk logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('loggedInUser');
    print("User telah logout.");
  }

  // Fungsi untuk mengecek status login saat aplikasi dimulai
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Fungsi untuk mendapatkan username yang sedang login
  Future<String?> getLoggedInUser() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('loggedInUser');
  }
}