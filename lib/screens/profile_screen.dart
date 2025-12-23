// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_app/stores/student_provider.dart';
import 'package:student_app/stores/dio_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingPhoto = false;
  bool _isUpdating = false;

  // Contrôleurs pour les formulaires
  final _personalFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();

  // Contrôleurs de texte
  late TextEditingController _nomController;
  late TextEditingController _postnomController;
  late TextEditingController _prenomController;
  late TextEditingController _telephoneController;
  late TextEditingController _emailController;
  late TextEditingController _adresseController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _postnomController = TextEditingController();
    _prenomController = TextEditingController();
    _telephoneController = TextEditingController();
    _emailController = TextEditingController();
    _adresseController = TextEditingController();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _postnomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _isUploadingPhoto = true;
      });

      try {
        // Lire les bytes du fichier sélectionné
        final bytes = await pickedFile.readAsBytes();
        final filename = pickedFile.name.isNotEmpty
            ? pickedFile.name
            : 'profile_photo.jpg';

        final success = await ref
            .read(etudiantProvider.notifier)
            .uploadProfilePhotoFromBytes(bytes, filename);

        setState(() {
          _isUploadingPhoto = false;
        });

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo de profil mise à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la mise à jour de la photo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isUploadingPhoto = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _deletePhoto() async {
    final success = await ref
        .read(etudiantProvider.notifier)
        .deleteProfilePhoto();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo supprimée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression de la photo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updatePersonalInfo() async {
    if (!_personalFormKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    final updateData = {
      'nom': _nomController.text.trim(),
      'post_nom': _postnomController.text.trim(),
      'prenom': _prenomController.text.trim(),
    };

    final success = await ref
        .read(etudiantProvider.notifier)
        .updateProfile(updateData);

    if (mounted) {
      setState(() => _isUpdating = false);
      if (success) {
        // Forcer la mise à jour de l'UI
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informations personnelles mises à jour'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la mise à jour'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updatePhone() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    final updateData = {'telephone': _telephoneController.text.trim()};

    final success = await ref
        .read(etudiantProvider.notifier)
        .updateProfile(updateData);

    if (mounted) {
      setState(() => _isUpdating = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Numéro de téléphone mis à jour'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la mise à jour'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    final updateData = {'email': _emailController.text.trim()};

    final success = await ref
        .read(etudiantProvider.notifier)
        .updateProfile(updateData);

    if (mounted) {
      setState(() => _isUpdating = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email mis à jour'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la mise à jour'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateAddressInfo() async {
    if (!_addressFormKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    final updateData = {'adresse': _adresseController.text.trim()};

    final success = await ref
        .read(etudiantProvider.notifier)
        .updateProfile(updateData);

    if (mounted) {
      setState(() => _isUpdating = false);
      if (success) {
        // Forcer la mise à jour de l'UI
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adresse mise à jour'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la mise à jour'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- MODALE RÉUTILISABLE (Builder Pattern) ---
  void _showEditModal({
    required String title,
    required Widget formContent,
    required Future<void> Function() onSave,
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
                  onPressed: _isUpdating
                      ? null
                      : () async {
                          await onSave();
                          if (mounted) Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isUpdating
                        ? Colors.grey
                        : Colors.black, // Bouton gris si loading
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isUpdating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
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

  Widget _buildPersonalInfoForm(etudiant) {
    _nomController.text = etudiant.nom ?? '';
    _postnomController.text = etudiant.postNom ?? '';
    _prenomController.text = etudiant.prenom ?? '';

    return Form(
      key: _personalFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nomController,
            decoration: _chicInputDecoration('Nom'),
            validator: (value) => value?.isEmpty == true ? 'Nom requis' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _postnomController,
            decoration: _chicInputDecoration('Post Nom'),
            validator: (value) =>
                value?.isEmpty == true ? 'Post nom requis' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _prenomController,
            decoration: _chicInputDecoration('Prénom'),
            validator: (value) =>
                value?.isEmpty == true ? 'Prénom requis' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForm(etudiant) {
    _adresseController.text = etudiant.adresse ?? '';

    return Form(
      key: _addressFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _adresseController,
            decoration: _chicInputDecoration('Adresse Complète'),
            maxLines: 3,
            validator: (value) =>
                value?.isEmpty == true ? 'Adresse requise' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneForm(etudiant) {
    _telephoneController.text = etudiant.telephone ?? '';

    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _telephoneController,
            decoration: _chicInputDecoration('Téléphone'),
            keyboardType: TextInputType.phone,
            validator: (value) =>
                value?.isEmpty == true ? 'Téléphone requis' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailForm(etudiant) {
    _emailController.text = etudiant.email ?? '';

    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 15),
          TextFormField(
            controller: _emailController,
            decoration: _chicInputDecoration('Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty == true) return 'Email requis';
              if (!value!.contains('@')) return 'Email invalide';
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final etudiantState = ref.watch(etudiantProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: etudiantState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(etudiantProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (etudiant) {
          if (etudiant == null) {
            return const Center(
              child: Text('Aucune donnée étudiant disponible'),
            );
          }

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                // App Bar moderne
                SliverAppBar(
                  expandedHeight: 100,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  flexibleSpace: const FlexibleSpaceBar(
                    titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                    title: Text(
                      'Mon Profil',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Contenu principal
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Section photo et infos principales
                      _buildProfileHeader(etudiant),
                      const SizedBox(height: 40),

                      // Informations personnelles
                      _buildSectionTitle('Informations personnelles'),
                      _buildProfileCard(
                        icon: Icons.person_outline,
                        title: 'Informations personnelles',
                        subtitle:
                            '${etudiant.nom} ${etudiant.postNom} ${etudiant.prenom}',
                        onTap: () => _showEditModal(
                          title: 'les informations personnelles',
                          formContent: _buildPersonalInfoForm(etudiant),
                          onSave: _updatePersonalInfo,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Contact
                      _buildSectionTitle('Contact'),
                      _buildProfileCard(
                        icon: Icons.phone_outlined,
                        title: 'Téléphone',
                        subtitle: etudiant.telephone ?? 'Non renseigné',
                        onTap: () => _showEditModal(
                          title: 'le numéro de téléphone',
                          formContent: _buildPhoneForm(etudiant),
                          onSave: _updatePhone,
                        ),
                      ),
                      _buildProfileCard(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        subtitle: etudiant.email ?? 'Non renseigné',
                        onTap: () => _showEditModal(
                          title: 'l\'adresse email',
                          formContent: _buildEmailForm(etudiant),
                          onSave: _updateEmail,
                        ),
                      ),

                      const SizedBox(height: 20), // Espace pour navigation
                      // Adresse
                      _buildSectionTitle('Adresse'),
                      _buildProfileCard(
                        icon: Icons.location_on_outlined,
                        title: 'Adresse',
                        subtitle: etudiant.adresse ?? 'Non renseignée',
                        onTap: () => _showEditModal(
                          title: 'l\'adresse',
                          formContent: _buildAddressForm(etudiant),
                          onSave: _updateAddressInfo,
                        ),
                      ),

                      const SizedBox(height: 100), // Espace pour navigation
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(etudiant) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo[400]!, Colors.indigo[600]!],
          ),
        ),
        child: Column(
          children: [
            // Photo de profil
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundImage: etudiant.photo != null
                        ? NetworkImage('${etudiant.photo}') // URL complète
                        : null,
                    child: etudiant.photo == null
                        ? Text(
                            '${etudiant.nom?[0] ?? ''}${etudiant.prenom?[0] ?? ''}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                if (_isUploadingPhoto)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.camera_alt, color: Colors.indigo),
                      onSelected: (value) {
                        if (value == 'upload') {
                          _pickAndUploadPhoto();
                        } else if (value == 'delete') {
                          _deletePhoto();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'upload',
                          child: ListTile(
                            leading: Icon(Icons.upload),
                            title: Text('Changer la photo'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        if (etudiant.photo != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text('Supprimer la photo'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nom complet
            Text(
              '${etudiant.nom ?? ''} ${etudiant.postNom ?? ''} ${etudiant.prenom ?? ''}'
                  .trim(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Matricule
            Text(
              'Matricule: ${etudiant.matricule ?? 'Non défini'}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),

            // Solde
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Solde: ${etudiant.solde?.toStringAsFixed(2) ?? '0.00'} CDF',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.indigo, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
}
