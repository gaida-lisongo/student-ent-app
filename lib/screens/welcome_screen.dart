import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/components/custom_button.dart';
import 'package:student_app/stores/auth_provider.dart';
import 'package:student_app/stores/student_provider.dart';
import 'package:student_app/stores/annee_provider.dart';
import 'package:student_app/model/inscription_model.dart';

// Le WelcomeScreen doit être un ConsumerWidget pour interagir avec Riverpod
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  // URL de simulation fournie
  static const String simulationUrl = '/parcours/6926d4e09c74cc9b8856a323';

  // Fonction pour gérer le résultat du scan (ou de la simulation)
  void handleAuthScanResult(
    BuildContext context,
    WidgetRef ref,
    String rawData,
  ) async {
    // 1. Lancer l'état de chargement et le processus de connexion
    final authNotifier = ref.read(authProvider.notifier);

    // Fermer l'écran de scan s'il est ouvert (important pour la navigation)
    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.pop(context);
    }

    // Affiche un indicateur de chargement global
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tentative de connexion...'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    try {
      // 2. Déclencher la connexion via le Provider
      print('Raw data from scan/simulation: $rawData');

      final inscriptionData = await authNotifier.login(rawData);

      // 3. Vérifier le résultat SEULEMENT si le widget est toujours monté
      if (!context.mounted) return;

      if (inscriptionData['success'] == true &&
          inscriptionData['data'] != null) {
        // Récupérer les données de l'inscription depuis la réponse
        final data = inscriptionData['data'] as Map<String, dynamic>;

        // Créer l'objet InscriptionData depuis les données
        final inscription = InscriptionData.fromJson({'data': data});

        final etudiantNotifier = ref.read(etudiantProvider.notifier);
        // Sauvegarder l'étudiant localement
        await etudiantNotifier.setEtudiant(inscription.etudiant);

        // Invalider les providers pour qu'ils se rechargent
        ref.invalidate(anneeProvider);

        // Succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bienvenue, ${inscription.etudiant.prenom}!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Échec
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur de connexion: ${inscriptionData['message'] ?? 'Erreur inconnue'}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Nouvelle fonction pour simuler le scan (déclenchement direct)
  void _startSimulationLogin(BuildContext context, WidgetRef ref) {
    handleAuthScanResult(context, ref, simulationUrl);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écouter l'état d'authentification
    final authState = ref.watch(authProvider);
    final etudiantState = ref.watch(etudiantProvider);

    // Déterminer si on est en train de charger
    final isLoading = authState.isLoading || etudiantState.isLoading;

    return Scaffold(
      body: Stack(
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
                    opacity: isLoading ? 0.6 : 1.0,
                    child: CustomButton(
                      title: isLoading
                          ? 'CONNEXION EN COURS...'
                          : 'SIMULATION AUTHENTIFICATION',
                      icon: Icons.login,
                      onTap: isLoading
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
