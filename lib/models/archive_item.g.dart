// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archive_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArchiveItemAdapter extends TypeAdapter<ArchiveItem> {
  @override
  final int typeId = 0;

  @override
  ArchiveItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArchiveItem(
      id: fields[0] as String,
      imagePath: fields[1] as String,
      restaurantName: fields[2] as String,
      menuName: fields[3] as String,
      category: fields[4] as String,
      location: fields[5] as String,
      date: fields[6] as DateTime?,
      searchKeyword: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ArchiveItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.restaurantName)
      ..writeByte(3)
      ..write(obj.menuName)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.searchKeyword);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArchiveItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
