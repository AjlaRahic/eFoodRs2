import 'package:json_annotation/json_annotation.dart';
 
part 'prilozi.g.dart';
 
@JsonSerializable()
class Prilozi{
int? prilogId;
String? nazivPriloga;
Prilozi(this.prilogId,this.nazivPriloga);
 
factory Prilozi.fromJson(Map<String,dynamic> json)=>_$PriloziFromJson(json);
 
Map<String,dynamic> toJson()=>_$PriloziToJson(this);
}