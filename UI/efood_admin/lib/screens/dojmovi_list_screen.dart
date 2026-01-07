import 'dart:convert';
import 'dart:math';

import 'package:efood_admin/models/jelo.dart';
import 'package:efood_admin/models/narudzba.dart';
import 'package:efood_admin/models/statusNarudzbe.dart';
import 'package:efood_admin/models/stavkeNarudzbe.dart';
import 'package:efood_admin/providers/jelo_provider.dart';
import 'package:efood_admin/providers/korisnik_provider.dart';
import 'package:efood_admin/providers/narudzbu_provider.dart';
import 'package:efood_admin/providers/statusNarudzbe_provider.dart';
import 'package:efood_admin/providers/stavkeNarudzbe_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/dojmovi.dart';
import '../models/search_result.dart';
import '../providers/dojmovi_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DojmoiListScreen extends StatefulWidget {
  const DojmoiListScreen({Key? key}) : super(key: key);

  @override
  State<DojmoiListScreen> createState() => _DojmoviListScreenState();
}

class _DojmoviListScreenState extends State<DojmoiListScreen> {
  late DojmoviProvider _dojmoviProvider;
  late ProductProvider _jeloProvider;
  late KorisnikProvider _korisnikProvider;
  late NarudzbaProvider _narudzbaProvider;
  late stavkeNarudzbeProvider _stavkeProvider;
  late StatusNarudzbeProvider _statusProvider;

  SearchResult<Dojmovi>? result;
  Map<String, String> jeloMap = {};
  Map<String, String> korisnikMap = {};
  List<StavkeNarudzbe> stavkeNarudzbe = [];
  List<Narudzba> narudzbeList = [];
  List<StatusNarudzbe> statusList = [];
  Map<int, String> jeloSlikaMap = {};
  Map<int, DateTime> randomDatumi = {};

  TextEditingController _nazivController = TextEditingController();

  bool _initialized = false;
  bool _datesLoaded = false;

  final _prefsKey = 'random_datumi_admin';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    _dojmoviProvider = context.read<DojmoviProvider>();
    _jeloProvider = context.read<ProductProvider>();
    _korisnikProvider = context.read<KorisnikProvider>();
    _narudzbaProvider = context.read<NarudzbaProvider>();
    _stavkeProvider = context.read<stavkeNarudzbeProvider>();
    _statusProvider = context.read<StatusNarudzbeProvider>();

