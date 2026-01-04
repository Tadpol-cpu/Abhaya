import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _msgController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  String _displayName = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchNameFromSignup();
  }

  // 1. FETCH THE 'name' FIELD FROM SIGNUP
  Future<void> _fetchNameFromSignup() async {
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      
      if (userDoc.exists && mounted) {
        setState(() {
          // This matches the 'name' field saved in your Signup Screen
          _displayName = userDoc.data()?['name'] ?? "Driver";
        });
      }
    }
  }

  // 2. SEND MESSAGE/SOS LOGIC
  void _sendMessage({String? text, bool isSOS = false}) async {
    if (!isSOS && _msgController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection('community_messages').add({
      'senderId': user?.uid,
      'senderName': _displayName, // Broadcasts the User's Name
      'text': isSOS ? "🚨 SOS! EMERGENCY! 🚨" : _msgController.text,
      'isSOS': isSOS,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE8E8), // Matches your app theme
      appBar: AppBar(
        title: const Text("Drivers Community", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // SOS BUTTON SECTION
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () => _sendMessage(isSOS: true),
              icon: const Icon(Icons.emergency_share, color: Colors.white),
              label: const Text("BROADCAST SOS ALERT", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),

          // CHAT STREAM
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('community_messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    bool isMe = data['senderId'] == user?.uid;
                    bool isSOS = data['isSOS'] ?? false;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isSOS ? Colors.red : (isMe ? Colors.blue[100] : Colors.white),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(15),
                            topRight: const Radius.circular(15),
                            bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(15),
                          ),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // DISPLAYS THE NAME FROM SIGNUP
                            Text(data['senderName'], 
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 11, 
                                color: isSOS ? Colors.white70 : Colors.blueGrey)),
                            const SizedBox(height: 3),
                            Text(data['text'], 
                              style: TextStyle(
                                color: isSOS ? Colors.white : Colors.black,
                                fontWeight: isSOS ? FontWeight.bold : FontWeight.normal)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // MESSAGE INPUT BOX
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: "Chat with active drivers...",
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}