import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/components/custom_button.dart';
import 'package:student_app/components/recharge_card.dart';
import 'package:student_app/model/recharge_model.dart';
import 'package:student_app/model/student_model.dart';
import 'package:student_app/stores/annee_provider.dart';
import 'package:student_app/stores/auth_provider.dart';
import 'package:student_app/stores/promotion_provider.dart';
import 'package:student_app/stores/recharge_provider.dart';
import 'package:student_app/stores/student_provider.dart';

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
    final studentState = ref.watch(etudiantProvider);
    // CORRECTION MAJEURE : Remplacer le Column principal par un ListView
    // pour permettre à tout le contenu, y compris la liste des transactions, de défiler.
    return studentState.when(
      data: (etudiant) => Stack(
        children: [
          // Widget 0 : Le fond en dégradé oblique (inchangé)
          // Container(
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       begin: Alignment.bottomLeft,
          //       end: Alignment.topRight,
          //       colors: [
          //         // const Color.fromARGB(255, 184, 184, 184),
          //         Colors.white,
          //       ],
          //       stops: const [0.0, 1.0],
          //     ),
          //   ),
          // ),

          // Widget 1 : Le contenu principal (Maintenant un ListView pour le défilement)
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(top: 10.0),
              children: <Widget>[
                (etudiant != null) ? userHeader(etudiant) : Container(),
                const SizedBox(height: 10),
                metricCard(context, ref),
                const SizedBox(height: 10),
                inscriptionStatusCard(),
                const SizedBox(height: 10),
                // Liste des recharges
                rechargesList(),
                const SizedBox(height: 20), // Espace en bas de la liste
              ],
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('Erreur de chargement de l\'étudiant: $error')),
    );
  }

  // --- WIDGETS DE TRAITEMENT DES TRANSACTIONS (Logique inchangée depuis la correction précédente) ---

  // Gérer le paiement (pending)
  // void _handlePayment(Recharge recharge) async {
  //   try {
  //     final rechargeNotifier = ref.read(rechargeProvider.notifier);
  //     final success = await rechargeNotifier.updateRechargeStatus(
  //       orderNumber: recharge.orderNumber,
  //       transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
  //       status: 'completed',
  //     );

  //     if (mounted && success) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Paiement effectué'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     } else if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Erreur lors du paiement'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
  //       );
  //     }
  //   }
  // }

  // Créditer le solde (ok)
  // void _handleCredit(Recharge recharge) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         'Solde crédité de ${recharge.amount} ${recharge.currency}',
  //       ),
  //     ),
  //   );
  // }

  // Supprimer la transaction (no et failed)
  // void _handleDelete(Recharge recharge) async {
  //   final confirm = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Confirmer la suppression'),
  //       content: Text(
  //         'Êtes-vous sûr de vouloir supprimer cette recharge de ${recharge.amount} ${recharge.currency}?',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text('Annuler'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (confirm == true && mounted) {
  //     try {
  //       final rechargeNotifier = ref.read(rechargeProvider.notifier);
  //       final success = await rechargeNotifier.deleteRecharge(recharge.id);

  //       if (success && mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Recharge supprimée avec succès'),
  //             backgroundColor: Colors.green,
  //           ),
  //         );
  //       } else if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Erreur lors de la suppression'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       }
  //     } catch (e) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Erreur lors de la suppression: $e'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       }
  //     }
  //   }
  // }
  // void _handleDelete(Transaction transaction) async {
  //   final confirm = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Confirmer la suppression'),
  //       content: Text(
  //         'Êtes-vous sûr de vouloir supprimer cette recharge de ${transaction.amount} ${transaction.currency}?',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text('Annuler'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (confirm == true && mounted) {
  //     try {
  //       final authState = ref.read(authProvider);
  //       final etudiantId = authState.user?.etudiant.id;

  //       if (etudiantId == null) {
  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text('Erreur: Utilisateur non identifié'),
  //             ),
  //           );
  //         }
  //         return;
  //       }

  //       // Appeler le provider de suppression
  //       await ref.read(
  //         deleteRechargeProvider({
  //           'rechargeId': transaction.id,
  //           'etudiantId': etudiantId,
  //         }).future,
  //       );

  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Recharge supprimée avec succès'),
  //             backgroundColor: Colors.green,
  //           ),
  //         );
  //       }
  //     } catch (e) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
  //         );
  //       }
  //     }
  //   }
  // }

  // Afficher les détails dans une bottom sheet (completed)
  // void _showTransactionDetails(Transaction transaction) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           bool isChecking = false;
  //           String? checkStatus;

  //           return Container(
  //             padding: const EdgeInsets.all(20.0),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Center(
  //                   child: Container(
  //                     width: 50,
  //                     height: 5,
  //                     decoration: BoxDecoration(
  //                       color: Colors.grey[400],
  //                       borderRadius: BorderRadius.circular(3),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 20),
  //                 const Text(
  //                   'Détails de la Transaction',
  //                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //                 ),
  //                 const SizedBox(height: 20),
  //                 _buildDetailRow('ID Transaction:', transaction.id),
  //                 _buildDetailRow(
  //                   'Numéro de Commande:',
  //                   transaction.orderNumber,
  //                 ),
  //                 _buildDetailRow(
  //                   'Date:',
  //                   transaction.createdAt.toString().split('.')[0],
  //                 ),
  //                 _buildDetailRow(
  //                   'Montant:',
  //                   '${transaction.amount} ${transaction.currency}',
  //                 ),
  //                 _buildDetailRow('Téléphone:', transaction.phone),
  //                 _buildDetailRow('Statut:', transaction.status),
  //                 _buildDetailRow(
  //                   'Méthode de paiement:',
  //                   transaction.paymentMethod,
  //                 ),
  //                 _buildDetailRow('Description:', transaction.description),
  //                 if (checkStatus != null)
  //                   Padding(
  //                     padding: const EdgeInsets.only(top: 20),
  //                     child: Text(
  //                       checkStatus!,
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         color: checkStatus!.contains('succès')
  //                             ? Colors.green
  //                             : Colors.orange,
  //                       ),
  //                     ),
  //                   ),
  //                 const SizedBox(height: 20),
  //                 if (transaction.status == 'pending')
  //                   SizedBox(
  //                     width: double.infinity,
  //                     child: ElevatedButton(
  //                       onPressed: isChecking
  //                           ? null
  //                           : () async {
  //                               setState(() {
  //                                 isChecking = true;
  //                                 checkStatus = null;
  //                               });
  //                               try {
  //                                 final checkAction = ref.read(
  //                                   checkRechargeStatusActionProvider,
  //                                 );
  //                                 final status = await checkAction(
  //                                   transaction.orderNumber,
  //                                 );
  //                                 setState(() {
  //                                   checkStatus =
  //                                       'Statut: ${status.status} - ${status.message}';
  //                                 });
  //                               } catch (e) {
  //                                 setState(() {
  //                                   checkStatus = 'Erreur: $e';
  //                                 });
  //                               } finally {
  //                                 setState(() {
  //                                   isChecking = false;
  //                                 });
  //                               }
  //                             },
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: Colors.blue,
  //                         padding: const EdgeInsets.symmetric(vertical: 12),
  //                       ),
  //                       child: Text(
  //                         isChecking
  //                             ? 'Vérification...'
  //                             : 'Vérifier le Paiement',
  //                         style: const TextStyle(color: Colors.white),
  //                       ),
  //                     ),
  //                   ),
  //                 const SizedBox(height: 8),
  //                 SizedBox(
  //                   width: double.infinity,
  //                   child: ElevatedButton(
  //                     onPressed: () => Navigator.pop(context),
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.black,
  //                       padding: const EdgeInsets.symmetric(vertical: 12),
  //                     ),
  //                     child: const Text(
  //                       'Fermer',
  //                       style: TextStyle(color: Colors.white, fontSize: 16),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // Widget utilitaire pour afficher les détails (inchangé)
  // Widget _buildDetailRow(String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           label,
  //           style: const TextStyle(
  //             fontSize: 14,
  //             fontWeight: FontWeight.w500,
  //             color: Colors.grey,
  //           ),
  //         ),
  //         Text(
  //           value,
  //           style: const TextStyle(
  //             fontSize: 14,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.black,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // --- WIDGET DE LISTE DES TRANSACTIONS (transactionList) ---

  // Widget transactionsList() {
  //   // Écouter les recharges via le nouveau provider
  //   final rechargesAsync = ref.watch(rechargeProvider);

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 16.0),
  //         child: Text(
  //           'Recharges Récentes',
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.black,
  //           ),
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       // Charger les recharges via le nouveau provider
  //       rechargesAsync.when(
  //         data: (recharges) {
  //           if (recharges.isEmpty) {
  //             return const Padding(
  //               padding: EdgeInsets.symmetric(horizontal: 16.0),
  //               child: Center(
  //                 child: Text(
  //                   'Aucune recharge trouvée',
  //                   style: TextStyle(color: Colors.grey),
  //                 ),
  //               ),
  //             );
  //           }

  //           return Column(
  //             children: recharges.map((recharge) {
  //               return Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //                 child: RechargeCard(
  //                   recharge: recharge,
  //                   onPayment: () => _handlePayment(recharge),
  //                   onCredit: () => _handleCredit(recharge),
  //                   onDelete: () => _handleDelete(recharge),
  //                   onDetails: () => _showRechargeDetails(recharge),
  //                 ),
  //               );
  //             }).toList(),
  //           );
  //         },
  //         loading: () => const Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 16.0),
  //           child: Center(child: CircularProgressIndicator()),
  //         ),
  //         error: (error, stackTrace) => Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //           child: Center(
  //             child: Text(
  //               'Erreur: $error',
  //               style: const TextStyle(color: Colors.red),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // --- WIDGETS PRÉCÉDENTS MAINTENUS INTACTS ---

  Widget userHeader(Etudiant etudiant) {
    // Utiliser le Consumer pour accéder à l'état d'authentification
    return SizedBox(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Consumer(
          builder: (context, ref, child) {
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
                  onPressed: () async {
                    // Déconnexion
                    await ref.read(authProvider.notifier).logout();
                    await ref.read(etudiantProvider.notifier).clearEtudiant();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Déconnecté avec succès')),
                      );
                    }
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

  Widget metricCard(BuildContext context, WidgetRef ref) {
    final etudiantState = ref.watch(etudiantProvider);
    final anneeSync = ref.watch(anneeProvider);
    final promotionSync = ref.watch(promotionProvider);

    return etudiantState.when(
      data: (etudiant) {
        if (etudiant == null) return SizedBox.shrink();

        return anneeSync.when(
          data: (annee) => promotionSync.when(
            data: (promotion) {
              final anneeDesignation = annee != null
                  ? "${annee.debut} - ${annee.fin}"
                  : "-";

              final promotionDesignation =
                  promotion?.designation ?? "Promotion";
              final niveau = promotion?.niveau ?? "N/A";
              final cycle = promotion?.cycle ?? "N/A";

              final totalSemestres = promotion?.semestres.length ?? 0;

              final totalCredits =
                  promotion?.semestres.fold(
                    0,
                    (sum, semestre) => sum + semestre.credits,
                  ) ??
                  0;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Stack(
                  children: [
                    // Background
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.asset(
                          "assets/images/metric_background.jpg",
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: const Color(0xFF0454DD)),
                        ),
                      ),
                    ),
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.home,
                                size: 18,
                                color: Colors.white,
                              ),
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
                          Text(
                            "Promotion $promotionDesignation",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            "${etudiant.solde.toStringAsFixed(2)} FC",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Système : ${promotion?.systeme} | Cycle: $cycle",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
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
                                    "$totalSemestres",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
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
                                    "$totalCredits",
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
            loading: () => _placeholder(),
            error: (_, __) => _error(),
          ),
          loading: () => _placeholder(),
          error: (_, __) => _error(),
        );
      },
      loading: () => _placeholder(),
      error: (_, __) => _error(),
    );
  }

  Widget _placeholder() => Container(
    height: 120,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: Colors.grey[300],
    ),
    child: const Center(child: CircularProgressIndicator()),
  );

  Widget _error() => Container(
    height: 120,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: Colors.red[100],
    ),
    child: const Center(
      child: Text('Erreur de chargement', style: TextStyle(color: Colors.red)),
    ),
  );

  // inscriptionStatusCard : Affiche le statut d'inscription
  Widget inscriptionStatusCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Consumer(
        builder: (context, ref, child) {
          final authAsync = ref.watch(authProvider);

          return authAsync.when(
            data: (token) {
              String statut = "Non disponible";

              if (token != null && token.contains(':')) {
                // Extraire le statut depuis le token (format: "id:statut")
                statut = token.split(':')[1];
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
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                    width: 1,
                  ),
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
            loading: () => Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.grey.withOpacity(0.05),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statut d\'Inscription',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      CircularProgressIndicator(strokeWidth: 2),
                    ],
                  ),
                ],
              ),
            ),
            error: (error, stack) => Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.red.withOpacity(0.05),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statut d\'Inscription',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Erreur',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // balanceCard : REVENU À SA VERSION ORIGINALE (AVEC BUTTON_ROW)
  Widget balanceCard(Etudiant etudiant) {
    return Consumer(
      builder: (context, ref, child) {
        final rechargeSync = ref.watch(rechargeProvider);

        return rechargeSync.when(
          data: (recharges) {
            double totalBalance = recharges
                .where((r) => r.status == 'completed')
                .fold(0.0, (sum, r) => sum + r.amount);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Solde Disponible',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '${totalBalance.toStringAsFixed(2)} USD',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // Boutons d'action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Action pour recharger le solde
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Recharger',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Erreur de chargement du solde: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      },
    );
  }

  // Widget pour afficher la liste des recharges avec métriques
  Widget rechargesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Consumer(
        builder: (context, ref, child) {
          final rechargeAsync = ref.watch(rechargeProvider);

          return rechargeAsync.when(
            data: (recharges) {
              // 1. Calculer les métriques (même si la liste est vide, ce sera des zéros)
              final metrics = _calculateRechargeMetrics(recharges);

              // 2. Préparer la liste des 5 dernières (peut être vide)
              final last5Recharges = recharges.take(5).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- A. Métriques (Toujours visibles) ---
                  rechargeMetricsCard(metrics),
                  const SizedBox(height: 16),

                  // --- B. En-tête et Boutons (Toujours visibles) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dernières recharges',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _showSearchModal(recharges),
                            icon: const Icon(Icons.search),
                            tooltip: 'Rechercher',
                          ),
                          IconButton(
                            onPressed: _showNewRechargeModal,
                            icon: const Icon(Icons.add),
                            // container decoration for emphasis?
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                            tooltip: 'Nouvelle recharge',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // --- C. Contenu Conditionnel (Liste ou Empty State) ---
                  if (recharges.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(30),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Aucune recharge trouvée',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Cliquez sur + pour effectuer votre première recharge.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // Liste des 5 dernières recharges
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: last5Recharges.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final recharge = last5Recharges[index];
                        return RechargeCard(recharge: recharge);
                      },
                    ),

                    // Bouton voir plus si il y a plus de 5 recharges
                    if (recharges.length > 5) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => _showAllRechargesModal(recharges),
                          child: Text('Voir toutes (${recharges.length})'),
                        ),
                      ),
                    ],
                  ],
                ],
              );
            },
            loading: () => Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Erreur de chargement des recharges: $error',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Calculer les métriques des recharges
  Map<String, dynamic> _calculateRechargeMetrics(List<Recharge> recharges) {
    int completed = 0;
    int pending = 0;
    int failed = 0;
    double totalCompletedCDF = 0.0;
    double totalCompletedUSD = 0.0;
    double totalPendingCDF = 0.0;
    double totalPendingUSD = 0.0;

    for (final recharge in recharges) {
      switch (recharge.status) {
        case 'completed':
          completed++;
          if (recharge.currency == 'CDF') {
            totalCompletedCDF += recharge.amount;
          } else if (recharge.currency == 'USD') {
            totalCompletedUSD += recharge.amount;
          }
          break;
        case 'pending':
          pending++;
          if (recharge.currency == 'CDF') {
            totalPendingCDF += recharge.amount;
          } else if (recharge.currency == 'USD') {
            totalPendingUSD += recharge.amount;
          }
          break;
        case 'failed':
          failed++;
          break;
      }
    }

    return {
      'completed': completed,
      'pending': pending,
      'failed': failed,
      'totalCompletedCDF': totalCompletedCDF,
      'totalCompletedUSD': totalCompletedUSD,
      'totalPendingCDF': totalPendingCDF,
      'totalPendingUSD': totalPendingUSD,
      'total': recharges.length,
    };
  }

  // Widget pour afficher les métriques des recharges
  Widget rechargeMetricsCard(Map<String, dynamic> metrics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métriques des recharges',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Complétées',
                  '${metrics['completed']}',
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'En attente',
                  '${metrics['pending']}',
                  Colors.orange,
                  Icons.access_time,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Échouées',
                  '${metrics['failed']}',
                  Colors.red,
                  Icons.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Complétées
              if (metrics['totalCompletedCDF'] > 0 ||
                  metrics['totalCompletedUSD'] > 0)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total complété :',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (metrics['totalCompletedCDF'] > 0)
                        Text(
                          '${metrics['totalCompletedCDF'].toStringAsFixed(0)} CDF',
                          style: const TextStyle(color: Colors.green),
                        ),
                      if (metrics['totalCompletedUSD'] > 0)
                        Text(
                          '${metrics['totalCompletedUSD'].toStringAsFixed(2)} USD',
                          style: const TextStyle(color: Colors.green),
                        ),
                    ],
                  ),
                )
              else
                const Expanded(child: SizedBox()),

              // Section En attente
              if (metrics['totalPendingCDF'] > 0 ||
                  metrics['totalPendingUSD'] > 0)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'En attente :',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (metrics['totalPendingCDF'] > 0)
                        Text(
                          '${metrics['totalPendingCDF'].toStringAsFixed(0)} CDF',
                          style: const TextStyle(color: Colors.orange),
                          textAlign: TextAlign.right,
                        ),
                      if (metrics['totalPendingUSD'] > 0)
                        Text(
                          '${metrics['totalPendingUSD'].toStringAsFixed(2)} USD',
                          style: const TextStyle(color: Colors.orange),
                          textAlign: TextAlign.right,
                        ),
                    ],
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Modal pour nouvelle recharge
  void _showNewRechargeModal() {
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCurrency = 'CDF';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nouvelle recharge',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',
                border: OutlineInputBorder(),
                prefixText: '243',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Montant',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Devise',
                      border: OutlineInputBorder(),
                    ),
                    items: ['CDF', 'USD'].map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      selectedCurrency = newValue ?? 'CDF';
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  title: 'Annuler',
                  icon: Icons.close,
                  onTap: () => Navigator.pop(context),
                ),
                CustomButton(
                  title: 'Créer',
                  icon: Icons.add,
                  isDarkMode: true,
                  onTap: () async {
                    if (phoneController.text.isNotEmpty &&
                        amountController.text.isNotEmpty) {
                      final rechargeNotifier = ref.read(
                        rechargeProvider.notifier,
                      );
                      final success = await rechargeNotifier.addRecharge(
                        amount: double.parse(amountController.text),
                        phone: '243${phoneController.text}',
                        currency: selectedCurrency,
                        description: descriptionController.text.isEmpty
                            ? 'Recharge de compte'
                            : descriptionController.text,
                      );

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Recharge créée avec succès'
                                  : 'Erreur lors de la création de la recharge',
                            ),
                            backgroundColor: success
                                ? Colors.green
                                : Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Modal pour recherche de recharges
  void _showSearchModal(List<Recharge> allRecharges) {
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          List<Recharge> filteredRecharges = allRecharges;

          if (searchController.text.isNotEmpty) {
            final query = searchController.text.toLowerCase();
            filteredRecharges = allRecharges.where((recharge) {
              return recharge.phone.toLowerCase().contains(query) ||
                  (recharge.orderNumber?.toLowerCase().contains(query) ??
                      false) ||
                  recharge.description.toLowerCase().contains(query) ||
                  recharge.status.toLowerCase().contains(query) ||
                  recharge.amount.toString().contains(query);
            }).toList();
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Rechercher une recharge',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Rechercher...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Téléphone, numéro, statut, montant...',
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filteredRecharges.isEmpty
                      ? const Center(child: Text('Aucune recharge trouvée'))
                      : ListView.separated(
                          itemCount: filteredRecharges.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return RechargeCard(
                              recharge: filteredRecharges[index],
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Modal pour afficher toutes les recharges
  void _showAllRechargesModal(List<Recharge> allRecharges) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Toutes les recharges (${allRecharges.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: allRecharges.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return RechargeCard(recharge: allRecharges[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
