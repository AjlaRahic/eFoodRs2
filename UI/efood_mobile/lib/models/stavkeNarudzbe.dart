import 'package:json_annotation/json_annotation.dart';

part 'stavkeNarudzbe.g.dart';

@JsonSerializable()
class StavkeNarudzbe {
  int? id;
  int? kolicina;
  int? cijena;
  int? jeloId;
  int? narudzbaId;
  int? ukupno;
  String? nazivJela;
  StavkeNarudzbe(this.id, this.kolicina, this.cijena, this.jeloId,
      this.narudzbaId, this.ukupno, this.nazivJela);

  factory StavkeNarudzbe.fromJson(Map<String, dynamic> json) =>
      _$StavkeNarudzbeFromJson(json);

  Map<String, dynamic> toJson() => _$StavkeNarudzbeToJson(this);
}
