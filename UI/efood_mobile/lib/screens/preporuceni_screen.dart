import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:efood_mobile/models/jelo.dart';
import 'package:efood_mobile/providers/meni_provider.dart';
import 'package:efood_mobile/widgets/master_screen.dart';

class RecommendedJeloScreen extends StatefulWidget {
  const RecommendedJeloScreen({Key? key}) : super(key: key);

  @override
  State<RecommendedJeloScreen> createState() => _RecommendedJeloScreenState();
}

class _RecommendedJeloScreenState extends State<RecommendedJeloScreen> {
  final MeniProvider _jeloProvider = MeniProvider();
  List<Jelo> _jela = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchJelo();
  }

  Future<void> _fetchJelo() async {
    try {
      final data = await _jeloProvider.fetchRecommendedJelo();
      setState(() {
        _jela = data ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Greška pri dohvaćanju: $e';
        _loading = false;
      });
    }
  }

  String? _extractReason(Jelo j) {
    final t = j as dynamic;

    final candidates = [
      tryCastString(() => t.reasonText),
      tryCastString(() => t.ReasonText),
      tryCastString(() => t.razlog),
      tryCastString(() => t.Razlog),
      tryCastString(() => t.opisPreporuke),
      tryCastString(() => t.OpisPreporuke),
      tryCastString(() => t.opis),
      tryCastString(() => t.Opis),
      tryCastString(() => t.napomena),
      tryCastString(() => t.Napomena),
    ].where((s) => s != null && s!.trim().isNotEmpty).cast<String>();

    if (candidates.isNotEmpty) return candidates.first;

    final naziv = j.naziv ?? '';
    final sepIndex = naziv.indexOf(' • ');
    if (sepIndex > 0 && sepIndex + 3 < naziv.length) {
      return naziv.substring(sepIndex + 3).trim();
    }

    return null;
  }

  String _baseName(Jelo j) {
    final naziv = j.naziv ?? '';
    final sepIndex = naziv.indexOf(' • ');
    return sepIndex > 0 ? naziv.substring(0, sepIndex).trim() : naziv;
  }

  Uint8List? _img(Jelo j) {
    final s = j.slika;
    if (s == null || s.isEmpty) return null;
    try {
      return base64Decode(s);
    } catch (_) {
      return null;
    }
  }

  String _catOf(Jelo j) {
    final d = j as dynamic;
    final rel = tryCastString(() => d.kategorija?.naziv);
    final flat = tryCastString(() => d.kategorijaNaziv);
    final tip = tryCastString(() => d.vrsta) ?? tryCastString(() => d.tip);
    return (rel ?? flat ?? tip ?? 'Ostalo').toString();
  }

  num? _priceOf(Jelo j) {
    final d = j as dynamic;
    return tryCastNum(() => d.cijena) ??
        tryCastNum(() => d.cijenaBAM) ??
        tryCastNum(() => d.price);
  }

  double? _ratingOf(Jelo j) {
    final d = j as dynamic;
    final v = tryCastNum(() => d.prosjecnaOcjena) ??
        tryCastNum(() => d.rating) ??
        tryCastNum(() => d.avgRating);
    return v?.toDouble();
  }

  Widget _stars(double rating) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < full
              ? Icons.star_rounded
              : (i == full && half
                  ? Icons.star_half_rounded
                  : Icons.star_border_rounded),
          size: 16,
          color: const Color(0xFFFFB300),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Preporučena jela",
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _jela.isEmpty
                  ? const Center(child: Text("Za sada nema preporuka."))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemCount: _jela.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _HeaderBlurb();
                        }

                        final j = _jela[index - 1];
                        final img = _img(j);
                        final baseName = _baseName(j);
                        final reason = _extractReason(j);
                        final cat = _catOf(j);
                        final price = _priceOf(j);
                        final rating = _ratingOf(j);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4)
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(14),
                                ),
                                child: img != null
                                    ? Image.memory(img,
                                        width: double.infinity,
                                        height: 160,
                                        fit: BoxFit.cover)
                                    : Container(
                                        width: double.infinity,
                                        height: 160,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                            Icons.image_not_supported_rounded,
                                            size: 32),
                                      ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 10, 12, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                            Icons.restaurant_menu_rounded,
                                            size: 18,
                                            color: Colors.black54),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            baseName.isNotEmpty
                                                ? baseName
                                                : (j.naziv ?? "Jelo"),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        _Chip(
                                            text: cat,
                                            icon: Icons.category_rounded),
                                        if (reason != null && reason.isNotEmpty)
                                          _Chip(
                                              text: reason,
                                              icon: Icons.auto_awesome_rounded,
                                              color: const Color(0xFFFFF3CD)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.attach_money_rounded,
                                            size: 18, color: Colors.black54),
                                        const SizedBox(width: 4),
                                        Text(
                                          price != null
                                              ? "${price.toString()} KM"
                                              : "Cijena na upit",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const Spacer(),
                                        if (rating != null) _stars(rating),
                                      ],
                                    ),
                                  ],
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

class _HeaderBlurb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Preporučeno za tebe",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            "Na osnovu tvojih izbora i popularnih jela.",
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? color;
  const _Chip({required this.text, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final bg = color ?? const Color(0xFFEFF3F8);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bg.withOpacity(.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

String? tryCastString(String? Function() getter) {
  try {
    final v = getter();
    if (v == null) return null;
    return v.toString();
  } catch (_) {
    return null;
  }
}

num? tryCastNum(num? Function() getter) {
  try {
    return getter();
  } catch (_) {
    return null;
  }
}
