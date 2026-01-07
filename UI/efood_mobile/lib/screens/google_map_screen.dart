import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DostavljacScreen extends StatefulWidget {
  const DostavljacScreen({Key? key}) : super(key: key);

  @override
  State<DostavljacScreen> createState() => _DostavljacScreenState();
}

class _DostavljacScreenState extends State<DostavljacScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  // Simulirana ruta (lista koordinata)
  final List<LatLng> _ruta = [
    LatLng(43.3438, 17.8120),
    LatLng(43.3440, 17.8125),
    LatLng(43.3442, 17.8130),
    LatLng(43.3445, 17.8135),
    LatLng(43.3448, 17.8140),
  ];

  int _index = 0;
  late LatLng _markerPos;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _markerPos = _ruta[0];
    _startSimulacija();
  }

  void _startSimulacija() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _markerPos = _ruta[_index];
        _index = (_index + 1) % _ruta.length; // kružno
      });
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
      appBar: AppBar(title: const Text("Dostavljač Panel")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _markerPos,
          zoom: 16,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("dostavljac"),
            position: _markerPos,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                270.0), // ljubičasta
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
