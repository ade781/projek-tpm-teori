import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/quote_model.dart';

class QuoteService {
  final String? _url = dotenv.env['QUOTE_API_URL'];

  Future<List<QuoteModel>> fetchQuotes() async {
    if (_url == null || _url.isEmpty) {
      throw Exception(
        "QUOTE_API_URL tidak ditemukan di file .env atau kosong.",
      );
    }

    try {
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode == 200) {
        return quoteModelFromJson(response.body);
      } else {
        throw Exception(
          'Gagal memuat kutipan. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil data: $e');
    }
  }
}
