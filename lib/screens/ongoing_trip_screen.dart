import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OngoingTripScreen extends StatefulWidget {
  final double riskScore;
  const OngoingTripScreen({super.key, required this.riskScore});

  @override
  State<OngoingTripScreen> createState() => _OngoingTripScreenState();
}

class _OngoingTripScreenState extends State<OngoingTripScreen> {
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  bool _isAccepted = false;
  bool _isSaferRoute = false;

  late String _customerName;
  late String _fromName;
  late String _toName;
  late LatLng _startPos;
  late LatLng _endPos;

  @override
  void initState() {
    super.initState();
    _generateTripData(); // Generates new points every time
    _getRoute(false);
  }

  void _generateTripData() {
    final random = Random();
    // RANDOM MALE CUSTOMERS
    final maleNames = ["Arjun", "Vikram", "Rohan", "Aditya", "Suresh", "Karthik"];
    final locations = ["Chennai Central", "T. Nagar", "Adyar", "Mylapore", "Velachery", "Guindy"];
    
    _customerName = maleNames[random.nextInt(maleNames.length)];
    _fromName = locations[random.nextInt(3)];
    _toName = locations[random.nextInt(3) + 3];
    
    // THE FIX: Randomize coordinates so map changes location
    _startPos = LatLng(13.08 + (random.nextDouble() * 0.04), 80.27 + (random.nextDouble() * 0.04));
    _endPos = LatLng(13.04 + (random.nextDouble() * 0.04), 80.23 + (random.nextDouble() * 0.04));
  }

  Future<void> _getRoute(bool isSafer) async {
    final String profile = isSafer ? "foot" : "driving";
    final url = 'https://router.project-osrm.org/route/v1/$profile/${_startPos.longitude},${_startPos.latitude};${_endPos.longitude},${_endPos.latitude}?overview=full&geometries=geojson';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coords = data['routes'][0]['geometry']['coordinates'];
        setState(() {
          _isSaferRoute = isSafer;
          _routePoints = coords.map((c) => LatLng(c[1] as double, c[0] as double)).toList();
        });
        // THE FIX: Explicitly move map camera to new location
        _mapController.move(_startPos, 13.0);
      }
    } catch (e) { debugPrint("Route Error: $e"); }
  }

  Future<void> _completeTrip(bool blackmark) async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('past_trips').add({
      'customerName': _customerName,
      'from': _fromName,
      'to': _toName,
      'riskLevel': widget.riskScore > 7.0 ? "High Risk" : "Low Risk",
      'isBlackmarked': blackmark,
      'timestamp': FieldValue.serverTimestamp(),
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController, // REQUIRED FOR MOVING
            options: MapOptions(initialCenter: _startPos, initialZoom: 13),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              PolylineLayer(polylines: [
                Polyline(points: _routePoints, color: _isSaferRoute ? Colors.green : (widget.riskScore > 7.0 ? Colors.red : Colors.blue), strokeWidth: 5),
              ]),
              MarkerLayer(markers: [
                Marker(point: _startPos, child: const Icon(Icons.my_location, color: Colors.blue)),
                Marker(point: _endPos, child: const Icon(Icons.location_on, color: Colors.red)),
              ]),
            ],
          ),
          if (!_isAccepted)
            Container(color: Colors.black87, child: Center(child: Card(margin: const EdgeInsets.all(30), child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text("New Trip Request"),
              Text(_customerName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Risk Score: ${widget.riskScore}", style: TextStyle(color: widget.riskScore > 7.0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 20),
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () { _getRoute(true); setState(() => _isAccepted = true); }, child: const Text("USE SAFER ROUTE", style: TextStyle(color: Colors.white))),
              OutlinedButton(onPressed: () { _getRoute(false); setState(() => _isAccepted = true); }, child: const Text("FASTEST ROUTE")),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Decline", style: TextStyle(color: Colors.red))),
            ]))))),
          if (_isAccepted)
            Positioned(bottom: 40, left: 20, right: 20, child: Column(children: [
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)), onPressed: () => _completeTrip(false), child: const Text("Complete Trip", style: TextStyle(color: Colors.white))),
              TextButton(onPressed: () => _completeTrip(true), child: const Text("Blackmark Customer", style: TextStyle(color: Colors.red))),
            ])),
        ],
      ),
    );
  }
}