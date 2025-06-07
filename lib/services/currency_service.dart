// lib/services/currency_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CurrencyService {
  final String? _apiKey = dotenv.env['EXCHANGE_RATE_API_KEY'];

  /// Mengambil data kurs terbaru beserta metadatanya.
  /// Sekarang mengembalikan seluruh Map dari response API yang berhasil.
  Future<Map<String, dynamic>> getLatestRates(String baseCurrency) async {
    if (_apiKey == null) {
      throw Exception("API Key tidak ditemukan di .env");
    }

    final url = Uri.parse(
      'https://v6.exchangerate-api.com/v6/$_apiKey/latest/$baseCurrency',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] == 'success') {
          // Mengembalikan seluruh data JSON, bukan hanya 'conversion_rates'
          return data;
        } else {
          throw Exception(
            'Gagal mendapatkan data dari API: ${data['error-type']}',
          );
        }
      } else {
        throw Exception(
          'Gagal terhubung ke server. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan atau koneksi: $e');
    }
  }
}
