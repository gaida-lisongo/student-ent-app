import 'package:flutter/material.dart';
// Assurez-vous que ces imports sont corrects dans votre projet
import 'package:student_app/components/custom_button.dart';
import 'package:student_app/screens/scanner_screen.dart'; // Importez votre ScannerScreen

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // ----------------------------------------------------
  // LOGIQUE DE TRAITEMENT DU SCAN D'AUTHENTIFICATION
  // ----------------------------------------------------

  // Cette fonction est la callback passée au ScannerScreen.
  // Elle est appelée soit immédiatement (si showActionButton est false),
  // soit lorsque le bouton "Se connecter" est cliqué.
  void handleAuthScanResult(BuildContext context, String rawData) {
    // 1. ARRÊTER LA NAVIGATION DU SCANNER
    // Nous avons les données, nous pouvons fermer l'écran du scanner.
    // NOTE: Si le ScannerScreen ne gère pas sa propre navigation de retour,
    // vous pourriez avoir besoin de le faire ici: Navigator.pop(context);

    // 2. LOGIQUE D'AUTHENTIFICATION AVEC LES DONNÉES BRUTES

    // Pour l'instant, on affiche une SnackBar de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Donnée scannée reçue: $rawData'),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
      ),
    );

    // TODO:
    // - Décoder `rawData` (JSON/Base64) pour extraire les identifiants ou l'endpoint.
    // - Appeler votre `AuthService` (via Riverpod, ou une simple classe) pour la requête API.
    // - Gérer la persistance de session (flutter_secure_storage) en cas de succès.
    // - Naviguer vers le Dashboard ou afficher une erreur.
  }

  // Fonction de navigation vers l'écran de scan
  void _navigateToScanScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(
          title: 'Scanner votre QR Code de Connexion',

          // --- Configuration pour le Workflow d'Authentification ---

          // 1. Afficher le bouton d'action après le scan
          showActionButton: true,
          actionButtonText: 'CONNEXION',

          // 2. Passer la callback de traitement des données
          // La donnée scannée (rawData) sera passée à cette fonction
          onScanDataReceived: (rawData) {
            // Ici, nous appelons la fonction de traitement avec le contexte
            handleAuthScanResult(context, rawData);
          },

          // 3. (Optionnel) : Callback pour le clic sur le bouton "CONNEXION"
          // Dans notre cas, la logique principale est dans onScanDataReceived,
          // mais vous pouvez utiliser ce champ pour une action distincte.
          onActionButtonPressed: () {
            // Optionnel: peut servir si vous vouliez délayer
            // le traitement des données scannées jusqu'au clic du bouton.
            // Actuellement, on utilise `onScanDataReceived` qui est appelé
            // lorsque le bouton est cliqué DANS le ScannerScreen.
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Image de fond (Corrigé le chemin d'accès)
          Positioned.fill(
            child: Image.asset(
              'assets/images/wallpaper.jpg', // Chemin d'accès standard 'assets/images/...'
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.black); // Fond noir de secours
              },
            ),
          ),

          // 2. Calque de dégradé (du bas vers le haut)
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
                // ... (Textes de Bienvenue et Description) ...
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

                const Text(
                  'Votre Espace Numérique de Travail (ENT) personnel. Suivez votre activité académique, consultez vos résultats et gérez votre cycle d\'études en toute simplicité.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 50),

                // Bouton d'Authentification (Custom Button)
                Center(
                  child: CustomButton(
                    title: 'S\'AUTHENTIFIER',
                    icon: Icons.qr_code_scanner,
                    onTap: () => _navigateToScanScreen(
                      context,
                    ), // Appel de la fonction de navigation
                    isDarkMode: true,
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
