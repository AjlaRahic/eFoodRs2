import 'dart:convert';
import 'package:efood_mobile/models/korisnik.dart';
import 'package:efood_mobile/providers/korisnik_provider.dart';
import 'package:efood_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import '../models/search_result.dart';
import 'package:image_picker/image_picker.dart';

class KorisnikDetailsScreen extends StatefulWidget {
  final Korisnik? korisnik;
  final Function()? onKorisnikUpdated;

  const KorisnikDetailsScreen({Key? key, this.korisnik, this.onKorisnikUpdated})
      : super(key: key);

  @override
  State<KorisnikDetailsScreen> createState() => _KorisnikDetailsScreenState();
}

class _KorisnikDetailsScreenState extends State<KorisnikDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late KorisnikProvider _korisnikProvider;

  SearchResult<Korisnik>? korisnikResults;
  bool isLoading = true;
  String? _base64Image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _korisnikProvider = context.read<KorisnikProvider>();
    initForm();
  }

  Future<void> initForm() async {
    korisnikResults = await _korisnikProvider.get();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: widget.korisnik?.ime ?? "Detalji korisnika",
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            isLoading ? const CircularProgressIndicator() : _buildForm(),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D6E63),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    var request = Map.from(_formKey.currentState!.value);
                    request['slika'] = _base64Image;

                    try {
                      if (widget.korisnik == null) {
                        await _korisnikProvider.insert(request);
                        _showSnackbar("Korisnik je uspješno dodan.");
                      } else {
                        await _korisnikProvider.update(
                          widget.korisnik!.id!,
                          request,
                        );
                        _showSnackbar("Korisnik je uspješno uređen.");
                      }

                      widget.onKorisnikUpdated?.call();
                      Navigator.of(context).pop();
                    } catch (e) {
                      _showErrorDialog(e.toString());
                    }
                  }
                },
                child: Text(
                  widget.korisnik == null ? "Sačuvaj" : "Uredi",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  FormBuilder _buildForm() {
    return FormBuilder(
      key: _formKey,
      initialValue: {
        'ime': widget.korisnik?.ime,
        'prezime': widget.korisnik?.prezime,
        'korisnickoIme': widget.korisnik?.korisnickoIme,
        'telefon': widget.korisnik?.telefon,
        'email': widget.korisnik?.email,
      },
      child: Column(
        children: [
          _inputField("ime", "Ime"),
          const SizedBox(height: 16),
          _inputField("prezime", "Prezime"),
          const SizedBox(height: 16),
          _inputField("korisnickoIme", "Korisničko ime"),
          const SizedBox(height: 16),
          _inputField("telefon", "Telefon"),
          const SizedBox(height: 16),
          _inputField("email", "Email"),
        ],
      ),
    );
  }

  Widget _inputField(String name, String label) {
    return FormBuilderTextField(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Color(0xFF8D6E63)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Greška",
          style: TextStyle(color: Color(0xFF8D6E63)),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(color: Color(0xFF8D6E63)),
            ),
          )
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF8D6E63),
      ),
    );
  }
}
