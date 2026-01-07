import 'dart:convert';
import 'package:efood_mobile/models/narudzba.dart';
import 'package:efood_mobile/models/search_result.dart';
import 'package:efood_mobile/providers/base_provider.dart';
import 'package:efood_mobile/providers/korisnik_provider.dart';
import 'package:http/http.dart' as http;

class NarudzbaProvider extends BaseProvider<Narudzba> {
  NarudzbaProvider() : super("Narudzba");

  KorisnikProvider? _korisnikProvider;
  set korisnikProvider(KorisnikProvider provider) {
    _korisnikProvider = provider;
  }

  @override
  Narudzba fromJson(data) => Narudzba.fromJson(data);

  /// Dohvati narudžbe za logiranog dostavljača
  Future<SearchResult<Narudzba>> getByLoggedDostavljac() async {
    if (_korisnikProvider == null || _korisnikProvider!.currentUser == null) {
      throw Exception("Nema logiranog korisnika");
    }

    final currentUser = _korisnikProvider!.currentUser!;
    final uri = Uri.parse('$totalUrl/dostavljac/${currentUser.id}');
    final headers = createHeaders();
    final response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      final data = jsonDecode(response.body) as List;
      final result = SearchResult<Narudzba>();
      result.count = data.length;
      result.result.addAll(data.map((item) => fromJson(item)));
      return result;
    } else {
      throw Exception("Greška prilikom dohvaćanja narudžbi");
    }
  }

  Future<SearchResult<Narudzba>> getByUser(int userId) async {
    return await get(filter: {"korisnikId": userId});
  }

  Future<SearchResult<Narudzba>> getByFilter(Map<String, dynamic> filter) async {
    return await get(filter: filter);
  }

  Future<void> zavrsiNarudzbu(int narudzbaId) async {
    final uri = Uri.parse('$totalUrl/$narudzbaId/hide');
    final response = await http.put(uri, headers: createHeaders());

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("Narudžba #$narudzbaId završena.");
    } else {
      throw Exception("Greška prilikom završavanja narudžbe: ${response.body}");
    }
  }

  
  Future<Narudzba> FetchById(int id) async {
    final uri = Uri.parse('$totalUrl/$id');
    final response = await http.get(uri, headers: createHeaders());

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return fromJson(data); 
    } else {
      throw Exception("Greška pri dohvaćanju narudžbe #$id: ${response.body}");
    }
  }
}
