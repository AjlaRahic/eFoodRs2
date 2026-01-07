import 'package:efood_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/narudzba.dart';
import '../models/stavkeNarudzbe.dart';
import '../models/jelo.dart';
import '../providers/narudzba_provider.dart';
import '../providers/stavkeNarudzbe_provider.dart';
import '../providers/jelo_provider.dart';
import 'pracenje_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = true;
  List<Narudzba> _narudzbe = [];
  Map<int, List<StavkeNarudzbe>> _stavkePoNarudzbi = {};
  Map<int, Jelo> _jelaById = {};

  @override
  void initState() {
    super.initState();
    _loadNarudzbe();
  }

  Future<void> _loadNarudzbe() async {
    setState(() => _isLoading = true);

    try {
      final narudzbaProvider = context.read<NarudzbaProvider>();
      final stavkeProvider = context.read<StavkeNarudzbeProvider>();
      final jeloProvider = context.read<ProductProvider>();

      final narudzbeResult = await narudzbaProvider.getByUser(Authorization.userId!);
      final narudzbe = narudzbeResult.result ?? [];

      final stavkeResult = await stavkeProvider.get();
      final Map<int, List<StavkeNarudzbe>> stavkeMap = {};
      final Set<int> jeloIds = {};

      for (var s in stavkeResult.result ?? []) {
        stavkeMap[s.narudzbaId ?? 0] = [...?stavkeMap[s.narudzbaId ?? 0], s];
        if (s.jeloId != null) jeloIds.add(s.jeloId!);
      }

      final jelaResult = await jeloProvider.get();
      final Map<int, Jelo> jelaMap = {
        for (var j in jelaResult.result ?? [])
          if (j.jeloId != null && jeloIds.contains(j.jeloId!)) j.jeloId!: j
      };

      setState(() {
        _narudzbe = narudzbe;
        _stavkePoNarudzbi = stavkeMap;
        _jelaById = jelaMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Greška pri učitavanju narudžbi: $e");
    }
  }

  String _naziviJela(int narudzbaId) {
    final stavke = _stavkePoNarudzbi[narudzbaId] ?? [];
    if (stavke.isEmpty) return "(nema stavki)";
    return stavke.map((s) => _jelaById[s.jeloId]?.naziv ?? "?").join(", ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historija narudžbi")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _narudzbe.length,
              itemBuilder: (ctx, i) {
                final n = _narudzbe[i];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    title: Text("Narudžba #${n.narudzbaId}"),
                    subtitle: Text(_naziviJela(n.narudzbaId ?? 0)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
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
                                  content: Text(
                                      "Dostavljač nije dodijeljen ovoj narudžbi."),
                                ),
                              );
                            }
                          },
                          child: const Text("Prati narudžbu"),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}
