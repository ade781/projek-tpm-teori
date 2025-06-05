// lib/models/word_model.dart

class WordModel {
  final String id;
  final String kata;
  final String arti;

  WordModel({required this.id, required this.kata, required this.arti});

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'] as String,
      kata: json['kata'] as String,
      arti: json['arti'] as String,
    );
  }

  @override
  String toString() {
    return 'WordModel(id: $id, kata: $kata, arti: $arti)';
  }
}
