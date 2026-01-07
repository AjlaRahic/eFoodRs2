// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uplata_po_korisniku.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UplataPoKorisniku _$UplataPoKorisnikuFromJson(Map<String, dynamic> json) =>
    UplataPoKorisniku(
      iznos: (json['iznos'] as num?)?.toDouble(),
      datumTransakcije: json['datumTransakcije'] == null
          ? null
          : DateTime.parse(json['datumTransakcije'] as String),
      brojTransakcije: json['brojTransakcije'] as String?,
      prezimeKorisnika: json['prezimeKorisnika'] as String?,
      imeKorisnika: json['imeKorisnika'] as String?,
      nacinPlacanja: json['nacinPlacanja'] as String?,
    );

Map<String, dynamic> _$UplataPoKorisnikuToJson(UplataPoKorisniku instance) =>
    <String, dynamic>{
      'iznos': instance.iznos,
      'datumTransakcije': instance.datumTransakcije?.toIso8601String(),
      'brojTransakcije': instance.brojTransakcije,
      'prezimeKorisnika': instance.prezimeKorisnika,
      'imeKorisnika': instance.imeKorisnika,
      'nacinPlacanja': instance.nacinPlacanja,
    };
