import 'package:json_annotation/json_annotation.dart';
import 'package:efood_mobile/models/stavkeNarudzbe.dart';

part 'narudzba.g.dart';

@JsonSerializable()
class Narudzba {
  @JsonKey(name: 'id')
  int? narudzbaId;
  DateTime? datumNarudzbe;
  int? korisnikId;
  String? stateMachine;
  int? StatusNarudzbeId;
  int? dostavljacId;
  List<StavkeNarudzbe>? stavke; // dodano

  Narudzba({
    this.narudzbaId,
    this.datumNarudzbe,
    this.korisnikId,
    this.StatusNarudzbeId,
    this.stateMachine,
    this.stavke,
    this.dostavljacId, // sada optional named
  });

  factory Narudzba.fromJson(Map<String, dynamic> json) => _$NarudzbaFromJson(json);
  Map<String, dynamic> toJson() => _$NarudzbaToJson(this);
}
