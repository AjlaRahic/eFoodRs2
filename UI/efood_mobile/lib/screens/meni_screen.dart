import 'dart:convert';

import 'package:efood_mobile/models/jelo.dart';
import 'package:efood_mobile/models/search_result.dart';
import 'package:efood_mobile/providers/jelo_provider.dart';
import 'package:efood_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import '../models/kategorija.dart';
import '../providers/kategorija_provider.dart';
import 'package:provider/provider.dart';
import 'product_details_screen.dart';

class MeniScreen extends StatefulWidget {
  const MeniScreen({Key? key}) : super(key: key);

  @override
  State<MeniScreen> createState() => _MeniScreenState();
}

class _MeniScreenState extends State<MeniScreen> {
  late KategorijaProvider _kategorijaProvider;
  late ProductProvider _jeloProvider;
  SearchResult<Kategorija>? result;
  SearchResult<Jelo>? jeloResult;

  final TextEditingController _nazivController = TextEditingController();
  Kategorija? _odabranaKategorija;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _kategorijaProvider = context.read<KategorijaProvider>();
    _jeloProvider = context.read<ProductProvider>();
    _fetchKategorije();
    _fetchJela();
  }

  Future<void> _fetchKategorije() async {
    final data = await _kategorijaProvider.get();
    setState(() => result = data);
  }

  Future<void> _fetchJela() async {
    final data = await _jeloProvider.get();
    setState(() => jeloResult = data);
  }

  Future<void> _searchJela() async {
    final filter = <String, dynamic>{};

    if (_nazivController.text.isNotEmpty) {
      filter['naziv'] = _nazivController.text;
    }
    if (_odabranaKategorija != null) {
      filter['kategorijaId'] = _odabranaKategorija!.kategorijaId;
    }
    var data = await _jeloProvider.get(filter: filter);

    setState(() => jeloResult = data);
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Meni",
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF4E4D9),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nazivController,
                        decoration: InputDecoration(
                          labelText: "Pretraži jela",
                          filled: true,
                          fillColor: Colors.white,
                          labelStyle:
                              const TextStyle(color: Color(0xFF4E3629)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (_) => _searchJela(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _searchJela,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8D6E63),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Traži",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Kategorija>(
                  value: _odabranaKategorija,
                  hint: const Text("Odaberi kategoriju"),
                  items: result?.result
                          .map(
                            (k) => DropdownMenuItem(
                              value: k,
                              child: Text(k.naziv ?? ""),
                            ),
                          )
                          .toList() ??
                      [],
                  onChanged: (value) {
                    setState(() => _odabranaKategorija = value);
                    _searchJela();
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _nazivController.clear();
                      _odabranaKategorija = null;
                      _fetchJela();
                      setState(() {});
                    },
                    child: const Text(
                      "Resetuj filtere",
                      style: TextStyle(color: Color(0xFF8D6E63)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: jeloResult?.result.length ?? 0,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 20,
                  childAspectRatio: 3 / 2,
                  mainAxisExtent: 260,
                ),
                itemBuilder: (context, index) {
                  final jelo = jeloResult!.result[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(jelo: jelo),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: (jelo.slika != null &&
                                        jelo.slika!.isNotEmpty)
                                    ? Image.memory(
                                        base64Decode(jelo.slika!),
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                            child: Text("Nema slike")),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              jelo.naziv ?? "",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${jelo.cijena!.toStringAsFixed(2)} KM",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8D6E63),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              jelo.opis ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
