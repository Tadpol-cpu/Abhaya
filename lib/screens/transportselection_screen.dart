import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import '../theme/colors.dart';

class TransportSelectionScreen extends StatefulWidget {
  final String passedLanguage;
  const TransportSelectionScreen({super.key, required this.passedLanguage});

  @override
  State<TransportSelectionScreen> createState() => _TransportSelectionScreenState();
}

class _TransportSelectionScreenState extends State<TransportSelectionScreen> {
  final List<String> modes = ['Auto', 'Bike', 'Scooty', 'Car'];
  String selectedMode = 'Auto';
  bool _isSaving = false;

  Future<void> _completeSetup() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'preferredLanguage': widget.passedLanguage,
        'transportMode': selectedMode,
        'setupComplete': true,
      });
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE8E8),
      appBar: AppBar(title: const Text("Mode Of Transport"), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Please Select Your Mode of Transport"),
            const SizedBox(height: 30),
            ...modes.map((mode) => GestureDetector(
              onTap: () => setState(() => selectedMode = mode),
              child: Container(
                width: double.infinity, margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: selectedMode == mode ? AppColors.primaryRed : Colors.transparent, width: 2),
                ),
                child: Text(mode, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            )).toList(),
            const Spacer(),
            _isSaving ? const CircularProgressIndicator() : SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.softRed),
                onPressed: _completeSetup,
                child: const Text("Finish", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}