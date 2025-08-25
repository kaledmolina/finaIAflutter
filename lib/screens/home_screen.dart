import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; // Importa para el efecto de desenfoque

// Importa las páginas que se mostrarán en la navegación
import 'dashboard_page.dart';
import 'transactions_screen.dart';
import 'categories_screen.dart';

// --- WIDGET DE TARJETA CON EFECTO GLASSMORPHISM MEJORADO ---
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final EdgeInsets? padding;
  
  const GlassCard({
    super.key, 
    required this.child,
    this.borderRadius = 20.0,
    this.padding
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius!),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius!),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ]
          ),
          padding: padding ?? const EdgeInsets.all(16),
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
        // Fondo mejorado con gradiente más suave
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey.shade50,
              Colors.blueGrey.shade100,
              Colors.blueGrey.shade50,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: _pages.elementAt(_selectedIndex), // Muestra la página seleccionada
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: GlassCard(
          borderRadius: 30.0,
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: GNav(
            rippleColor: Colors.grey.shade300,
            hoverColor: Colors.grey.shade200,
            gap: 8,
            activeColor: Colors.blueGrey.shade800,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: Colors.white.withOpacity(0.5),
            color: Colors.blueGrey.shade600,
            textStyle: GoogleFonts.manrope(
              color: Colors.blueGrey.shade800,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              GButton(
                icon: Icons.home_outlined,
                text: 'Inicio',
              ),
              GButton(
                icon: Icons.list_alt_outlined,
                text: 'Transacciones',
              ),
              GButton(
                icon: Icons.category_outlined,
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
    );
  }
}

