import 'dart:ui'; // Importa para el efecto de desenfoque
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// Importa las páginas que se mostrarán en la navegación
import 'dashboard_page.dart';
import 'transactions_screen.dart';
import 'categories_screen.dart';

// --- WIDGET DE TARJETA CON EFECTO GLASSMORPHISM (Reutilizable) ---
class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// --- PANTALLA PRINCIPAL (CONTENEDOR) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Lista de las páginas que se mostrarán
  static const List<Widget> _pages = <Widget>[
    DashboardPage(),
    TransactionsScreen(),
    CategoriesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Permite que el cuerpo se extienda detrás de la barra
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade300, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _pages.elementAt(_selectedIndex), // Muestra la página seleccionada
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: GNav(
              rippleColor: Colors.grey[800]!,
              hoverColor: Colors.grey[700]!,
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.blue.withOpacity(0.3),
              color: Colors.white.withOpacity(0.6),
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Inicio',
                ),
                GButton(
                  icon: Icons.list_alt,
                  text: 'Transacciones',
                ),
                GButton(
                  icon: Icons.category,
                  text: 'Categorías',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
