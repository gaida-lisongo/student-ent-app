import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/model/annee_model.dart';
import 'package:student_app/model/promotion_model.dart';
import 'package:student_app/model/recharge_model.dart';
import 'package:student_app/model/student_model.dart';
import 'package:student_app/stores/annee_provider.dart';
import 'package:student_app/stores/auth_provider.dart';
import 'package:student_app/stores/promotion_provider.dart';
import 'package:student_app/stores/recharge_provider.dart';
import 'package:student_app/stores/student_provider.dart';
// import 'package:student_app/components/button_row.dart';
// import 'package:student_app/components/transaction_card.dart';
// import 'package:student_app/components/recharge_bottom_sheet.dart';
// import 'package:student_app/model/student_model.dart';
// import 'package:student_app/model/transaction_model.dart';
// import 'package:student_app/stores/auth_provider.dart';
// import 'package:student_app/stores/student_provider.dart';

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
                (etudiant != null) ? metricCard(etudiant) : Container(),
                const SizedBox(height: 10),
                inscriptionStatusCard(),
                const SizedBox(height: 10),
                (etudiant != null)
                    ? balanceCard(etudiant)
                    : Container(), // WIDGET MAINTENU ET NON CASSÉ
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

  Widget metricCard(Etudiant etudiant) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Consumer(
        builder: (context, ref, child) {
          final anneeSync = ref.watch(anneeProvider);
          final promotionSync = ref.watch(promotionProvider);

          return anneeSync.when(
            data: (annee) => promotionSync.when(
              data: (promotion) {
                String anneeDesignation = "-";
                String promotionDesignation = "Promotion";
                String niveau = "N/A";
                String cycle = "N/A";
                int totalSemestres = 0;
                int totalCredits = 0;

                if (annee != null) {
                  anneeDesignation = "${annee.debut} - ${annee.fin}";
                }

                if (promotion != null) {
                  promotionDesignation = promotion.designation;
                  niveau = promotion.niveau;
                  cycle = promotion.cycle;
                  totalSemestres = promotion.semestres.length;
                  totalCredits = promotion.semestres.fold(
                    0,
                    (sum, semestre) => sum + semestre.credits,
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
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Promotion $promotionDesignation",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  "${etudiant.solde} FC",
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
              loading: () => Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.grey[300],
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.red[100],
                ),
                child: const Center(
                  child: Text(
                    'Erreur de chargement des promotions',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
            loading: () => Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.grey[300],
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.red[100],
              ),
              child: const Center(
                child: Text(
                  'Erreur de chargement des années',
                  style: TextStyle(color: Colors.red),
                ),
              ),
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

  // Widget pour afficher la liste des recharges
  Widget rechargesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Consumer(
        builder: (context, ref, child) {
          final rechargeAsync = ref.watch(rechargeProvider);

          return rechargeAsync.when(
            data: (recharges) {
              if (recharges.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Aucune recharge trouvée',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Historique des recharges',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recharges.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final recharge = recharges[index];
                      return rechargeCard(recharge);
                    },
                  ),
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

  // Widget pour afficher une carte de recharge individuelle
  Widget rechargeCard(Recharge recharge) {
    Color statusColor;
    IconData statusIcon;

    switch (recharge.status) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case 'failed':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${recharge.amount.toStringAsFixed(2)} ${recharge.currency}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    recharge.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recharge.description,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tel: ${recharge.phone}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              if (recharge.createdAt != null)
                Text(
                  '${recharge.createdAt!.day}/${recharge.createdAt!.month}/${recharge.createdAt!.year}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // // Méthode pour afficher les détails d'une recharge
  // void _showRechargeDetails(Recharge recharge) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Détails de la recharge'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('Montant: ${recharge.amount} ${recharge.currency}'),
  //           Text('Numéro: ${recharge.orderNumber}'),
  //           Text('Téléphone: ${recharge.phone}'),
  //           Text('Statut: ${recharge.status}'),
  //           Text('Description: ${recharge.description}'),
  //           if (recharge.createdAt != null)
  //             Text('Date: ${recharge.createdAt!.toString()}'),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Fermer'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

// Widget temporaire RechargeCard
// class RechargeCard extends StatelessWidget {
//   final Recharge recharge;
//   final VoidCallback onPayment;
//   final VoidCallback onCredit;
//   final VoidCallback onDelete;
//   final VoidCallback onDetails;

//   const RechargeCard({
//     Key? key,
//     required this.recharge,
//     required this.onPayment,
//     required this.onCredit,
//     required this.onDelete,
//     required this.onDetails,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8.0),
//       child: ListTile(
//         title: Text('${recharge.amount} ${recharge.currency}'),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Numéro: ${recharge.orderNumber}'),
//             Text('Statut: ${recharge.status}'),
//             if (recharge.createdAt != null)
//               Text('Date: ${recharge.createdAt!.toString().split(' ')[0]}'),
//           ],
//         ),
//         trailing: PopupMenuButton<String>(
//           onSelected: (value) {
//             switch (value) {
//               case 'pay':
//                 onPayment();
//                 break;
//               case 'credit':
//                 onCredit();
//                 break;
//               case 'delete':
//                 onDelete();
//                 break;
//               case 'details':
//                 onDetails();
//                 break;
//             }
//           },
//           itemBuilder: (context) => [
//             if (recharge.status == 'pending')
//               const PopupMenuItem(
//                 value: 'pay',
//                 child: Text('Payer'),
//               ),
//             if (recharge.status == 'completed')
//               const PopupMenuItem(
//                 value: 'credit',
//                 child: Text('Créditer'),
//               ),
//             const PopupMenuItem(
//               value: 'details',
//               child: Text('Détails'),
//             ),
//             if (recharge.status == 'failed' || recharge.status == 'cancelled')
//               const PopupMenuItem(
//                 value: 'delete',
//                 child: Text('Supprimer'),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
