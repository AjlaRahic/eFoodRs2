import 'dart:convert';
import 'package:efood_admin/models/narudzba.dart';
import 'package:efood_admin/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class NarudzbaProvider extends BaseProvider<Narudzba> {
  NarudzbaProvider() : super("Narudzba");

  @override
  Narudzba fromJson(data) {
    return Narudzba.fromJson(data);
  }

  /// Dohvat svih narudžbi
  Future<List<Narudzba>> getAll() async {
    final result = await get();
    return result.result;
  }

  /// ✅ DODJELA DOSTAVLJAČA (PUT!)
  Future<void> dodijeliDostavljaca({
    required int narudzbaId,
    required int dostavljacId,
  }) async {
    final url = Uri.parse("$totalUrl/DodijeliDostavljaca");

    final body = jsonEncode({
      "NarudzbaId": narudzbaId,
      "DostavljacId": dostavljacId,
    });

    final response = await http.put(
      url,
      headers: createHeaders(),
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      print("Greška backend: ${response.statusCode} - ${response.body}");
      throw Exception("Neuspješno dodavanje dostavljača");
    }
  }
}
