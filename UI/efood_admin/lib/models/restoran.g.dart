// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restoran.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Restoran _$RestoranFromJson(Map<String, dynamic> json) => Restoran(
      (json['restoranId'] as num?)?.toInt(),
      json['nazivRestorana'] as String?,
      json['adresa'] as String?,
      json['email'] as String?,
      json['telefon'] as String?,
      (json['gradId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RestoranToJson(Restoran instance) => <String, dynamic>{
      'restoranId': instance.restoranId,
      'nazivRestorana': instance.nazivRestorana,
      'adresa': instance.adresa,
      'email': instance.email,
      'telefon': instance.telefon,
      'gradId': instance.gradId,
    };
