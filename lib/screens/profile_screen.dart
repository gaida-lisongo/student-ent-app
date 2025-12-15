import 'dart:io'; // Nécessaire pour File

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Importation nécessaire

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

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  // Données de l'utilisateur (Mock data)
  String userName = "Alice Dupont";
  String matricule = "STD-2024-001";
  String telephone = "+243 81 000 0001";
  String email = "alice.dupont@student.edu";

  // Stockage local de la photo sélectionnée
  File? _imageFile;
  String _avatarSeed = "Alice Dupont";

  // --- LOGIQUE DE SELECTION DE PHOTO (image_picker) ---
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickNewPhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil mise à jour localement.'),
        ),
      );
    }
  }

  // --- MODALE RÉUTILISABLE (Builder Pattern) ---
  void _showEditModal({
    required String title,
    required Widget formContent,
    required VoidCallback onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      transitionAnimationController: AnimationController(
        // Contrôleur pour l'animation personnalisée
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
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
              // Poignée
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
              // Titre
              Text(
                'Modifier $title',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Contenu du Formulaire
              formContent,

              const SizedBox(height: 30),
              // Bouton Sauvegarder
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onSave();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Bouton noir
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Sauvegarder',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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

  // --- WIDGETS DE FORMULAIRE CHICS (Nouvelles couleurs/styles) ---

  // Style élégant pour les champs de texte
  InputDecoration _chicInputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.grey.shade700),
      floatingLabelStyle: const TextStyle(color: Colors.indigo), // Bleu chic
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.indigo,
          width: 2.0,
        ), // Mieux en focus
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(decoration: _chicInputDecoration('Nom')),
        const SizedBox(height: 15),
        TextFormField(decoration: _chicInputDecoration('Post Nom')),
        const SizedBox(height: 15),
        TextFormField(decoration: _chicInputDecoration('Prénom')),
        const SizedBox(height: 15),
        TextFormField(decoration: _chicInputDecoration('Lieu de Naissance')),
        const SizedBox(height: 15),
        TextFormField(
          decoration: _chicInputDecoration('Date de Naissance'),
          keyboardType: TextInputType.datetime,
        ),
      ],
    );
  }

  Widget _buildAddressForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          decoration: _chicInputDecoration('Adresse Complète'),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildContactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          decoration: _chicInputDecoration('Téléphone', hint: telephone),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 15),
        TextFormField(
          decoration: _chicInputDecoration('Email', hint: email),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc pur
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20.0,
            20.0,
            20.0,
            80.0,
          ), // Ajouter du padding en bas pour la barre flottante
          children: <Widget>[
            // 1. Titre de la page
            const Text(
              'Mon Profil',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900, // Extra Bold
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 35),

            // 2. Photo de l'avatar et sélection (Stylisation BackdropFilter)
            _buildAvatarSection(context),
            const SizedBox(height: 20),

            // 3. Nom et Matricule
            Center(
              child: Column(
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 24,
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
            const SizedBox(height: 40),

            // 4. Section des Informations Modifiables
            _buildProfileCard(
              icon: Icons.person_outline,
              title: "Informations Personnelles",
              subtitle: "Nom, post-nom, prénom, sexe, date de naissance...",
              onTap: () => _showEditModal(
                title: "les informations personnelles",
                formContent: _buildPersonalInfoForm(),
                onSave: () {
                  /* Logique de sauvegarde */
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
                  /* Logique de sauvegarde */
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
                  /* Logique de sauvegarde */
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // WIDGETS DE COMPOSANTS RÉUTILISABLES STYLISÉS
  // ----------------------------------------------------

  // 1. Section Avatar avec Photo Locale/Réseau et Bouton de Modification
  Widget _buildAvatarSection(BuildContext context) {
    // Déterminer la source de l'image
    ImageProvider imageProvider;
    if (_imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    } else {
      imageProvider = NetworkImage(AvatarService.getAvatarUrl(_avatarSeed));
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60, // Augmenter la taille
            backgroundImage: imageProvider,
            backgroundColor: Colors.grey.shade100,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickNewPhoto,
              child: Container(
                padding: const EdgeInsets.all(8), // Plus grand
                decoration: BoxDecoration(
                  color: Colors.indigo, // Bleu foncé chic
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Carte d'Information (Design minimaliste chic)
  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0, // Enlever l'ombre pour un look plus plat/moderne
      color: Colors.grey.shade50, // Fond très clair
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200, width: 1), // Bordure fine
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Icône de la section (Couleur bleue chic)
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.indigo, size: 24),
        ),
        // Titre et Sous-titre
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600, // Semi-bold
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        // Icône de navigation (flèche)
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
}
