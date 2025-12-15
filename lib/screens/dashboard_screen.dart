import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/components/button_row.dart';
import 'package:student_app/components/transaction_card.dart';
import 'package:student_app/components/recharge_bottom_sheet.dart';
import 'package:student_app/model/student_model.dart';
import 'package:student_app/model/transaction_model.dart'; // MAINTENU
import 'package:student_app/stores/autth_provider.dart'; // Importer le provider d'auth
import 'package:student_app/stores/transaction_provider.dart'; // Importer le provider de transaction

// 1. Service d'Avatar Simulé (inchangé)
class AvatarService {
  static String getAvatarUrl(String seed) {
    return 'https://api.dicebear.com/8.x/lorelei/png?seed=$seed';
  }
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final String cardBackgroundImageUrl =
      'https://images.unsplash.com/photo-1557683316-92c18d2d6695?q=80&w=1500&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

  @override
  void initState() {
    super.initState();
    // Les transactions seront chargées via Riverpod dans transactionsList()
  }

  @override
  Widget build(BuildContext context) {
    // CORRECTION MAJEURE : Remplacer le Column principal par un ListView
    // pour permettre à tout le contenu, y compris la liste des transactions, de défiler.
    return Stack(
      children: [
        // Widget 0 : Le fond en dégradé oblique (inchangé)
        Container(
          decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   begin: Alignment.bottomLeft,
            //   end: Alignment.topRight,
            //   colors: [
            //     const Color.fromARGB(255, 224, 223, 223),
            //     const Color.fromARGB(255, 184, 184, 184),
            //     Colors.white,
            //   ],
            //   stops: const [0.0, 0.5, 1.0],
            // ),
            color: Colors.white,
          ),
        ),

        // Widget 1 : Le contenu principal (Maintenant un ListView pour le défilement)
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(top: 10.0),
            children: <Widget>[
              userHeader(),
              const SizedBox(height: 10),
              metricCard(),
              const SizedBox(height: 10),
              inscriptionStatusCard(),
              const SizedBox(height: 10),
              balanceCard(), // WIDGET MAINTENU ET NON CASSÉ
              const SizedBox(height: 10),
              // INTÉGRATION DE LA LISTE DES TRANSACTIONS
              transactionsList(),
              const SizedBox(height: 20), // Espace en bas de la liste
            ],
          ),
        ),
      ],
    );
  }

  // --- WIDGETS DE TRAITEMENT DES TRANSACTIONS (Logique inchangée depuis la correction précédente) ---

  // Gérer le paiement (pending)
  void _handlePayment(Transaction transaction) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Paiement de ${transaction.amount} ${transaction.currency} en cours...',
        ),
      ),
    );
    // La mise à jour sera faite via l'API
  }

  // Créditer le solde (ok)
  void _handleCredit(Transaction transaction) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Solde crédité de ${transaction.amount} ${transaction.currency}',
        ),
      ),
    );
    // La mise à jour sera faite via l'API
  }

  // Supprimer la transaction (no)
  void _handleDelete(Transaction transaction) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Transaction supprimée')));
    // La suppression sera faite via l'API
  }

  // Afficher les détails dans une bottom sheet (completed)
  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const Text(
                'Détails de la Transaction',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('ID Transaction:', transaction.id),
              _buildDetailRow('Numéro de Commande:', transaction.orderNumber),
              _buildDetailRow(
                'Date:',
                transaction.createdAt.toString().split('.')[0],
              ),
              _buildDetailRow(
                'Montant:',
                '${transaction.amount} ${transaction.currency}',
              ),
              _buildDetailRow('Téléphone:', transaction.phone),
              _buildDetailRow('Statut:', transaction.status),
              _buildDetailRow(
                'Méthode de paiement:',
                transaction.paymentMethod,
              ),
              _buildDetailRow('Description:', transaction.description),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget utilitaire pour afficher les détails (inchangé)
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET DE LISTE DES TRANSACTIONS (transactionList) ---

  Widget transactionsList() {
    // Utilisation d'un Column pour le titre et la liste
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Recharges Récentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Charger les recharges via Riverpod
        Consumer(
          builder: (context, ref, child) {
            final rechargesAsync = ref.watch(userRechargesProvider);

            return rechargesAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: Text(
                        'Aucune recharge trouvée',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Column(
                  children: transactions.map((transaction) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TransactionCard(
                        transaction: transaction,
                        onPayment: () => _handlePayment(transaction),
                        onCredit: () => _handleCredit(transaction),
                        onDelete: () => _handleDelete(transaction),
                        onDetails: () => _showTransactionDetails(transaction),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    'Erreur: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --- WIDGETS PRÉCÉDENTS MAINTENUS INTACTS ---

  Widget userHeader() {
    // Utiliser le Consumer pour accéder à l'état d'authentification
    return SizedBox(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Consumer(
          builder: (context, ref, child) {
            final authState = ref.watch(authProvider);

            // Si pas d'utilisateur authentifié
            if (authState.user == null) {
              return const Center(child: Text('Non authentifié'));
            }

            final user = authState.user!;
            final etudiant = user.etudiant;
            final promotion = user.promotion;
            final annee = user.annee;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          AvatarService.getAvatarUrl(
                            '${etudiant.nom} ${etudiant.prenom}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${etudiant.nom} ${etudiant.prenom}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Matricule: ${etudiant.matricule}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Déconnexion
                    ref.read(authProvider.notifier).signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Déconnecté avec succès')),
                    );
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                  tooltip: 'Déconnexion',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget metricCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Consumer(
        builder: (context, ref, child) {
          final authState = ref.watch(authProvider);

          // Données par défaut si non authentifié
          String anneeDesignation = "2024 - 2025";
          String promotionDesignation = "Promotion";
          String niveau = "N/A";
          String cycle = "N/A";
          int totalSemestres = 0;
          int totalCredits = 0;

          if (authState.user != null) {
            final user = authState.user!;
            anneeDesignation = "${user.annee.debut} - ${user.annee.fin}";
            promotionDesignation = user.promotion.designation;
            niveau = user.promotion.niveau;
            cycle = user.promotion.cycle;
            totalSemestres = user.promotion.semestres.length;
            totalCredits = user.promotion.semestres.fold(
              0,
              (value, Semestre element) => value + element.credits,
            );
          }

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Stack(
              children: [
                // 1. Image de fond
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.asset(
                      "assets/images/metric_background.jpg",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color.fromARGB(255, 4, 84, 221),
                        );
                      },
                    ),
                  ),
                ),
                // 2. Calque d'opacité
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: const Color.fromARGB(
                        255,
                        1,
                        7,
                        10,
                      ).withOpacity(0.6),
                    ),
                  ),
                ),
                // 3. Contenu de la carte
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.home, size: 18, color: Colors.white),
                          Text(
                            anneeDesignation,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Promotion",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            promotionDesignation,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Niveau: $niveau | Cycle: $cycle",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Semestre",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                totalSemestres.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 40),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Crédits",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                totalCredits.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // inscriptionStatusCard : Affiche le statut d'inscription
  Widget inscriptionStatusCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Consumer(
        builder: (context, ref, child) {
          final authState = ref.watch(authProvider);

          String statut = "Non disponible";

          if (authState.user != null) {
            statut = authState.user!.statut;
          }

          // Couleur basée sur le statut
          Color statusColor = Colors.grey;
          if (statut.toLowerCase() == 'actif' ||
              statut.toLowerCase() == 'inscrit') {
            statusColor = Colors.green;
          } else if (statut.toLowerCase() == 'en attente') {
            statusColor = Colors.orange;
          }

          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
              borderRadius: BorderRadius.circular(12.0),
              color: statusColor.withOpacity(0.05),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statut d\'Inscription',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      statut,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: statusColor,
                    size: 24,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // balanceCard : REVENU À SA VERSION ORIGINALE (AVEC BUTTON_ROW)
  Widget balanceCard() {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authProvider);

        // Données par défaut si non authentifié
        int soldeValue = 0;

        if (authState.user != null) {
          soldeValue = authState.user!.etudiant.solde;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Balance solde",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 8.0),
              Text(
                "$soldeValue FC",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16.0),
              // Utilisation du ButtonRow comme dans ton code initial
              // NOTE: Le widget ButtonRow doit exister dans ton projet pour que ceci fonctionne
              // Si ButtonRow n'est pas un widget standard ou n'est pas fourni, le code peut échouer ici.
              ButtonRow(
                leftButtonTitle: "Recharger",
                leftButtonIcon: Icons.add,
                leftButtonOnTap: () {
                  // Afficher la bottom sheet de recharge
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => const RechargeBottomSheet(),
                  );
                },
                rightButtonTitle: "Historique",
                rightButtonIcon: Icons.history,
                rightButtonOnTap: () {
                  print('Historique tapped');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Historique des transactions'),
                    ),
                  );
                },
                isDarkMode: true,
              ),
            ],
          ),
        );
      },
    );
  }
}
