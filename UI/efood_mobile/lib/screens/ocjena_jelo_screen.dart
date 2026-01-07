import 'package:efood_mobile/models/dojmovi.dart';
import 'package:efood_mobile/models/jelo.dart';
import 'package:efood_mobile/models/korisnik.dart';
import 'package:efood_mobile/providers/dojmovi_provider.dart';
import 'package:efood_mobile/providers/jelo_provider.dart';
import 'package:efood_mobile/providers/korisnik_provider.dart';
import 'package:efood_mobile/screens/preporuceni_screen.dart';
import 'package:efood_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class OcjenaJeloScreen extends StatefulWidget {
  final Dojmovi? dojmovi;
  final Jelo? jelo; 

  const OcjenaJeloScreen({Key? key, this.dojmovi, this.jelo}) : super(key: key);

  @override
  State<OcjenaJeloScreen> createState() => _OcjenaJeloScreenState();
}

class _OcjenaJeloScreenState extends State<OcjenaJeloScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  late KorisnikProvider _korisnikProvider;
  late DojmoviProvider _dojmoviProvider;
  late ProductProvider _productProvider;

  List<Jelo>? _jela;

  String? _selectedJeloId;
  int? _selectedOcjena;

  late Map<String, dynamic> _initialValue;
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    _initialValue = {
      'ocjena': widget.dojmovi?.ocjena,
      'opis': widget.dojmovi?.opis,
      'korisnikId': widget.dojmovi?.korisnikId?.toString(),
      'jeloId': widget.dojmovi?.jeloId?.toString() ?? widget.jelo?.jeloId?.toString(),
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bootstrapped) return;
    _bootstrapped = true;

    _dojmoviProvider = context.read<DojmoviProvider>();
    _korisnikProvider = context.read<KorisnikProvider>();
    _productProvider = context.read<ProductProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _korisnikProvider.loadCurrentUser().catchError((_) {});
      try {
        final jelaRes = await _productProvider.get();
        setState(() => _jela = jelaRes.result);
      } catch (e) {
        debugPrint('Error fetching jelo: $e');
      }

      final me = _korisnikProvider.currentUser;
      if (me != null) {
        _formKey.currentState?.fields['korisnikId']?.didChange(me.id.toString());
      }
      setState(() {});
    });
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      final validationErrors = _formKey.currentState?.errors;
      debugPrint('Validation errors: $validationErrors');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provjerite formu i pokušajte ponovo.')),
      );
      return;
    }

    final formData = Map<String, dynamic>.from(_formKey.currentState!.value);

    formData['ocjena'] = (formData['ocjena'] is int)
        ? formData['ocjena']
        : int.tryParse(formData['ocjena'].toString()) ?? 0;

    formData['jeloId'] = (formData['jeloId'] is int)
        ? formData['jeloId']
        : int.tryParse(formData['jeloId'].toString()) ?? 0;

    formData['korisnikId'] = _korisnikProvider.currentUser?.id;

    try {
      String msg;
      if (widget.dojmovi == null) {
        await _dojmoviProvider.insert(Dojmovi.fromJson(formData));
        msg = 'Ocjena uspješno dodana.';
      } else {
        await _dojmoviProvider.update(
          widget.dojmovi!.id!,
          Dojmovi.fromJson(formData),
        );
        msg = 'Ocjena uspješno uređena.';
      }

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Uspjeh'),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => RecommendedJeloScreen()),
                );
              },
              child: const Text('Preporučeno jelo'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error saving rating: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška pri spremanju ocjene. Pokušajte ponovo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<KorisnikProvider>().currentUser;

    final String? prefilledJeloId = _initialValue['jeloId']?.toString();

    return MasterScreenWidget(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            initialValue: _initialValue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ocijenite jelo', style: TextStyle(color: Colors.black, fontSize: 24)),
                const SizedBox(height: 4),
                Text(
                  '${me?.ime ?? "Nepoznat korisnik"}, dobrodošli u sekciju za dodavanje vaše ocjene.',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 12),

                Offstage(
                  offstage: true,
                  child: FormBuilderTextField(
                    name: 'korisnikId',
                    initialValue: me?.id.toString(),
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Korisnik (ID)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (prefilledJeloId != null && prefilledJeloId.isNotEmpty) ...[
                  Offstage(
                    offstage: true,
                    child: FormBuilderTextField(
                      name: 'jeloId',
                      initialValue: prefilledJeloId,
                      readOnly: true,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Jelo',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      widget.jelo?.naziv ??
                          (_jela?.firstWhere(
                            (x) => (x.jeloId?.toString() == prefilledJeloId),
                          ).naziv ?? 'Jelo #$prefilledJeloId'),
                    ),
                  ),
                ] else ...[
                  FormBuilderDropdown<String>(
                    name: 'jeloId',
                    decoration: const InputDecoration(
                      labelText: 'Jelo',
                      border: OutlineInputBorder(),
                    ),
                    items: (_jela ?? [])
                        .map((j) => DropdownMenuItem<String>(
                              value: j.jeloId.toString(),
                              child: Text(j.naziv ?? ''),
                            ))
                        .toList(),
                    initialValue: _initialValue['jeloId']?.toString(),
                    onChanged: (value) {
                      setState(() => _selectedJeloId = value);
                      debugPrint('Odabrani jeloId: $_selectedJeloId');
                    },
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Ovo polje je obavezno!' : null,
                  ),
                ],
                const SizedBox(height: 16),

                FormBuilderDropdown<int>(
                  name: 'ocjena',
                  decoration: const InputDecoration(
                    labelText: 'Ocjena',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(5, (i) {
                    final rating = i + 1;
                    return DropdownMenuItem<int>(
                      value: rating,
                      child: Text(rating.toString()),
                    );
                  }),
                  initialValue: _initialValue['ocjena'],
                  onChanged: (value) {
                    setState(() => _selectedOcjena = value);
                    debugPrint('Odabrana ocjena: $value');
                  },
                  validator: (value) => value == null ? 'Ovo polje je obavezno!' : null,
                ),
                const SizedBox(height: 16),

                FormBuilderTextField(
                  name: 'opis',
                  decoration: const InputDecoration(
                    labelText: 'Opis',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => (value == null || value.isEmpty) ? 'Ovo polje je obavezno!' : null,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Dodaj', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
