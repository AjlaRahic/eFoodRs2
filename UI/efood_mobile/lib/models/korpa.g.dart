// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'korpa.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Korpa _$KorpaFromJson(Map<String, dynamic> json) => Korpa(
      (json['korpaId'] as num?)?.toInt(),
      (json['jeloId'] as num?)?.toInt(),
      (json['korisnikId'] as num?)?.toInt(),
      (json['cijena'] as num?)?.toDouble(),
      (json['kolicina'] as num?)?.toInt(),
      (json['kategorijaId'] as num?)?.toInt(),
      json['jelo'] == null
          ? null
          : Jelo.fromJson(json['jelo'] as Map<String, dynamic>),
      (json['prilogId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$KorpaToJson(Korpa instance) => <String, dynamic>{
      'korpaId': instance.korpaId,
      'jeloId': instance.jeloId,
      'korisnikId': instance.korisnikId,
      'cijena': instance.cijena,
      'kolicina': instance.kolicina,
      'kategorijaId': instance.kategorijaId,
      'jelo': instance.jelo,
      'prilogId': instance.prilogId,
    };
