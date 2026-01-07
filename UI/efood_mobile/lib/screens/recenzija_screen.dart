import 'dart:convert';
import 'dart:math';
import 'package:efood_mobile/models/dojmovi.dart';
import 'package:efood_mobile/models/jelo.dart';
import 'package:efood_mobile/models/search_result.dart';
import 'package:efood_mobile/providers/dojmovi_provider.dart';
import 'package:efood_mobile/providers/jelo_provider.dart';
import 'package:efood_mobile/providers/korisnik_provider.dart';
import 'package:efood_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecenzijaScreen extends StatefulWidget {
  const RecenzijaScreen({Key? key}) : super(key: key);

  @override
  State<RecenzijaScreen> createState() => _RecenzijaScreen();
}

class _RecenzijaScreen extends State<RecenzijaScreen> {
  late DojmoviProvider _dojmoviProvider;
  late ProductProvider _jeloProvider;
  late KorisnikProvider _korisnikProvider;

  SearchResult<Dojmovi>? stavkeResult;
  Map<String, Jelo> jeloMap = {};
  Map<String, String> korisnikMap = {};
  Map<int, DateTime> randomDatumi = {};

  final TextEditingController _nazivController = TextEditingController();
  bool _initialized = false;
  bool _datesLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    _dojmoviProvider = context.read<DojmoviProvider>();
    _jeloProvider = context.read<ProductProvider>();
    _korisnikProvider = context.read<KorisnikProvider>();

    _init();
  }

  Future<void> _init() async {
    await _loadSavedRandomDates();
    await _fetchInitialData();
    setState(() {
      _datesLoaded = true;
    });
  }

  Future<void> _fetchInitialData() async {
    try {
      stavkeResult = await _dojmoviProvider.get();
      var jeloResult = await _jeloProvider.get();
      var korisnikResult = await _korisnikProvider.get();

      if (jeloResult?.result != null && korisnikResult?.result != null) {
        setState(() {
          jeloMap = {
            for (var jelo in jeloResult!.result) jelo.jeloId.toString(): jelo
          };
          korisnikMap = {
            for (var k in korisnikResult!.result) k.id.toString(): k.ime ?? ''
          };
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Widget _buildStars(double ocjena) {
    int fullStars = ocjena.floor();
    bool hasHalf = (ocjena - fullStars) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.orange, size: 16);
        } else if (index == fullStars && hasHalf) {
          return const Icon(Icons.star_half, color: Colors.orange, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.orange, size: 16);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title_widget: const Text("Recenzije korisnika"),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: stavkeResult == null
            ? const Center(child: CircularProgressIndicator())
            : stavkeResult!.result.isEmpty
                ? const Center(child: Text("Nema recenzija za prikaz"))
                : ListView.builder(
                    itemCount: stavkeResult!.result.length,
                    itemBuilder: (context, index) {
                      final d = stavkeResult!.result[index];
                      final jelo = jeloMap[d.jeloId.toString()];
                      final korisnik =
                          korisnikMap[d.korisnikId.toString()] ?? 'Nepoznato';

                      final dt = getOrCreateDateForId(d.id!);
                      final datum = DateFormat('dd.MM.yyyy').format(dt);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (jelo?.slika != null &&
                                  jelo!.slika!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    base64Decode(jelo.slika!),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child:
                                      const Center(child: Text('Nema slike')),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          jelo?.naziv ?? 'Nepoznato jelo',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.orange),
                                        ),
                                        Text(
                                          datum,
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    _buildStars((d.ocjena ?? 0).toDouble()),
                                    const SizedBox(height: 4),
                                    Text(
                                      d.opis ?? '',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Korisnik: $korisnik',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
      ),
    );
  }

  Future<void> _loadSavedRandomDates() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('random_datumi') ?? '{}';
    final map = Map<String, String>.from(json.decode(jsonStr));
    randomDatumi = map.map((k, v) => MapEntry(int.parse(k), DateTime.parse(v)));
    setState(() {});
  }

  Future<void> _saveRandomDates() async {
    final prefs = await SharedPreferences.getInstance();
    final map =
        randomDatumi.map((k, v) => MapEntry(k.toString(), v.toIso8601String()));
    await prefs.setString('random_datumi', json.encode(map));
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
}
