import 'package:efood_mobile/models/jelo.dart';
import 'package:efood_mobile/models/narudzba.dart';
import 'package:efood_mobile/models/stavkeNarudzbe.dart';
import 'package:efood_mobile/providers/jelo_provider.dart';
import 'package:efood_mobile/providers/korisnik_provider.dart';
import 'package:efood_mobile/providers/narudzba_provider.dart';
import 'package:efood_mobile/providers/stavkeNarudzbe_provider.dart';
import 'package:efood_mobile/screens/pracenje_screen.dart';
import 'package:efood_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistorijaScreen extends StatefulWidget {
  @override
  _HistorijaScreenState createState() => _HistorijaScreenState();
}

class _HistorijaScreenState extends State<HistorijaScreen> {
  bool _isLoading = true;
  late KorisnikProvider _korisnikProvider;
  late NarudzbaProvider _narudzbaProvider;
  late StavkeNarudzbeProvider stavkeProvider;
  late ProductProvider productProvider;

  List<Narudzba> _narudzbe = [];
  Map<int, List<StavkeNarudzbe>> _stavkePoNarudzbi = {};
  Map<int, Jelo> _jelaById = {};
  Map<int, String> _korisniciById = {};

  @override
  void initState() {
    super.initState();
    _loadNarudzbe();
  }

