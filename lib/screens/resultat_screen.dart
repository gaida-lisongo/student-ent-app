import 'package:flutter/material.dart';

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

class ResultatScreen extends StatefulWidget {
  const ResultatScreen({super.key});

  @override
  State<ResultatScreen> createState() => _ResultatScreenState();
}

class _ResultatScreenState extends State<ResultatScreen> {
  // Mock Data pour les produits disponibles (Section 1)
  final List<BulletinProduct> _products = [
    BulletinProduct(
      id: '1',
      designation: 'Résultat Annuel',
      description:
          'Bulletin pour l\'année académique complète, indispensable pour la transition.',
      montant: 5000,
      credit: 60,
      anneeAcad: '2024-2025',
    ),
    BulletinProduct(
      id: '2',
      designation: 'Résultat Semestre 1',
      description:
          'Consultation détaillée de toutes les notes et crédits du premier semestre.',
      montant: 2500,
      credit: 30,
      anneeAcad: '2024-2025',
    ),
    BulletinProduct(
      id: '3',
      designation: 'Résultat Semestre 2',
      description:
          'Consultation détaillée de toutes les notes et crédits du second semestre.',
      montant: 2500,
      credit: 30,
      anneeAcad: '2024-2025',
    ),
  ];

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. En-tête du titre
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                'Mes Résultats',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // 2. Section de Commande des Bulletins (Horizontal ListView)
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
              height: 190, // Augmenté pour accueillir la description
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(_products[index], index);
                },
              ),
            ),
            const SizedBox(height: 25),

            // 3. Section d'Historique des Bulletins (avec bord arrondi)
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
                        'Historique des commandes (PDF)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // Liste des bulletins commandés (Vertical ListView)
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryCard(_history[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
