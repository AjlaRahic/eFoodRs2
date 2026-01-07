import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/lokacija.dart';
import '../models/narudzba.dart';
import '../providers/lokacija_provider.dart';
import '../providers/narudzba_provider.dart';
import '../utils/util.dart'; 

class PracenjeNarudzbeScreen extends StatefulWidget {
  final int narudzbaId;

  const PracenjeNarudzbeScreen({Key? key, required this.narudzbaId})
      : super(key: key);

  @override
  State<PracenjeNarudzbeScreen> createState() =>
      _PracenjeNarudzbeScreenState();
}

class _PracenjeNarudzbeScreenState extends State<PracenjeNarudzbeScreen> {
  LokacijaProvider? _lokacijaProvider;
  NarudzbaProvider? _narudzbaProvider;

  double? _lat ;
  double? _lon ;
  double? _targetLat ; 
  double? _targetLon;

  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _lokacijaProvider = context.read<LokacijaProvider>();
    _narudzbaProvider = context.read<NarudzbaProvider>();
    _initTracking();
  }

  Future<void> _initTracking() async {
    setState(() => _loading = true);

    try {
      
      final Narudzba narudzba =
          await _narudzbaProvider!.FetchById(widget.narudzbaId);

   
      final int? dostavljacId = narudzba.dostavljacId;
      if (dostavljacId == null) {
        print(" Narudžba nema dodijeljenog dostavljača!");
        setState(() => _loading = false);
        return;
      }

      final Lokacija? lokDostavljac =
          await _lokacijaProvider!.getZadnjaLokacija(dostavljacId);

      if (lokDostavljac != null) {
        _lat = lokDostavljac.latitude!;
        _lon = lokDostavljac.longitude!;
        print(" Dostavljač start: $_lat, $_lon");
      } else {
        print("⚠️ Dostavljač nema zadnju lokaciju, koristi default Rondo");
      }

     
      final Lokacija? lokKorisnik =
          await _lokacijaProvider!.getZadnjaLokacija(Authorization.userId!);

      if (lokKorisnik != null) {
        _targetLat = lokKorisnik.latitude!;
        _targetLon = lokKorisnik.longitude!;
        print(" Lokacija korisnika (cilj): $_targetLat, $_targetLon");
      } else {
        print(" Korisnik nema lokaciju, koristi default Blagaj");
      }

      setState(() => _loading = false);

      
      _startTracking();
    } catch (e) {
     
      setState(() => _loading = false);
    }
  }

  void _startTracking() {
    const interval = Duration(seconds: 1);
    const step = 0.002;

    _timer = Timer.periodic(interval, (timer) {
      final dx = _targetLat! - _lat!;
      final dy = _targetLon! - _lon!;
      final distance = sqrt(dx * dx + dy * dy);

      if (distance < 0.0005) {
        timer.cancel();
        
        return;
      }

     _lat = _lat! + dx * step / distance;
    _lon = _lon! + dy * step / distance;

      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Praćenje narudžbe")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(_lat!, _lon!),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c', 'd'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_lat!, _lon!),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                    Marker(
                      point: LatLng(_targetLat!, _targetLon!),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
               /* PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [LatLng(_lat, _lon), LatLng(_targetLat, _targetLon)],
                      color: Colors.green,
                      strokeWidth: 4,
                    ),
                  ],
                ),*/
              ],
            ),
    );
  }
}
