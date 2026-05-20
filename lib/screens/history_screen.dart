import 'package:flutter/material.dart';
import '../models/history_event.dart';
import '../services/history_service.dart';
import '../theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Écouter les changements pour mettre à jour l'interface quand un événement est ajouté
    historyService.addListener(_onHistoryChanged);
  }

  @override
  void dispose() {
    historyService.removeListener(_onHistoryChanged);
    super.dispose();
  }

  void _onHistoryChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bg : AppColors.bgLight;
    final events = historyService.events;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des Alertes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: () {
              historyService.clearHistory();
            },
            tooltip: "Effacer l'historique",
          )
        ],
      ),
      backgroundColor: bgColor,
      body: events.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: (isDark ? AppColors.subText : AppColors.subTextLight).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Aucun événement enregistré.",
                    style: TextStyle(
                      color: isDark ? AppColors.subText : AppColors.subTextLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return _buildHistoryCard(events[index], isDark);
              },
            ),
    );
  }

  Widget _buildHistoryCard(HistoryEvent event, bool isDark) {
    final cardColor = isDark ? AppColors.card : AppColors.cardLight;
    final subColor = isDark ? AppColors.subText : AppColors.subTextLight;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (event.status) {
      case DetectionStatus.alert:
        statusColor = AppColors.redAlert;
        statusText = "Alerte Feu";
        statusIcon = Icons.local_fire_department_rounded;
        break;
      case DetectionStatus.warning:
        statusColor = AppColors.orange;
        statusText = "Avertissement";
        statusIcon = Icons.warning_rounded;
        break;
      case DetectionStatus.safe:
        statusColor = AppColors.green;
        statusText = "Sécurisé";
        statusIcon = Icons.check_circle_rounded;
        break;
    }

    final day = event.timestamp.day.toString().padLeft(2, '0');
    final month = event.timestamp.month.toString().padLeft(2, '0');
    final year = event.timestamp.year;
    final hour = event.timestamp.hour.toString().padLeft(2, '0');
    final minute = event.timestamp.minute.toString().padLeft(2, '0');
    final formattedDate = "$day/$month/$year à $hour:$minute";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: SizedBox(
              width: 110,
              child: Image.asset(
                event.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: statusColor.withOpacity(0.1),
                  child: Icon(Icons.broken_image_rounded, color: statusColor),
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, color: subColor, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: TextStyle(color: subColor, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        event.source == DetectionSource.camera
                            ? Icons.videocam_rounded
                            : Icons.sensors_rounded,
                        color: subColor,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Source: ${event.source == DetectionSource.camera ? 'Caméra' : 'Capteur'}",
                        style: TextStyle(color: subColor, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
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
