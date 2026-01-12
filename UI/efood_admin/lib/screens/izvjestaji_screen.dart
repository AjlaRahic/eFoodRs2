import 'package:efood_admin/screens/izvjestaj_o_prometu_po_korisniku.dart';
import 'package:efood_admin/screens/izvjestaj_o_prometu_screen.dart';
import 'package:flutter/material.dart';

class IzvjestajiScreen extends StatelessWidget {
  const IzvjestajiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            

        
          

            const SizedBox(height: 30),

            
            _buildReportCard(
              context,
              title: "Uplate po korisniku",
              subtitle: "Prikaz svih transakcija po korisniku",
              icon: Icons.credit_card,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UplatePoKorisnikuReport(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            _buildReportCard(
              context,
              title: "Promet po korisniku",
              subtitle: "Detaljni pregled narudžbi korisnika",
              icon: Icons.analytics,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrometPoKorisnikuReport(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            /// IKONA
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),

            const SizedBox(width: 16),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}
