import 'package:efood_admin/models/kategorija.dart';
import 'package:efood_admin/providers/kategorija_provider.dart';
import 'package:efood_admin/screens/kategorija_screen_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/search_result.dart';
import '../widgets/master_screen.dart';

class KategorijaListScreen extends StatefulWidget {
  const KategorijaListScreen({Key? key}) : super(key: key);

  @override
  State<KategorijaListScreen> createState() => _KategorijaListScreen();
}

class _KategorijaListScreen extends State<KategorijaListScreen> {
  late KategorijaProvider _kategorijaProvider;
  SearchResult<Kategorija>? result;
  final TextEditingController _nazivController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _kategorijaProvider = context.read<KategorijaProvider>();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      var data = await _kategorijaProvider.get();
      print('Fetched data: ${data.result}');
      setState(() {
        result = data;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title_widget: const Text("Kategorija List"),
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
              decoration: const InputDecoration(labelText: "naziv"),
              controller: _nazivController,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              try {
                var data = await _kategorijaProvider.get(filter: {
                  'naziv': _nazivController.text,
                });
                print('Search result: ${data.result}');
                setState(() {
                  result = data;
                });
              } catch (e) {
                print('Error during search: $e');
              }
            },
            child: const Text("Pretraga"),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>  KategorijaDetailScreen(kategorija: null),
                ),
              );
            },
            child: const Text("Dodaj"),
          ),
        ],
      ),
    );
  }

  Widget _buildDataListView() {
  print('Result: ${result?.result}');
  return SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: DataTable(
      columns: const [
        DataColumn(
          label: Text('ID', style: TextStyle(fontStyle: FontStyle.italic)),
        ),
        DataColumn(
          label: Text('Naziv', style: TextStyle(fontStyle: FontStyle.italic)),
        ),
        DataColumn(
          label: Text('Opis', style: TextStyle(fontStyle: FontStyle.italic)),
        ),
      ],
      rows: result?.result
              .map((Kategorija e) {
                print('Row data: ID: ${e.kategorijaId}, Naziv: ${e.naziv}, Cijena: ${e.opis}');
                return DataRow(
                  onSelectChanged: (selected) {
                    if (selected == true) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => KategorijaDetailScreen(kategorija: e),
                        ),
                      );
                    }
                  },
                 
                  cells: [
                    DataCell(Text(e.kategorijaId?.toString() ?? '')),
                    DataCell(Text(e.naziv ?? '')),
                    DataCell(Text(e.opis ?? '')),
                  ],
                );
              })
              .toList() ??
          [],
    ),
  );
}
}

