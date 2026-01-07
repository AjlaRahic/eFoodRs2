import 'package:json_annotation/json_annotation.dart';

part 'user_insert.g.dart';

@JsonSerializable(explicitToJson: true)
class UserInsert{
  String? userName;
  String? userSurname;
  String? userEmail;
  String? userPhone;
  String? userPassword;
  String? userPasswordRepeat;
  int? userStatus;

  UserInsert(this.userName, this.userSurname, this.userEmail, this.userPhone, this.userPassword, this.userPasswordRepeat, this.userStatus);
  factory UserInsert.fromJson(Map<String, dynamic> json) => _$UserInsertFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$UserInsertToJson(this);
}