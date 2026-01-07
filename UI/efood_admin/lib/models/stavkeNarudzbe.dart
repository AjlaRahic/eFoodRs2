import 'package:json_annotation/json_annotation.dart';

part 'stavkeNarudzbe.g.dart';

@JsonSerializable()
class StavkeNarudzbe{
int? id;
int? kolicina;
int? cijena;
int? jeloId;
int? narudzbaId;
int? ukupno;
StavkeNarudzbe(this.id,this.kolicina,this.cijena,
this.jeloId,this.narudzbaId,this.ukupno);

factory StavkeNarudzbe.fromJson(Map<String,dynamic> json)=>_$StavkeNarudzbeFromJson(json);

Map<String,dynamic> toJson()=>_$StavkeNarudzbeToJson(this);
}