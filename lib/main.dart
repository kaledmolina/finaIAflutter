import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Método para verificar si el token de sesión existe
  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Devuelve 'true' si el token no es nulo
    return prefs.getString('auth_token') != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finanzas IA',
      debugShowCheckedModeBanner: false,
      // Configuración del tema visual de la aplicación
      theme: ThemeData(
        textTheme: GoogleFonts.manropeTextTheme(
          Theme.of(context).textTheme,
        ),
        brightness: Brightness.dark, // Usar un tema base oscuro
        scaffoldBackgroundColor: Colors.transparent, // Hacer el fondo del scaffold transparente
      ),
      // Configuración para que las fechas se muestren en español
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''), // Español
        Locale('en', ''), // Inglés (como fallback)
      ],
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          // Mientras se verifica el estado, muestra una pantalla de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Si el usuario ya ha iniciado sesión (snapshot.data == true)
          if (snapshot.hasData && snapshot.data == true) {
            return const HomeScreen();
          }
          // Si no, muestra la pantalla de login
          return const LoginScreen();
        },
      ),
    );
  }
}
