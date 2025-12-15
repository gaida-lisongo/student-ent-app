import 'package:flutter/material.dart';
// Assurez-vous que ces chemins d'importation sont corrects pour vos fichiers
import 'package:student_app/screens/dashboard_screen.dart';
import 'package:student_app/screens/profile_screen.dart';
import 'package:student_app/screens/resultat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Student App Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentPage = 1;
  // Déclarer _pageController tardivement (late) ou dans initState
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Correction : initState doit être void, et _pageController initialisé ici.
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fonction pour gérer le changement de page
  void _onItemTapped(int index) {
    setState(() {
      _currentPage = index;
      // Utiliser animateToPage pour une transition plus fluide
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // Le widget pour un item de navigation stylisé
  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = index == _currentPage;
    final Color activeColor = Colors.white;
    final Color inactiveColor = Colors.grey.shade400;

    return Expanded(
      // Pour que les éléments prennent une largeur égale
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            // Indicateur de sélection
            AnimatedContainer(
              // Utiliser AnimatedContainer pour une transition douce
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: isSelected ? 24 : 0,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget de la barre de navigation flottante
  Widget _buildFloatingNavBar() {
    return Positioned(
      bottom: 25, // Élévation du bas
      left: 90,
      right: 90,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(
            0.85,
          ), // Arrière-plan sombre/transparent
          borderRadius: BorderRadius.circular(30), // Coins très arrondis
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.person, 'Profile', 0),
            _buildNavItem(Icons.dashboard, 'Dashboard', 1),
            _buildNavItem(Icons.payment, 'Recharge', 2),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- REMPLACEMENT DE bottomNavigationBar PAR STACK ---
      body: Stack(
        children: [
          // 1. Contenu de la page (PageView)
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            // Assurez-vous que ProfileScreen, DashboardScreen, RechargeScreen
            // sont bien importés et définis (comme vous l'avez fait)
            children: [ProfileScreen(), DashboardScreen(), ResultatScreen()],
          ),

          // 2. La Bottom Navigation Bar Flottante
          _buildFloatingNavBar(),
        ],
      ),
      // bottomNavigationBar est retiré pour que le contenu puisse s'étendre en bas
      // et que le widget Positioned puisse le recouvrir.
    );
  }
}
