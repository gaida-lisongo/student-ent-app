import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/components/custom_button.dart';
import 'package:student_app/stores/autth_provider.dart';

// Le WelcomeScreen doit être un ConsumerWidget pour interagir avec Riverpod
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  // URL de simulation fournie
  static const String simulationUrl =
      'http://172.20.10.14:3000/api/parcours/6926d4e09c74cc9b8856a323';

  // Fonction pour gérer le résultat du scan (ou de la simulation)
  void handleAuthScanResult(
    BuildContext context,
    WidgetRef ref,
    String rawData,
  ) async {
    // 1. Lancer l'état de chargement et le processus de connexion
    // Le AuthNotifier gère l'état et le stockage sécurisé.
    final authNotifier = ref.read(authProvider.notifier);

    // Fermer l'écran de scan s'il est ouvert (important pour la navigation)
    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.pop(context);
    }

    // Affiche un indicateur de chargement global si le ProviderScope ne le gère pas
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tentative de connexion...'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    // 2. Déclencher la connexion via le Provider
    await authNotifier.signIn(rawData);

    // 3. Vérifier le résultat SEULEMENT si le widget est toujours monté
    if (!context.mounted) return;

    final authState = ref.read(authProvider);
    if (authState.user != null) {
      // Succès: La navigation vers Dashboard est gérée par AuthChecker dans main.dart
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bienvenue, ${authState.user!.etudiant.prenom}!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (authState.errorMessage != null) {
      // Échec
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion: ${authState.errorMessage}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Nouvelle fonction pour simuler le scan (déclenchement direct)
  void _startSimulationLogin(BuildContext context, WidgetRef ref) {
    handleAuthScanResult(context, ref, simulationUrl);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écouter l'état pour afficher les erreurs si nécessaire, mais l'UI est simple
    final authState = ref.watch(authProvider);

    // Le bouton S'AUTHENTIFIER devient le bouton SIMULATION pour l'étape actuelle
    return Scaffold(
      body: Stack(
        // ... (Contenu du Stack inchangé : Image, Dégradé) ...
        children: [
          // 1. Image de fond
          Positioned.fill(
            child: Image.asset(
              'assets/images/wallpaper.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.black);
              },
            ),
          ),

          // 2. Calque de dégradé
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.4, 0.8],
                ),
              ),
            ),
          ),

          // 3. Contenu (Texte et Bouton)
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Texte de Bienvenue
                const Text(
                  'Bienvenue !',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Description
                const Text(
                  'Simulation : Cliquez sur le bouton pour vous authentifier directement avec les données de test (QR Code de l\'ENT).',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.yellow, // Mettre en évidence la simulation
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 50),

                // Bouton de Simulation / Authentification
                Center(
                  child: Opacity(
                    opacity: authState.isLoading ? 0.6 : 1.0,
                    child: CustomButton(
                      title: authState.isLoading
                          ? 'CONNEXION EN COURS...'
                          : 'SIMULATION AUTHENTIFICATION',
                      icon: Icons.login,
                      onTap: authState.isLoading
                          ? () {} // Callback vide pour désactiver
                          : () => _startSimulationLogin(context, ref),
                      isDarkMode: true,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Credit By ELMES
                const Center(
                  child: Text(
                    'Crédit By ELMES',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white38,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
