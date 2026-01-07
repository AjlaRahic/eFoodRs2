
import 'dart:convert';
import 'dart:io';
import 'package:efood_mobile/models/dojmovi.dart';
import 'package:efood_mobile/models/jelo.dart';
import 'package:efood_mobile/models/korisnik.dart';
import 'package:efood_mobile/providers/dojmovi_provider.dart';
import 'package:efood_mobile/providers/korisnik_provider.dart';
import 'package:efood_mobile/providers/meni_provider.dart';
import 'package:efood_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import '../models/search_result.dart';
import 'package:image_picker/image_picker.dart';

class DojmoviDetailsScreen extends StatefulWidget {
  final Dojmovi? dojmovi;
  final Function()? onKorisnikUpdated;

  DojmoviDetailsScreen({Key? key, this.dojmovi, this.onKorisnikUpdated})
      : super(key: key);

  @override
  State<DojmoviDetailsScreen> createState() => _DojmoviDetailsScreenState();
}

class _DojmoviDetailsScreenState extends State<DojmoviDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late KorisnikProvider _korisnikProvider;
  late DojmoviProvider _dojmoviProvider;
  late MeniProvider _meniProvider;


  SearchResult<Korisnik>? korisnikResults;
  SearchResult<Dojmovi>? dojmoviResults;
  SearchResult<Jelo>? jeloResults;


  bool isLoading = true;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _korisnikProvider = context.read<KorisnikProvider>();
    _dojmoviProvider = context.read<DojmoviProvider>();
    _meniProvider = context.read<MeniProvider>();


    initForm();
  }

  Future<void> initForm() async {
    korisnikResults = await _korisnikProvider.get();
    jeloResults=await _meniProvider.get();

    if (korisnikResults == null || korisnikResults!.result == null) {
      print('korisnik result je null ili prazan');
      return;
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      child: Column(
        children: [
          isLoading
              ? CircularProgressIndicator()
              : _buildForm(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent, 
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      var request = Map.from(_formKey.currentState!.value);
                      request['slika'] = _base64Image;

                      try {
                        if (widget.dojmovi == null) {
                          await _dojmoviProvider.insert(request);
                          _showSnackbar("Dojmovi su uspješno dodano.");
                        } else {
                          await _dojmoviProvider.update(widget.dojmovi!.id!, request);
                          _showSnackbar("Korisnik je uspješno uređeno.");
                        }

                        if (widget.onKorisnikUpdated != null) {
                          widget.onKorisnikUpdated!();
                        }

                        Navigator.of(context).pop();
                      } catch (e) {
                        print('Error occurred: $e');
                        _showErrorDialog(e.toString());
                      }
                    }
                  },
                  child: Text(widget.dojmovi == null ? "Sačuvaj" : "Uredi"),
                ),
              ),
            ],
          ),
        ],
      ),
      title: widget.dojmovi?.opis ?? "Detalji korisnik",
    );
  }

  FormBuilder _buildForm() {
    return FormBuilder(
      key: _formKey,
      initialValue: {
        'ocjena': widget.dojmovi?.ocjena,
        'opis': widget.dojmovi?.opis,
        'jeloId': widget.dojmovi?.jeloId,
        'korisnikId': widget.dojmovi?.korisnikId,

      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: "ocjena",
                    decoration: InputDecoration(
                      labelText: "Ocjena",
                      labelStyle: TextStyle(color: Colors.orangeAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.orangeAccent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: "opis",
                    decoration: InputDecoration(
                      labelText: "Opis",
                      labelStyle: TextStyle(color: Colors.orangeAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.orangeAccent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: FormBuilderDropdown<String>(
                    name: 'jeloId',
                    decoration: InputDecoration(
                      labelText: 'Jelo',
                      labelStyle: TextStyle(color: Colors.orangeAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.orangeAccent),
                      ),
                    ),
                    items: jeloResults?.result
                            .map((item) => DropdownMenuItem<String>(
                                value: item.kategorijaId.toString(),
                                child: Text(item.naziv ?? "")))
                            .toList() ??
                        [],
                    initialValue: widget.dojmovi?.jeloId?.toString(),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: FormBuilderDropdown<String>(
                    name: 'korisnikId',
                    decoration: InputDecoration(
                      labelText: 'Korisnik',
                      labelStyle: TextStyle(color: Colors.orangeAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.orangeAccent),
                      ),
                    ),
                    items: korisnikResults?.result
                            .map((item) => DropdownMenuItem<String>(
                                value: item.id.toString(),
                                child: Text(item.ime ?? "")))
                            .toList() ??
                        [],
                    initialValue: widget.dojmovi?.korisnikId?.toString(),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Greška", style: TextStyle(color: Colors.orangeAccent)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: Colors.orangeAccent)),
          )
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.orangeAccent,
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
