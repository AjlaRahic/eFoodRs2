import 'package:json_annotation/json_annotation.dart';
 
part 'statusNarudzbe.g.dart';
 
@JsonSerializable()
class StatusNarudzbe{
int? id;
String? naziv;
 
StatusNarudzbe(this.id,this.naziv);
 
factory StatusNarudzbe.fromJson(Map<String,dynamic> json)=>_$StatusNarudzbeFromJson(json);
 
Map<String,dynamic> toJson()=>_$StatusNarudzbeToJson(this);
}