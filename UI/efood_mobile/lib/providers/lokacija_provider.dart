import 'dart:convert';
import 'package:efood_mobile/models/lokacija.dart';
import 'package:efood_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class LokacijaProvider extends BaseProvider<Lokacija> {
  LokacijaProvider() : super("Lokacija");

  @override
  Lokacija fromJson(data) => Lokacija.fromJson(data);

 
  Future<void> insertLokacija(Lokacija lokacija) async {
    final uri = Uri.parse('${baseUrl}Lokacija/insert');
    final body = jsonEncode({
      "dostavljacId": lokacija.korisnikId,
      "latitude": lokacija.latitude,
      "longitude": lokacija.longitude,
      "datum": lokacija.datum?.toUtc().toIso8601String(),
    });

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json-patch+json",
        "Authorization": createHeaders()["Authorization"]!,
      },
      body: body,
    );

  
  }

 
  Future<Lokacija?> getZadnjaLokacija(int korisnikId) async {
    
      final uri = Uri.parse('${baseUrl}Lokacija/zadnja/$korisnikId');
      final response = await http.get(uri, headers: createHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Lokacija.fromJson(data);}
     else{
      return null;}
    }
  

 
  Future<Lokacija?> getLokacijaKorisnika(int narudzbaId) async {
    
      final uri = Uri.parse('${baseUrl}Lokacija/narudzba/$narudzbaId/lokacijaKorisnika');
      final response = await http.get(uri, headers: createHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        return Lokacija.fromPartialJson(data);
      } 
       else {
        
        return null;
      }
    } 
  

  
  Future<List<Lokacija>> getLokacijeZaNarudzbu(int narudzbaId) async {
   
      final uri = Uri.parse('${baseUrl}Lokacija/narudzba/$narudzbaId');
      final response = await http.get(uri, headers: createHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Lokacija.fromJson(e)).toList();
      } else {
        
        return [];
      }
    
    }
  }

