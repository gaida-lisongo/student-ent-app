import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/model/annee_model.dart';
import 'package:student_app/model/promotion_model.dart';
import 'package:student_app/model/semestre_model.dart';
import 'package:student_app/model/student_model.dart';
import 'package:student_app/model/matiere_model.dart';
import 'package:student_app/model/promotion_model.dart';
import 'package:student_app/model/semestre_model.dart';
import 'package:student_app/model/unite_model.dart';
import 'package:student_app/stores/annee_provider.dart';
import 'package:student_app/stores/promotion_provider.dart';
import 'package:student_app/stores/student_provider.dart';
import 'package:student_app/screens/matiere_screen.dart';

// Modèle de Produit pour la commande de bulletins
class BulletinProduct {
  final String id;
  final String designation;
  final String description;
  final double montant;
  final int credit;
  final String anneeAcad;

  BulletinProduct({
    required this.id,
    required this.designation,
    required this.description,
    required this.montant,
    required this.credit,
    required this.anneeAcad,
  });
}

// Modèle de Bulletin Commandé (Historique)
class OrderedBulletin {
  final String orderId;
  final String designation;
  final String dateOrdered;
  final String status; // Ex: 'Completed', 'Pending'

  OrderedBulletin({
    required this.orderId,
    required this.designation,
    required this.dateOrdered,
    required this.status,
  });
}

class ResultatScreen extends ConsumerStatefulWidget {
  const ResultatScreen({super.key});

  @override
  ConsumerState<ResultatScreen> createState() => _ResultatScreenState();
}

