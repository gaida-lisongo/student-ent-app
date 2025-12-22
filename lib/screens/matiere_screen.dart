import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/model/matiere_model.dart';
import 'package:student_app/model/semestre_model.dart';
import 'package:student_app/model/unite_model.dart';
import 'package:student_app/stores/annee_provider.dart';

class MatiereScreen extends ConsumerStatefulWidget {
  final Matiere matiere;
  final UniteEnseignement unite;
  final Semestre semestre;

  const MatiereScreen({
    super.key,
    required this.matiere,
    required this.unite,
    required this.semestre,
  });

  @override
  ConsumerState<MatiereScreen> createState() => _MatiereScreenState();
}

class _MatiereScreenState extends ConsumerState<MatiereScreen> {
  String _selectedMenu = 'Activités';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _menuItems = [
    'Activités',
    'Ressources',
    'Recours',
    'Séances',
  ];

  @override
  Widget build(BuildContext context) {
    final anneeAsync = ref.watch(anneeProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.matiere.code,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          children: [
            // 1. Année Académique (Top)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              color: Colors.grey[100],
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Année Académique',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  anneeAsync.when(
                    data: (annee) => Text(
                      annee != null
                          ? '${annee.debut}/${annee.fin}'
                          : 'Non définie',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    loading: () => const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, __) => const Text('Erreur'),
                  ),
                ],
              ),
            ),

            // 2. Header Matière (ID Card Style)
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade600, Colors.indigo.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.book_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.matiere.credits} Crédits',
                          style: TextStyle(
                            color: Colors.indigo.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.matiere.designation,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.matiere.code,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // 3. Menu Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  final isSelected = _selectedMenu == item;
                  return ListTile(
                    leading: Icon(
                      _getMenuIcon(item),
                      color: isSelected ? Colors.indigo : Colors.grey[600],
                    ),
                    title: Text(
                      item,
                      style: TextStyle(
                        color: isSelected ? Colors.indigo : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: Colors.indigo.withOpacity(0.05),
                    onTap: () {
                      setState(() {
                        _selectedMenu = item;
                      });
                      Navigator.pop(context); // Fermer le drawer
                    },
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // 4. Footer (UE & Semestre)
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[50],
              child: Column(
                children: [
                  _buildFooterRow(
                    'Unité d\'Enseignement',
                    widget.unite.designation,
                    Icons.school,
                  ),
                  const SizedBox(height: 15),
                  _buildFooterRow(
                    'Semestre',
                    widget.semestre.designation,
                    Icons.calendar_today,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Titre de la section courante
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Text(
                  _selectedMenu,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher dans $_selectedMenu...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Grille de contenu (Placeholder)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
              ),
              itemCount: 6, // Exemple
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getMenuIcon(_selectedMenu),
                        size: 40,
                        color: Colors.indigo.withOpacity(0.5),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Item ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMenuIcon(String menu) {
    switch (menu) {
      case 'Activités':
        return Icons.local_activity_outlined;
      case 'Ressources':
        return Icons.folder_open_outlined;
      case 'Recours':
        return Icons.gavel_outlined;
      case 'Séances':
        return Icons.schedule_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Widget _buildFooterRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
