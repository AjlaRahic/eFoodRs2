import 'package:efood_admin/models/korisnik.dart';
import 'package:efood_admin/models/search_result.dart';
import 'package:efood_admin/providers/korisnik_provider.dart';
import 'package:efood_admin/screens/korisnik_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KorisnikScreen extends StatefulWidget {
  const KorisnikScreen({Key? key}) : super(key: key);

  @override
  State<KorisnikScreen> createState() => _KorisnikScreen();
}

class _KorisnikScreen extends State<KorisnikScreen> {
  late KorisnikProvider _korisnikProvider;
  SearchResult<Korisnik>? result;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _korisnikProvider = context.read<KorisnikProvider>();
    _fetchKorisnici();
  }

  Future<void> _fetchKorisnici() async {
    var data = await _korisnikProvider.get();
    setState(() {
      result = SearchResult<Korisnik>(
        result: data.result.where((korisnik) {
          return korisnik.korisniciUloges.any((uloga) => uloga.ulogaId == 1);
        }).toList(),
        count: data.count,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final korisnik = result?.result.first;

    return Scaffold(
      body: korisnik != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${korisnik.ime ?? ''} ${korisnik.prezime ?? ''}",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple[700],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ],
                          ),
                          Divider(color: Colors.purple[200]),
                          SizedBox(height: 16),
                          _buildProfileDetail("Korisničko ime",
                              korisnik.korisnickoIme ?? "", Icons.person),
                          SizedBox(height: 24),
                          _buildProfileDetail(
                              "Telefon", korisnik.telefon ?? "", Icons.phone),
                          SizedBox(height: 24),
                          _buildProfileDetail(
                              "Email", korisnik.email ?? "", Icons.email),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () async {
                              final changed =
                                  await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => KorisniciDetailsScreen(
                                      korisnik: korisnik),
                                ),
                              );

                              if (changed == true) {
                                await _fetchKorisnici();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[600],
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: Size(double.infinity, 50),
                            ),
                            child: const Text(
                              "Uredi",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Center(child: CircularProgressIndicator(color: Colors.purple[400])),
    );
  }

  Widget _buildProfileDetail(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.1),
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.purple[400], size: 28),
            SizedBox(width: 16),
            Text(
              "$title:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.purple[700],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: 20, color: Colors.purple[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
