import 'package:efood_admin/models/search_result.dart';
import 'package:efood_admin/providers/narudzbu_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/stavkeNarudzbe.dart';
import '../providers/jelo_provider.dart';
import '../providers/stavkeNarudzbe_provider.dart';

class EvidencijaObavjestenja extends StatefulWidget {
  const EvidencijaObavjestenja({Key? key}) : super(key: key);

  @override
  State<EvidencijaObavjestenja> createState() => _EvidencijaObavjestenjaState();
}

class _EvidencijaObavjestenjaState extends State<EvidencijaObavjestenja> {
  late stavkeNarudzbeProvider _stavkeNarudzbeProvider;
  late NarudzbaProvider _narudzbaProvider;
  late ProductProvider _jeloProvider;

  SearchResult<StavkeNarudzbe>? _stavkeResult;

  Map<String, String> _jeloMap = {}; 
  Map<String, Map<String, String?>> _narudzbaInfoMap = {};

  final TextEditingController _nazivController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stavkeNarudzbeProvider = context.read<stavkeNarudzbeProvider>();
    _jeloProvider = context.read<ProductProvider>();
    _narudzbaProvider = context.read<NarudzbaProvider>();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final stavke = await _stavkeNarudzbeProvider.get();
      final jela = await _jeloProvider.get();
      final narudzbe = await _narudzbaProvider.get();

      setState(() {
        _stavkeResult = stavke;

        _jeloMap = {
          for (final j in jela.result) j.jeloId.toString(): j.naziv ?? ''
        };

        _narudzbaInfoMap = {
          for (final n in narudzbe.result)
            n.id.toString(): {
              'datum': n.datumNarudzbe ?? 'Nepoznato',
              'paymentId': (n.paymentId?.toString().trim().isNotEmpty ?? false)
                  ? n.paymentId.toString()
                  : null,
            }
        };
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri učitavanju: $e')),
      );
    }
  }

  Future<void> _search() async {
    try {
      final data = await _stavkeNarudzbeProvider.get(filter: {
        'naziv': _nazivController.text,
      });
      setState(() => _stavkeResult = data);
    } catch (e) {
      debugPrint('Error during search: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri pretrazi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(child: _buildTable()),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    final rows = (_stavkeResult?.result ?? []).map((e) {
      final nazivJela = _jeloMap[e.jeloId?.toString() ?? ''] ?? 'Nepoznato';
      final info = _narudzbaInfoMap[e.narudzbaId?.toString() ?? ''];
      final datumNarudzbe = DateTime.tryParse(info?['datum'] ?? '') ?? DateTime.now();
      final datumText = DateFormat('dd.MM.yyyy').format(datumNarudzbe);
      final paymentId = info?['paymentId'];
      final nacinPlacanja = _resolvePaymentLabel(paymentId);

      return DataRow(
        cells: [
          DataCell(Text(e.kolicina?.toString() ?? '')),
          DataCell(Text(e.cijena != null ? e.cijena!.toStringAsFixed(2) : '')),
          DataCell(Text(nazivJela)),
          DataCell(Text(datumText)),
          DataCell(
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nacinPlacanja),
                if (paymentId != null)
                  Text(
                    'Txn: $paymentId',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      );
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Količina', style: TextStyle(fontStyle: FontStyle.italic))),
          DataColumn(label: Text('Cijena', style: TextStyle(fontStyle: FontStyle.italic))),
          DataColumn(label: Text('Naziv Jela', style: TextStyle(fontStyle: FontStyle.italic))),
          DataColumn(label: Text('Datum Narudžbe', style: TextStyle(fontStyle: FontStyle.italic))),
          DataColumn(label: Text('Način plaćanja', style: TextStyle(fontStyle: FontStyle.italic))),
        ],
        rows: rows,
      ),
    );
  }

  String _resolvePaymentLabel(String? paymentId) {
    if (paymentId == null || paymentId.trim().isEmpty) {
      return 'Gotovina po preuzecu';
    }
    if (paymentId.startsWith('PAYID-')) {
      return 'Karticom (PayPal)';
    }
    if (paymentId.startsWith('pi_')) {
      return 'Karticom (Stripe)';
    }
    return 'Karticom';
  }
}
