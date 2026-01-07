import 'package:json_annotation/json_annotation.dart';

part 'promet_po_korisniku.g.dart';

@JsonSerializable()
class PrometPoKorisniku {
  String? imeKorisnika;
  String? datumNarudzbe;
  String? nazivKategorije;

  PrometPoKorisniku({
    this.imeKorisnika,
    this.datumNarudzbe,
    this.nazivKategorije,
  });

  factory PrometPoKorisniku.fromJson(Map<String, dynamic> json) =>
      _$PrometPoKorisnikuFromJson(json);

  Map<String, dynamic> toJson() => _$PrometPoKorisnikuToJson(this);
}

