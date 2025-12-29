import 'dart:math';
import 'package:flutter/material.dart';

class RiskCard extends StatefulWidget {
  final Function(bool) onDecision;

  const RiskCard({super.key, required this.onDecision});

  @override
  State<RiskCard> createState() => _RiskCardState();
}

class _RiskCardState extends State<RiskCard> {
  late int riskScore;

  @override
  void initState() {
    super.initState();
    riskScore = Random().nextInt(101); // 0–100
  }

  @override
  Widget build(BuildContext context) {
    bool highRisk = riskScore > 65;

    return Card(
      color: highRisk ? Colors.red.shade100 : Colors.green.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Trip Risk Analysis",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            Text(
              "Risk Score: $riskScore / 100",
              style: const TextStyle(fontSize: 22),
            ),

            const SizedBox(height: 10),

            Text(
              highRisk ? "⚠ High Risk Zone Detected" : "✅ Safe Trip",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: () => widget.onDecision(false),
                  child: const Text("Cancel Trip"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => widget.onDecision(true),
                  child: const Text("Accept Trip"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

