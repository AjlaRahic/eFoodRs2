

import 'dart:convert';
 
import 'package:efood_mobile/models/jelo.dart';
import 'package:json_annotation/json_annotation.dart';
 
part 'korpa.g.dart';
 
@JsonSerializable()
class Korpa{
int? korpaId;
int? jeloId;
int? korisnikId;
double? cijena;
int? kolicina;
int? kategorijaId;
Jelo?jelo;
int?prilogId;
 
 
Korpa(this.korpaId, this.jeloId, this.korisnikId, this.cijena, this.kolicina, this.kategorijaId, this.jelo,this.prilogId);
 
factory Korpa.fromJson(Map<String,dynamic> json)=>_$KorpaFromJson(json);
 
Map<String,dynamic> toJson()=>_$KorpaToJson(this);
}
 