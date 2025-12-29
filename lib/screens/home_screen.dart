import 'package:flutter/material.dart';
import '../widgets/risk_card.dart';
import 'trip_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void handleDecision(BuildContext context, bool accepted) {
    if (accepted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TripScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Trip cancelled due to safety concerns")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Safety Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RiskCard(
          onDecision: (accepted) => handleDecision(context, accepted),
        ),
      ),
    );
  }
}

