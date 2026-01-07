import 'package:efood_admin/models/grad.dart';
import 'package:efood_admin/models/restoran.dart';
import 'package:efood_admin/models/search_result.dart';
import 'package:efood_admin/providers/grad_provider.dart';
import 'package:efood_admin/providers/restoran_provider.dart';
import 'package:efood_admin/screens/izvjestaj_o_prometu_po_korisniku.dart';
import 'package:efood_admin/screens/izvjestaj_o_prometu_screen.dart';
import 'package:efood_admin/screens/meni_screen.dart';
import 'package:efood_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late RestoranProvider _restoranProvider;
  late GradProvider _gradProvider;

  SearchResult<Restoran>? restoran;
  SearchResult<Grad>? grad;

  final _nazivController = TextEditingController();
  final _adresaController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonController = TextEditingController();
  int? _selectedGradId;

  @override
  void dispose() {
    _nazivController.dispose();
    _adresaController.dispose();
    _emailController.dispose();
    _telefonController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restoranProvider = context.read<RestoranProvider>();
    _gradProvider = context.read<GradProvider>();
    _loadData();
    _loadGrad();
  }

  Future<void> _loadData() async {
    var data = await _restoranProvider.get();
    setState(() {
      restoran = data;
    });
  }

  Future<void> _loadGrad() async {
    var data = await _gradProvider.get();
    setState(() {
      grad = data;
    });
  }

  String getGradNaziv(int? gradId) {
    if (grad == null || grad!.result.isEmpty || gradId == null) return 'N/A';
    var gradObj = grad!.result.firstWhere((g) => g.id == gradId);
    return gradObj.naziv ?? 'N/A';
  }

  void _showEditDialog(Restoran restoranData) {
    final rootContext = context;

    _nazivController.text = restoranData.nazivRestorana ?? '';
    _adresaController.text = restoranData.adresa ?? '';
    _emailController.text = restoranData.email ?? '';
    _telefonController.text = restoranData.telefon ?? '';
    _selectedGradId = restoranData.gradId;

    showDialog(
      context: rootContext,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Uredi podatke o restoranu'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: _nazivController,
                  decoration:
                      const InputDecoration(labelText: 'Naziv restorana')),
              TextField(
                  controller: _adresaController,
                  decoration: const InputDecoration(labelText: 'Adresa')),
              TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email')),
              TextField(
                  controller: _telefonController,
                  decoration: const InputDecoration(labelText: 'Telefon')),
              DropdownButtonFormField<int>(
                value: _selectedGradId,
                items: grad?.result
                        .map((g) => DropdownMenuItem<int>(
                            value: g.id, child: Text(g.naziv ?? '')))
                        .toList() ??
                    [],
                onChanged: (val) => _selectedGradId = val,
                decoration: const InputDecoration(labelText: 'Grad'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              child: const Text('Otkaži'),
              onPressed: () => Navigator.pop(dialogCtx)),
          ElevatedButton(
            child: const Text('Spasi'),
            onPressed: () async {
              try {
                restoranData.nazivRestorana = _nazivController.text;
                restoranData.adresa = _adresaController.text;
                restoranData.email = _emailController.text;
                restoranData.telefon = _telefonController.text;
                restoranData.gradId = _selectedGradId;

                await _restoranProvider.update(
                    restoranData.restoranId!, restoranData);
                if (Navigator.of(dialogCtx).canPop())
                  Navigator.of(dialogCtx).pop();
                await _loadData();

                showDialog(
                  context: rootContext,
                  barrierDismissible: false,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    title: const Text('Uspjeh'),
                    content: const Text('Podaci su uspješno spašeni.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('OK'))
                    ],
                  ),
                );
              } catch (e) {
                showDialog(
                  context: rootContext,
                  builder: (_) => AlertDialog(
                      title: const Text('Greška'),
                      content: Text('Spremanje nije uspjelo.\n$e'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(rootContext).pop(),
                            child: const Text('Zatvori'))
                      ]),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3E5F5),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lijeva kolona: Meni + izvještaji
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildMeniCard(),
                  const SizedBox(height: 20),
                  _buildIzvjestajiRow(),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Desna kolona: Kontakt
            Expanded(
              flex: 1,
              child: _buildKontaktCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeniCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => MasterScreenWidget(
            child:
                MeniScreen(), // Ovdje se koristi MeniScreen unutar MasterScreenWidget
            title: 'Meni', // Naslov se može postaviti po potrebi
            activeItem: 'Meni',
          ),
        )),
        child: Container(
          height: 180,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: const [
              Expanded(
                  child: Center(
                      child: Icon(Icons.menu_book,
                          size: 65, color: Colors.purple))),
              SizedBox(height: 12),
              Text("Meni",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIzvjestajiRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSingleIzvjestajCard(
            title: 'Uplate po korisniku',
            icon: Icons.attach_money,
            iconColor: Colors.green,
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => UplatePoKorisnikuReport())),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSingleIzvjestajCard(
            title: 'Promet po korisniku',
            icon: Icons.bar_chart,
            iconColor: Colors.blue,
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PrometPoKorisnikuReport())),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleIzvjestajCard(
      {required String title,
      required IconData icon,
      required Color iconColor,
      required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Icon(icon, size: 60, color: iconColor)),
                ),
              ),
              const SizedBox(height: 10),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKontaktCard() {
    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // visina raste samo koliko treba
          children: [
            Text('Kontakt informacije',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700])),
            const SizedBox(height: 10),
            Divider(color: Colors.purple[200]),
            const SizedBox(height: 10),
            if (restoran != null && restoran!.result.isNotEmpty)
              Column(
                children: [
                  _buildContactRow(Icons.store, 'Naziv:',
                      restoran!.result.first.nazivRestorana ?? 'N/A'),
                  _buildContactRow(Icons.location_on, 'Adresa:',
                      restoran!.result.first.adresa ?? 'N/A'),
                  _buildContactRow(Icons.email, 'Email:',
                      restoran!.result.first.email ?? 'N/A'),
                  _buildContactRow(Icons.phone, 'Telefon:',
                      restoran!.result.first.telefon ?? 'N/A'),
                  _buildContactRow(Icons.location_city, 'Grad:',
                      getGradNaziv(restoran!.result.first.gradId)),
                ],
              )
            else
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.edit, color: Colors.white, size: 18),
              label: const Text('Uredi', style: TextStyle(color: Colors.white)),
              onPressed: () => _showEditDialog(restoran!.result.first),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple[700], size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text("$label $value",
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
