import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_role_update.g.dart';

@JsonSerializable(explicitToJson: true)
class UserRoleUpdate{
  int? ulogaId;
 // String? datumIzmjene;

  UserRoleUpdate(this.ulogaId, );
  factory UserRoleUpdate.fromJson(Map<String, dynamic> json) => _$UserRoleUpdateFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$UserRoleUpdateToJson(this);
}