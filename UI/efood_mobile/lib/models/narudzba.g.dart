// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'narudzba.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Narudzba _$NarudzbaFromJson(Map<String, dynamic> json) => Narudzba(
      narudzbaId: (json['id'] as num?)?.toInt(),
      datumNarudzbe: json['datumNarudzbe'] == null
          ? null
          : DateTime.parse(json['datumNarudzbe'] as String),
      korisnikId: (json['korisnikId'] as num?)?.toInt(),
      StatusNarudzbeId: (json['StatusNarudzbeId'] as num?)?.toInt(),
      stateMachine: json['stateMachine'] as String?,
      stavke: (json['stavke'] as List<dynamic>?)
          ?.map((e) => StavkeNarudzbe.fromJson(e as Map<String, dynamic>))
          .toList(),
      dostavljacId: (json['dostavljacId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NarudzbaToJson(Narudzba instance) => <String, dynamic>{
      'id': instance.narudzbaId,
      'datumNarudzbe': instance.datumNarudzbe?.toIso8601String(),
      'korisnikId': instance.korisnikId,
      'stateMachine': instance.stateMachine,
      'StatusNarudzbeId': instance.StatusNarudzbeId,
      'dostavljacId': instance.dostavljacId,
      'stavke': instance.stavke,
    };
