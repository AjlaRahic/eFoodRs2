import 'package:json_annotation/json_annotation.dart';
 
part 'dojmovi.g.dart';
 
@JsonSerializable()
class Dojmovi{
int? id;
int? ocjena;
String? opis;
int? jeloId;
int? korisnikId;
Dojmovi(this.id,this.ocjena, this.opis, this.jeloId,this.korisnikId);
 
factory Dojmovi.fromJson(Map<String,dynamic> json)=>_$DojmoviFromJson(json);
 
Map<String,dynamic> toJson()=>_$DojmoviToJson(this);
}