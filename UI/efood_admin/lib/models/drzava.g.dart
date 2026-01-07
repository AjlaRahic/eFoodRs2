// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drzava.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Drzava _$DrzavaFromJson(Map<String, dynamic> json) => Drzava(
      (json['Id'] as num?)?.toInt(),
      json['Naziv'] as String?,
    );

Map<String, dynamic> _$DrzavaToJson(Drzava instance) => <String, dynamic>{
      'Id': instance.Id,
      'Naziv': instance.Naziv,
    };
