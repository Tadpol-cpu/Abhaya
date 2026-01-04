import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'ongoing_trip_screen.dart';
import 'community_screen.dart'; // Ensure this import exists

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("ABHAYA", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); 
              if (context.mounted) {
                // Clears stack to ensure Auth Gate in main.dart takes over
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildNewTripButton(context),
          
          // NEW: Community Access Button
          _buildCommunityButton(context),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft, 
              child: Text("Recent Trip History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users').doc(uid).collection('past_trips')
                  .orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No past trips found."));
                }
                return ListView(
                  children: snapshot.data!.docs.map((doc) => _tripHistoryCard(doc.data() as Map<String, dynamic>)).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewTripButton(BuildContext context) {
    return InkWell(
      onTap: () {
        // Generates random risk score (1.0 to 10.0) for simulation
        double randomRisk = (Random().nextDouble() * 9) + 1;
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => OngoingTripScreen(riskScore: double.parse(randomRisk.toStringAsFixed(1))))
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.purple, Colors.blue]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Start New Trip", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text("Check risk & safe routes", style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // Helper widget for the Community entry point
  Widget _buildCommunityButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[800],
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const CommunityScreen())
        ),
        icon: const Icon(Icons.groups, color: Colors.white),
        label: const Text(
          "DRIVER COMMUNITY & SOS", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }

  Widget _tripHistoryCard(Map<String, dynamic> data) {
    bool blackmarked = data['isBlackmarked'] ?? false;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: blackmarked ? Colors.red[50] : Colors.blue[50],
          child: Icon(
            blackmarked ? Icons.report_problem : Icons.person, 
            color: blackmarked ? Colors.red : Colors.blue
          ),
        ),
        title: Text("Customer: ${data['customerName'] ?? 'Anonymous'}", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("From: ${data['from']}\nTo: ${data['to']}", style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: data['riskLevel'] == "High Risk" ? Colors.red[100] : Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            data['riskLevel'] ?? 'Low', 
            style: TextStyle(
              color: data['riskLevel'] == "High Risk" ? Colors.red[900] : Colors.green[900], 
              fontWeight: FontWeight.bold,
              fontSize: 10
            )
          ),
        ),
      ),
    );
  }
}




