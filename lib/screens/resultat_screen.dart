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
      description: 'Bulletin pour l\'année académique complète.',
      montant: 5000,
      credit: 60,
      anneeAcad: '2024-2025',
    ),
    BulletinProduct(
      id: '2',
      designation: 'Résultat Semestre 1',
      description: 'Bulletin détaillé du premier semestre.',
      montant: 2500,
      credit: 30,
      anneeAcad: '2024-2025',
    ),
    BulletinProduct(
      id: '3',
      designation: 'Résultat Semestre 2',
      description: 'Bulletin détaillé du second semestre.',
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

  // Action pour commander un bulletin
  void _orderBulletin(BulletinProduct product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Commande de "${product.designation}" à ${product.montant} FC en cours...',
        ),
      ),
    );
    // Logique réelle d'appel API de commande ici
  }

  // Action pour visualiser/générer le PDF
  void _viewBulletinPDF(OrderedBulletin order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Récupération du PDF pour l\'ordre ${order.orderId} (${order.designation})...',
        ),
      ),
    );
    // Logique réelle de récupération/génération du PDF ici
  }

  // --- WIDGETS DE COMPOSANTS ---

  // 1. Carte de Commande de Bulletin (Section Horizontale)
  Widget _buildOrderCard(BulletinProduct product) {
    return Container(
      width:
          MediaQuery.of(context).size.width * 0.85, // Prend 85% de la largeur
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          // Dégradé pour effet "carte bancaire"
          colors: [Color.fromARGB(255, 33, 33, 33), Color(0xFF1E2749)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // En-tête (Désignation)
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
              Text(
                product.anneeAcad,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // Infos Crédit/Montant
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Crédits',
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
                  backgroundColor: Colors.indigo.shade400, // Bleu pour l'action
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  'Commander (${product.montant} FC)',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Carte d'Historique de Bulletin (Section Verticale)
  Widget _buildHistoryCard(OrderedBulletin order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12, left: 5, right: 5),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.file_copy_outlined, color: Colors.green),
        ),
        title: Text(
          order.designation,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Commandé le ${order.dateOrdered} | Statut: ${order.status}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: ElevatedButton(
          onPressed: () => _viewBulletinPDF(order),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Voir',
            style: TextStyle(color: Colors.white, fontSize: 13),
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
        // Utilisation d'un Column pour empiler la barre horizontale et la section arrondie
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
              height: 180, // Hauteur fixe pour le défilement horizontal
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(_products[index]);
                },
              ),
            ),
            const SizedBox(height: 25),

            // 3. Section d'Historique des Bulletins (avec bord arrondi)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color:
                      Colors.grey.shade50, // Fond légèrement grisé pour séparer
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
                        'Historique des commandes',
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
