import 'package:efood_admin/models/grad.dart';
import 'package:efood_admin/models/restoran.dart';
import 'package:efood_admin/models/search_result.dart';
import 'package:efood_admin/providers/grad_provider.dart';
import 'package:efood_admin/providers/restoran_provider.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restoranProvider = context.read<RestoranProvider>();
    _gradProvider = context.read<GradProvider>();
    _loadData();
    _loadGrad();
  }

  Future<void> _loadData() async {
    restoran = await _restoranProvider.get();
    setState(() {});
  }

  Future<void> _loadGrad() async {
    grad = await _gradProvider.get();
    setState(() {});
  }

  String getGradNaziv(int? gradId) {
    if (grad == null || grad!.result.isEmpty || gradId == null) return 'N/A';
    return grad!.result.firstWhere((g) => g.id == gradId).naziv ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F0FA),
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, // BITNO
        children: [
          Expanded(child: _buildMeniCard()),
          const SizedBox(width: 24),
          Expanded(child: _buildKontaktCard()),
        ],
      ),
    );
  }



  Widget _buildMeniCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MasterScreenWidget(
            child: MeniScreen(),
            title: 'Meni',
            activeItem: 'Meni',
          ),
        ),
      ),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFE1BEE7),
                child: Icon(
                  Icons.restaurant_menu,
                  size: 52,
                  color: Color(0xFF6A1B9A),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Meni",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Upravljanje ponudom restorana",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildKontaktCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.store, color: Color(0xFF6A1B9A), size: 26),
                SizedBox(width: 10),
                Text(
                  "Podaci o restoranu",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A1B9A),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: Colors.purple[200]),
            const SizedBox(height: 16),

            if (restoran != null && restoran!.result.isNotEmpty)
              Expanded(
                child: Column(
                  children: [
                    _buildContactRow(Icons.store, "Naziv",
                        restoran!.result.first.nazivRestorana ?? "N/A"),
                    _buildContactRow(Icons.location_on, "Adresa",
                        restoran!.result.first.adresa ?? "N/A"),
                    _buildContactRow(Icons.email, "Email",
                        restoran!.result.first.email ?? "N/A"),
                    _buildContactRow(Icons.phone, "Telefon",
                        restoran!.result.first.telefon ?? "N/A"),
                    _buildContactRow(Icons.location_city, "Grad",
                        getGradNaziv(restoran!.result.first.gradId)),
                  ],
                ),
              )
            else
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),

            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                 style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A), 
                  foregroundColor: const Color.fromRGBO(255, 255, 255, 1), 
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text("Uredi"),
                onPressed: () => _showEditDialog(restoran!.result.first),
              ),
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
            child: Text(
              "$label: $value",
              style: const TextStyle(
                
                fontSize: 15,
                fontWeight: FontWeight.w500,
               
              ),
            ),
          ),
        ],
      ),
    );
  }

  

  void _showEditDialog(Restoran restoranData) {
    _nazivController.text = restoranData.nazivRestorana ?? '';
    _adresaController.text = restoranData.adresa ?? '';
    _emailController.text = restoranData.email ?? '';
    _telefonController.text = restoranData.telefon ?? '';
    _selectedGradId = restoranData.gradId;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Uredi podatke"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _nazivController, decoration: const InputDecoration(labelText: "Naziv")),
              TextField(controller: _adresaController, decoration: const InputDecoration(labelText: "Adresa")),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
              TextField(controller: _telefonController, decoration: const InputDecoration(labelText: "Telefon")),
              DropdownButtonFormField<int>(
                value: _selectedGradId,
                decoration: const InputDecoration(labelText: "Grad"),
                items: grad?.result
                        .map((g) => DropdownMenuItem(value: g.id, child: Text(g.naziv ?? '')))
                        .toList() ??
                    [],
                onChanged: (val) => _selectedGradId = val,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Otkaži")),
          ElevatedButton(
            onPressed: () async {
              restoranData
                ..nazivRestorana = _nazivController.text
                ..adresa = _adresaController.text
                ..email = _emailController.text
                ..telefon = _telefonController.text
                ..gradId = _selectedGradId;

              await _restoranProvider.update(restoranData.restoranId!, restoranData);
              Navigator.pop(context);
              _loadData();
            },
            child: const Text("Spasi"),
          ),
        ],
      ),
    );
  }
}
