import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projek_akhir_teori/models/game_history.dart';
import 'package:projek_akhir_teori/models/user_model.dart';
import 'package:projek_akhir_teori/pages/login_page.dart';
import 'package:projek_akhir_teori/services/auth_service.dart';
import 'package:projek_akhir_teori/services/stats_service.dart';
import '../widgets/profile/credential_card.dart';
import '../widgets/profile/game_history_section.dart';
import '../widgets/profile/info_card.dart';
import '../widgets/profile/profile_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final StatsService _statsService = StatsService();
  User? _currentUser;
  bool _isLoading = true;
  late Future<List<GameHistory>> _gameHistoryFuture;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final user = await _authService.getLoggedInUserObject();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
        if (user != null) {
          _gameHistoryFuture = _statsService.getGameHistoryForUser(
            user.username,
          );
        }
      });
    }
  }

  Future<void> _pickAndSaveImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile == null) return;

    await _authService.updateUserImagePath(pickedFile.path);
    await _loadInitialData();
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
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _currentUser == null
                ? const Center(child: Text('Gagal memuat data pengguna.'))
                : _buildProfileView(context),
      ),
    );
  }

  Widget _buildProfileView(BuildContext context) {
    return CustomScrollView(
      slivers: [
        ProfileHeader(user: _currentUser!, onEditImage: _pickAndSaveImage),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                CredentialCard(user: _currentUser!),
                const SizedBox(height: 32),
                _buildSectionTitle(context, 'Tentang Aplikasi Lurufa'),
                const InfoCard(
                  icon: Icons.info_outline,
                  title: 'Filosofi Lurufa',
                  content:
                      'Lurufa adalah teman digital yang membumi, tenang, dan mencerahkan. "Luru" dari bahasa Malagasi berarti halus, samar, ringan. "Fa" (فَ) dari bahasa Arab adalah partikel penghubung. Dengan filosofi ini, Lurufa hadir sebagai aplikasi serbaguna yang tidak hanya menyediakan hiburan, tetapi juga alat praktis untuk menuntun dan mencerahkan setiap langkah Anda.',
                ),
                const SizedBox(height: 32),
                _buildSectionTitle(context, 'Kesan Mata Kuliah TPM'),
                const InfoCard(
                  icon: Icons.school_outlined,
                  title: 'Saran dan Kesan',
                  content:
                      'Mata kuliah TPM menjadi salah satu pengalaman belajar yang paling berkesan. Di sini, saya bisa mengimplementasikan ilmu dari matkul lain, memacu diri untuk break the limit, dan mengasah skill secara langsung. Menyenangkan sekaligus menantang.',
                ),
                const SizedBox(height: 32),
                _buildSectionTitle(context, 'Riwayat Permainan'),
                GameHistorySection(gameHistoryFuture: _gameHistoryFuture),
                const SizedBox(height: 40),
                _buildLogoutButton(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
