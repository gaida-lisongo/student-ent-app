import 'package:flutter/material.dart';
import 'package:student_app/components/custom_button.dart';
// Importer le CustomElevatedButton si vous l'avez mis dans un fichier séparé
// import 'package:votre_projet/widgets/custom_elevated_button.dart';

// (Si vous n'avez pas créé de fichier séparé, utilisez la classe CustomElevatedButton ci-dessus dans ce fichier.)

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Fonction factice (mock) pour la navigation vers l'écran de scan
  void _navigateToScanScreen(BuildContext context) {
    // Remplacer plus tard par la navigation réelle vers le QR code scanner
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers l\'écran de Scan du QR Code...'),
        duration: Duration(seconds: 1),
      ),
    );
    // Exemple de navigation (à ajuster)
    // Navigator.push(context, MaterialPageRoute(builder: (context) => ScanScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Image de fond
          Positioned.fill(
            child: Image.asset(
              'images/wallpaper.jpg',
              fit: BoxFit.cover,
              // Utiliser un `errorBuilder` pour éviter les erreurs visibles si l'asset est manquant
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
                    Colors.black.withOpacity(
                      0.9,
                    ), // Très opaque en bas pour le texte
                    Colors.black.withOpacity(0.6),
                    Colors.transparent, // Transparent en haut
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.4, 0.8], // Contrôle de la transition
                ),
              ),
            ),
          ),

          // 3. Contenu (Texte et Bouton)
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Aligner le contenu en bas
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

                // Description de la Plateforme (ENT)
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
                    icon:
                        Icons.qr_code_scanner, // Icône suggérée pour le scan QR
                    onTap: () => _navigateToScanScreen(context),
                    // Nous forçons le isDarkMode à true pour un look contrasté sur le fond sombre
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

// ----------------------------------------------------
// NOTE: N'oubliez pas d'inclure la définition de 
// CustomElevatedButton (voir section 1)
// ----------------------------------------------------