    _init();
  }

  Future<void> _init() async {
    await _loadSavedRandomDates();
    await _fetchInitialData();
    await _loadData();
    setState(() => _datesLoaded = true);
  }

  Future<void> _fetchInitialData() async {
    try {
      result = await _dojmoviProvider.get();

      var jeloResult = await _jeloProvider.get();
      if (jeloResult?.result != null) {
        jeloMap = {for (var jelo in jeloResult!.result) jelo.jeloId.toString(): jelo.naziv ?? ''};
        jeloSlikaMap = {for (var jelo in jeloResult.result) jelo.jeloId!: jelo.slika ?? ''};
      }

      var korisnikResult = await _korisnikProvider.get();
      if (korisnikResult?.result != null) {
        korisnikMap = {for (var korisnik in korisnikResult!.result) korisnik.id.toString(): korisnik.ime ?? ''};
      }

      var narudzbeResult = await _narudzbaProvider.get();
      narudzbeList = narudzbeResult?.result ?? [];

      var stavkeResult = await _stavkeProvider.get();
      stavkeNarudzbe = stavkeResult?.result ?? [];

      var statusResult = await _statusProvider.get();
      statusList = statusResult?.result ?? [];

      setState(() {});
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _loadData() async {
    var data = await _dojmoviProvider.get(filter: {'naziv': _nazivController.text});
    setState(() {
      result = data;
    });
  }

  Future<void> _loadSavedRandomDates() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey) ?? '{}';
    final map = Map<String, String>.from(json.decode(jsonStr));
    setState(() {
      randomDatumi = map.map((k, v) => MapEntry(int.parse(k), DateTime.parse(v)));
    });
  }

  Future<void> _saveRandomDates() async {
    final prefs = await SharedPreferences.getInstance();
    final map = randomDatumi.map((k, v) => MapEntry(k.toString(), v.toIso8601String()));
    await prefs.setString(_prefsKey, json.encode(map));
  }

  DateTime getOrCreateDateForId(int id) {
    final existing = randomDatumi[id];
    if (existing != null) return existing;

    final created = getRandomDateWithTime();
    randomDatumi[id] = created;
    _saveRandomDates();
    return created;
  }

  DateTime getRandomDateWithTime() {
    final now = DateTime.now();
    final r = Random();
    final days = r.nextInt(30);
    final hours = r.nextInt(24);
    final minutes = r.nextInt(60);
    return now.subtract(Duration(days: days, hours: hours, minutes: minutes));
  }

  String getStatus(Dojmovi dojam, Map<int, Narudzba> narudzbaMap, Map<int, StatusNarudzbe> statusMap) {
    final stavka = stavkeNarudzbe.firstWhere((s) => s.jeloId == dojam.jeloId, orElse: () => StavkeNarudzbe(0, 0, 0, 0, 0, 0));
    if (stavka.narudzbaId == null) return "Nepoznat status";

    final narudzba = narudzbaMap[stavka.narudzbaId];
    if (narudzba == null) return "Nepoznat status";

    final status = statusMap[narudzba.statusNarudzbeId];
    return status?.naziv ?? "Nepoznat status";
  }

  Icon getStatusIcon(String status) {
    switch (status) {
      case 'Kreirana':
        return Icon(Icons.create_outlined, color: Colors.purple[200]);
      case 'Prihvaćena':
        return Icon(Icons.check_circle_outline, color: Colors.purple[400]);
      case 'U toku':
        return Icon(Icons.autorenew, color: Colors.purple[300]);
      case 'Završena':
        return Icon(Icons.done_all, color: Colors.purple[500]);
      case 'Poslano':
        return Icon(Icons.local_shipping, color: Colors.purple[700]);
      default:
        return Icon(Icons.help_outline, color: Colors.purple[100]);
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Kreirana':
        return Colors.purple[200]!;
      case 'Prihvaćena':
        return Colors.purple[400]!;
      case 'U toku':
        return Colors.purple[300]!;
      case 'Završena':
        return Colors.purple[500]!;
      case 'Poslano':
        return Colors.purple[700]!;
      default:
        return Colors.purple[100]!;
    }
  }

  String getNarudzbaDatum(Dojmovi dojam, Map<int, Narudzba> narudzbaMap) {
    final stavka = stavkeNarudzbe.firstWhere((s) => s.jeloId == dojam.jeloId, orElse: () => StavkeNarudzbe(0, 0, 0, 0, 0, 0));
    final narudzba = narudzbaMap[stavka.narudzbaId];
    if (narudzba?.datumNarudzbe == null || narudzba!.datumNarudzbe!.isEmpty) return "Nepoznat datum";

    try {
      DateTime dt = DateTime.parse(narudzba.datumNarudzbe!);
      return DateFormat('dd.MM.yyyy').format(dt);
    } catch (_) {
      return narudzba.datumNarudzbe!;
    }
  }

  ImageProvider? _imageForJeloId(int jeloId) {
    final slika = jeloSlikaMap[jeloId];
    if (slika == null || slika.isEmpty) return null;
    if (slika.startsWith('http')) return NetworkImage(slika);

    try {
      final bytes = base64Decode(slika);
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<int, Narudzba> narudzbaMap = {for (var n in narudzbeList) n.id!: n};
    Map<int, StatusNarudzbe> statusMap = {for (var s in statusList) s.id!: s};

    return Scaffold(
      body: Column(
        children: [
          
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: result?.result.map((Dojmovi e) {
                        String nazivJela = jeloMap[e.jeloId.toString()] ?? 'Nepoznato';
                        String imeKorisnika = korisnikMap[e.korisnikId.toString()] ?? 'Nepoznato';
                        String statusNaziv = getStatus(e, narudzbaMap, statusMap);
                        Icon statusIcon = getStatusIcon(statusNaziv);
                        String datumNarudzbe = getNarudzbaDatum(e, narudzbaMap);
                        ImageProvider? imgProvider = _imageForJeloId(e.jeloId!);
                        final dt = getOrCreateDateForId(e.id!);
                        final datum = DateFormat('dd.MM.yyyy').format(dt);

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: imgProvider != null
                                      ? Image(
                                          image: imgProvider,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => const Center(
                                            child: Icon(Icons.broken_image,
                                                size: 40, color: Colors.purple),
                                          ),
                                        )
                                      : Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.fastfood,
                                              size: 40, color: Colors.purple),
                                        ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: List.generate(5, (index) {
                                          return Icon(
                                            index < (e.ocjena?.round() ?? 0)
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.purple[400],
                                            size: 20,
                                          );
                                        }),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Opis: ${e.opis ?? "Nema opisa"}',
                                          style: TextStyle(color: Colors.black54)),
                                      const SizedBox(height: 4),
                                      Text('Jelo: $nazivJela',
                                          style: TextStyle(color: Colors.black54)),
                                      const SizedBox(height: 4),
                                      Text('Korisnik: $imeKorisnika',
                                          style: TextStyle(color: Colors.black54)),
                                      const SizedBox(height: 4),
                                      Text('Datum: $datum',
                                          style: TextStyle(
                                              color: Colors.black54, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  children: [
                                    statusIcon,
                                    const SizedBox(height: 8),
                                    Text(
                                      statusNaziv,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: getStatusColor(statusNaziv),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (dialogContext) {
                                            return AlertDialog(
                                              title: Text("Potvrda brisanja"),
                                              content: Text("Da li želite obrisati ovaj dojam?"),
                                              actions: [
                                                TextButton(
                                                  child: Text("Otkaži"),
                                                  onPressed: () => Navigator.of(dialogContext).pop(false),
                                                ),
                                                TextButton(
                                                  child: Text("Obriši", style: TextStyle(color: Colors.red)),
                                                  onPressed: () => Navigator.of(dialogContext).pop(true),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirm == true) {
                                          try {
                                            await _dojmoviProvider.delete(e.id!);
                                            _loadData();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Obrisali ste dojam"),
                                                duration: Duration(seconds: 2),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          } catch (err) {
                                            print("Greška prilikom brisanja: $err");
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList() ??
                      [],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
