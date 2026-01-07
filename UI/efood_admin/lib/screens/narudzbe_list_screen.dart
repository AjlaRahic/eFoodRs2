import 'package:efood_admin/models/search_result.dart';
import 'package:efood_admin/providers/narudzbu_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stavkeNarudzbe.dart';
import '../providers/jelo_provider.dart';
import '../providers/stavkeNarudzbe_provider.dart';
import '../widgets/master_screen.dart';

class NarudzbaListScreen extends StatefulWidget {
  const NarudzbaListScreen({Key? key}) : super(key: key);

  @override
  State<NarudzbaListScreen> createState() => _NarudzbaListScreen();
}

class _NarudzbaListScreen extends State<NarudzbaListScreen> {
  late stavkeNarudzbeProvider _stavkeNarudzbeProvider;
  late NarudzbaProvider _narudzbaProvider;
  late ProductProvider _jeloProvider;
  SearchResult<StavkeNarudzbe>? stavkeResult;
  Map<String, String> jeloMap = {}; 
  Map<String, String> narudzbaMap = {}; 

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
      stavkeResult = await _stavkeNarudzbeProvider.get();
      
      var jeloResult = await _jeloProvider.get();
      var narudzbaResult = await _narudzbaProvider.get();

      if (jeloResult?.result != null && narudzbaResult?.result != null) {
        setState(() {
          jeloMap = {
            for (var jelo in jeloResult!.result) jelo.jeloId.toString(): jelo.naziv ?? ''
          };

          narudzbaMap = {
            for (var narudzba in narudzbaResult!.result) narudzba.id.toString(): narudzba.datumNarudzbe ?? 'Nepoznato'
          };

          print('Jelo Map: $jeloMap');
          print('Narudzba Map: $narudzbaMap'); 
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title_widget: const Text("Evidencija narudžbi"),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildSearch(),
            Expanded(child: _buildDataListView()),
          ],
        ),
      ),
    );
  }


  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(labelText: "Naziv jela"),
              controller: _nazivController,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              try {
                var data = await _stavkeNarudzbeProvider.get(filter: {
                  'naziv': _nazivController.text,
                });
                setState(() {
                  stavkeResult = data;
                });
              } catch (e) {
                print('Error during search: $e');
              }
            },
            child: const Text("Pretraga"),
          ),
        ],
      ),
    );
  }

  Widget _buildDataListView() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: const [
          DataColumn(
            label: Text('ID', style: TextStyle(fontStyle: FontStyle.italic)),
          ),
          DataColumn(
            label: Text('Količina', style: TextStyle(fontStyle: FontStyle.italic)),
          ),
          DataColumn(
            label: Text('Cijena', style: TextStyle(fontStyle: FontStyle.italic)),
          ),
          DataColumn(
            label: Text('Naziv Jela', style: TextStyle(fontStyle: FontStyle.italic)),
          ),
          DataColumn(
            label: Text('Datum Narudžbe', style: TextStyle(fontStyle: FontStyle.italic)),
          ),

        ],
        rows: stavkeResult?.result.map((StavkeNarudzbe e) {
          String nazivJela = jeloMap[e.jeloId.toString()] ?? 'Nepoznato';
          String datumNarudzbe = narudzbaMap[e.narudzbaId.toString()] ?? 'Nepoznato';

          print('Red: ID: ${e.id}, Količina: ${e.kolicina}, Cijena: ${e.cijena}, Jelo ID: ${e.jeloId}, Naziv Jela: $nazivJela, Datum narudzbe:$datumNarudzbe');
          return DataRow(
            cells: [
              DataCell(Text(e.id?.toString() ?? '')),
              DataCell(Text(e.kolicina?.toString() ?? '')),
              DataCell(Text(e.cijena != null ? e.cijena!.toStringAsFixed(2) : '')),
              DataCell(Text(nazivJela)),
              DataCell(Text(datumNarudzbe)),
              
            ],
          );
        }).toList() ?? [],
      ),
    );
  }
}
