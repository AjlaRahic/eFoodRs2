import 'dart:convert';
import 'package:efood_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:efood_admin/models/jelo.dart';
import 'package:efood_admin/models/search_result.dart';
import 'package:efood_admin/models/kategorija.dart';

import 'package:efood_admin/providers/jelo_provider.dart';
import 'package:efood_admin/providers/kategorija_provider.dart';

import 'package:efood_admin/screens/product_detail_screen.dart';

class MeniScreen extends StatefulWidget {
  const MeniScreen({Key? key}) : super(key: key);

  @override
  State<MeniScreen> createState() => _MeniScreenState();
}

class _MeniScreenState extends State<MeniScreen> {
  late KategorijaProvider _kategorijaProvider;
  late ProductProvider _jeloProvider;

  SearchResult<Kategorija>? _kategorije;
  SearchResult<Jelo>? _jela;

  final TextEditingController _nazivController = TextEditingController();
  int? _selectedKategorijaId;

  final Color primaryColor = const Color(0xFF9C27B0); // tamno ljubičasta

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _kategorijaProvider = context.read<KategorijaProvider>();
    _jeloProvider = context.read<ProductProvider>();

    _fetchKategorije();
    _fetchJela();
  }

  Future<void> _fetchKategorije() async {
    try {
      final data = await _kategorijaProvider.get();
      setState(() {
        _kategorije = data;
        if (_selectedKategorijaId != null &&
            !((_kategorije?.result ?? [])
                .any((k) => k.kategorijaId == _selectedKategorijaId))) {
          _selectedKategorijaId = null;
        }
      });
    } catch (e) {
      debugPrint('Greška pri dohvaćanju kategorija: $e');
    }
  }

  Future<void> _fetchJela() async {
    try {
      final data = await _jeloProvider.get();
      setState(() => _jela = data);
    } catch (e) {
      debugPrint('Greška pri dohvaćanju jela: $e');
    }
  }

  Future<void> _searchJela() async {
    try {
      final filter = <String, dynamic>{};
      if (_nazivController.text.isNotEmpty) {
        filter['Naziv'] = _nazivController.text;
      }
      if (_selectedKategorijaId != null) {
        filter['KategorijaId'] = _selectedKategorijaId;
      }
      final data = await _jeloProvider.get(filter: filter);
      setState(() => _jela = data);
    } catch (e) {
      debugPrint('Greška pri pretrazi: $e');
    }
  }

  ImageProvider? _imageForJelo(Jelo j) {
    final raw = j.slika;
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http')) return NetworkImage(raw);
    try {
      final bytes = base64Decode(raw);
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _jela?.result ?? [];
    final kategorije = _kategorije?.result ?? [];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    
                    TextField(
                      controller: _nazivController,
                      decoration: const InputDecoration(
                        labelText: "Pretraži jela",
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _searchJela(),
                    ),
                    const SizedBox(height: 12),

                    
                    DropdownButtonFormField<int>(
                      value: _selectedKategorijaId,
                      hint: const Text("Odaberi kategoriju"),
                      items: kategorije
                          .map(
                            (k) => DropdownMenuItem<int>(
                              value: k.kategorijaId,
                              child: Text(k.naziv ?? "Bez naziva"),
                            ),
                          )
                          .toList(),
                      onChanged: (newId) {
                        setState(() => _selectedKategorijaId = newId);
                        _searchJela();
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                  
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _searchJela,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              "Pretraži",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _selectedKategorijaId = null;
                                _nazivController.clear();
                              });
                              await _fetchJela();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              "Resetuj filtere",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

           
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 3 / 2,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final jelo = items[index];
                    final imgProvider = _imageForJelo(jelo);

                    return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: InkWell(
                          onTap: () async {
                            final changed = Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(
                                  jelo: jelo,
                                  onProductUpdated: () async {
                                    await _fetchJela();
                                  },
                                ),
                              ),
                            );
                          },
                          hoverColor: primaryColor.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        color: Colors.grey.shade200,
                                        width: double.infinity,
                                        child: imgProvider != null
                                            ? Image(
                                                image: imgProvider,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                errorBuilder: (c, e, s) =>
                                                    const Center(
                                                  child: Icon(
                                                      Icons.broken_image,
                                                      size: 40,
                                                      color: Color(0xFF9C27B0)),
                                                ),
                                              )
                                            : const Center(
                                                child: Icon(Icons.fastfood,
                                                    size: 50,
                                                    color: Color(0xFF9C27B0)),
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    jelo.naziv ?? "Nepoznato jelo",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    jelo.cijena != null
                                        ? '${jelo.cijena!.toStringAsFixed(2)} KM'
                                        : 'Nepoznata cijena',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () async {
                                          final confirmed =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                  "Potvrda brisanja"),
                                              content: Text(
                                                'Da li ste sigurni da želite obrisati jelo "${jelo.naziv}"?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(false),
                                                  child: const Text("Otkaži"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                  ),
                                                  child: const Text("Obriši"),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirmed == true) {
                                            try {
                                              await _jeloProvider
                                                  .delete(jelo.jeloId!);
                                              await _fetchJela();
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Jelo "${jelo.naziv}" je obrisano.',
                                                  ),
                                                ),
                                              );
                                            } catch (e) {
                                              debugPrint(
                                                  "Greška prilikom brisanja: $e");
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Greška prilikom brisanja jela."),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ]),
                          ),
                        ));
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

           
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final changed = await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => ProductDetailScreen()),
                  );
                  if (changed) {
                    await _fetchJela();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Dodaj jelo",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
