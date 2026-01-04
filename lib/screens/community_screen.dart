import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart'; 
import 'package:permission_handler/permission_handler.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _msgController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  
  String _displayName = "Driver"; 
  String _currentDestination = "Fetching history..."; 
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _fetchUserData(); 
  }

  // 1. DATA FETCH: Pulls latest history for the SOS
  Future<void> _fetchUserData() async {
    if (user == null) return;
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (userDoc.exists && mounted) {
        setState(() { _displayName = userDoc.data()?['name'] ?? "Driver"; });
      }

      final lastTrip = await FirebaseFirestore.instance
          .collection('users').doc(user!.uid).collection('past_trips')
          .orderBy('timestamp', descending: true).limit(1).get();

      if (lastTrip.docs.isNotEmpty && mounted) {
        var data = lastTrip.docs.first.data();
        setState(() { 
          _currentDestination = data['destination'] ?? data['to'] ?? "Recent Trip"; 
        });
      } else {
        if (mounted) setState(() => _currentDestination = "No Destination History");
      }
    } catch (e) {
      if (mounted) setState(() => _currentDestination = "Error Loading History");
    }
  }

  // 2. PERFECT AUDIO: Handled with Permissions and Voice Engine
  void _toggleListening() async {
    if (!_isListening) {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        bool available = await _speech.initialize(
          onError: (val) => setState(() => _isListening = false),
        );

        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) {
              String words = val.recognizedWords.toLowerCase();
              if (words.contains("help") || words.contains("sos")) {
                _triggerSOS(isVoice: true); 
              }
            },
            listenFor: const Duration(seconds: 30),
            pauseFor: const Duration(seconds: 5),
            listenMode: stt.ListenMode.confirmation,
          );
        }
      }
    } else {
      _stopListening();
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  // 3. SOS TRIGGER
  void _triggerSOS({required bool isVoice}) async {
    if (isVoice) _stopListening(); 
    await _fetchUserData(); 
    
    String alertType = isVoice ? "🚨 VOICE ACTIVATED SOS! 🚨" : "🚨 MANUAL SOS ALERT! 🚨";
    _sendMessage(customText: "$alertType\nHeading to: $_currentDestination", isSOS: true);
  }

  // 4. MESSAGE SENDING
  void _sendMessage({String? customText, bool isSOS = false}) async {
    String msgText = customText ?? _msgController.text.trim();
    if (msgText.isEmpty) return;

    await FirebaseFirestore.instance.collection('community_messages').add({
      'senderId': user?.uid,
      'senderName': _displayName, 
      'text': msgText,
      'isSOS': isSOS,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE8E8),
      appBar: AppBar(
        title: const Text("Drivers Community"),
        actions: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none, 
                 color: _isListening ? Colors.red : Colors.black),
            onPressed: _toggleListening,
          )
        ],
      ),
      body: Column(
        children: [
          if (_isListening)
            Container(
              width: double.infinity,
              color: Colors.red,
              padding: const EdgeInsets.all(8),
              child: const Text("LISTENING FOR 'HELP' OR 'SOS'...", 
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 55)),
              onPressed: () => _triggerSOS(isVoice: false), 
              icon: const Icon(Icons.warning, color: Colors.white),
              label: const Text("SEND SOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('community_messages').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    bool isMe = data['senderId'] == user?.uid;
                    bool isSOS = data['isSOS'] ?? false;

                    // Date and Time Formatting
                    String formattedDateTime = "";
                    if (data['timestamp'] != null) {
                      DateTime dt = (data['timestamp'] as Timestamp).toDate();
                      formattedDateTime = DateFormat('MMM d, hh:mm a').format(dt);
                    }

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSOS ? Colors.red : (isMe ? Colors.blue[100] : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(data['senderName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                            const SizedBox(height: 4),
                            Text(data['text'], style: TextStyle(color: isSOS ? Colors.white : Colors.black)),
                            const SizedBox(height: 6),
                            Text(
                              formattedDateTime,
                              style: TextStyle(
                                fontSize: 8,
                                color: isSOS ? Colors.white70 : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _msgController, decoration: const InputDecoration(hintText: "Type message..."))),
                IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: () => _sendMessage()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}