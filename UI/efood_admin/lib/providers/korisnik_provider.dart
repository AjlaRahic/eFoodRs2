
import 'dart:convert';

import 'package:efood_admin/models/korisnik.dart';
import 'package:efood_admin/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class KorisnikProvider extends BaseProvider<Korisnik> {
  KorisnikProvider(): super("Korisnik");

   @override
  Korisnik fromJson(data) {
    return Korisnik.fromJson(data);
  }
  Future<Korisnik?> login(String username, String password) async {
    try {
      var url = "$totalUrl/login";
      var uri = Uri.parse(url);

      var headers = createHeaders();
      var body = jsonEncode({'username': username, 'password': password});

      var response = await http.post(uri, headers: headers, body: body);

      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);
        Korisnik user = fromJson(data);
        return user;
      } else {
        print("Invalid credentials");
        return null;
      }
    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }

  Future<Korisnik> Authenticate({dynamic filter}) async {
    var url = "$totalUrl/Authenticate";

    var uri = Uri.parse(url);

    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      Korisnik user = fromJson(data) as Korisnik;
      return user;
    } else {
      throw Exception("Pogrešno korisničko ime ili lozinka");
    }
  }
 Future<List<Korisnik>> getDostavljaci() async {
    // koristi direktan endpoint /Korisnik/Dostavljaci
    var url = "$totalUrl/Dostavljaci";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => fromJson(item)).toList();
    } else {
        throw Exception("Neuspješno učitavanje dostavljača");
    }
  
  
}}

