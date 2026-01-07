// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'narudzba.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Narudzba _$NarudzbaFromJson(Map<String, dynamic> json) => Narudzba(
      (json['id'] as num?)?.toInt(),
      json['datumNarudzbe'] as String?,
      (json['korisnikId'] as num?)?.toInt(),
      (json['statusNarudzbeId'] as num?)?.toInt(),
      (json['dostavljacId'] as num?)?.toInt(),
      json['stateMachine'] as String?,
      json['paymentId'] as String?,
    );

Map<String, dynamic> _$NarudzbaToJson(Narudzba instance) => <String, dynamic>{
      'id': instance.id,
      'datumNarudzbe': instance.datumNarudzbe,
      'korisnikId': instance.korisnikId,
      'statusNarudzbeId': instance.statusNarudzbeId,
      'dostavljacId': instance.dostavljacId,
      'stateMachine': instance.stateMachine,
      'paymentId': instance.paymentId,
    };
