
import 'package:efood_mobile/models/kategorija.dart';
import 'package:efood_mobile/providers/cart_provider.dart';
import 'package:efood_mobile/providers/meni_provider.dart';
import 'package:efood_mobile/screens/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/jelo.dart';
import '../models/search_result.dart';
import '../widgets/master_screen.dart';
import 'dart:convert';
import 'dart:typed_data'; 

class ProductListScreen extends StatefulWidget {
  final Kategorija? kategorija;

  const ProductListScreen({Key? key, this.kategorija}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late MeniProvider _productProvider;
  SearchResult<Jelo>? result;
  final TextEditingController _nazivController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productProvider = context.read<MeniProvider>();
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
        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 24),
      ),
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
              decoration: InputDecoration(
                labelText: "Naziv",
                labelStyle: TextStyle(color: Colors.orange),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              controller: _nazivController,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
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
            child: const Text("Pretraga"),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () {
              /*Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(jelo: ),
                ),
              ).then((_) {
                _fetchInitialData();
              });*/
            },
            child: const Text("Dodaj"),
          ),
        ],
      ),
    );
  }

 Widget _buildDataListView() {
  print('Result: ${result?.result}');
  
  final filteredResults = widget.kategorija != null 
      ? result?.result.where((jelo) => jelo.kategorijaId == widget.kategorija!.kategorijaId).toList() 
      : result?.result ?? [];

  final searchQuery = _nazivController.text.toLowerCase();
  final finalResults = searchQuery.isNotEmpty
      ? filteredResults?.where((jelo) => jelo.naziv!.toLowerCase().contains(searchQuery)).toList()
      : filteredResults;

  return ListView.builder(
    itemCount: finalResults?.length ?? 0,
    itemBuilder: (context, index) {
      Jelo e = finalResults![index];
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(jelo: e),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.naziv ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  e.cijena != null ? '${e.cijena!.toStringAsFixed(2)} RSD' : 'Cena nije dostupna',
                ),
                const SizedBox(height: 8),
                e.slika != null && e.slika!.isNotEmpty
                    ? Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: MemoryImage(base64Decode(e.slika!)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : const Text('Nema slike'),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    context.read<CartProvider>().insert(e);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${e.naziv} added to cart!")),
                    );
                  },
                  child: const Text("Dodaj u korpu"),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


}
