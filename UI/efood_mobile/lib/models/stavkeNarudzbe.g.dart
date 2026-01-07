// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stavkeNarudzbe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StavkeNarudzbe _$StavkeNarudzbeFromJson(Map<String, dynamic> json) =>
    StavkeNarudzbe(
      (json['id'] as num?)?.toInt(),
      (json['kolicina'] as num?)?.toInt(),
      (json['cijena'] as num?)?.toInt(),
      (json['jeloId'] as num?)?.toInt(),
      (json['narudzbaId'] as num?)?.toInt(),
      (json['ukupno'] as num?)?.toInt(),
      json['nazivJela'] as String?,
    );

Map<String, dynamic> _$StavkeNarudzbeToJson(StavkeNarudzbe instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kolicina': instance.kolicina,
      'cijena': instance.cijena,
      'jeloId': instance.jeloId,
      'narudzbaId': instance.narudzbaId,
      'ukupno': instance.ukupno,
      'nazivJela': instance.nazivJela,
    };
