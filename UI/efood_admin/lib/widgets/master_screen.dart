import 'package:efood_admin/main.dart';
import 'package:efood_admin/screens/dojmovi_list_screen.dart';
import 'package:efood_admin/screens/evidencija_obavjestenja.dart';
import 'package:efood_admin/screens/home_screen.dart';
import 'package:efood_admin/screens/izvjestaji_screen.dart';
import 'package:efood_admin/screens/korisnik_profile_screen.dart';
import 'package:efood_admin/screens/meni_screen.dart';
import 'package:efood_admin/screens/status_narudzba_screen.dart';
import 'package:efood_admin/utils/util.dart';
import 'package:flutter/material.dart';

class MasterScreenWidget extends StatefulWidget {
  final Widget? child;
  final String? title;
  final String? activeItem;
  final Widget? title_widget;
  const MasterScreenWidget(
      {this.child, this.title, this.activeItem, super.key, this.title_widget});

  @override
  State<MasterScreenWidget> createState() => _MasterScreenWidgetState();
}

class _MasterScreenWidgetState extends State<MasterScreenWidget> {
  late String _activeItem;

  final Color appBarColor = const Color(0xFF9C27B0); 
  final Color activeUnderlineColor = Colors.white;
  final Color contentBackgroundColor = const Color(0xFFF3E5F5);

  @override
  void initState() {
    super.initState();
    _activeItem = widget.activeItem ?? "Početna";
  }

  void _logout() {
    Authorization.korisnik = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor:  Color(0xFF9C27B0),
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            _buildNavbarItem("Početna", HomeScreen(), Icons.home_filled),
            _buildNavbarItem("Meni", MeniScreen(), Icons.menu_book),
            _buildNavbarItem(
                "Narudžbe", StatusNarudzbaScreen(), Icons.receipt),
            _buildNavbarItem(
                "Obavještenja", EvidencijaObavjestenja(), Icons.notifications_active),
            _buildNavbarItem("Dojmovi", DojmoiListScreen(), Icons.rate_review),
            _buildNavbarItem("Izvjestaji", IzvjestajiScreen(), Icons.report),
            _buildNavbarItem("Administrator", KorisnikScreen(), Icons.admin_panel_settings),
            const Spacer(),
            _buildNavbarLogout(),
          ],
        ),
        leading: null,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: widget.child ?? Container(),
      ),
    );
  }

  // ---- STANDARD NAVBAR ITEM ----
  Widget _buildNavbarItem(String title, Widget screen, IconData icon) {
    final bool isActive = _activeItem == title;

    return InkWell(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MasterScreenWidget(
              child: screen,
              title: title,
              activeItem: title,
            ),
          ),
        );
      },
      hoverColor: Colors.white24,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: isActive
              ? Border(
                  bottom: BorderSide(
                    color: activeUnderlineColor,
                    width: 3,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: isActive ? 22 : 20),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- LOGOUT ITEM SA TEKSTOM ----
  Widget _buildNavbarLogout() {
    final bool isActive = false; // Logout nikad nije aktivan kao tab

    return InkWell(
      onTap: _logout,
      hoverColor: Colors.white24,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: const [
            Icon(Icons.logout, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              "Odjavi se",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
