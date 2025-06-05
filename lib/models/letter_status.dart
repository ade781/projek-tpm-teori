// lib/models/letter_status.dart
// Enum untuk merepresentasikan status dari setiap huruf yang ditebak.

enum LetterStatus {
  // Status awal, belum dievaluasi.
  initial,

  // Huruf tidak ada di dalam kata. (Warna Abu-abu)
  notInWord,

  // Huruf ada di dalam kata, tetapi posisinya salah. (Warna Kuning)
  inWordWrongLocation,

  // Huruf dan posisinya benar. (Warna Hijau)
  inWordCorrectLocation,
}
