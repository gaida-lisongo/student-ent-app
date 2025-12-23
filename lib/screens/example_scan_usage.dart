import 'package:flutter/material.dart';
import 'package:student_app/screens/scanner_screen.dart';

// Exemple d'utilisation du ScannerScreen dans un autre contexte
// (par exemple, pour scanner des bulletins de notes)
class ExampleScanUsage extends StatelessWidget {
  const ExampleScanUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exemples d\'utilisation Scanner')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Voici différents exemples d\'utilisation du ScannerScreen:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Exemple 1: Scan immédiat (comme pour l'authentification)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ScannerScreen(
                      title: 'Scanner Authentification',
                      onScanDataReceived: (String data) {
                        // Traitement immédiat des données
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Données scannées: $data'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context); // Retour automatique
                      },
                      showActionButton:
                          false, // Pas de bouton, traitement immédiat
                    ),
                  ),
                );
              },
              child: const Text('Scan avec traitement immédiat'),
            ),

            const SizedBox(height: 10),

            // Exemple 2: Scan avec confirmation (bouton d'action)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ScannerScreen(
                      title: 'Scanner Bulletin',
                      onScanDataReceived: (String data) {
                        // Traitement des données après confirmation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Bulletin traité: $data'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      showActionButton: true,
                      actionButtonText: 'Traiter Bulletin',
                      onActionButtonPressed: () {
                        // Action supplémentaire avant le traitement si nécessaire
                        print('Bouton d\'action pressé!');
                      },
                    ),
                  ),
                );
              },
              child: const Text('Scan avec bouton de confirmation'),
            ),

            const SizedBox(height: 10),

            // Exemple 3: Scan de ressources pédagogiques
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ScannerScreen(
                      title: 'Scanner Ressource',
                      onScanDataReceived: (String data) {
                        // Traitement spécialisé pour les ressources
                        _handleResourceScan(context, data);
                      },
                      showActionButton: false,
                    ),
                  ),
                );
              },
              child: const Text('Scan de ressources'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleResourceScan(BuildContext context, String data) {
    // Exemple de traitement spécialisé
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ressource Détectée'),
        content: Text('URL de la ressource:\n$data'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fermer le dialog
              Navigator.pop(context); // Fermer le scanner
            },
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
