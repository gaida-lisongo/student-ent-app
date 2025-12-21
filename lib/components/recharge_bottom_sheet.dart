import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/stores/auth_provider.dart';
import 'package:student_app/stores/recharge_provider.dart';
import 'package:student_app/screens/payment_status_page.dart';
import 'package:student_app/components/custom_button.dart';
import 'package:student_app/services/transaction_service.dart';

class RechargeBottomSheet extends ConsumerStatefulWidget {
  const RechargeBottomSheet({super.key});

  @override
  ConsumerState<RechargeBottomSheet> createState() =>
      _RechargeBottomSheetState();
}

class _RechargeBottomSheetState extends ConsumerState<RechargeBottomSheet> {
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Traiter le numéro de téléphone (prendre 9 derniers chiffres et ajouter 243)
  String _processPhoneNumber(String phone) {
    // Enlever tous les caractères non numériques
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Si le numéro commence par 243, prendre les 9 derniers chiffres
    if (cleanPhone.startsWith('243')) {
      return cleanPhone;
    }

    // Prendre les 9 derniers chiffres
    final lastNine = cleanPhone.length >= 9
        ? cleanPhone.substring(cleanPhone.length - 9)
        : cleanPhone;

    // Ajouter le préfixe 243
    return '243$lastNine';
  }

  // Générer la description avec matricule:promotion
  String _generateDescription() {
    final authState = ref.read(authProvider);
    if (authState.user == null) return '';

    final user = authState.user!;
    final etudiant = user.etudiant;
    final promotion = user.promotion;

    return 'Recharge de compte - ${etudiant.nom} ${etudiant.postNom} ${etudiant.prenom}:${etudiant.matricule}';
  }

  // Soumettre la recharge
  Future<void> _submitRecharge() async {
    if (_amountController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authState = ref.read(authProvider);
    if (authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur non authentifié'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = int.parse(_amountController.text);
      final phone = _processPhoneNumber(_phoneController.text);
      // final description = _generateDescription(); // Si utilisé
      final etudiantId = authState.user!.etudiant.id;

      // 1. Obtenir la fonction d'action Riverpod (ref.read)
      final createAction = ref.read(createRechargeActionProvider);

      // 2. Appeler la fonction d'action qui gère l'API et la mise à jour du store
      final transaction = await createAction(
        etudiantId: etudiantId,
        amount: amount,
        phone: phone,
        description:
            _generateDescription(), // Appel de la description si nécessaire
        currency: 'CDF',
        paymentMethod: 'mobile_money',
      );

      // --- Les lignes de ref.refresh ne sont plus nécessaires ici ! ---
      // L'action Riverpod s'occupe de la mise à jour locale.

      if (!mounted) return;

      // Fermer la bottom sheet
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poignée pour fermer
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Titre
              const Text(
                'Effectuer une Recharge',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Informations utilisateur
              if (authState.user != null) ...[
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${authState.user!.etudiant.nom} ${authState.user!.etudiant.postNom} ${authState.user!.etudiant.prenom}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Matricule: ${authState.user!.etudiant.matricule}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Promotion: ${authState.user!.promotion.designation}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Champ Montant
              const Text(
                'Montant (CDF)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Ex: 5000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Champ Téléphone
              const Text(
                'Numéro de Téléphone',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Ex: 816420451 ou +243816420451',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Note
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: const Text(
                  'Note: Entrez les 9 derniers chiffres ou le numéro complet. Le préfixe 243 sera ajouté automatiquement.',
                  style: TextStyle(fontSize: 12, color: Colors.amber),
                ),
              ),
              const SizedBox(height: 24),

              // Boutons
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        title: 'Annuler',
                        icon: Icons.close,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        title: 'Recharger',
                        icon: Icons.add_circle,
                        onTap: _submitRecharge,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
