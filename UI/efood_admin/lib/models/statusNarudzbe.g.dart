// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statusNarudzbe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatusNarudzbe _$StatusNarudzbeFromJson(Map<String, dynamic> json) =>
    StatusNarudzbe(
      (json['id'] as num?)?.toInt(),
      json['naziv'] as String?,
    );

Map<String, dynamic> _$StatusNarudzbeToJson(StatusNarudzbe instance) =>
    <String, dynamic>{
      'id': instance.id,
      'naziv': instance.naziv,
    };
