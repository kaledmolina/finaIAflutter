import 'package:flutter/material.dart';
import '../services/api_service.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  void _register() async {
    // Oculta el teclado si está abierto
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);
    final success = await _apiService.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Registro exitoso! Por favor, inicia sesión.')),
      );
      // Navega a Login y elimina la pantalla de registro del stack
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error en el registro. Inténtalo de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // bg-slate-50
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Imagen de cabecera (igual que en Login) ---
            Container(
              height: 250, // Altura ajustada para móvil
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      "https://lh3.googleusercontent.com/aida-public/AB6AXuCPFIAv8BSB6Nb5KYvklOd0GjuLUzWHcl7VKQGbRdUZqCTBAbt8Yr4v6dgInvC_eGkYG9HFzKbNWNur9orC0828qO_hyq2S031FpYh2flfAqblofjEYtWuZtAw_mp0K12i1a9bScxpTy4ys_UEhWMUH1-ebAU1-T1ATLdhBUtvQAAI065ZCR8pO_7jZW4vnnScGM87gAAazoEEeALFPY9zAczt4z6z5WvY-ImHqcKA69656MnEUJX_GICA3IY3LXUOVKU0J99HeZUo"),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                )
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // --- Campo de Nombre ---
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Nombre',
                      hintStyle: const TextStyle(color: Color(0xFF49739C)),
                      filled: true,
                      fillColor: const Color(0xFFE7EDF4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // --- Campo de Email ---
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: const TextStyle(color: Color(0xFF49739C)),
                      filled: true,
                      fillColor: const Color(0xFFE7EDF4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // --- Campo de Contraseña ---
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      hintStyle: const TextStyle(color: Color(0xFF49739C)),
                      filled: true,
                      fillColor: const Color(0xFFE7EDF4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // --- Botón de Registrarse ---
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3D99F5),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: const Text(
                              'Crear Cuenta',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),
                  // --- Botón para ir a Login ---
                  TextButton(
                    onPressed: () {
                      // Simplemente regresa a la pantalla anterior (Login)
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      '¿Ya tienes cuenta? Inicia Sesión',
                      style: TextStyle(color: Color(0xFF49739C)),
                    ),
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
