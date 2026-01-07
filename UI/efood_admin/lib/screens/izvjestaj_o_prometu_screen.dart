import 'dart:io';

import 'package:efood_admin/providers/uplata_po_korisniku_provider.dart';
import 'package:efood_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:efood_admin/models/uplata_po_korisniku.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class UplatePoKorisnikuReport extends StatefulWidget {
  @override
  _UplatePoKorisnikuReportState createState() =>
      _UplatePoKorisnikuReportState();
}

class _UplatePoKorisnikuReportState extends State<UplatePoKorisnikuReport> {
  late UplatePoKorisnikuProvider _uplatePoKorisnikuProvider;
  late Future<List<UplataPoKorisniku>> _uplateFuture;

  @override
  void initState() {
    super.initState();
    _uplatePoKorisnikuProvider = UplatePoKorisnikuProvider();
    _uplateFuture = _uplatePoKorisnikuProvider.fetchUplate();
  }

  Future<void> _generatePdf(List<UplataPoKorisniku> uplate) async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load('assets/fonts/ttf/DejaVuSans.ttf');
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Promet po korisnicima',
                  style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              ...uplate.map((item) {
                return pw.Text(
                  'Korisnik: ${item.imeKorisnika ?? "Nepoznato"}\n'
                  'Datum transakcije: ${item.datumTransakcije != null ? DateFormat('dd.MM.yyyy').format(item.datumTransakcije!) : "Nepoznato"}\n'
                  'Način plaćanja: ${item.nacinPlacanja ?? "Nepoznato"}\n'
                  'Iznos: ${item.iznos ?? "Nepoznato"}\n'
                  '----------------------------------------',
                  style: pw.TextStyle(
                  fontSize: 24, fontWeight: pw.FontWeight.bold, font: ttf),
                );
              }).toList(),
            ],
          );
        },
      ),
    );

    try {
      final outputDir = await getApplicationDocumentsDirectory();
      final filePath = '${outputDir.path}/uplata_po_korisniku.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      _showReportDownloadedDialog(filePath);
    } catch (e) {
      print('Greška pri generisanju PDF-a: $e');
    }
  }

  void _showReportDownloadedDialog(String filePath) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Izveštaj preuzet'),
        content: Text('Izveštaj je preuzet i sačuvan na:\n$filePath'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Zatvori'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      child: FutureBuilder<List<UplataPoKorisniku>>(
        future: _uplateFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Greška: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Nema podataka za prikaz.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          } else {
            List<UplataPoKorisniku> uplate = snapshot.data!;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () => _generatePdf(uplate),
                    icon: const Icon(Icons.download),
                    label: const Text("Preuzmi PDF izveštaj"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: uplate.length,
                    itemBuilder: (context, index) {
                      final uplata = uplate[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${uplata.imeKorisnika} ${uplata.prezimeKorisnika}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      uplata.nacinPlacanja ?? "Nepoznato",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor:
                                        const Color.fromARGB(255, 203, 71, 31),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Iznos: ${uplata.iznos?.toStringAsFixed(2)} KM",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black87),
                              ),
                              Text(
                                "Datum: ${uplata.datumTransakcije != null ? DateFormat('dd.MM.yyyy').format(uplata.datumTransakcije!) : "Nepoznato"}",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
