import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService {
  final Box<User> _userBox = Hive.box<User>('users');

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> registerUser(String username, String password) async {
    if (_userBox.containsKey(username)) {
      print("Username sudah ada.");
      return false;
    }

    final hashedPassword = _hashPassword(password);

    print('Password yang di-hash untuk $username: $hashedPassword');
    final user = User(
      username: username,
      password: hashedPassword,
      imagePath: null,
    );
    await _userBox.put(username, user);
    print("Registrasi berhasil untuk user: $username");
    return true;
  }

  Future<void> updateUserImagePath(String imagePath) async {
    final username = await getLoggedInUser();
    if (username != null) {
      final user = _userBox.get(username);
      if (user != null) {
        user.imagePath = imagePath;
        await user.save();
        print("Gambar profil untuk $username telah diupdate.");
      }
    }
  }

  Future<bool> loginUser(String username, String password) async {
    final user = _userBox.get(username);
    if (user != null) {
      final hashedPasswordAttempt = _hashPassword(password);
      print('Password yang dimasukkan (hash): $hashedPasswordAttempt');
      print('Password yang tersimpan (hash): ${user.password}');

      if (user.password == hashedPasswordAttempt) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('loggedInUser', username);
        return true;
      }
    }
    return false;
  }

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
