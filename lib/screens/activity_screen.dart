import 'package:flutter/material.dart';
import 'package:student_app/model/activity_model.dart';

class ActivityScreen extends StatelessWidget {
  final Activity activity;

  const ActivityScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activity.title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Content
            Text(
              activity.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Text(
                'Type: ${activity.type.toUpperCase()}',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              activity.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Score Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange),
                  const SizedBox(width: 12),
                  Text(
                    'Note Maximum: ${activity.maximumScore}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Placeholder content for the actual activity
            Center(
              child: Column(
                children: [
                   Icon(Icons.construction, size: 64, color: Colors.grey[300]),
                   const SizedBox(height: 16),
                   Text(
                     'Le contenu de cette activité sera disponible bientôt.',
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.grey[500]),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
