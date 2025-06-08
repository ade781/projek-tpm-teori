import 'dart:convert';

// Fungsi untuk mem-parse List<QuoteModel> dari JSON String
List<QuoteModel> quoteModelFromJson(String str) =>
    List<QuoteModel>.from(json.decode(str).map((x) => QuoteModel.fromJson(x)));

class QuoteModel {
  final String id;
  final String isi;

  QuoteModel({required this.id, required this.isi});

  factory QuoteModel.fromJson(Map<String, dynamic> json) =>
      QuoteModel(id: json["id"], isi: json["isi"]);
}
