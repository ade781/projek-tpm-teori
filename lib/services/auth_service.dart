// lib/services/auth_service.dart
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:convert'; // Import untuk utf8
import 'package:crypto/crypto.dart'; // Import untuk SHA256

class AuthService {
  final Box<User> _userBox = Hive.box<User>('users');

  // Fungsi untuk menghash password menggunakan SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password); // Konversi string ke bytes
    final digest = sha256.convert(bytes); // Hasilkan hash SHA256
    return digest.toString(); // Kembalikan hash sebagai string
  }

  Future<bool> registerUser(String username, String password) async {
    if (_userBox.containsKey(username)) {
      print("Username sudah ada.");
      return false;
    }

    final hashedPassword = _hashPassword(
      password,
    ); // Hash password saat registrasi
    // --- DEBUGGING: Cetak hash password ke konsol ---
    print(
      'Password yang di-hash untuk $username: $hashedPassword',
    ); // Tambahkan ini
    // -------------------------------------------------
    final user = User(
      username: username,
      password: hashedPassword,
      imagePath: null,
    );
    await _userBox.put(username, user);
    print("Registrasi berhasil untuk user: $username");
    return true;
  }

  // FUNGSI BARU: untuk mengupdate path gambar pengguna
  Future<void> updateUserImagePath(String imagePath) async {
    final username = await getLoggedInUser();
    if (username != null) {
      final user = _userBox.get(username);
      if (user != null) {
        user.imagePath = imagePath;
        await user
            .save(); // Gunakan user.save() untuk menyimpan perubahan pada HiveObject
        print("Gambar profil untuk $username telah diupdate.");
      }
    }
  }

  // Fungsi loginUser tidak berubah
  Future<bool> loginUser(String username, String password) async {
    final user = _userBox.get(username);
    if (user != null) {
      final hashedPasswordAttempt = _hashPassword(
        password,
      ); // Hash password yang dimasukkan
      // --- DEBUGGING: Cetak password yang dimasukkan (setelah di-hash) dan yang tersimpan ---
      print(
        'Password yang dimasukkan (hash): $hashedPasswordAttempt',
      ); // Tambahkan ini
      print(
        'Password yang tersimpan (hash): ${user.password}',
      ); // Tambahkan ini
      // -------------------------------------------------------------------------------------
      if (user.password == hashedPasswordAttempt) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('loggedInUser', username);
        return true;
      }
    }
    return false;
  }

  // Fungsi lain tidak ada perubahan
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('loggedInUser');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<String?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('loggedInUser');
  }

  Future<User?> getLoggedInUserObject() async {
    final username = await getLoggedInUser();
    if (username != null) {
      return _userBox.get(username);
    }
    return null;
  }
}
