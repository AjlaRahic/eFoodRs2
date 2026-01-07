import 'package:json_annotation/json_annotation.dart';
 
part 'uplata.g.dart';
 
@JsonSerializable()
class Uplata{
int? Id;
int? Iznos;
String? BrojTransakcije;
String? DatumTransakcije;
int? KorisnikId;
Uplata(this.Id,this.Iznos, this.BrojTransakcije, this.DatumTransakcije, this.KorisnikId);
 
factory Uplata.fromJson(Map<String,dynamic> json)=>_$UplataFromJson(json);
 
Map<String,dynamic> toJson()=>_$UplataToJson(this);
}