import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
class MapScreen extends StatelessWidget {
  static const routeName = '/map';
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Carte (démo)")),
      drawer: const AppDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.map, size: 64),
              const SizedBox(height: 12),
              const Text(
                "Carte en mode démo.\n\nQuand tu seras prête, je te donne la version Google Maps (avec API Key) + géolocalisation.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Retour"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}