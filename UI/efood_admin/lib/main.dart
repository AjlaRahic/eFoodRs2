import 'package:efood_admin/providers/dojmovi_provider.dart';
import 'package:efood_admin/providers/dostavljaci_provider.dart';
import 'package:efood_admin/providers/grad_provider.dart';
import 'package:efood_admin/providers/jelo_provider.dart';
import 'package:efood_admin/providers/kategorija_provider.dart';
import 'package:efood_admin/providers/korisnik_provider.dart';
import 'package:efood_admin/providers/narudzbu_provider.dart';
import 'package:efood_admin/providers/restoran_provider.dart';
import 'package:efood_admin/providers/statusNarudzbe_provider.dart';
import 'package:efood_admin/providers/stavkeNarudzbe_provider.dart';
import 'package:efood_admin/providers/dostavljaci_provider.dart';
import 'package:efood_admin/providers/uloga_provider.dart';
import 'package:efood_admin/screens/home_screen.dart';
import 'package:efood_admin/utils/util.dart';
import 'package:efood_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GradProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => KategorijaProvider()),
        ChangeNotifierProvider(create: (_) => KorisnikProvider()),
         ChangeNotifierProvider(create: (_) => DostavljaciProvider()),
        ChangeNotifierProvider(create: (_) => stavkeNarudzbeProvider()),
        ChangeNotifierProvider(create: (_) => NarudzbaProvider()),
        ChangeNotifierProvider(create: (_) => DojmoviProvider()),
        ChangeNotifierProvider(create: (_) => UlogaProvider()),
        ChangeNotifierProvider(create: (_) => StatusNarudzbeProvider()),
        ChangeNotifierProvider(create: (_) => RestoranProvider()),
       
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eFood Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.purple[50],
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
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

    Authorization.username = _usernameController.text;
    Authorization.password = _passwordController.text;

    try {
      Authorization.korisnik = await _korisnikProvider.Authenticate();

      if (Authorization.korisnik?.korisniciUloges
              .any((role) => role.uloga?.naziv == "Admin") ==
          true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MasterScreenWidget(
              child: HomeScreen(),
              title: "Početna",
              activeItem: "Početna",
            ),
          ),
        );
      } else {
        _showError("Vaš korisnički račun nema permisije za pristup admin panelu!");
      }
    } catch (_) {
      _showError("Pogrešno korisničko ime ili lozinka!");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Greška"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _korisnikProvider = context.read<KorisnikProvider>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                   radius: 50,
                   backgroundColor: Colors.purple[100],
                   backgroundImage: AssetImage("assets/images/slika1.jpg"),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "eFood Admin",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Korisničko ime",
                      prefixIcon: Icon(Icons.person, color: Colors.purple[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Lozinka",
                      prefixIcon: Icon(Icons.lock, color: Colors.purple[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Prijavi se",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
