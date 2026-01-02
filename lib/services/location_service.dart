import 'package:geolocator/geolocator.dart';
import 'firestore_service.dart';

class LocationService {
  final FirestoreService _firestore = FirestoreService();

  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  void startTracking(String uid) {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      _firestore.updateTrip(uid, {
        'currentLocation': {'lat': position.latitude, 'lng': position.longitude},
        'lastUpdated': DateTime.now(),
      });
    });
  }
}
