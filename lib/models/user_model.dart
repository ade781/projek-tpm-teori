// lib/models/user_model.dart
import 'package:hive/hive.dart';

// Jalankan 'flutter packages pub run build_runner build' setelah membuat file ini
part 'user_model.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String username;

  @HiveField(1)
  late String password; // PERINGATAN: Di aplikasi nyata, HASH password ini!

  User({required this.username, required this.password});
}
