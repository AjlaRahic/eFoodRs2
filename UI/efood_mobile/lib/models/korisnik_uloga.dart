import 'package:efood_mobile/models/uloga.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'korisnik_uloga.g.dart';

@JsonSerializable()
class KorisnikUloga {
  int? korisnikUlogaId;
  int? korisnikId;
  int? ulogaId;
  String? datumIzmjene;
  Uloga? uloga;

  KorisnikUloga(
      {this.korisnikUlogaId,
      this.korisnikId,
      this.ulogaId,
      this.datumIzmjene,
      this.uloga});

  factory KorisnikUloga.fromJson(Map<String, dynamic> json) =>
      _$KorisnikUlogaFromJson(json);

  Map<String, dynamic> toJson() => _$KorisnikUlogaToJson(this);
}