  Future<void> _loadNarudzbe() async {
    if (Authorization.userId == null) {
      _toast('Korisnik nije ulogovan.');
      setState(() => _isLoading = false);
      return;
    }

    try {
      _narudzbaProvider = context.read<NarudzbaProvider>();
      stavkeProvider = context.read<StavkeNarudzbeProvider>();
      productProvider = context.read<ProductProvider>();
      _korisnikProvider = context.read<KorisnikProvider>();

      final korisniciResult = await _korisnikProvider.get();
      _korisniciById = {
        for (final k in korisniciResult.result)
          if (k.id != null) k.id!: k.ime!,
      };
      final narudzbeResult =
          await _narudzbaProvider.getByUser(Authorization.userId!);

      final narudzbe = (narudzbeResult.result ?? [])
          .where((n) => n.korisnikId == Authorization.userId)
          .toList();

      if (narudzbe.isEmpty) {
        setState(() {
          _narudzbe = [];
          _stavkePoNarudzbi = {};
          _jelaById = {};
          _isLoading = false;
        });
        return;
      }

      final stavkeResult = await stavkeProvider.get();
      final idsNarudzbi =
          narudzbe.map((n) => n.narudzbaId).whereType<int>().toSet();

      final Map<int, List<StavkeNarudzbe>> stavkeMap = {};
      final Set<int> potrebniJeloIds = {};

      for (final s in (stavkeResult.result ?? [])) {
        final nid = s.narudzbaId;
        if (nid == null || !idsNarudzbi.contains(nid)) continue;

        (stavkeMap[nid] ??= []).add(s);
        if (s.jeloId != null) potrebniJeloIds.add(s.jeloId!);
      }

      final jelaResult = await productProvider.get();
      final Map<int, Jelo> jelaMap = {};
      for (final j in (jelaResult.result ?? [])) {
        final id = j.jeloId;
        if (id != null && potrebniJeloIds.contains(id)) {
          jelaMap[id] = j;
        }
      }

      for (final jid in potrebniJeloIds) {
        if (!jelaMap.containsKey(jid)) {
          debugPrint(
              "Upozorenje: jeloId=$jid nije pronađen u ProductProvider.get()");
        }
      }

      setState(() {
        _narudzbe = narudzbe;
        _stavkePoNarudzbi = stavkeMap;
        _jelaById = jelaMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Greška kod dohvata narudžbi: $e");
      _toast('Greška pri dohvatu narudžbi.');
    }
  }

  String _naziviJelaZaNarudzbu(int? narudzbaId) {
    if (narudzbaId == null) return "-";
    final stavke = _stavkePoNarudzbi[narudzbaId] ?? [];
    if (stavke.isEmpty) return "(nema stavki)";

    final nazivi = <String>[];
    for (final s in stavke) {
      final jid = s.jeloId;
      final j = (jid != null) ? _jelaById[jid] : null;
      nazivi.add(j?.naziv ?? "Jelo #${jid ?? '?'}");
    }

    const maxPrikaza = 3;
    if (nazivi.length > maxPrikaza) {
      return "${nazivi.take(maxPrikaza).join(', ')} +${nazivi.length - maxPrikaza}";
    }
    return nazivi.join(', ');
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDatum(DateTime? dt) {
    if (dt == null) return "-";
    return "${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historija mojih narudžbi")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _narudzbe.isEmpty
              ? const Center(child: Text("Nemate prethodnih narudžbi."))
              : ListView.builder(
                  itemCount: _narudzbe.length,
                  itemBuilder: (ctx, i) {
                    final n = _narudzbe[i];
                    final stavke = _stavkePoNarudzbi[n.narudzbaId] ?? [];
                    final meta = _statusMeta(n);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      child: ExpansionTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _naziviJelaZaNarudzbu(n.narudzbaId),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(meta.icon, size: 16, color: meta.color),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: meta.color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                        color: meta.color.withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    meta.label,
                                    style: TextStyle(
                                      color: meta.color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Datum: ${_formatDatum(n.datumNarudzbe)}"),
                              Text(
                                  "Korisnik: ${_korisniciById[n.korisnikId] ?? 'Nepoznato ime'}"),
                              const SizedBox(height: 4),
                              Text(
                                "Stavke narudžbi: {${stavke.length}}",
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        children: [
  // 1️⃣ STAVKE
  if (stavke.isEmpty)
    const ListTile(title: Text("Nema stavki."))
  else
    ...stavke.map((s) {
      final jid = s.jeloId;
      final j = (jid != null) ? _jelaById[jid] : null;
      return ListTile(
        leading: const Icon(Icons.fastfood_rounded),
        title: Text(j?.naziv ?? "Jelo #${jid ?? '?'}"),
        subtitle: Text("Količina: ${s.kolicina ?? 0}"),
        trailing: Text(
          "${(s.ukupno ?? ((s.cijena ?? 0) * (s.kolicina ?? 1))).toStringAsFixed(2)} KM",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }),

  // 2️⃣ RAZMAK
  const SizedBox(height: 8),

  // 3️⃣ DUGME NA DNU
  Padding(
    padding: const EdgeInsets.all(12.0),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.location_on),
        label: const Text("Prati narudžbu"),
        onPressed: () {
          if (n.dostavljacId != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PracenjeNarudzbeScreen(
                  narudzbaId: n.narudzbaId!,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text("Dostavljač nije dodijeljen ovoj narudžbi."),
              ),
            );
          }
        },
      ),
    ),
  ),
],

                              
                              
                      ),
                    );
                    
                  },
                  
                ),
    );
  }
}

class _StatusMeta {
  final String label;
  final IconData icon;
  final Color color;
  const _StatusMeta(this.label, this.icon, this.color);
}

_StatusMeta _statusMeta(Narudzba n) {
  final raw = (n.stateMachine ?? '').toLowerCase();

  if (raw.contains('kreiran')) {
    return _StatusMeta('Kreirana', Icons.fiber_new_rounded, Colors.blue);
  }
  if (raw.contains('prihva') || raw.contains('accept')) {
    return _StatusMeta('Prihvaćena', Icons.verified_rounded, Colors.teal);
  }
  if (raw.contains('tok') || raw.contains('progress')) {
    return _StatusMeta(
        'U toku', Icons.pending_actions_rounded, Colors.amber[800]!);
  }
  if (raw.contains('zavr') || raw.contains('done') || raw.contains('isporu')) {
    return _StatusMeta(
        'Završena', Icons.check_circle_rounded, Colors.green[700]!);
  }
  if (raw.contains('otkaz') || raw.contains('cancel')) {
    return _StatusMeta('Otkazana', Icons.cancel_rounded, Colors.red[700]!);
  }
  return _StatusMeta(
    (n.stateMachine ?? 'Nepoznat'),
    Icons.help_outline_rounded,
    Colors.grey[600]!,
  );
}