class _ResultatScreenState extends ConsumerState<ResultatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Variables supprimées pour éviter LateInitializationError
  // Les données seront gérées directement via les providers async

  // Mock Data pour l'historique des commandes (Section 2)
  final List<OrderedBulletin> _history = [
    OrderedBulletin(
      orderId: 'ORD-1001',
      designation: 'Résultat Annuel (2023-2024)',
      dateOrdered: '15/07/2024',
      status: 'Completed',
    ),
    OrderedBulletin(
      orderId: 'ORD-1002',
      designation: 'Résultat Semestre 1 (2023-2024)',
      dateOrdered: '20/02/2024',
      status: 'Completed',
    ),
    OrderedBulletin(
      orderId: 'ORD-1003',
      designation: 'Résultat Annuel (2022-2023)',
      dateOrdered: '05/08/2023',
      status: 'Completed',
    ),
  ];

  // --- ACTIONS DE L'UTILISATEUR ---

  void _orderBulletin(BulletinProduct product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Commande de "${product.designation}" à ${product.montant} FC en cours...',
        ),
      ),
    );
  }

  void _viewBulletinPDF(OrderedBulletin order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Récupération du PDF pour l\'ordre ${order.orderId} (${order.designation})...',
        ),
      ),
    );
  }

  // --- WIDGETS DE COMPOSANTS ---

  void _showMatieresModal(UniteEnseignement ue, Semestre s) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Matières - ${ue.designation}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Code: ${ue.code} | Crédits: ${ue.credits}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              if (ue.matieres.isEmpty)
                const Center(child: Text('Aucune matière associée.'))
              else
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: ue.matieres.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final matiere = ue.matieres[index];
                    return ListTile(
                      title: Text(matiere.designation),
                      subtitle: Text(
                        'Code: ${matiere.code} | Crédits: ${matiere.credits}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatiereScreen(
                              matiere: matiere,
                              unite: ue,
                              semestre: s,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSemestresCard(List<Semestre> semestres) {
    if (semestres.isEmpty) {
      return const Center(child: Text('Aucun semestre disponible.'));
    }

    // Mettre à jour le contrôleur si le nombre de semestres change
    if (_tabController.length != semestres.length) {
      _tabController = TabController(length: semestres.length, vsync: this);
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.indigo,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.indigo,
          tabs: semestres.map((semestre) {
            return Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(semestre.designation),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${semestre.credits}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: semestres.map((semestre) {
              if (semestre.unites.isEmpty) {
                return const Center(
                  child: Text('Aucune unité d\'enseignement.'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: semestre.unites.length,
                itemBuilder: (context, index) {
                  final ue = semestre.unites[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  ue.designation,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${ue.credits} Crédits',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Code: ${ue.code}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Matières: ${ue.matieres.length}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _showMatieresModal(ue, semestre),
                              icon: const Icon(Icons.list, size: 18),
                              label: const Text('Voir les matières'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.indigo,
                                side: const BorderSide(color: Colors.indigo),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getCardImagePath(int index) {
    final int imageNumber = (index % 3) + 1;
    // J'ai corrigé le chemin ici, en supposant que "images" est le sous-dossier de "assets"
    return 'assets/images/check-$imageNumber.jpg';
  }

  // 1. Carte de Commande de Bulletin (Section Horizontale)
  Widget _buildOrderCard(BulletinProduct product, int index) {
    final String imagePath = _getCardImagePath(index);

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      margin: const EdgeInsets.only(right: 15),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),

          child: Stack(
            children: [
              // Composant 1: Image de fond (avec gestion d'erreur)
              Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors
                          .black, // Couleur de secours si image non trouvée
                    );
                  },
                ),
              ),

              // Composant 2: Calque de gradient (PLUS FONCÉ ET PLUS SÉCURISANT)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.8), // Plus opaque en bas
                        Colors.black.withOpacity(0.4), // Moins opaque en haut
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

              // Composant 3: Contenu réel de la carte (Texte et Boutons)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // En-tête (Désignation, Description, Année)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.designation,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // AJOUT DE LA DESCRIPTION
                        Text(
                          product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          product.anneeAcad,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    // Infos Crédit/Montant/Bouton
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Crédits Totaux',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '${product.credit}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        // Bouton Commander
                        ElevatedButton(
                          onPressed: () => _orderBulletin(product),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8, // L'ai rendu un peu plus petit
                            ),
                          ),
                          child: Text(
                            'Commander (${product.montant} FC)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Carte d'Historique de Bulletin (Section Verticale - REFAITE AVEC ANIMATION)
  Widget _buildHistoryCard(OrderedBulletin order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 5, right: 5),
      child: Material(
        // Utiliser Material pour l'InkWell et l'élévation
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        elevation: 5, // Plus d'élévation pour un look plus "chic"
        child: InkWell(
          // Ajout d'InkWell pour les animations de tap
          onTap: () => _viewBulletinPDF(order),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icone et Texte
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1), // Bleu subtil
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons
                            .insert_drive_file_outlined, // Icône plus spécifique
                        color: Colors.indigo,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.designation,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Commandé: ${order.dateOrdered}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'ID Commande: ${order.orderId}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Bouton Voir
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Voir',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final etudiantState = ref.watch(etudiantProvider);
    final promotionState = ref.watch(promotionProvider);
    final anneeState = ref.watch(anneeProvider);

    // Vérifier que toutes les données sont disponibles
    return etudiantState.when(
      data: (etudiant) => promotionState.when(
        data: (promotion) => anneeState.when(
          data: (annee) {
            if (etudiant == null || promotion == null || annee == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return _buildMainContent(etudiant, promotion, annee);
          },
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stack) =>
              Scaffold(body: Center(child: Text('Erreur: $error'))),
        ),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, stack) =>
            Scaffold(body: Center(child: Text('Erreur: $error'))),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Erreur: $error'))),
    );
  }

  Widget _buildMainContent(
    Etudiant etudiant,
    Promotion promotion,
    Annee annee,
  ) {
    final String anneeAcad = '${annee.debut}/${annee.fin}';
    // Produits dynamiques basés sur l'année
    final products = [
      BulletinProduct(
        id: '1',
        designation: 'Résultat Annuel',
        description: 'Bulletin pour l\'année académique complète.',
        montant: 5000,
        credit: 60,
        anneeAcad: anneeAcad,
      ),
      BulletinProduct(
        id: '2',
        designation: 'Résultat Semestre 1',
        description: 'Notes et crédits du premier semestre.',
        montant: 2500,
        credit: 30,
        anneeAcad: anneeAcad,
      ),
      BulletinProduct(
        id: '3',
        designation: 'Résultat Semestre 2',
        description: 'Notes et crédits du second semestre.',
        montant: 2500,
        credit: 30,
        anneeAcad: anneeAcad,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. En-tête
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mes Résultats',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (promotion.id.isNotEmpty)
                    Text(
                      'Promotion: ${promotion.designation}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  Text(
                    'Année: $anneeAcad',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

            // 2. Section de Commande
            const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 15),
              child: Text(
                'Commander un bulletin',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(
              height: 190,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(products[index], index);
                },
              ),
            ),
            const SizedBox(height: 25),

            // 3. Historique (Remplacé par les Semestres)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Text(
                        'Programme Académique',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // Liste des Semestres avec Tabs
                    Expanded(child: _buildSemestresCard(promotion.semestres)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode helper pour construire les cards de produit avec les bonnes données
  Widget _buildProductCard(BulletinProduct product, Etudiant etudiant) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.designation,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(product.description),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${product.montant} FCFA',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text('Crédits: ${product.credit}'),
              ],
            ),
            const SizedBox(height: 8),
            Text('Année: ${product.anneeAcad}'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleOrder(product, etudiant),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Commander - ${product.montant} FCFA'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleOrder(BulletinProduct product, Etudiant etudiant) {
    // Logique de commande ici
    print('Commande pour ${product.designation} par ${etudiant.nom}');
  }
}
