import 'package:json_annotation/json_annotation.dart';
part 'uplata_po_korisniku.g.dart';

@JsonSerializable()
class UplataPoKorisniku {
  double? iznos;
  DateTime? datumTransakcije;
  String? brojTransakcije;
  String? prezimeKorisnika;
  String? imeKorisnika;
  String? nacinPlacanja;

  // Konstruktor sa named parameters
  UplataPoKorisniku({
    this.iznos,
    this.datumTransakcije,
    this.brojTransakcije,
    this.prezimeKorisnika,
    this.imeKorisnika,
    this.nacinPlacanja,
  });

  factory UplataPoKorisniku.fromJson(Map<String, dynamic> json) =>
      _$UplataPoKorisnikuFromJson(json);

  Map<String, dynamic> toJson() => _$UplataPoKorisnikuToJson(this);
}
