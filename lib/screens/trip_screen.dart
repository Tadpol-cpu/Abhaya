import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/sos_button.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  late GoogleMapController mapController;
  bool rerouted = false;

  final LatLng center = const LatLng(12.9716, 77.5946); // Bangalore center

  // Danger zone circle
  final Set<Circle> dangerZones = {
    Circle(
      circleId: const CircleId("danger1"),
      center: LatLng(12.9716, 77.5946),
      radius: 400,
      fillColor: Colors.red.withOpacity(0.4),
      strokeWidth: 0,
    ),
  };

  // Fake place markers
  final Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _generateFakePlaces();
  }

  // Generate fake markers once to avoid freezing UI
  void _generateFakePlaces() {
    final Random random = Random();

    for (int i = 0; i < 5; i++) {
      double latOffset = (random.nextDouble() - 0.5) / 50; // small offset
      double lngOffset = (random.nextDouble() - 0.5) / 50;

      LatLng location = LatLng(center.latitude + latOffset, center.longitude + lngOffset);
      int score = 50 + random.nextInt(50); // safety score 50-99

      markers.add(
        Marker(
          markerId: MarkerId("place_$i"),
          position: location,
          infoWindow: InfoWindow(
            title: "Place $i",
            snippet: "Safety Score: $score",
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            score > 75 ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }
  }

  // Button action: reroute safely
  void suggestSafeRoute() async {
    setState(() {
      rerouted = true;
    });

    // Optional: animate camera safely
    await mapController.animateCamera(
      CameraUpdate.newLatLng(center),
    );

    // Show message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Unsafe area detected. Redirecting to safer route."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Trip")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: center,
              zoom: 13,
            ),
            circles: dangerZones,
            markers: markers,
            onMapCreated: (controller) {
              mapController = controller;
            },
          ),
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: suggestSafeRoute,
              child: Text(
                rerouted ? "Safer Route Activated" : "Avoid High-Risk Zone",
              ),
            ),
          ),
          const Positioned(
            bottom: 30,
            right: 30,
            child: SOSButton(),
          ),
        ],
      ),
    );
  }
}



