import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:efood_mobile/models/jelo.dart';
import 'package:efood_mobile/models/search_result.dart';
import 'package:efood_mobile/providers/jelo_provider.dart';
import 'package:efood_mobile/providers/prilozi_provider.dart';
import 'package:efood_mobile/screens/historija_narudzbi_screen.dart';
import 'package:efood_mobile/screens/historija_screen.dart';
import 'package:efood_mobile/screens/preporuceni_screen.dart';
import 'package:efood_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:provider/provider.dart';
import 'package:efood_mobile/providers/cart_provider.dart';
import '../models/korpa.dart';
import '../widgets/master_screen.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartProvider _cartProvider;
  late ProductProvider _jeloProvider;
  late PriloziProvider _priloziProvider;

  SearchResult<Korpa>? _korpa;
  bool _isLoading = true;
  DateTime? _selectedDate;

  static const String PAYPAL_CLIENT_ID =
      "AQN5aMhuwAxbyotTYqQDTYNBtW3W2loVRijMYLQwEjWAiacQ0qRECCkssxAPZjuHQOpBrCwYIHZP2tk9";
  static const String PAYPAL_SECRET_KEY =
      "EAWqFWQuvAWmSh8hQL2Fn0v-T7uvFepO6BKEzqzkNaSncZa8BiE9EHXIOzj4ZDYgs5BeOWi-I5e8cFfq";
  static const bool PAYPAL_SANDBOX = true;
  static const String PAYPAL_CURRENCY = "EUR";
  static const double BAM_PER_EUR = 1.95583;
  static const double EUR_PER_BAM = 1 / BAM_PER_EUR;

  @override
  void initState() {
    super.initState();
    _cartProvider = context.read<CartProvider>();
    _jeloProvider = context.read<ProductProvider>();
    _priloziProvider = context.read<PriloziProvider>();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _jeloProvider.fetchAll();
      await _priloziProvider.fetchAll();
      await _fetchInitialData();
    } catch (e) {
      debugPrint("Error loading data: $e");
      setState(() => _isLoading = false);
      _toast('Greška pri učitavanju podataka.');
    }
  }

  Future<void> _fetchInitialData() async {
    try {
      final data = await _cartProvider.get();
      setState(() {
        _korpa = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching cart data: $e');
      setState(() => _isLoading = false);
      _toast('Greška pri dohvatu korpe.');
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDatum(DateTime? dt) {
    if (dt == null) return "Odaberite datum i vrijeme dostave";
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return "$d.$m.$y $hh:$mm";
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _selectedDate ?? now.add(const Duration(hours: 1));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      helpText: 'Izaberite datum isporuke',
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );

    final withTime = pickedTime != null
        ? DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          )
        : DateTime(pickedDate.year, pickedDate.month, pickedDate.day, 12, 0);

    setState(() => _selectedDate = withTime);
  }

  double _calcSubtotalBAM() {
    if (_korpa == null) return 0;
    double sum = 0;
    for (final item in _korpa!.result) {
      final qty = (item.kolicina ?? 0);
      final price = (item.cijena ?? 0);
      sum += price * qty;
    }
    return sum;
  }

  String _to2(double v) => v.toStringAsFixed(2);
  String _bamToEurStr(double bam) => _to2(bam * EUR_PER_BAM);
  int _eurCentsFromBAM(double bam) => ((bam * EUR_PER_BAM) * 100).round();
  String _eurStrFromCents(int cents) => _to2(cents / 100.0);

  List<Map<String, dynamic>> _buildPaypalTransactions() {
    final subtotalBAM = _calcSubtotalBAM();
    if (subtotalBAM <= 0) {
      throw Exception('Korpa je prazna ili iznosi nisu postavljeni.');
    }

    int subtotalEurCents = 0;

    final items = _korpa!.result.map((item) {
      final jelo =
          _jeloProvider.items.firstWhere((x) => x.jeloId == item.jeloId);
      final int qty = (item.kolicina ?? 0);
      final double unitBAM = (item.cijena ?? 0);

      final unitEurCents = _eurCentsFromBAM(unitBAM);
      subtotalEurCents += unitEurCents * qty;

      return {
        "name": jelo.naziv ?? "Nepoznato jelo",
        "quantity": qty,
        "price": _eurStrFromCents(unitEurCents),
        "currency": PAYPAL_CURRENCY
      };
    }).toList();

    final int shippingEurCents = 0;
    final int discountCents = 0;
    final int totalEurCents =
        subtotalEurCents + shippingEurCents - discountCents;

    final subtotalStr = _eurStrFromCents(subtotalEurCents);
    final shippingStr = _eurStrFromCents(shippingEurCents);
    final totalStr = _eurStrFromCents(totalEurCents);

    return [
      {
        "amount": {
          "total": totalStr,
          "currency": PAYPAL_CURRENCY,
          "details": {
            "subtotal": subtotalStr,
            "shipping": shippingStr,
            "shipping_discount": 0
          }
        },
        "description": "Plaćanje narudžbe u efood aplikaciji",
        "item_list": {
          "items": items,
        }
      }
    ];
  }

  Future<bool> _guardDateSelected() async {
    if (_selectedDate != null) return true;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nedostaje datum'),
        content: const Text('Molimo odaberite datum isporuke prije plaćanja.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('U redu'),
          ),
        ],
      ),
    );
    return false;
  }

  Future<void> _startPaypalCheckout() async {
    if (_korpa == null || _korpa!.result.isEmpty) {
      _toast('Korpa je prazna.');
      return;
    }
    if (!await _guardDateSelected()) return;

    late final List<Map<String, dynamic>> transactions;
    try {
      transactions = _buildPaypalTransactions();
    } catch (e) {
      _toast(e.toString());
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => PaypalCheckoutView(
        sandboxMode: PAYPAL_SANDBOX,
        clientId: PAYPAL_CLIENT_ID,
        secretKey: PAYPAL_SECRET_KEY,
        transactions: transactions,
        note: "Hvala što koristite našu aplikaciju!",
        onSuccess: (Map params) async {
          final paymentId =
              (params['data']?['id'] ?? params['id'] ?? params['paymentId'])
                  ?.toString();

          final id = await _cartProvider.checkoutFromCart(
            Authorization.userId!,
            paymentId,
            datumNarudzbe: _selectedDate,
          );

          if (!mounted) return;
          _toast('Narudžba #$id kreirana!');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HistorijaScreen()),
          );
        },
        onError: (error) {
          debugPrint("PayPal onError: $error");
          _toast('Greška u plaćanju: $error');
          if (mounted) Navigator.pop(context);
        },
        onCancel: () {
          debugPrint('PayPal cancelled');
          _toast('Plaćanje otkazano');
          if (mounted) Navigator.pop(context);
        },
      ),
    ));
  }

  Future<void> _startCashCheckout() async {
    if (_korpa == null || _korpa!.result.isEmpty) {
      _toast('Korpa je prazna.');
      return;
    }
    if (!await _guardDateSelected()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Plaćanje gotovinom'),
        content:
            const Text('Želite li potvrditi narudžbu sa plaćanjem gotovinom?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Odustani')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Potvrdi')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final id = await _cartProvider.checkoutFromCart(
        Authorization.userId!,
        null,
        datumNarudzbe: _selectedDate,
      );
      if (!mounted) return;
      _toast('Narudžba #$id kreirana (gotovina).');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OrdersScreen()),
      );
    } catch (e) {
      _toast('Greška pri kreiranju narudžbe: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotalBAM = _calcSubtotalBAM();
    final subtotalEUR = _bamToEurStr(subtotalBAM);
    final canCheckout =
        !_isLoading && _korpa != null && _korpa!.result.isNotEmpty;

    return WillPopScope(
      onWillPop: () async => false,
      child: MasterScreenWidget(
        title: "Moja korpa",
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_korpa == null || _korpa!.result.isEmpty)
                ? const Center(child: Text("Vaša korpa je prazna"))
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: _DateChip(
                          label: _formatDatum(_selectedDate),
                          onTap: _pickDate,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: _DetailsCard(
                          rows: [
                            _DetailRowData(
                              icon: Icons.timelapse_rounded,
                              title: "Artikala",
                              subtitle: "${_korpa!.result.length}",
                            ),
                            _DetailRowData(
                              icon: Icons.shopping_bag_rounded,
                              title: "Ukupno (KM)",
                              subtitle: subtotalBAM.toStringAsFixed(2),
                            ),
                            _DetailRowData(
                              icon: Icons.payments_rounded,
                              title: "≈ u EUR",
                              subtitle: subtotalEUR,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            ..._korpa!.result.map((item) {
                              final jelo = _jeloProvider.items
                                  .firstWhere((x) => x.jeloId == item.jeloId);
                              final prilog = (item.prilogId != null)
                                  ? _priloziProvider.items.firstWhereOrNull(
                                      (x) => x.prilogId == item.prilogId)
                                  : null;
                              final nazivPriloga =
                                  prilog?.nazivPriloga ?? "Bez priloga";
                              final qty = item.kolicina ?? 0;
                              final unitBAM = item.cijena ?? 0;
                              final lineTotalBAM = unitBAM * qty;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _CartLine(
                                  title: jelo.naziv ?? "Nepoznato jelo",
                                  subtitle:
                                      "$nazivPriloga · $qty x ${unitBAM.toStringAsFixed(2)} KM",
                                  trailing:
                                      "${lineTotalBAM.toStringAsFixed(2)} KM",
                                  imageBytes: (jelo.slika != null &&
                                          jelo.slika!.isNotEmpty)
                                      ? base64Decode(jelo.slika!)
                                      : null,
                                  onDelete: () async {
                                    await _cartProvider.delete(item.korpaId);
                                    await _fetchInitialData();
                                  },
                                ),
                              );
                            }),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                              child: _RecommendationBanner(
                                text: "Drugi trenutno gledaju ove artikle",
                                actionText: "Vidi preporuke",
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RecommendedJeloScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed:
                                      canCheckout ? _startCashCheckout : null,
                                  child: const Text('Plati gotovinom'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      canCheckout ? _startPaypalCheckout : null,
                                  child: const Text('Plati sa PayPal'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

// --- Helper Widgets ---

class _DateChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _DateChip({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.date_range_rounded, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

class _DetailRowData {
  final IconData icon;
  final String title;
  final String subtitle;
  _DetailRowData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _DetailsCard extends StatelessWidget {
  final List<_DetailRowData> rows;

  const _DetailsCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ...rows.map((row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(row.icon, size: 20),
                      const SizedBox(width: 8),
                      Text("${row.title}: ",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(row.subtitle),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class _CartLine extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final Uint8List? imageBytes;
  final VoidCallback? onDelete;

  const _CartLine({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.imageBytes,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // **Ovdje nema color, koristi default cardColor iz teme**
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            imageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(imageBytes!,
                        width: 60, height: 60, fit: BoxFit.cover),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    child: const Center(child: Text('Nema slike')),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            Text(trailing, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (onDelete != null)
              IconButton(
                  onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
          ],
        ),
      ),
    );
  }
}

class _RecommendationBanner extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback? onPressed;

  const _RecommendationBanner(
      {required this.text, required this.actionText, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(text),
        trailing: TextButton(onPressed: onPressed, child: Text(actionText)),
      ),
    );
  }
}
