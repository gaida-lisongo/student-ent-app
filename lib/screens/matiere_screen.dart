import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/model/charge_model.dart';
import 'package:student_app/model/matiere_model.dart';
import 'package:student_app/model/promotion_model.dart';
import 'package:student_app/model/semestre_model.dart';
import 'package:student_app/model/unite_model.dart';
import 'package:student_app/stores/annee_provider.dart';
import 'package:student_app/stores/matiere_provider.dart';
import 'package:student_app/stores/promotion_provider.dart';

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
  String _selectedMenu = 'Informations';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _recoursController = TextEditingController();

  final List<String> _menuItems = [
    'Informations',
    'Activités',
    'Ressources',
    'Séances',
    'Recours',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  Future<void> _fetchInitialData() async {
    try {
      final anneeAsync = ref.read(anneeProvider);
      if (anneeAsync.value != null) {
        await ref
            .read(matiereProvider.notifier)
            .fetchRecharge(widget.matiere.id, anneeAsync.value!.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final anneeAsync = ref.watch(anneeProvider);
    final charge = ref.watch(matiereProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          charge.status.isNotEmpty
              ? charge.status.toUpperCase()
              : 'CHARGEMENT...',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _getStatusColor(charge.status),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: _buildDrawer(charge, anneeAsync),
      body: _buildBody(charge),
    );
  }

  Widget _buildDrawer(Charge charge, AsyncValue anneeAsync) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          // Informations enseignant
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade600, Colors.indigo.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    _getInitials(
                      charge.enseignant.nom,
                      charge.enseignant.prenom,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  '${charge.enseignant.nom} ${charge.enseignant.postNom}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  charge.enseignant.prenom,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Mat: ${charge.enseignant.matricule}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (charge.enseignant.email.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.email, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          charge.enseignant.email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (charge.enseignant.telephone.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        charge.enseignant.telephone,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Menu items
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
                  trailing: _getMenuBadge(item, charge),
                  selected: isSelected,
                  selectedTileColor: Colors.indigo.withOpacity(0.05),
                  onTap: () {
                    setState(() {
                      _selectedMenu = item;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),

          // Footer avec année académique
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.grey[50],
            child: Column(
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Erreur'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMenuIcon(String menu) {
    switch (menu) {
      case 'Informations':
        return Icons.info_outline;
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

  Widget _buildBody(Charge charge) {
    switch (_selectedMenu) {
      case 'Informations':
        return _buildInformationsView(charge);
      case 'Activités':
        return _buildActivitiesView(charge);
      case 'Ressources':
        return _buildRessourcesView(charge);
      case 'Séances':
        return _buildSeancesView(charge);
      case 'Recours':
        return _buildRecoursView(charge);
      default:
        return _buildInformationsView(charge);
    }
  }

  Widget _buildInformationsView(Charge charge) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte matière
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade600, Colors.indigo.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        charge.cours.designation.isNotEmpty
                            ? charge.cours.designation
                            : widget.matiere.designation,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        charge.cours.code.isNotEmpty
                            ? charge.cours.code
                            : widget.matiere.code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Crédits: ${charge.cours.credits ?? widget.matiere.credits}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section Objectifs
          if (charge.objectif.isNotEmpty) ...[
            _buildInfoSection(
              'Objectifs',
              charge.objectif,
              Icons.flag_outlined,
              Colors.green,
            ),
            const SizedBox(height: 15),
          ],

          // Section Évaluation
          if (charge.evaluation.isNotEmpty) ...[
            _buildInfoSection(
              'Évaluation',
              charge.evaluation,
              Icons.assessment_outlined,
              Colors.orange,
            ),
            const SizedBox(height: 15),
          ],

          // Section Méthodologie
          if (charge.methodologie.isNotEmpty) ...[
            _buildInfoSection(
              'Méthodologie',
              charge.methodologie,
              Icons.psychology_outlined,
              Colors.purple,
            ),
            const SizedBox(height: 15),
          ],

          // Section Contenu
          if (charge.contenu.isNotEmpty) ...[
            _buildInfoSection(
              'Contenu',
              charge.contenu,
              Icons.book_outlined,
              Colors.blue,
            ),
            const SizedBox(height: 15),
          ],

          // Section Références
          if (charge.references.isNotEmpty) ...[
            _buildInfoSection(
              'Références',
              charge.references,
              Icons.library_books_outlined,
              Colors.red,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesView(Charge charge) {
    final activities = charge.activities ?? [];

    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'Aucune activité disponible',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      activity.title,
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
                      color: _getActivityTypeColor(activity.type),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      activity.type.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                activity.description,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.grade, size: 16, color: Colors.amber[700]),
                  const SizedBox(width: 5),
                  Text(
                    'Note max: ${activity.maximumScore}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRessourcesView(Charge charge) {
    final ressources = charge.ressources ?? [];

    if (ressources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'Aucune ressource disponible',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: ressources.length,
      itemBuilder: (context, index) {
        final ressource = ressources[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.description, color: Colors.blue[600]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ressource.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${ressource.montant} FC',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ressource.description,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeancesView(Charge charge) {
    final seances = charge.seances ?? [];

    if (seances.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'Aucune séance programmée',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: seances.length,
      itemBuilder: (context, index) {
        final seance = seances[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.event, color: Colors.purple[600]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      seance.topic,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                seance.description,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 5),
                  Text(
                    '${seance.startTime} - ${seance.endTime}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 15),
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 5),
                  Text(seance.location, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecoursView(Charge charge) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Soumettre un recours',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _recoursController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Description de votre recours',
                    hintText: 'Décrivez en détail l\'objet de votre recours...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_recoursController.text.trim().isNotEmpty) {
                        _submitRecours();
                      }
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Soumettre le recours'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitRecours() {
    // TODO: Implémenter la soumission du recours
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recours soumis avec succès!'),
        backgroundColor: Colors.green,
      ),
    );
    _recoursController.clear();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getInitials(String nom, String prenom) {
    if (nom.isEmpty && prenom.isEmpty) return '??';
    final nomInitial = nom.isNotEmpty ? nom[0] : '';
    final prenomInitial = prenom.isNotEmpty ? prenom[0] : '';
    return (nomInitial + prenomInitial).toUpperCase();
  }

  Widget? _getMenuBadge(String menu, Charge charge) {
    int count = 0;
    switch (menu) {
      case 'Activités':
        count = charge.activities?.length ?? 0;
        break;
      case 'Ressources':
        count = charge.ressources?.length ?? 0;
        break;
      case 'Séances':
        count = charge.seances?.length ?? 0;
        break;
      case 'Recours':
        count = charge.recours?.length ?? 0;
        break;
      default:
        return null;
    }

    if (count == 0) return null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getActivityTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'devoir':
        return Colors.blue;
      case 'quiz':
        return Colors.green;
      case 'projet':
        return Colors.purple;
      case 'examen':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
