import 'package:json_annotation/json_annotation.dart';

part 'user_role_insert.g.dart';

@JsonSerializable(explicitToJson: true)
class UserRoleInsert{
  int? korisnikId;
  int? ulogaId;
  //String? datumIzmjene;

  UserRoleInsert(this.korisnikId, this.ulogaId);
  factory UserRoleInsert.fromJson(Map<String, dynamic> json) => _$UserRoleInsertFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$UserRoleInsertToJson(this);
}