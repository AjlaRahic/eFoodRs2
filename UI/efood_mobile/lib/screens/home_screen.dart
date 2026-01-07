import 'package:efood_mobile/screens/meni_screen.dart';
import 'package:flutter/material.dart';
import 'package:efood_mobile/widgets/master_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      child: Stack(
        children: [
          
          Positioned.fill(
            child: Image.asset(
              "assets/images/hranaa.jpg", 
              fit: BoxFit.cover,
            ),
          ),

         
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // HERO TEXT
                const Text(
                  "Šta ćemo danas jesti?",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Topla hrana stiže brzo",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),

                const Spacer(),

                // MAIN CARD
                Card(
                  color: const Color(0xFFFFCBA4), // peach
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Pregled menija",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4E3629),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Odaberi svoje omiljeno jelo i naruči odmah",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF4E3629),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _navigateToMenuPage(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF8D6E63), // smeđa
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Pogledaj meni",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMenuPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MeniScreen()),
    );
  }
}
