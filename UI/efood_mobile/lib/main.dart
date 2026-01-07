import 'package:efood_mobile/models/korisnik_uloga.dart';
import 'package:efood_mobile/providers/base_provider.dart';
import 'package:efood_mobile/providers/cart_provider.dart';
import 'package:efood_mobile/providers/dojmovi_provider.dart';
import 'package:efood_mobile/providers/jelo_provider.dart';
import 'package:efood_mobile/providers/kategorija_provider.dart';
import 'package:efood_mobile/providers/korisnik_provider.dart';
import 'package:efood_mobile/providers/korisnik_uloga_provider.dart';
import 'package:efood_mobile/providers/lokacija_provider.dart';
import 'package:efood_mobile/providers/meni_provider.dart';
import 'package:efood_mobile/providers/narudzba_provider.dart';
import 'package:efood_mobile/providers/payment_provider.dart';
import 'package:efood_mobile/providers/prilozi_provider.dart';

import 'package:efood_mobile/providers/status_provider.dart';
import 'package:efood_mobile/providers/uloga_provider.dart';
import 'package:efood_mobile/providers/stavkeNarudzbe_provider.dart';
import 'package:efood_mobile/screens/dostavljac_screen.dart';
import 'package:efood_mobile/screens/home_screen.dart';
import 'package:efood_mobile/screens/registration.dart';
import 'package:efood_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      
      ChangeNotifierProvider(create: (_) => KorisnikProvider()),
      ChangeNotifierProvider(create: (_) => UlogaProvider()),
      ChangeNotifierProvider(create: (_) => MeniProvider()),
      ChangeNotifierProvider(create: (_) => KategorijaProvider()),
      
      ChangeNotifierProvider(create: (_) => DojmoviProvider()),
      ChangeNotifierProvider(create: (_) => KorisnikUlogaProvider()),
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => ProductProvider()),
      ChangeNotifierProvider(create: (_) => LokacijaProvider()),
      ChangeNotifierProxyProvider<KorisnikProvider, NarudzbaProvider>(
        create: (_) => NarudzbaProvider(),
        update: (_, korisnikProvider, narudzbaProvider) {
          narudzbaProvider!.korisnikProvider = korisnikProvider;
          return narudzbaProvider;
        },
      ),

      ChangeNotifierProvider(create: (_) => StatusProvider()),
      ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ChangeNotifierProvider(create: (_) => PriloziProvider()),
      ChangeNotifierProvider(create: (_) => StavkeNarudzbeProvider()),

    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eFood Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFCBA4), brightness: Brightness.light),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late KorisnikProvider _korisnikProvider;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    var username = _usernameController.text.trim();
    var password = _passwordController.text.trim();

    Authorization.username = username;
    Authorization.password = password;

    try {
      // Authenticate korisnik
      Authorization.korisnik = await _korisnikProvider.Authenticate();

      if (Authorization.korisnik == null) {
        _showMessage("Pogrešno korisničko ime ili lozinka!");
        return;
      }

      Authorization.userId = Authorization.korisnik!.id;

      // Provjera uloga: uzmi prvu relevantnu (Korisnik ili Dostavljac)
      var uloge = Authorization.korisnik!.korisniciUloges ?? [];
      KorisnikUloga? odabranaUloga;

      for (var u in uloge) {
        if (u.uloga?.naziv == "Korisnik" || u.uloga?.naziv == "Dostavljac") {
          odabranaUloga = u;
          break;
        }
      }

      if (odabranaUloga == null) {
        _showMessage(
            "Vaš korisnički račun nema permisije za pristup korisničkom panelu!");
        return;
      }

      Authorization.uloga = odabranaUloga.uloga;

      // Navigacija po ulozi
      if (Authorization.uloga?.naziv == "Korisnik") {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()));
      } else if (Authorization.uloga?.naziv == "Dostavljac") {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => DostavljacScreen()));
      } else {
        _showMessage(
            "Vaš korisnički račun nema permisije za pristup korisničkom panelu!");
      }
    } catch (e) {
      _showMessage("Pogrešno korisničko ime ili lozinka!");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(), child: const Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _korisnikProvider = context.read<KorisnikProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Prijava korisnika"),
        backgroundColor: const Color(0xFF8D6E63),
      ),
      body: Stack(children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.85,
            child: Image.asset(
              "assets/images/ehomee.jpg",
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFCBA4).withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Okrugla slika
                  CircleAvatar(
                    radius: 90,
                    backgroundImage: AssetImage("assets/images/pizza.jpg"),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                      controller: _usernameController,
                      label: "Korisničko ime",
                      icon: Icons.account_circle),
                  const SizedBox(height: 10),
                  _buildTextField(
                      controller: _passwordController,
                      label: "Lozinka",
                      icon: Icons.lock,
                      obscure: true),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF8D6E63))
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(const Color(0xFF8D6E63)),
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(vertical: 14)),
                            ),
                            child: const Text(
                              "Prijavi se",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                      );
                    },
                    child: const Text(
                      "Nemate račun? Registrujte se!",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      required IconData icon,
      bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF8D6E63).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF8D6E63)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}
