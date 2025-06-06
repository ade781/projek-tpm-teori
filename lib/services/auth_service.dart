// lib/services/auth_service.dart
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final Box<User> _userBox = Hive.box<User>('users');

  // Kembalikan registerUser ke versi semula
  Future<bool> registerUser(String username, String password) async {
    if (_userBox.containsKey(username)) {
      print("Username sudah ada.");
      return false;
    }

    // Simpan user tanpa imagePath awal
    final user = User(username: username, password: password, imagePath: null);
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
        await _userBox.put(username, user); // Menyimpan perubahan ke Hive
        print("Gambar profil untuk $username telah diupdate.");
      }
    }
  }

  // Fungsi loginUser tidak berubah
  Future<bool> loginUser(String username, String password) async {
    final user = _userBox.get(username);
    if (user != null && user.password == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('loggedInUser', username);
      return true;
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
