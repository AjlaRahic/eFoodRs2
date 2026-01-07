import 'dart:convert';
import 'package:efood_admin/models/jelo.dart';
import 'package:efood_admin/models/kategorija.dart';
import 'package:efood_admin/providers/jelo_provider.dart';
import 'package:efood_admin/providers/kategorija_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/search_result.dart';

class ProductDetailScreen extends StatefulWidget {
  final Jelo? jelo;
  final Function()? onProductUpdated;

  const ProductDetailScreen({Key? key, this.jelo, this.onProductUpdated})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late KategorijaProvider _kategorijaProvider;
  late ProductProvider _productProvider;

  SearchResult<Kategorija>? _kategorijaResult;
  bool _isLoading = true;

  final ImagePicker _picker = ImagePicker();
  String? _base64Image;
  bool _removeImage = false;

  bool get _isEdit => widget.jelo != null;

  @override
  void initState() {
    super.initState();
    _kategorijaProvider = context.read<KategorijaProvider>();
    _productProvider = context.read<ProductProvider>();
    _initForm();
  }

  bool _hasUnsavedChanges = false;

  Future<void> _initForm() async {
    _kategorijaResult = await _kategorijaProvider.get();
    setState(() => _isLoading = false);
  }

  Future<bool> _confirmDiscardIfNeeded() async {
    if (!_hasUnsavedChanges) return true;

    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Odbaciti promjene?"),
        content: const Text(
            "Napravili ste izmjene koje nisu spašene. Želite li odustati i odbaciti promjene?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Nastavi uređivanje"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Odbaci", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final screenTitle = _isEdit ? (widget.jelo!.naziv ?? "Jelo") : 'Novo jelo';

    return WillPopScope(
      onWillPop: () async {
        return await _confirmDiscardIfNeeded();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(screenTitle, overflow: TextOverflow.ellipsis),
          backgroundColor: Colors.purple[700],
          leading: BackButton(onPressed: () async {
            final canLeave = await _confirmDiscardIfNeeded();
            if (canLeave) Navigator.of(context).pop(false);
          }),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              )
            : Column(
                children: [
                  Expanded(child: _buildForm()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.purple[700],
                            side: BorderSide(color: Colors.purple[700]!),
                          ),
                          onPressed: () async {
                            final canLeave = await _confirmDiscardIfNeeded();
                            if (canLeave) Navigator.of(context).pop(false);
                          },
                          child: const Text("Odustani"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[700],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _onSavePressed,
                          child: Text(_isEdit ? "Spasi" : "Dodaj"),
                        ),
                      ),
                    ],
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
        'naziv': widget.jelo?.naziv,
        'cijena': widget.jelo?.cijena?.toString(),
        'opis': widget.jelo?.opis,
        'kategorijaId': widget.jelo?.kategorijaId?.toString(),
        'slika': widget.jelo?.slika,
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Naziv
            FormBuilderTextField(
              name: "naziv",
              decoration: InputDecoration(
                labelText: "Naziv *",
                labelStyle: TextStyle(color: Colors.purple[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple[700]!),
                ),
              ),
              validator: (v) {
                final val = (v ?? '').trim();
                if (val.isEmpty) return 'Naziv je obavezan.';
                if (val.length < 2) return 'Naziv mora imati min. 2 znaka.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Opis
            FormBuilderTextField(
              name: "opis",
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Opis",
                labelStyle: TextStyle(color: Colors.purple[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple[700]!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Cijena i Kategorija
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: FormBuilderDropdown<String>(
                    name: 'kategorijaId',
                    decoration: InputDecoration(
                      labelText: 'Kategorija *',
                      labelStyle: TextStyle(color: Colors.purple[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.purple[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.purple[700]!, width: 1.5),
                      ),
                      prefixIcon: Icon(Icons.category, color: Colors.purple[400]),
                    ),
                    items: _kategorijaResult?.result
                            .map((item) => DropdownMenuItem<String>(
                                  value: item.kategorijaId?.toString(),
                                  child: Text(item.naziv ?? ""),
                                ))
                            .toList() ??
                        [],
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Odaberite kategoriju.' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: FormBuilderTextField(
                    name: 'cijena',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Cijena *',
                      labelStyle: TextStyle(color: Colors.purple[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.purple[700]!),
                      ),
                      prefixIcon: Icon(Icons.euro, color: Colors.purple[400]),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            // Image picker
            FormBuilderField<String?>(
              name: 'imageId',
              builder: (field) {
                final hasNewImage =
                    _base64Image != null && _base64Image!.isNotEmpty;
                final hasExistingImage = !_removeImage &&
                    widget.jelo?.slika != null &&
                    widget.jelo!.slika!.isNotEmpty;

                Widget content;
                if (hasNewImage) {
                  content = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _imagePreview(_base64Image!),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(Icons.edit, color: Colors.purple[700]),
                            label: Text('Promijeni sliku', style: TextStyle(color: Colors.purple[700])),
                          ),
                          OutlinedButton.icon(
                            onPressed: _clearNewImage,
                            icon: Icon(Icons.delete_outline, color: Colors.purple[700]),
                            label: Text('Ukloni', style: TextStyle(color: Colors.purple[700])),
                          ),
                        ],
                      ),
                    ],
                  );
                } else if (hasExistingImage) {
                  content = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _imagePreview(widget.jelo!.slika!),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(Icons.edit, color: Colors.purple[700]),
                            label: Text('Promijeni sliku', style: TextStyle(color: Colors.purple[700])),
                          ),
                          OutlinedButton.icon(
                            onPressed: _markRemoveExistingImage,
                            icon: Icon(Icons.delete_outline, color: Colors.purple[700]),
                            label: Text('Ukloni', style: TextStyle(color: Colors.purple[700])),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  content = ListTile(
                    leading: Icon(Icons.photo, color: Colors.purple[400]),
                    title: Text("Odaberite sliku", style: TextStyle(color: Colors.purple[700])),
                    trailing: Icon(Icons.file_upload, color: Colors.purple[400]),
                    onTap: _pickImage,
                  );
                }

                return InputDecorator(
                  decoration: InputDecoration(
                    label: const Text('Slika (opcionalno)'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple[700]!),
                    ),
                  ),
                  child: content,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePreview(String b64) {
    return Container(
      constraints:
          const BoxConstraints(maxHeight: 200, maxWidth: double.infinity),
      child: Image.memory(base64Decode(b64), fit: BoxFit.cover),
    );
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
        _removeImage = false;
      });
      _formKey.currentState?.fields['imageId']?.reset();
    }
  }

  void _clearNewImage() {
    setState(() {
      _base64Image = null;
    });
  }

  void _markRemoveExistingImage() {
    setState(() {
      _removeImage = true;
      _base64Image = null;
    });
    _formKey.currentState?.fields['imageId']?.reset();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title:
            const Text("Greška", style: TextStyle(color: Colors.purple)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("OK", style: TextStyle(color: Colors.purple)),
          )
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.purple[700],
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _onSavePressed() async {
    final valid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!valid) {
      _showSnackbar("Provjerite formu i pokušajte ponovo.");
      return;
    }

    final request = Map<String, dynamic>.from(_formKey.currentState!.value);

    final naziv = (request['naziv'] ?? '').toString().trim();
    request['naziv'] = naziv;
    request['opis'] = (request['opis'] ?? '').toString().trim();

    final katStr = request['kategorijaId']?.toString();
    final katId = int.tryParse(katStr ?? '');
    if (katId == null) {
      _formKey.currentState?.fields['kategorijaId']
          ?.invalidate('Odaberite kategoriju.');
      _showSnackbar("Odaberite kategoriju.");
      return;
    }
    request['kategorijaId'] = katId;

    final cijenaStr =
        (request['cijena'] ?? '').toString().replaceAll(',', '.').trim();
    final cijena = double.tryParse(cijenaStr);
    if (cijena == null || cijena <= 0) {
      _formKey.currentState?.fields['cijena']
          ?.invalidate('Unesite cijenu veću od 0 (npr. 12.50).');
      _showSnackbar("Cijena mora biti veća od 0.");
      return;
    }
    request['cijena'] = cijena;

    if (_base64Image != null && _base64Image!.isNotEmpty) {
      request['slika'] = _base64Image;
      request.remove('removeImage');
    } else if (_isEdit && _removeImage) {
      request['slika'] = null;
      request['removeImage'] = true;
    } else if (_isEdit) {
      request.remove('slika');
      request.remove('removeImage');
    } else {
      request.remove('slika');
      request.remove('removeImage');
    }

    try {
      if (_isEdit) {
        await _productProvider.update(widget.jelo!.jeloId!, request);
        _showSnackbar("Jelo je uspješno uređeno.");
      } else {
        await _productProvider.insert(request);
        _showSnackbar("Jelo je uspješno dodano.");
      }

      widget.onProductUpdated?.call();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }
}
