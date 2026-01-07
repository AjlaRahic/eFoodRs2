import 'package:efood_admin/models/kategorija.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/jelo.dart';
import '../models/search_result.dart';
import '../providers/jelo_provider.dart';
import '../screens/product_detail_screen.dart';
import '../widgets/master_screen.dart';
import 'dart:convert';

class ProductListScreen extends StatefulWidget {
  final Kategorija? kategorija;

  const ProductListScreen({Key? key, this.kategorija}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late ProductProvider _productProvider;
  SearchResult<Jelo>? result;
  final TextEditingController _nazivController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider = context.read<ProductProvider>();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      var data = await _productProvider.get();
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
      title_widget: Text(
        widget.kategorija != null
            ? "Proizvodi za ${widget.kategorija!.naziv}"
            : "Lista Proizvoda",
        style: TextStyle(
            color: Colors.purple[700], fontWeight: FontWeight.bold, fontSize: 24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildSearch(),
            Expanded(child: _buildDataListView()),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(jelo: null),
                    ),
                  )
                      .then((_) {
                    _fetchInitialData();
                  });
                },
                child: const Text(
                  "Dodaj",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
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
              decoration: InputDecoration(
                  labelText: "Naziv",
                  border: UnderlineInputBorder(),
                  filled: true,
                  fillColor: Color.fromARGB(255, 255, 255, 255),
                  labelStyle: TextStyle(color: Color.fromARGB(255, 3, 3, 3))),
              controller: _nazivController,
              style: TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () async {
              try {
                var data = await _productProvider.get(filter: {
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
            child: const Text(
              "Pretraga",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildDataListView() {
    final filteredResults = widget.kategorija != null
        ? result?.result
            .where(
                (jelo) => jelo.kategorijaId == widget.kategorija!.kategorijaId)
            .toList()
        : result?.result ?? [];

    final searchQuery = _nazivController.text.toLowerCase();
    final finalResults = searchQuery.isNotEmpty
        ? filteredResults
            ?.where((jelo) => jelo.naziv!.toLowerCase().contains(searchQuery))
            .toList()
        : filteredResults;

    if (finalResults == null || finalResults.isEmpty) {
      return const Center(child: Text('Nema proizvoda za prikaz'));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 3 / 2,
      ),
      itemCount: finalResults.length,
      itemBuilder: (context, index) {
        final e = finalResults[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(jelo: e),
                ),
              )
                  .then((_) {
                _fetchInitialData();
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: e.slika != null && e.slika!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(e.slika!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(child: Text('Nema slike')),
                          ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.naziv ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.purple, // ljubičasto
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    e.cijena != null
                        ? '${e.cijena!.toStringAsFixed(2)} KM'
                        : '',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.purple),
                        onPressed: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(jelo: e),
                            ),
                          )
                              .then((_) {
                            _fetchInitialData();
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Potvrda brisanja"),
                              content: Text(
                                  "Da li ste sigurni da želite obrisati proizvod \"${e.naziv}\"?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Ne"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Da"),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            try {
                              await _productProvider.delete(e.jeloId!);
                              _fetchInitialData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Proizvod \"${e.naziv}\" je uspješno obrisan.")),
                              );
                            } catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Greška prilikom brisanja proizvoda: $error")),

                              );
                            }
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
