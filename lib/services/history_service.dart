import 'package:flutter/foundation.dart';
import '../models/history_event.dart';

class HistoryService extends ChangeNotifier {
  // Liste en mémoire pour stocker l'historique
  final List<HistoryEvent> _events = [
    // Mock data for demonstration
    HistoryEvent(
      id: 'evt_1',
      imagePath: 'assets/images/firetree2.jpg', // Using an existing image
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      status: DetectionStatus.alert,
      source: DetectionSource.camera,
    ),
    HistoryEvent(
      id: 'evt_2',
      imagePath: 'assets/images/firetree2.jpg',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      status: DetectionStatus.warning,
      source: DetectionSource.sensor,
    ),
    HistoryEvent(
      id: 'evt_3',
      imagePath: 'assets/images/firetree2.jpg',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      status: DetectionStatus.safe,
      source: DetectionSource.camera,
    ),
  ];

  List<HistoryEvent> get events => List.unmodifiable(_events);

  void addEvent(HistoryEvent event) {
    _events.insert(0, event); // Add new events at the top
    notifyListeners();
  }

  void clearHistory() {
    _events.clear();
    notifyListeners();
  }
}

// Instance globale (singleton) pour un accès facile
final historyService = HistoryService();
