import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uposlenik Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2EB),
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        title: const Text(
          'Uposlenik Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [

            /// --- GRID BUTTONI ---
            Expanded(
              flex: 2,
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  DashboardCard(
                    title: 'Uposlenici',
                    icon: Icons.people,
                    onTap: () => _navigateToEmployees(context),
                  ),
                  DashboardCard(
                    title: 'Meni',
                    icon: Icons.restaurant_menu,
                    onTap: () => _navigateToMenu(context),
                  ),
                  DashboardCard(
                    title: 'Narudžbe',
                    icon: Icons.shopping_cart,
                    onTap: () => _navigateToOrders(context),
                  ),
                  DashboardCard(
                    title: 'Izvještaji',
                    icon: Icons.bar_chart,
                    onTap: () => _navigateToReports(context),
                  ),
                  DashboardCard(
                    title: 'Obavijesti',
                    icon: Icons.notifications,
                    onTap: () => _navigateToNotifications(context),
                  ),
                  DashboardCard(
                    title: 'Dojmovi',
                    icon: Icons.feedback,
                    onTap: () => _navigateToFeedback(context),
                  ),
                  DashboardCard(
                    title: 'Podaci',
                    icon: Icons.info,
                    onTap: () => _navigateToData(context),
                  ),
                  DashboardCard(
                    title: 'Odjava',
                    icon: Icons.logout,
                    color: Colors.red.shade300,
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  'Dobrodošli! Odaberite opciju sa menija.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _navigateToEmployees(BuildContext context) {}
  void _navigateToMenu(BuildContext context) {}
  void _navigateToOrders(BuildContext context) {}
  void _navigateToReports(BuildContext context) {}
  void _navigateToNotifications(BuildContext context) {}
  void _navigateToFeedback(BuildContext context) {}
  void _navigateToData(BuildContext context) {}
  void _logout(BuildContext context) {}
}


class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: color ?? Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 45, color: Colors.orange.shade800),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
