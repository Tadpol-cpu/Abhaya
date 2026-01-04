import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'ongoing_trip_screen.dart';

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
              // 1. Sign out from Firebase
              await FirebaseAuth.instance.signOut(); 
              // 2. THE FIX: Clear the navigation stack so the Auth Gate works
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildNewTripButton(context),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(alignment: Alignment.centerLeft, child: Text("Trip History", style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users').doc(uid).collection('past_trips')
                  .orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
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
        // RANDOM RISK SCORE GENERATOR
        double randomRisk = (Random().nextDouble() * 9) + 1;
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => OngoingTripScreen(riskScore: double.parse(randomRisk.toStringAsFixed(1))))
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.purple, Colors.blue]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Start New Trip", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _tripHistoryCard(Map<String, dynamic> data) {
    bool blackmarked = data['isBlackmarked'] ?? false;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(blackmarked ? Icons.report_problem : Icons.person, color: blackmarked ? Colors.red : Colors.blue),
        title: Text("Customer: ${data['customerName']}"),
        subtitle: Text("From: ${data['from']}\nTo: ${data['to']}"),
        trailing: Text(data['riskLevel'] ?? 'Low', style: TextStyle(color: data['riskLevel'] == "High Risk" ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
      ),
    );
  }
}




