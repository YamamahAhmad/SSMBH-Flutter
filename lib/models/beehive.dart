import 'package:firebase_database/firebase_database.dart';

class Beehive {
  final String id;
  String name;
  double currentWeight, maxWeightCapacity, temperature, humidity;
  bool isDoorOpen, alert, hasCamera;
  String reason, userId, doorControlMode;
  double latitude, longitude;
  String cameraUrl;

  Beehive({
    required this.id,
    required this.name,
    required this.userId,
    this.currentWeight = 0.0,
    this.maxWeightCapacity = 50.0,
    this.temperature = 0.0,
    this.humidity = 0.0,
    this.isDoorOpen = false,
    this.alert = false,
    this.reason = "N/A",
    this.hasCamera = false,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.doorControlMode = 'manual',
    this.cameraUrl = '',
  });

  factory Beehive.fromRtdb(DataSnapshot snapshot) {
    final map = Map<String, dynamic>.from(
      snapshot.value as Map,
    );
    final info = Map<String, dynamic>.from(
      map['info'] ?? {},
    );
    final data = Map<String, dynamic>.from(
      map['data'] ?? {},
    );

    print("📷 cameraUrl from Firebase = ${info['cameraUrl']}");

    return Beehive(
      id: snapshot.key!,
      name: info['name'] ?? 'Unnamed Beehive',
      userId: info['userId'] ?? '',
      maxWeightCapacity: (info['maxWeightCapacity'] ?? 50.0).toDouble(),
      hasCamera: info['hasCamera'] ?? false,
      doorControlMode: info['doorControlMode'] ?? 'manual',
      currentWeight: (data['weight_kg'] ?? 0.0).toDouble(),
      temperature: (data['temp'] ?? 0.0).toDouble(),
      humidity: (data['hum'] ?? 0.0).toDouble(),
      isDoorOpen: (info['doorState'] ?? 'closed') == 'open',
      alert: data['alert'] ?? false,
      reason: data['reason'] ?? 'Status OK',
      latitude: (data['lat'] ?? 0.0).toDouble(),
      longitude: (data['lng'] ?? 0.0).toDouble(),
      cameraUrl: info['cameraUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toInfoMap() => {
    'name': name,
    'userId': userId,
    'maxWeightCapacity': maxWeightCapacity,
    'hasCamera': hasCamera,
    'doorControlMode': doorControlMode,
  };
}