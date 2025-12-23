import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/model/activity_model.dart';
import 'package:student_app/model/student_model.dart';
import 'package:student_app/screens/activity_screen.dart';
import 'package:student_app/stores/transaction_provider.dart';

class PaymentBottomSheet extends ConsumerStatefulWidget {
  final Activity activity;
  final ActivityTransaction transaction;
  final Etudiant student;

  const PaymentBottomSheet({
    super.key,
    required this.activity,
    required this.transaction,
    required this.student,
  });

  @override
  ConsumerState<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends ConsumerState<PaymentBottomSheet> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _processPayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref.read(transactionProvider.notifier).subscribeToTransaction(
          transactionId: widget.transaction.id,
          studentId: widget.student.id,
        );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result.success) {
        Navigator.pop(context); // Close sheet
        // Navigate to Activity Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityScreen(activity: widget.activity),
          ),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paiement effectué avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double solde = widget.student.solde ?? 0;
    final int amount = widget.transaction.amount;
    final bool hasSufficientBalance = solde >= amount;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Débloquer l\'activité',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.activity.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.indigo,
                ),
          ),
          const SizedBox(height: 24),

          // Transaction Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Montant à payer'),
                    Text(
                      '$amount CDF',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Votre solde actuel'),
                    Text(
                      '${solde.toStringAsFixed(2)} CDF',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: hasSufficientBalance ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[100]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[900], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: (!hasSufficientBalance || _isLoading) 
                  ? null 
                  : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      hasSufficientBalance ? 'Payer $amount CDF' : 'Solde insuffisant',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          
          if (!hasSufficientBalance)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Veuillez recharger votre compte pour accéder à cette activité.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange[800], fontSize: 12),
              ),
            ),
            
           const SizedBox(height: 16),
        ],
      ),
    );
  }
}
