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

  // Function to send a standard message or an SOS
  void _sendMessage({String? text, bool isSOS = false}) async {
    if (!isSOS && _msgController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection('community_messages').add({
      'senderId': user?.uid,
      'senderName': user?.email?.split('@')[0] ?? "Driver",
      'text': isSOS ? "🚨 SOS! EMERGENCY NEARBY! 🚨" : _msgController.text,
      'isSOS': isSOS,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Drivers Community")),
      body: Column(
        children: [
          // 1. SOS BUTTON (DUMMY ALERT)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => _sendMessage(isSOS: true),
              icon: const Icon(Icons.warning, color: Colors.white),
              label: const Text("SEND EMERGENCY SOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),

          // 2. CHAT MESSAGES
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
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    bool isMe = data['senderId'] == user?.uid;
                    bool isSOS = data['isSOS'] ?? false;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSOS ? Colors.red : (isMe ? Colors.blue[100] : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['senderName'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: isSOS ? Colors.white : Colors.black)),
                            Text(data['text'], style: TextStyle(color: isSOS ? Colors.white : Colors.black)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 3. INPUT FIELD
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _msgController, decoration: const InputDecoration(hintText: "Chat with nearby drivers..."))),
                IconButton(icon: const Icon(Icons.send), onPressed: () => _sendMessage()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}