// lib/models/word_model.dart
// Komentar: Mendefinisikan struktur data untuk sebuah kata yang diterima dari API.
// Class ini memiliki factory constructor untuk parsing JSON.

class WordModel {
  final String id;
  final String kata;

  // Konstruktor untuk WordModel.
  WordModel({required this.id, required this.kata});

  // Factory constructor untuk membuat instance WordModel dari Map JSON.
  // Ini berguna saat mengambil data dari API.
  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      // Mengambil nilai 'id' dari JSON.
      id: json['id'] as String,
      // Mengambil nilai 'kata' dari JSON.
      kata: json['kata'] as String,
    );
  }

  // Override toString untuk debugging yang lebih mudah.
  @override
  String toString() {
    return 'WordModel(id: $id, kata: $kata)';
  }
}
