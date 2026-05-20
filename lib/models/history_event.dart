import 'package:flutter/foundation.dart';

enum DetectionStatus { alert, warning, safe }
enum DetectionSource { camera, sensor }

class HistoryEvent {
  final String id;
  final String imagePath;
  final DateTime timestamp;
  final DetectionStatus status;
  final DetectionSource source;

  HistoryEvent({
    required this.id,
    required this.imagePath,
    required this.timestamp,
    required this.status,
    required this.source,
  });
}
