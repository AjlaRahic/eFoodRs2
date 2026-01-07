// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dojmovi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dojmovi _$DojmoviFromJson(Map<String, dynamic> json) => Dojmovi(
      (json['id'] as num?)?.toInt(),
      (json['ocjena'] as num?)?.toInt(),
      json['opis'] as String?,
      (json['jeloId'] as num?)?.toInt(),
      (json['korisnikId'] as num?)?.toInt(),
    )..datumRecenzije = json['datumRecenzije'] == null
        ? null
        : DateTime.parse(json['datumRecenzije'] as String);

Map<String, dynamic> _$DojmoviToJson(Dojmovi instance) => <String, dynamic>{
      'id': instance.id,
      'ocjena': instance.ocjena,
      'opis': instance.opis,
      'datumRecenzije': instance.datumRecenzije?.toIso8601String(),
      'jeloId': instance.jeloId,
      'korisnikId': instance.korisnikId,
    };
