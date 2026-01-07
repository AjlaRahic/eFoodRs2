import 'dart:convert';
import 'package:efood_mobile/providers/prilozi_provider.dart';
import 'package:efood_mobile/screens/ocjena_jelo_screen.dart';
import 'package:efood_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/jelo.dart';
import '../models/prilozi.dart';
import '../providers/cart_provider.dart';
import '../widgets/master_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Jelo jelo;
  const ProductDetailScreen({Key? key, required this.jelo}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _kolicina = 1;

  late PriloziProvider _prilogProvider;
  bool _loadingPrilozi = true;
  List<Prilozi> _prilozi = [];
  Prilozi? _selectedPrilog;

  @override
  void initState() {
    super.initState();
    _prilogProvider = context.read<PriloziProvider>();
    _loadPrilozi();
  }

  Future<void> _loadPrilozi() async {
    final res = await _prilogProvider.get();
    setState(() {
      _prilozi = res.result;
      _loadingPrilozi = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final jelo = widget.jelo;

    return MasterScreenWidget(
      title: jelo.naziv ?? "Detalji jela",
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: jelo.slika != null && jelo.slika!.isNotEmpty
                    ? Image.memory(
                        base64Decode(jelo.slika!),
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 220,
                        color: const Color(0xFFFFE0C7),
                        child: const Icon(Icons.fastfood,
                            size: 60, color: Color(0xFF8D6E63)),
                      ),
              ),
              const SizedBox(height: 20),
              Text(
                jelo.naziv ?? "",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E3629),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                jelo.opis ?? "Nema opisa",
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Text(
                "${jelo.cijena!.toStringAsFixed(2)} KM",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8D6E63),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Color(0xFF8D6E63)),
                    onPressed: () {
                      if (_kolicina > 1) {
                        setState(() => _kolicina--);
                      }
                    },
                  ),
                  Text(
                    '$_kolicina',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF8D6E63)),
                    onPressed: () => setState(() => _kolicina++),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _loadingPrilozi
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<Prilozi>(
                      value: _selectedPrilog,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: "Odaberi prilog (opcionalno)",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _prilozi
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.nazivPriloga ?? ""),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedPrilog = val),
                    ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8D6E63),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        if (Authorization.uloga == null ||
                            Authorization.uloga!.ulogaId != 2) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Nemate dozvolu za ovu akciju.")),
                          );
                          return;
                        }

                        final payload = {
                          "jeloId": jelo.jeloId,
                          "korisnikId": Authorization.userId,
                          "kolicina": _kolicina,
                          "kategorijaId": jelo.kategorijaId,
                          "cijena": jelo.cijena,
                          "prilogId": _selectedPrilog?.prilogId,
                        };

                        context.read<CartProvider>().insert(payload).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text("${jelo.naziv} dodano u korpu")),
                          );
                        });
                      },
                      child: const Text(
                        "Dodaj u korpu",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB5654D),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "Otkaži",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCBA4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            OcjenaJeloScreen(jelo: jelo),
                      ),
                    );
                  },
                  child: const Text(
                    "Ocijeni jelo",
                    style: TextStyle(
                        color: Color(0xFF4E3629), fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
