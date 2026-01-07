import 'dart:convert';

import 'package:efood_mobile/main.dart';
import 'package:efood_mobile/models/korisnik.dart';
import 'package:efood_mobile/providers/korisnik_provider.dart';
import 'package:efood_mobile/providers/uloga_provider.dart';
import 'package:efood_mobile/screens/korisnik_details_screen.dart';
import 'package:efood_mobile/utils/util.dart';

import 'package:efood_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KorisnikProfileScreen extends StatefulWidget {
  final Korisnik? korisnik;
  const KorisnikProfileScreen({Key? key, this.korisnik}) : super(key: key);

  @override
  State<KorisnikProfileScreen> createState() => _KorisnikProfileScreen();
}

class _KorisnikProfileScreen extends State<KorisnikProfileScreen> {
  late KorisnikProvider _korisnikProvider;
  late UlogaProvider _ulogaProvider;
  List<Korisnik>? korisnikResult;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _korisnikProvider = context.read<KorisnikProvider>();
    _ulogaProvider = context.read<UlogaProvider>();
    _fetchKorisnici();
  }

  Future<void> _fetchKorisnici() async {
    try {
      var data = await _korisnikProvider.get();
      setState(() {
        korisnikResult = data.result.where((korisnik) {
          return korisnik.korisniciUloges!.any((uloga) => uloga.ulogaId == 2);
        }).toList();
      });
    } catch (e) {
      print('Error fetching korisnici: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final korisnik = korisnikResult?.first;
    final screenWidth = MediaQuery.of(context).size.width;

    return MasterScreenWidget(
      title_widget: const Text(
        "Profil korisnika",
        style: TextStyle(color: Colors.black),
      ),
      child: korisnik != null
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: const Color(0xFFF4E4D9), 
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: screenWidth > 600
                            ? Row(
                                children: [
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${korisnik.ime ?? ''} ${korisnik.prezime ?? ''}",
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.brown,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          korisnik.korisnickoIme ?? '',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  const SizedBox(height: 16),
                                  Text(
                                    "${korisnik.ime ?? ''} ${korisnik.prezime ?? ''}",
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                  ),
                                 
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildProfileDetail("Korisnicko ime",
                        korisnik.korisnickoIme ?? '', Icons.person),
                    _buildProfileDetail(
                        "Ime korisnika", korisnik.ime ?? '', Icons.person),
                    _buildProfileDetail("Prezime korisnika",
                        korisnik.prezime ?? '', Icons.person),
                    _buildProfileDetail(
                        "Telefon", korisnik.telefon ?? '', Icons.phone),
                    _buildProfileDetail(
                        "Email", korisnik.email ?? '', Icons.email),
                    const SizedBox(height: 16),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (context) =>
                                KorisnikDetailsScreen(korisnik: korisnik),
                          ),
                        )
                            .then((_) {
                          _fetchKorisnici();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child:
                              Text('Odjavi se', style: TextStyle(fontSize: 16)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildProfileDetail(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4E4D9), // ista nježna boja kao kod recenzija
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.brown, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$title:",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    Authorization.korisnik = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }
}
