import 'dart:async';
import 'package:firebase_database/firebase_database.dart';


class RobotLiveData {
  final String status;
  final String mode;
  final double temperature;
  final int gas;
  final bool flame;
  final double distance;
  final bool fire;
  final String fireColor;
  final String cause;
  final int urgency;
  final int confidence;

  RobotLiveData({
    required this.status,
    required this.mode,
    required this.temperature,
    required this.gas,
    required this.flame,
    required this.distance,
    required this.fire,
    required this.fireColor,
    required this.cause,
    required this.urgency,
    required this.confidence,
  });

  factory RobotLiveData.fromMap(Map data) {
    final sensors = Map.from(data["sensors"] ?? {});
    final ai = Map.from(data["ai"] ?? {});
    final decision = Map.from(data["decision"] ?? {});

    return RobotLiveData(
      status: data["status"]?.toString() ?? "UNKNOWN",
      mode: data["mode"]?.toString() ?? "UNKNOWN",

      temperature:
      double.tryParse((sensors["temperature"] ?? 0).toString()) ?? 0,

      gas:
      int.tryParse((sensors["gas"] ?? 0).toString()) ?? 0,

      flame:
      sensors["flame"] == true,

      distance:
      double.tryParse((sensors["distance"] ?? 0).toString()) ?? 0,
      
      fire:
      ai["fire"] == true,

      fireColor:
      ai["fire_color"]?.toString() ?? "unknown",

      cause:
      decision["probable_cause"]?.toString() ?? "Unknown",

      urgency:
      int.tryParse((decision["urgency"] ?? 0).toString()) ?? 0,

      confidence:
      int.tryParse((decision["confidence"] ?? 0).toString()) ?? 0,
    );
  }
}

class FirebaseRobotService {
  FirebaseRobotService._();

  static final FirebaseRobotService instance = FirebaseRobotService._();

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Stream<bool> get connectionStream {
    return _db.child(".info/connected").onValue.map((event) {
      return event.snapshot.value == true;
    });
  }

  Future<bool> get isConnected async {
    final snapshot = await _db.child(".info/connected").get();
    return snapshot.value == true;
  }

  Stream<RobotLiveData> get liveDataStream {
    return _db.child("robot/live").onValue.map((event) {
      final value = event.snapshot.value;

      if (value == null) {
        return RobotLiveData(
          status: "NO DATA",
          mode: "UNKNOWN",
          temperature: 0,
          gas: 0,
          flame: false,
          distance: 0,
          fire: false,
          fireColor: "unknown",
          cause: "No data",
          urgency: 0,
          confidence: 0,
        );
      }

      return RobotLiveData.fromMap(Map.from(value as Map));
    });
  }

  Future<void> sendCommand(String command) async {
    await _db.child("robot/command").set({
      "value": command,
      "timestamp": ServerValue.timestamp,
    });
  }

  Future<void> forward() => sendCommand("FORWARD");
  Future<void> backward() => sendCommand("BACKWARD");
  Future<void> left() => sendCommand("LEFT");
  Future<void> right() => sendCommand("RIGHT");
  Future<void> stop() => sendCommand("STOP");
  Future<void> autoMode() => sendCommand("AUTO");
  Future<void> manualMode() => sendCommand("MANUAL");
}

final firebaseRobotService = FirebaseRobotService.instance;