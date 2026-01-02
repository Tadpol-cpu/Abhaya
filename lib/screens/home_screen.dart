import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/colors.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Function to handle logout
  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        // Redirect to Login Page and clear the navigation stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes the default back button
        title: const Text(
          "ABHAYA",
          style: TextStyle(
            color: AppColors.primaryRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // LOGOUT BUTTON
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            onPressed: () => _handleLogout(context),
            tooltip: "Logout",
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Start New Trip Button (Gradient)
            _buildNewTripButton(),

            // 2. Tab Switcher (History / Community)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTab(Icons.history, "History", true),
                  _buildTab(Icons.people_outline, "Community", false),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft, 
                child: Text(
                  "Recent Trips", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                )
              ),
            ),

            // 3. Trip Cards List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _tripHistoryCard("TRP001", "T Nagar", "Velachery", "Low Risk", Colors.green),
                  _tripHistoryCard("TRP002", "Anna Nagar", "OMR", "Medium", Colors.orange),
                  _tripHistoryCard("TRP003", "Mylapore", "Tambaram", "High Risk", Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewTripButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFB06AB3), Color(0xFF4568DC)]),
        borderRadius: BorderRadius.circular(40),
      ),
      child: InkWell(
        onTap: () {
          // Future navigation to Risk Assessment Screen
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Start New Trip", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        Icon(icon, color: isActive ? Colors.purple : Colors.grey),
        Text(label, style: TextStyle(color: isActive ? Colors.purple : Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _tripHistoryCard(String id, String from, String to, String risk, Color riskColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Trip ID: $id", style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: riskColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(risk, style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 11)),
                )
              ],
            ),
            const Divider(height: 20),
            _locationRow(Icons.circle_outlined, "From", from),
            const SizedBox(height: 8),
            _locationRow(Icons.location_on, "To", to),
          ],
        ),
      ),
    );
  }

  Widget _locationRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }
}




