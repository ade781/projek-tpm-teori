// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameHistoryAdapter extends TypeAdapter<GameHistory> {
  @override
  final int typeId = 1;

  @override
  GameHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameHistory(
      username: fields[0] as String,
      correctWord: fields[1] as String,
      guesses: (fields[2] as List).cast<String>(),
      isWin: fields[3] as bool,
      timestamp: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GameHistory obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.correctWord)
      ..writeByte(2)
      ..write(obj.guesses)
      ..writeByte(3)
      ..write(obj.isWin)
      ..writeByte(4)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
