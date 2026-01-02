import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data);
  }

  Future<void> updateTrip(String uid, Map<String, dynamic> tripData) async {
    await _db.collection('trips').doc(uid).set(tripData, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> getTripStream(String uid) {
    return _db.collection('trips').doc(uid).snapshots();
  }
}
