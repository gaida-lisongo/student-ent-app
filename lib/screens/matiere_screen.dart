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

  @override
  void dispose() {
    _recoursController.dispose();
    super.dispose();
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
          // Carte matière améliorée
          _buildEnhancedCourseCard(charge),
          const SizedBox(height: 25),

          // Section Descriptions horizontales
          _buildDescriptionSection(charge),
          const SizedBox(height: 25),

          // Section Ressources
          _buildRessourcesSection(charge),
        ],
      ),
    );
  }

  Widget _buildEnhancedCourseCard(Charge charge) {
    return Container(
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
          // Titre et code
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
          const SizedBox(height: 15),

          // Informations détaillées
          Row(
            children: [
              Icon(
                Icons.school,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'UE: ${widget.unite.designation}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Semestre: ${widget.semestre.designation}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (charge.promotionId != null) ...[
            Row(
              children: [
                Icon(
                  Icons.groups,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Promotion: ${charge.promotionId!.designation}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          Row(
            children: [
              Icon(Icons.star, color: Colors.white.withOpacity(0.8), size: 16),
              const SizedBox(width: 8),
              Text(
                'Crédits: ${widget.matiere.credits}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(Charge charge) {
    final descriptions = [
      if (charge.objectif.isNotEmpty)
        {
          'title': 'Objectifs',
          'content': charge.objectif,
          'icon': Icons.flag_outlined,
          'color': Colors.green,
        },
      if (charge.evaluation.isNotEmpty)
        {
          'title': 'Évaluation',
          'content': charge.evaluation,
          'icon': Icons.assessment_outlined,
          'color': Colors.orange,
        },
      if (charge.methodologie.isNotEmpty)
        {
          'title': 'Méthodologie',
          'content': charge.methodologie,
          'icon': Icons.psychology_outlined,
          'color': Colors.purple,
        },
      if (charge.contenu.isNotEmpty)
        {
          'title': 'Contenu',
          'content': charge.contenu,
          'icon': Icons.book_outlined,
          'color': Colors.blue,
        },
      if (charge.references.isNotEmpty)
        {
          'title': 'Références',
          'content': charge.references,
          'icon': Icons.library_books_outlined,
          'color': Colors.red,
        },
    ];

    if (descriptions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descriptions du cours',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: descriptions.length,
            itemBuilder: (context, index) {
              final desc = descriptions[index];
              return Container(
                width: 140,
                margin: EdgeInsets.only(
                  right: index < descriptions.length - 1 ? 15 : 0,
                ),
                child: _buildDescriptionCard(
                  desc['title'] as String,
                  desc['content'] as String,
                  desc['icon'] as IconData,
                  desc['color'] as Color,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () => _showDescriptionBottomSheet(title, content, icon, color),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              'Voir détails',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDescriptionBottomSheet(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Container(
                  width: double.infinity,
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.8,
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRessourcesSection(Charge charge) {
    final ressources = charge.ressources ?? [];

    if (ressources.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ressources disponibles',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: ressources.asMap().entries.map((entry) {
              int index = entry.key;
              var ressource = entry.value;

              return Column(
                children: [
                  _buildRessourceCard(ressource),
                  if (index < ressources.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRessourceCard(dynamic ressource) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.description, color: Colors.blue[600], size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ressource.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ressource.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${ressource.montant} FC',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        print('Commander ressource: ${ressource.title}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Commander',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
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
