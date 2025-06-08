import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/word_model.dart';

class WordService {
  final String? _baseUrl = dotenv.env['WORD_API_URL'];

  Future<List<WordModel>> fetchWords() async {
    if (_baseUrl == null || _baseUrl.isEmpty) {
      throw Exception("WORD_API_URL tidak ditemukan di .env atau kosong.");
    }

    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((json) => WordModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Gagal memuat data kata. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error di fetchWords: $e');
      throw Exception('Terjadi kesalahan saat mengambil data: $e');
    }
  }
}
