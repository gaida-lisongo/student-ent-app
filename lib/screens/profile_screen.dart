import 'package:flutter/material.dart';

// Service utilitaire pour l'avatar (inchangé)
class AvatarService {
  static String getAvatarUrl(String seed) {
    return 'https://api.dicebear.com/8.x/lorelei/png?seed=$seed';
  }
}

// ----------------------------------------------------
// WIDGET PRINCIPAL
// ----------------------------------------------------

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Données de l'utilisateur (Mock data basé sur ton modèle)
  String userName = "Alice Dupont";
  String matricule = "STD-2024-001";
  String email = "alice.dupont@student.edu";
  String telephone = "+243 81 000 0001";
  String avatarSeed = "Alice Dupont";

  // Simulation de la sélection de photo (nécessite 'image_picker')
  void _pickNewPhoto() {
    // Si 'image_picker' est installé:
    // final ImagePicker picker = ImagePicker();
    // final XFile? photo = await picker.pickImage(source: ImageSource.gallery);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Déclenchement du sélecteur de photos via image_picker...',
        ),
      ),
    );
    // Simulation du changement
    setState(() {
      avatarSeed = 'NewAvatarSeed${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  // --- MODALE RÉUTILISABLE (Le Builder Pattern) ---
  // La fonction prend un Widget formContent à afficher
  void _showEditModal({
    required String title,
    required Widget formContent, // Le contenu du formulaire est passé ici
    required VoidCallback onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Modifier $title',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Affichage du Widget de formulaire passé en paramètre
              formContent,

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onSave(); // Appel de la logique de sauvegarde spécifique
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Sauvegarder',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGETS DE FORMULAIRE SPÉCIFIQUES ---

  // Formulaire pour Informations Personnelles (basé sur ton modèle)
  Widget _buildPersonalInfoForm() {
    return Column(
      children: const [
        TextField(
          decoration: InputDecoration(
            labelText: 'Nom',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            labelText: 'Post Nom',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            labelText: 'Prénom',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            labelText: 'Lieu de Naissance',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            labelText: 'Date de Naissance',
            border: OutlineInputBorder(),
          ),
        ),
        // Le sexe peut être un Dropdown
      ],
    );
  }

  // Formulaire pour Coordonnées
  Widget _buildAddressForm() {
    return Column(
      children: const [
        TextField(
          decoration: InputDecoration(
            labelText: 'Adresse Complète',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  // Formulaire pour Contact
  Widget _buildContactForm() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Téléphone',
            border: OutlineInputBorder(),
            hintText: telephone,
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            hintText: email,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  // Formulaire pour Changer le Mot de Passe
  Widget _buildPasswordChangeForm() {
    return Column(
      children: const [
        TextField(
          decoration: InputDecoration(
            labelText: 'Mot de Passe Actuel',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            labelText: 'Nouveau Mot de Passe',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            labelText: 'Confirmer Nouveau Mot de Passe',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            // ... (Titre, Avatar, Nom/Matricule - inchangé) ...
            const Text(
              'Mon Profil',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 25),
            _buildAvatarSection(context),
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Matricule: $matricule',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 4. Section des Informations Modifiables (Utilisation du Builder Pattern)
            _buildProfileCard(
              icon: Icons.person_outline,
              title: "Informations Personnelles",
              subtitle: "Nom, post-nom, prénom, sexe, date de naissance...",
              onTap: () => _showEditModal(
                title: "les informations personnelles",
                formContent:
                    _buildPersonalInfoForm(), // Passe le widget du formulaire
                onSave: () {
                  // Logique de sauvegarde des informations personnelles ici
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Informations personnelles sauvegardées !'),
                    ),
                  );
                },
              ),
            ),
            _buildProfileCard(
              icon: Icons.location_on_outlined,
              title: "Coordonnées",
              subtitle: "Adresse physique...",
              onTap: () => _showEditModal(
                title: "les coordonnées",
                formContent: _buildAddressForm(),
                onSave: () {
                  // Logique de sauvegarde des coordonnées ici
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coordonnées sauvegardées !')),
                  );
                },
              ),
            ),
            _buildProfileCard(
              icon: Icons.phone_outlined,
              title: "Contact",
              subtitle: "Numéro de téléphone, email...",
              onTap: () => _showEditModal(
                title: "le contact",
                formContent: _buildContactForm(),
                onSave: () {
                  // Logique de sauvegarde du contact ici
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact sauvegardé !')),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            // CHANGEMENT DE MOT DE PASSE (Mot clé ajusté)
            _buildProfileCard(
              icon: Icons.lock_outline,
              title: "Changer le Mot de Passe", // Libellé ajusté
              subtitle: "Sécurité du compte",
              onTap: () => _showEditModal(
                title: "le mot de passe",
                formContent: _buildPasswordChangeForm(),
                onSave: () {
                  // Logique de changement de mot de passe ici
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mot de passe changé avec succès !'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // WIDGETS DE COMPOSANTS RÉUTILISABLES (Inchangés/Simplifiés)
  // ----------------------------------------------------

  Widget _buildAvatarSection(BuildContext context) {
    // ... (Logique inchangée)
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              AvatarService.getAvatarUrl(avatarSeed),
            ),
            backgroundColor: Colors.grey.shade200,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickNewPhoto,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap, // Simplifié : pas besoin de 'section' ici
  }) {
    // ... (Logique inchangée)
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: Colors.deepPurple, size: 30),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
