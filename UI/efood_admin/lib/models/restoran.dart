import 'package:json_annotation/json_annotation.dart';

part 'restoran.g.dart';

@JsonSerializable()
class Restoran {
  int? restoranId;
  String? nazivRestorana;
  String? adresa;
  String? email;
  String? telefon;
  int? gradId;
  Restoran(this.restoranId, this.nazivRestorana, this.adresa, this.email,
      this.telefon, this.gradId);

  factory Restoran.fromJson(Map<String, dynamic> json) =>
      _$RestoranFromJson(json);

  Map<String, dynamic> toJson() => _$RestoranToJson(this);
}
