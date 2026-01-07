import 'dart:convert';
import 'package:efood_mobile/models/korisnik.dart';
import 'package:efood_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class KorisnikProvider extends BaseProvider<Korisnik> {
  Korisnik? _currentUser;
  Korisnik? get currentUser => _currentUser;

  KorisnikProvider() : super("Korisnik");

  @override
  Korisnik fromJson(data) => Korisnik.fromJson(data);

  /// Login bez Basic header-a; nakon uspjeha postavi Basic i currentUser.
  Future<Korisnik?> login(String username, String password) async {
    try {
      final uri = Uri.parse('$totalUrl/login');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (isValidResponse(response)) {
        final data = jsonDecode(response.body);
        final user = fromJson(data);

        
        BaseProvider.setBasic(username, password);
        _currentUser = user;
        notifyListeners();

        return user;
      } else {
        return null;
      }
    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }

  
  Future<Korisnik> Authenticate({dynamic filter}) async {
    final uri = Uri.parse('$totalUrl/Authenticate');
    final headers = createHeaders();

    final response = await http.get(uri, headers: headers);
    if (isValidResponse(response)) {
      final data = jsonDecode(response.body);
      final user = fromJson(data) as Korisnik;
      _currentUser = user;
      notifyListeners();
      return user;
    } else {
      throw Exception("Pogrešno korisničko ime ili lozinka");
    }
  }

  /// Praktični helper koji pozove /Authenticate ako user još nije učitan
  Future<void> loadCurrentUser() async {
    try {
      if (_currentUser != null) return;
      await Authenticate();
    } catch (e) {
      print('loadCurrentUser error: $e');
    }
  }

  /// (Opcionalno) Logout – očisti currentUser i credse
  void logout() {
    _currentUser = null;
    // ako imaš centralizirane credse negdje (npr. Authorization.*), očisti i njih
    BaseProvider.setBasic('', '');
    notifyListeners();
  }



  Future<String> registerUser(
      String username, String password, String ime, String prezime) async {
    if (username.isEmpty || password.isEmpty || ime.isEmpty || prezime.isEmpty) {
      throw Exception("All fields must be filled.");
    }

    final uri = Uri.parse('$totalUrl/registration').replace(queryParameters: {
      'username': username,
      'password': password,
      'ime': ime,
      'prezime': prezime,
    });

    // Ako tvoj API zahtijeva admin Basic ovdje – ostavi ga; u suprotnom ukloni.
    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return 'Registration successful: ${responseData['korisnickoIme']}';
    } else {
      throw Exception('Error: ${response.body}');
    }
  }

  Future<void> registerUserWithRole(
    String username,
    String password,
    String ime,
    String prezime,
    String telefon,
    String email,
    int selectedRoleId,
  ) async {
    final response = await http.post(
      Uri.parse('$totalUrl/registration'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'username': username,
        'password': password,
        'ime': ime,
        'prezime': prezime,
        'telefon': telefon,
        'email': email,
        'korisniciUloges': [
          {'ulogaId': selectedRoleId},
        ],
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Greška pri registraciji: ${response.body}');
    }
  }

  Future<Korisnik> register({
    required String username,
    required String password,
    required String ime,
    required String prezime,
  }) async {
    final uri = Uri.parse('$totalUrl/registration').replace(queryParameters: {
      'username': username,
      'password': password,
      'ime': ime,
      'prezime': prezime,
    });

    final res = await http.post(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final user = fromJson(jsonDecode(res.body));
      
      BaseProvider.setBasic(username, password);
      _currentUser = user;
      notifyListeners();
      return user;
    }

    throw Exception('Registracija nije uspjela: ${res.statusCode}\n${res.body}');
  }
}
