import 'package:efood_admin/models/korisnik.dart';
import 'package:efood_admin/models/narudzba.dart';
import 'package:efood_admin/models/search_result.dart';
import 'package:efood_admin/models/statusNarudzbe.dart';
import 'package:efood_admin/providers/korisnik_provider.dart';
import 'package:efood_admin/providers/narudzbu_provider.dart';
import 'package:efood_admin/providers/statusNarudzbe_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatusNarudzbaScreen extends StatefulWidget {
  const StatusNarudzbaScreen({Key? key}) : super(key: key);

  @override
  State<StatusNarudzbaScreen> createState() => _StatusNarudzbaScreenState();
}

class _StatusNarudzbaScreenState extends State<StatusNarudzbaScreen> {
  late StatusNarudzbeProvider _statusNarudzbeProvider;
  late NarudzbaProvider _narudzbaProvider;
  late KorisnikProvider _korisnikProvider;

  SearchResult<StatusNarudzbe>? statusResult;
  List<Narudzba>? narudzbaResult;
  SearchResult<Korisnik>? korisnikResult;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _statusNarudzbeProvider = context.read<StatusNarudzbeProvider>();
    _narudzbaProvider = context.read<NarudzbaProvider>();
    _korisnikProvider = context.read<KorisnikProvider>();

    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final statuses = await _statusNarudzbeProvider.get();
      final narudzbe = await _narudzbaProvider.getAll();
      final korisnici = await _korisnikProvider.get();

      setState(() {
        statusResult = statuses;
        narudzbaResult = narudzbe;
        korisnikResult = korisnici;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Greška prilikom učitavanja podataka")),
      );
    }
  }

  Future<void> _dodijeliDostavljaca(Narudzba narudzba, int dostavljacId) async {
    try {
      await _narudzbaProvider.dodijeliDostavljaca(
        narudzbaId: narudzba.id!,
        dostavljacId: dostavljacId,
      );

      final refreshedStatuses = await _statusNarudzbeProvider.get();
      final refreshedNarudzbe = await _narudzbaProvider.getAll();

      setState(() {
        statusResult = refreshedStatuses;
        narudzbaResult = refreshedNarudzbe;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dostavljač dodijeljen')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Neuspješno dodavanje dostavljača')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (statusResult == null ||
        narudzbaResult == null ||
        korisnikResult == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: statusResult!.result.length,
          itemBuilder: (context, index) {
            final status = statusResult!.result[index];
            final filteredNarudzbe = narudzbaResult!
                .where((n) => n.statusNarudzbeId == status.id)
                .toList();

            return _buildStatusCard(status, filteredNarudzbe);
          },
        ),
      ),
    );
  }

  Widget _buildStatusCard(
      StatusNarudzbe status, List<Narudzba> filteredNarudzbe) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade100,
              Colors.purple.shade300,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status.naziv ?? "Nepoznati status",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Broj narudžbi: ${filteredNarudzbe.length}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Column(
              children: filteredNarudzbe.map((narudzba) {
                final datum = _formatDatum(narudzba.datumNarudzbe);
                final korisnikIme =
                    _getKorisnikIme(narudzba.korisnikId);
                final dostavljacDodijeljen =
                    narudzba.dostavljacId != null;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text("Datum: $datum")),
                      Expanded(child: Text("Korisnik: $korisnikIme")),
                      Expanded(
                        child: Text(
                          "Stanje: ${narudzba.stateMachine ?? 'Nepoznato'}",
                        ),
                      ),
                      dostavljacDodijeljen
                          ? const Expanded(
                              child: Text(
                                "Dostavljač dodijeljen",
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.purple.shade400,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                final dostavljac =
                                    await _odaberiDostavljaca();
                                if (dostavljac != null) {
                                  await _dodijeliDostavljaca(
                                      narudzba, dostavljac.id!);
                                }
                              },
                              child:
                                  const Text("Dodijeli dostavljača"),
                            ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDatum(String? datum) {
    if (datum == null || datum.isEmpty) return 'Nepoznato';
    try {
      final dt = DateTime.parse(datum);
      return DateFormat('dd.MM.yyyy').format(dt);
    } catch (_) {
      return datum;
    }
  }

  String _getKorisnikIme(int? korisnikId) {
    final korisnik = korisnikResult!.result.firstWhere(
      (k) => k.id == korisnikId,
      orElse: () => Korisnik(id: 0, ime: 'Nepoznat korisnik'),
    );
    return korisnik.ime ?? 'Nepoznat korisnik';
  }

  Future<Korisnik?> _odaberiDostavljaca() async {
    final dostavljaci = await _korisnikProvider.getDostavljaci();

    return showDialog<Korisnik>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Odaberi dostavljača"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: dostavljaci.length,
              itemBuilder: (context, index) {
                final d = dostavljaci[index];
                return ListTile(
                  title: Text(d.ime ?? 'Nepoznato ime'),
                  onTap: () => Navigator.of(context).pop(d),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
