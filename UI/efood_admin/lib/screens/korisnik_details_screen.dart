import 'package:efood_admin/providers/korisnik_provider.dart';
import 'package:efood_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:efood_admin/models/korisnik.dart';
import 'package:provider/provider.dart';

class KorisniciDetailsScreen extends StatefulWidget {
  final Korisnik? korisnik;
  KorisniciDetailsScreen({Key? key, this.korisnik}) : super(key: key);

  @override
  State<KorisniciDetailsScreen> createState() => _KorisniciDetailsScreenState();
}

class _KorisniciDetailsScreenState extends State<KorisniciDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late KorisnikProvider _korisnikProvider;
  late Map<String, dynamic> _initialValue;

  @override
  void initState() {
    super.initState();
    _initialValue = {
      'ime': widget.korisnik?.ime,
      'prezime': widget.korisnik?.prezime,
      'korisnickoIme': widget.korisnik?.korisnickoIme,
      'telefon': widget.korisnik?.telefon,
      'email': widget.korisnik?.email,
      'korisnikUlogas': widget.korisnik?.korisniciUloges ?? [],
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _korisnikProvider = context.read<KorisnikProvider>();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.saveAndValidate()) {
      Map<String, dynamic> formData = Map.from(_formKey.currentState!.value);

      try {
        if (widget.korisnik == null) {
          await _korisnikProvider.insert(Korisnik.fromJson(formData));
          _showSuccessDialog('Korisnik uspješno dodan.');
        } else {
          await _korisnikProvider.update(
              widget.korisnik!.id!, Korisnik.fromJson(formData));
          _showSuccessDialog('Podaci korisnika uspješno uređeni.', popParent: true);
        }
      } catch (e) {
        print('Error: $e');
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text("Greška"),
            content: Text(
                "Neuspješno spremanje korisnika. Pokušajte ponovo: ${e.toString()}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showSuccessDialog(String message, {bool popParent = false}) {
    final rootContext = context;

    showDialog(
      context: rootContext,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Uspješno'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              if (popParent) {
                Navigator.of(rootContext).pop(true);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                Text(
                  widget.korisnik != null
                      ? 'Uredi profil korisnika'
                      : 'Dodaj novi korisnik',
                  style: TextStyle(
                    color: Colors.purple[700],
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24),
                _buildFormField("Ime korisnika", "ime", Icons.person),
                SizedBox(height: 16),
                _buildFormField("Prezime korisnika", "prezime", Icons.person_outline),
                SizedBox(height: 16),
                _buildFormField("Korisničko ime", "korisnickoIme", Icons.account_circle),
                SizedBox(height: 16),
                _buildFormField("Telefon", "telefon", Icons.phone),
                SizedBox(height: 16),
                _buildFormField("Email", "email", Icons.email),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.purple[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    widget.korisnik == null ? 'Dodaj' : 'Spasi',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      title: widget.korisnik != null
          ? "Korisnik: ${widget.korisnik?.ime}"
          : "Detalji korisnika",
    );
  }

  Widget _buildFormField(String label, String name, IconData icon,
      {bool obscureText = false}) {
    return FormBuilderTextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueGrey[800]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(icon, color: Colors.purple[400]),
      ),
      name: name,
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ovo polje je obavezno';
        }
        return null;
      },
    );
  }
}
