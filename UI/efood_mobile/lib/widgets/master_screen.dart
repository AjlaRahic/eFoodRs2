import 'package:badges/badges.dart' as custom_badges;
import 'package:efood_mobile/screens/cart_screen.dart';
import 'package:efood_mobile/screens/historija_narudzbi_screen.dart';
import 'package:efood_mobile/screens/historija_screen.dart';
import 'package:efood_mobile/screens/home_screen.dart';
import 'package:efood_mobile/screens/korisnik_profile_screen.dart';
import 'package:efood_mobile/screens/meni_screen.dart';
import 'package:efood_mobile/screens/preporuceni_screen.dart';
import 'package:efood_mobile/screens/recenzija_screen.dart';
import 'package:flutter/material.dart';

import 'package:efood_mobile/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:efood_mobile/models/korpa.dart';
import 'package:efood_mobile/models/search_result.dart';

class MasterScreenWidget extends StatefulWidget {
  final Widget? child;
  final String? title;
  final Widget? title_widget;
  const MasterScreenWidget({this.child, this.title, this.title_widget, Key? key})
      : super(key: key);

  @override
  State<MasterScreenWidget> createState() => _MasterScreenWidgetState();
}

class _MasterScreenWidgetState extends State<MasterScreenWidget> {
  int _selectedIndex = 0;

  late CartProvider _cartProvider;
  Future<int>? _cartCountFuture;

  final List<Widget> _mainScreens = [
    HomeScreen(),
    MeniScreen(),
    RecommendedJeloScreen(),
    CartScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cartProvider = context.read<CartProvider>();
    _refreshCartCount();
  }

  void _refreshCartCount() {
    _cartCountFuture = _loadCartCount();
    if (mounted) setState(() {});
  }

  Future<int> _loadCartCount() async {
    try {
      final SearchResult<Korpa> data = await _cartProvider.get();
      int totalQty = 0;
      for (final item in data.result) {
        totalQty += item.kolicina ?? 0;
      }
      return totalQty;
    } catch (_) {
      return 0;
    }
  }

  void _onMainItemTapped(int index) async {
    if (index < 4) {
      setState(() => _selectedIndex = index);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => _mainScreens[index]),
      );
    } else {
      // show “Više” menu
      final selected = await showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(1000, 600, 10, 100),
        items: [
          const PopupMenuItem(value: 'Recenzija', child: Text('Recenzija')),
          const PopupMenuItem(value: 'Historija', child: Text('Historija narudzbi')),
          // dodaj ovdje još stavki ako želiš
        ],
      );

      if (selected != null && selected == 'Recenzija') {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const RecenzijaScreen()))
            .then((_) => _refreshCartCount());
      }
       if (selected != null && selected == 'Historija') {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) =>  HistorijaScreen()))
            .then((_) => _refreshCartCount());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.brown[700],
        title: widget.title_widget ??
            Text(
              widget.title ?? "E-Food",
              style: const TextStyle(color: Colors.white),
            ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const KorisnikProfileScreen()),
              );
            },
          ),
          FutureBuilder<int>(
            future: _cartCountFuture,
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return custom_badges.Badge(
                badgeContent: Text('$count', style: const TextStyle(color: Colors.white)),
                badgeColor: Colors.red,
                position: custom_badges.BadgePosition.topEnd(top: 0, end: 3),
                child: IconButton(
                  icon: const Icon(Icons.shopping_basket),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (_) => CartScreen()))
                        .then((_) => _refreshCartCount());
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: widget.child ?? _mainScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onMainItemTapped,
        backgroundColor: Colors.brown[600],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.brown[200],
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Početna'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Meni'),
          BottomNavigationBarItem(icon: Icon(Icons.app_registration), label: 'Preporučena jela'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: 'Korpa'),
          BottomNavigationBarItem(icon: Icon(Icons.more_vert), label: 'Više'),
        ],
      ),
    );
  }
}
