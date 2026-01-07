import 'dart:async';
import 'dart:math';
import 'package:efood_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:efood_mobile/models/lokacija.dart';
import 'package:efood_mobile/models/narudzba.dart';
import 'package:efood_mobile/providers/lokacija_provider.dart';
import 'package:efood_mobile/providers/narudzba_provider.dart';
import 'package:efood_mobile/utils/util.dart';

class DostavljacScreen extends StatefulWidget {
  const DostavljacScreen({Key? key}) : super(key: key);

  @override
  State<DostavljacScreen> createState() => _DostavljacScreenState();
}

class _DostavljacScreenState extends State<DostavljacScreen> {
  late NarudzbaProvider _narudzbaProvider;
  late LokacijaProvider _lokacijaProvider;

  List<Narudzba> narudzbe = [];
  bool loading = true;
  bool tracking = false;

  Timer? _timer;

  double? _lat;
  double? _lon;

  @override
  void initState() {
    super.initState();
    _narudzbaProvider = context.read<NarudzbaProvider>();
    _lokacijaProvider = context.read<LokacijaProvider>();
    _loadNarudzbe();
  }

  Future<void> _loadNarudzbe() async {
    setState(() => loading = true);
    final result = await _narudzbaProvider.getByLoggedDostavljac();
    narudzbe = result?.result ?? [];
    setState(() => loading = false);
  }

  void _toggleTracking() {
    if (tracking) {
      _timer?.cancel();
      setState(() => tracking = false);
      return;
    }

    setState(() => tracking = true);
    _startTracking();
  }

  Future<void> _startTracking() async {
    if (narudzbe.isEmpty) return;

    final narudzba = narudzbe.first;

    // 1️⃣ početna lokacija dostavljača (rondo / zadnja poznata)
    final startLok =
        await _lokacijaProvider.getZadnjaLokacija(Authorization.userId!);

    if (startLok == null) {
      print("Dostavljač nema početnu lokaciju");
      return;
    }

    _lat = startLok.latitude;
    _lon = startLok.longitude;

    // 2️⃣ lokacija korisnika koji je kreirao narudžbu
    final ciljLok = await _lokacijaProvider
        .getLokacijaKorisnika(narudzba.narudzbaId!);

    if (ciljLok == null) {
      print("Korisnik nema lokaciju");
      return;
    }

    const step = 0.0005;
    const interval = Duration(seconds: 2);

    _timer = Timer.periodic(interval, (timer) async {
      if (_lat == null || _lon == null) return;

      final dx = ciljLok.latitude! - _lat!;
      final dy = ciljLok.longitude! - _lon!;
      final distance = sqrt(dx * dx + dy * dy);

      if (distance < step) {
        timer.cancel();
        print("Dostavljač stigao");
        return;
      }

      _lat = _lat! + dx / distance * step;
      _lon = _lon! + dy / distance * step;

      await _lokacijaProvider.insertLokacija(
        Lokacija(
          korisnikId: Authorization.userId!,
          latitude: _lat!,
          longitude: _lon!,
          datum: DateTime.now(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dostavljač")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _toggleTracking,
              child: Text(tracking ? "Isključi GPS" : "Uključi GPS"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: narudzbe.length,
                      itemBuilder: (context, index) {
                        final n = narudzbe[index];
                        return Card(
                          child: ListTile(
                            title: Text("Narudžba #${n.narudzbaId}"),
                            subtitle:
                                Text("Korisnik: ${n.korisnikId}"),
                          ),
                        );
                      },
                    ),
                    
            ),
            SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Odjavi se', style: TextStyle(fontSize: 16)),
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

