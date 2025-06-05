// lib/services/word_service.dart
// Komentar: Bertanggung jawab untuk mengambil data kata dari API.
// Menggunakan package http untuk request HTTP.

import 'dart:convert'; // Untuk jsonDecode
import 'package:http/http.dart' as http;
import '../models/word_model.dart'; // Impor model kata

class WordService {
  // URL dasar dari API.
  static const String _baseUrl =
      'https://6841bca7d48516d1d35cb3d3.mockapi.io/tebakkatatpm/datakata';

  // Fungsi untuk mengambil semua kata dari API.
  // Mengembalikan Future karena ini adalah operasi asynchronous.
  Future<List<WordModel>> fetchWords() async {
    try {
      // Melakukan GET request ke API.
      final response = await http.get(Uri.parse(_baseUrl));

      // Mengecek apakah request berhasil (status code 200).
      if (response.statusCode == 200) {
        // Mendecode response body dari JSON String menjadi List<dynamic>.
        final List<dynamic> data = jsonDecode(response.body);

        // Mengubah setiap item dalam list menjadi objek WordModel.
        return data.map((json) => WordModel.fromJson(json)).toList();
      } else {
        // Jika status code bukan 200, lempar exception.
        throw Exception(
          'Gagal memuat data kata. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Menangkap error lain (misalnya, masalah jaringan).
      // Sebaiknya log error ini atau tampilkan pesan yang lebih user-friendly.
      print('Error di fetchWords: $e');
      throw Exception('Terjadi kesalahan saat mengambil data: $e');
    }
  }
}
