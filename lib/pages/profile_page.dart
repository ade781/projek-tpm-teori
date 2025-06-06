// lib/pages/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projek_akhir_teori/models/user_model.dart';
import 'package:projek_akhir_teori/pages/login_page.dart';
import 'package:projek_akhir_teori/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    final user = await _authService.getLoggedInUserObject();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndSaveImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    // Panggil service untuk update path di database
    await _authService.updateUserImagePath(pickedFile.path);

    // Muat ulang data pengguna untuk refresh UI
    await _loadUserData();
  }

  void _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentUser == null
              ? const Center(child: Text('Gagal memuat data pengguna.'))
              : _buildProfileView(),
    );
  }

  Widget _buildProfileView() {
    final user = _currentUser!;
    final hasImage = user.imagePath != null && user.imagePath!.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    hasImage ? FileImage(File(user.imagePath!)) : null,
                child:
                    !hasImage
                        ? const Icon(Icons.person, size: 80, color: Colors.grey)
                        : null,
              ),
              // Tombol untuk mengubah gambar
              Material(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  onTap: _pickAndSaveImage,
                  borderRadius: BorderRadius.circular(30),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.edit, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            user.username,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
