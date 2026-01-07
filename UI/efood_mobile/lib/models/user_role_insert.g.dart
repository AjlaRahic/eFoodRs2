// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role_insert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRoleInsert _$UserRoleInsertFromJson(Map<String, dynamic> json) =>
    UserRoleInsert(
      (json['korisnikId'] as num?)?.toInt(),
      (json['ulogaId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserRoleInsertToJson(UserRoleInsert instance) =>
    <String, dynamic>{
      'korisnikId': instance.korisnikId,
      'ulogaId': instance.ulogaId,
    };
