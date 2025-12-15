import 'package:flutter/material.dart';
import 'package:student_app/components/custom_button.dart';
import 'package:student_app/components/button_row.dart'; // MAINTENU

// 1. Service d'Avatar Simulé (inchangé)
class AvatarService {
  static String getAvatarUrl(String seed) {
    return 'https://api.dicebear.com/8.x/lorelei/png?seed=$seed';
  }
}

// 2. Modèle Transaction (inchangé)
class Transaction {
  final String id;
  final String orderNumber;
  final String dateCreated;
  final double amount;
  final String currency;
  final String status; // 'completed' | 'pending' | 'ok' | 'no'
  final String phone;

  Transaction({
    required this.id,
    required this.orderNumber,
    required this.dateCreated,
    required this.amount,
    required this.currency,
    required this.status,
    required this.phone,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Données utilisateur à afficher
  final String userId = '123456';
  final String userName = 'John Doe';
  final String memberSince = 'Membre depuis 2020';

  // Mock transactions list
  late List<Transaction> _transactions;

  final String cardBackgroundImageUrl =
      'https://images.unsplash.com/photo-1557683316-92c18d2d6695?q=80&w=1500&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

  @override
  void initState() {
    super.initState();
    _transactions = [
      Transaction(
        id: '1',
        orderNumber: 'ORD-001',
        dateCreated: '2025-12-15 10:30',
        amount: 5000,
        currency: 'FC',
        status: 'completed',
        phone: '+243812345678',
      ),
      Transaction(
        id: '2',
        orderNumber: 'ORD-002',
        dateCreated: '2025-12-14 14:20',
        amount: 2500,
        currency: 'FC',
        status: 'pending',
        phone: '+243987654321',
      ),
      Transaction(
        id: '3',
        orderNumber: 'ORD-003',
        dateCreated: '2025-12-13 09:15',
        amount: 3000,
        currency: 'FC',
        status: 'ok',
        phone: '+243812111222',
      ),
      Transaction(
        id: '4',
        orderNumber: 'ORD-004',
        dateCreated: '2025-12-12 16:45',
        amount: 1500,
        currency: 'FC',
        status: 'no',
        phone: '+243833333333',
      ),
      Transaction(
        id: '5',
        orderNumber: 'ORD-005',
        dateCreated: '2025-12-11 11:00',
        amount: 6000,
        currency: 'FC',
        status: 'completed',
        phone: '+243844444444',
      ),
    ];
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
    setState(() {
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = Transaction(
          id: transaction.id,
          orderNumber: transaction.orderNumber,
          dateCreated: transaction.dateCreated,
          amount: transaction.amount,
          currency: transaction.currency,
          status: 'completed', // Changement de statut simulé
          phone: transaction.phone,
        );
      }
    });
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
    setState(() {
      _transactions.removeWhere(
        (t) => t.id == transaction.id,
      ); // Suppression simulée
    });
  }

  // Supprimer la transaction (no)
  void _handleDelete(Transaction transaction) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Transaction supprimée')));
    setState(() {
      _transactions.removeWhere(
        (t) => t.id == transaction.id,
      ); // Suppression simulée
    });
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
              _buildDetailRow('Date:', transaction.dateCreated),
              _buildDetailRow(
                'Montant:',
                '${transaction.amount} ${transaction.currency}',
              ),
              _buildDetailRow('Téléphone:', transaction.phone),
              _buildDetailRow('Statut:', transaction.status),
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
            'Transactions Récentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Utiliser la méthode map() pour générer dynamiquement les TransactionCard
        ..._transactions.map((transaction) {
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
      ],
    );
  }

  // --- WIDGETS PRÉCÉDENTS MAINTENUS INTACTS ---

  Widget userHeader() {
    return SizedBox(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      AvatarService.getAvatarUrl('John Doe'),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'John Doe',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Membre depuis 2020',
                        style: TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                print('Logout pressed');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Déconnexion simulée')),
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
        ),
      ),
    );
  }

  Widget metricCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
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
                  color: const Color.fromARGB(255, 1, 7, 10).withOpacity(0.6),
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
                      const Text(
                        "2024 - 2025",
                        style: TextStyle(fontSize: 15, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Promotion",
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      Text(
                        'L1 HE',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Mention: BTP",
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Semestre",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            "2",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Crédits",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            "60",
                            style: TextStyle(fontSize: 14, color: Colors.white),
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
      ),
    );
  }

  // balanceCard : REVENU À SA VERSION ORIGINALE (AVEC BUTTON_ROW)
  Widget balanceCard() {
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
          const Text(
            "11000 FC",
            style: TextStyle(
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
              print('Recharger tapped');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recharge en cours...')),
              );
            },
            rightButtonTitle: "Historique",
            rightButtonIcon: Icons.history,
            rightButtonOnTap: () {
              print('Historique tapped');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Historique des transactions')),
              );
            },
            isDarkMode: true,
          ),
        ],
      ),
    );
  }
}

// Widget pour afficher une carte de transaction (MAIN COMPONENT)
class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onPayment;
  final VoidCallback onCredit;
  final VoidCallback onDelete;
  final VoidCallback onDetails;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onPayment,
    required this.onCredit,
    required this.onDelete,
    required this.onDetails,
  });

  Color _getStatusColor() {
    switch (transaction.status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'ok':
        return Colors.blue;
      case 'no':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel() {
    switch (transaction.status) {
      case 'completed':
        return 'Complétée';
      case 'pending':
        return 'En attente';
      case 'ok':
        return 'Approuvée';
      case 'no':
        return 'Échouée';
      default:
        return 'Inconnu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec numéro et statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  transaction.orderNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Montant et date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${transaction.amount} ${transaction.currency}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  transaction.dateCreated,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Téléphone
            Text(
              'Téléphone: ${transaction.phone}',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            // Boutons d'action (Logique conditionnelle)
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // Bouton par défaut avec style cohérent
    Widget buildButton({
      required String title,
      required Color color,
      required VoidCallback onPressed,
      IconData? icon,
    }) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: icon != null
              ? Icon(icon, color: Colors.white, size: 18)
              : const SizedBox.shrink(),
          label: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      );
    }

    switch (transaction.status) {
      case 'pending':
        return buildButton(
          title: 'Effectuer le Paiement',
          color: Colors.orange.shade700,
          onPressed: onPayment,
          icon: Icons.payment,
        );
      case 'ok':
        return buildButton(
          title: 'Créditer le Solde',
          color: Colors.blue.shade700,
          onPressed: onCredit,
          icon: Icons.account_balance_wallet,
        );
      case 'no':
        return buildButton(
          title: 'Supprimer',
          color: Colors.red.shade700,
          onPressed: onDelete,
          icon: Icons.delete_forever,
        );
      case 'completed':
        return buildButton(
          title: 'Voir les Détails',
          color: Colors.green.shade700,
          onPressed: onDetails,
          icon: Icons.info_outline,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
