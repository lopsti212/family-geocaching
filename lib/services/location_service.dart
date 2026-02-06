import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';

class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;

  // Singleton
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Prüfe und fordere Berechtigungen an
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Aktuelle Position einmalig abrufen
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Position Stream starten
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Mindestens 5 Meter Bewegung
      ),
    );
  }

  // Kompass Stream
  Stream<CompassEvent>? getCompassStream() {
    return FlutterCompass.events;
  }

  // Distanz zwischen zwei Punkten berechnen (in Metern)
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  // Richtung zum Ziel berechnen (in Grad, 0 = Nord)
  double calculateBearing(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.bearingBetween(startLat, startLng, endLat, endLng);
  }

  // Prüfen ob Ziel erreicht
  bool isTargetReached(
    Position currentPosition,
    double targetLat,
    double targetLng,
    double radiusInMeters,
  ) {
    final distance = calculateDistance(
      currentPosition.latitude,
      currentPosition.longitude,
      targetLat,
      targetLng,
    );
    return distance <= radiusInMeters;
  }

  // Zufälligen Punkt im Umkreis generieren (für Level 2 Hinweis)
  Map<String, double> getRandomPointInRadius(
    double centerLat,
    double centerLng,
    double radiusInMeters,
  ) {
    final random = Random();
    final angle = random.nextDouble() * 2 * pi;
    final distance = random.nextDouble() * radiusInMeters;

    // Umrechnung in Koordinaten
    final latOffset = (distance / 111320) * cos(angle);
    final lngOffset = (distance / (111320 * cos(centerLat * pi / 180))) * sin(angle);

    return {
      'latitude': centerLat + latOffset,
      'longitude': centerLng + lngOffset,
    };
  }

  // Ressourcen freigeben
  void dispose() {
    _positionSubscription?.cancel();
    _compassSubscription?.cancel();
  }
}
