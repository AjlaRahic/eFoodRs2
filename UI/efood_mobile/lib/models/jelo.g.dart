// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jelo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Jelo _$JeloFromJson(Map<String, dynamic> json) => Jelo(
      (json['jeloId'] as num?)?.toInt(),
      json['naziv'] as String?,
      json['slika'] as String?,
      (json['cijena'] as num?)?.toDouble(),
      json['opis'] as String?,
      (json['kategorijaId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$JeloToJson(Jelo instance) => <String, dynamic>{
      'jeloId': instance.jeloId,
      'naziv': instance.naziv,
      'slika': instance.slika,
      'cijena': instance.cijena,
      'opis': instance.opis,
      'kategorijaId': instance.kategorijaId,
    };
