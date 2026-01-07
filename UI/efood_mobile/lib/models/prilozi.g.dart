// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prilozi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Prilozi _$PriloziFromJson(Map<String, dynamic> json) => Prilozi(
      (json['prilogId'] as num?)?.toInt(),
      json['nazivPriloga'] as String?,
    );

Map<String, dynamic> _$PriloziToJson(Prilozi instance) => <String, dynamic>{
      'prilogId': instance.prilogId,
      'nazivPriloga': instance.nazivPriloga,
    };
