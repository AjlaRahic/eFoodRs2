import 'dart:convert';
import 'package:efood_mobile/models/jelo.dart';
import 'package:efood_mobile/models/preporucenojelo.dart';
import 'package:efood_mobile/models/search_result.dart';
import 'package:efood_mobile/models/stavkeNarudzbe.dart';
import 'package:efood_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;

  final String _endpoint;
  String? totalUrl;

  BaseProvider(String endpoint) : _endpoint = endpoint {
   _baseUrl = const String.fromEnvironment("baseUrl", defaultValue: "http://10.0.2.2:7072/");
    totalUrl= "$_baseUrl$endpoint";}
  //http://10.0.2.2:7072/
  //http://localhost:5041/
  String get baseUrl => _baseUrl!;

  static String? _basicUser;
  static String? _basicPass;
  static void setBasic(String username, String password) {
    _basicUser = username;
    _basicPass = password;
  }

  static bool get hasAuth => (_basicUser?.isNotEmpty ?? false);

  //http://10.0.2.2:7002/
  //http://localhost:7002/

  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = "$_baseUrl$_endpoint";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      var result = SearchResult<T>();

      result.count = data['count'];

      for (var item in data['result']) {
        result.result.add(fromJson(item));
      }

      return result;
    } else {
      throw Exception("Unknown error");
    }
  }

Future<Jelo> getById(int id) async {
  var url = "$_baseUrl$_endpoint/$id";
  var uri = Uri.parse(url);
  var headers = createHeaders();

  Response response = await http.get(uri, headers: headers);
  if (isValidResponse(response)) {
    var data = jsonDecode(response.body) as Map<String, dynamic>;
    return Jelo.fromJson(data);
  } else {
    throw Exception("Unknown error");
  }
}

  T? firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
    for (final i in items) {
      if (test(i)) return i;
    }
    return null;
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  Future<T> insert(dynamic request) async {
    var url = "$_baseUrl$_endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      print("response: ${response.request}");
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T> update(int id, [dynamic request]) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      print("response: ${response.request}");
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<T> delete(int? id) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.delete(uri, headers: headers);

    if (isValidResponse(response)) {
      print("response: ${response.request}");
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to delete product with ID $id");
    }
  }

  bool isValidResponse(Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception(
          "Unauthorized access. Status code: ${response.statusCode}");
    } else if (response.statusCode == 400) {
      throw Exception(
          "Bad request. Status code: ${response.statusCode}, Body: ${response.body}");
    } else {
      print("Error response body: ${response.body}");
      throw Exception(
          "Something bad happened. Status code: ${response.statusCode}, Body: ${response.body}");
    }
  }

  Map<String, String> createHeaders() {
    String username = Authorization.username ?? "";
    String password = Authorization.password ?? "";

    print("passed creds: $username, $password");
   

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";
     print("FINAL AUTH HEADER: $basicAuth");
    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth
    };

    return headers;
  }

  String getQueryString(Map params,
      {String prefix = '&', bool inRecursion = false}) {
    String query = '';
    params.forEach((key, value) {
      if (inRecursion) {
        if (key is int) {
          key = '[$key]';
        } else if (value is List || value is Map) {
          key = '.$key';
        } else {
          key = '.$key';
        }
      }
      if (value is String || value is int || value is double || value is bool) {
        var encoded = value;
        if (value is String) {
          encoded = Uri.encodeComponent(value);
        }
        query += '$prefix$key=$encoded';
      } else if (value is DateTime) {
        query += '$prefix$key=${(value).toIso8601String()}';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query +=
              getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
        });
      }
    });
    return query;
  }

  Future<List<Jelo>> fetchRecommendedJelo() async {
    try {
      final response = await http.get(Uri.parse('$totalUrl/preporuceno'),
          headers: createHeaders());
      if (isValidResponse(response)) {
        return (jsonDecode(response.body) as List)
            .map((item) => Jelo.fromJson(item))
            .toList();
      } else {
        throw Exception('Invalid response: ${response.body}');
      }
    } catch (e) {
      print('Error fetching recommended doctors: $e');
      rethrow;
    }
  }

  Future<int> checkoutFromCart(
  int userId,
  String? paymentId, {
  int? statusId,
  DateTime? datumNarudzbe,
}) async {
  final uri = Uri.parse('${_baseUrl}Narudzba/checkoutFromCart');
  final headers = createHeaders();

  final bodyMap = <String, dynamic>{
    "korisnikId": userId,
    "paymentId": paymentId,
    if (statusId != null) "statusId": statusId,
    if (datumNarudzbe != null)
      "datumNarudzbe": datumNarudzbe.toIso8601String(),
  };

  final resp = await http.post(
    uri,
    headers: headers,
    body: jsonEncode(bodyMap),
  );

  debugPrint('checkoutFromCart ${resp.statusCode}: ${resp.body}');

  if (resp.statusCode >= 200 && resp.statusCode < 300) {
    final data = jsonDecode(resp.body);
    return data is int ? data : int.parse(data.toString());
  } else {
    throw Exception('Checkout failed: ${resp.statusCode} ${resp.body}');
  }
}


Future<SearchResult<T>> getByFilter(Map<String, dynamic> filter) async {
  return await get(filter: filter);
}

Future<List<PreporucenoJeloDto>> fetchRecommendedJeloDetaljno() async {
    final resp = await http.get(Uri.parse('$_baseUrl/jelo/preporuke/me'), headers: {
      'Authorization': 'Bearer YOUR_TOKEN',
      'Content-Type': 'application/json',
    });

    if (resp.statusCode != 200) {
      throw Exception('Greška: ${resp.statusCode} ${resp.body}');
    }
    final list = (jsonDecode(resp.body) as List)
        .map((e) => PreporucenoJeloDto.fromJson(e))
        .toList();
    return list;
    }
}
