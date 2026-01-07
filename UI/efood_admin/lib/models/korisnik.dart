import 'package:efood_admin/models/korisnik_uloga.dart';
import 'package:json_annotation/json_annotation.dart';

part 'korisnik.g.dart';

@JsonSerializable(explicitToJson: true)
class Korisnik {
  int? id;
  String? ime;
  String? prezime;
  String? korisnickoIme;
  String? telefon;
  String? email;

  @JsonKey(defaultValue: [])
  List<KorisnikUloga> korisniciUloges;

  Korisnik({
    this.id,
    this.ime,
    this.prezime,
    this.korisnickoIme,
    this.email,
    this.telefon,
    this.korisniciUloges = const [],
  });

  factory Korisnik.fromJson(Map<String, dynamic> json) =>
      _$KorisnikFromJson(json);

  Map<String, dynamic> toJson() => _$KorisnikToJson(this);
}
