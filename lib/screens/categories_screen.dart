import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'home_screen.dart'; // Para usar GlassCard
import 'dart:ui';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ApiService _apiService = ApiService();
  Future<List<dynamic>>? _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _apiService.getCategories();
  }

  void _refreshCategories() {
    setState(() {
      _categoriesFuture = _apiService.getCategories();
    });
  }

  void _openAddCategoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: const AddCategoryModal(),
      ),
    ).then((result) {
      if (result == true) {
        _refreshCategories();
      }
    });
  }

  void _openSuggestionsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: const SuggestionsModal(),
      ),
    ).then((result) {
      if (result == true) {
        _refreshCategories();
      }
    });
  }

  void _openCategoryDetailModal(Map<String, dynamic> category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: CategoryDetailModal(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              // Encabezado con efecto de vidrio
              GlassCard(
                borderRadius: 0,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categorías',
                      style: GoogleFonts.manrope(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.blueGrey.shade800
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _openSuggestionsModal,
                      icon: Icon(Icons.lightbulb_outline, color: Colors.blueGrey.shade800, size: 20),
                      label: Text(
                        'Sugerencias', 
                        style: GoogleFonts.manrope(color: Colors.blueGrey.shade800)
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: GlassCard(
                          borderRadius: 100,
                          padding: const EdgeInsets.all(20),
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.category, size: 40, color: Colors.blueGrey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'No has creado categorías.',
                                style: GoogleFonts.manrope(color: Colors.blueGrey.shade600),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final incomeCategories = snapshot.data!.where((c) => c['type'] == 'ingreso').toList();
                    final expenseCategories = snapshot.data!.where((c) => c['type'] == 'gasto').toList();
                    return ListView(
                      padding: const EdgeInsets.only(bottom: 100), // Espacio para el FAB
                      children: [
                        _buildCategorySection('Ingresos', incomeCategories),
                        _buildCategorySection('Gastos', expenseCategories),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // Ajuste para que no se oculte con la barra de navegación
        child: FloatingActionButton(
          onPressed: _openAddCategoryModal,
          backgroundColor: Colors.blueGrey.shade800,
          foregroundColor: Colors.white,
          elevation: 0,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title, List<dynamic> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: GoogleFonts.manrope(
              color: Colors.blueGrey.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        ...categories.map((cat) => CategoryTile(
              category: cat,
              onTap: () => _openCategoryDetailModal(cat),
            )),
      ],
    );
  }
}

class CategoryTile extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback onTap;

  const CategoryTile({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCategoryIcon(category['name']),
                  color: Colors.blueGrey.shade800,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                category['name'] ?? 'Sin nombre',
                style: GoogleFonts.manrope(
                  color: Colors.blueGrey.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? categoryName) {
    switch (categoryName?.toLowerCase()) {
      case 'mercado':
        return Icons.shopping_cart;
      case 'arriendo / hipoteca':
        return Icons.home;
      case 'servicios públicos':
        return Icons.electrical_services;
      case 'salud':
        return Icons.local_hospital;
      case 'transporte':
        return Icons.directions_car;
      case 'restaurantes':
        return Icons.restaurant;
      case 'entretenimiento':
        return Icons.movie;
      case 'compras (ropa, etc.)':
        return Icons.shopping_bag;
      case 'viajes':
        return Icons.flight;
      case 'ahorro a largo plazo':
      case 'inversiones':
      case 'pago de deudas':
        return Icons.savings;
      default:
        return Icons.category;
    }
  }
}

// --- MODAL PARA DETALLES DE CATEGORÍA ---
class CategoryDetailModal extends StatelessWidget {
  final Map<String, dynamic> category;
  const CategoryDetailModal({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detalle de Categoría',
                  style: GoogleFonts.manrope(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.blueGrey.shade800
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.blueGrey.shade800),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Nombre:', category['name'] ?? 'N/A'),
            const SizedBox(height: 16),
            _buildDetailRow('Tipo:', (category['type'] == 'ingreso' ? 'Ingreso' : 'Gasto')),
            if (category['type'] == 'gasto' && category['expense_type'] != null) ...[
              const SizedBox(height: 16),
              _buildDetailRow('Tipo de Gasto:', (category['expense_type'] as String).replaceFirst(category['expense_type'][0], category['expense_type'][0].toUpperCase())),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            color: Colors.blueGrey.shade600, 
            fontSize: 16
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            color: Colors.blueGrey.shade800, 
            fontSize: 16, 
            fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }
}

// --- MODAL PARA AÑADIR CATEGORÍA ---
class AddCategoryModal extends StatefulWidget {
  const AddCategoryModal({super.key});
  @override
  State<AddCategoryModal> createState() => _AddCategoryModalState();
}

class _AddCategoryModalState extends State<AddCategoryModal> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _nameController = TextEditingController();
  String _selectedType = 'gasto';
  String? _selectedExpenseType;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final success = await _apiService.storeCategory({
        'name': _nameController.text,
        'type': _selectedType,
        'expense_type': _selectedType == 'gasto' ? _selectedExpenseType : null,
      });
      if (success && mounted) {
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar la categoría')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassCard(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20, 
          left: 20, 
          right: 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nueva Categoría', 
                style: GoogleFonts.manrope(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.blueGrey.shade800
                )
              ),
              const SizedBox(height: 24),
              _buildTextField(controller: _nameController, hint: 'Nombre de la categoría'),
              const SizedBox(height: 16),
              _buildDropdownField(
                hint: 'Tipo',
                value: _selectedType,
                items: const [
                  DropdownMenuItem(value: 'gasto', child: Text('Gasto')),
                  DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
                ],
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              if (_selectedType == 'gasto') ...[
                const SizedBox(height: 16),
                _buildDropdownField(
                  hint: 'Tipo de Gasto (50/20/30)',
                  value: _selectedExpenseType,
                  items: const [
                    DropdownMenuItem(value: 'básico', child: Text('Básico (Necesidad)')),
                    DropdownMenuItem(value: 'lujo', child: Text('Lujo (Deseo)')),
                    DropdownMenuItem(value: 'ahorro', child: Text('Ahorro / Inversión')),
                  ],
                  onChanged: (value) => setState(() => _selectedExpenseType = value),
                  validator: (value) => value == null ? 'Selecciona un tipo de gasto' : null,
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'Guardar', 
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16
                  )
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint}) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.blueGrey.shade800),
      decoration: _inputDecoration(hint),
      validator: (value) => value == null || value.isEmpty ? 'Este campo es requerido' : null,
    );
  }
  
  Widget _buildDropdownField<T>({
    required String hint, 
    T? value, 
    required List<DropdownMenuItem<T>> items, 
    required ValueChanged<T?> onChanged, 
    FormFieldValidator<T>? validator
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(color: Colors.blueGrey.shade800),
      decoration: _inputDecoration(hint),
      dropdownColor: Colors.blueGrey.shade50,
      icon: Icon(Icons.arrow_drop_down, color: Colors.blueGrey.shade800),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.blueGrey.shade600),
      filled: true,
      fillColor: Colors.blueGrey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), 
        borderSide: BorderSide.none
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    );
  }
}

// --- MODAL PARA SUGERENCIAS ---
class SuggestionsModal extends StatefulWidget {
  const SuggestionsModal({super.key});

  @override
  State<SuggestionsModal> createState() => _SuggestionsModalState();
}

class _SuggestionsModalState extends State<SuggestionsModal> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _suggestionsFuture;
  final List<dynamic> _selectedSuggestions = [];

  @override
  void initState() {
    super.initState();
    _suggestionsFuture = _apiService.getCategorySuggestions();
  }

  void _onSuggestionTapped(dynamic suggestion) {
    setState(() {
      if (_selectedSuggestions.contains(suggestion)) {
        _selectedSuggestions.remove(suggestion);
      } else {
        _selectedSuggestions.add(suggestion);
      }
    });
  }

  Future<void> _saveSuggestions() async {
    if (_selectedSuggestions.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final success = await _apiService.storeSelectedSuggestions(_selectedSuggestions);
    if (success && mounted) {
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar las sugerencias')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassCard(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Categorías Sugeridas', 
              style: GoogleFonts.manrope(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: Colors.blueGrey.shade800
              )
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _suggestionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: GlassCard(
                        borderRadius: 100,
                        padding: const EdgeInsets.all(20),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay nuevas sugerencias.', 
                        style: GoogleFonts.manrope(color: Colors.blueGrey.shade600)
                      )
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final suggestion = snapshot.data![index];
                      final isSelected = _selectedSuggestions.contains(suggestion);
                      return CheckboxListTile(
                        title: Text(
                          suggestion['name'], 
                          style: TextStyle(color: Colors.blueGrey.shade800)
                        ),
                        value: isSelected,
                        onChanged: (_) => _onSuggestionTapped(suggestion),
                        activeColor: Colors.blueGrey.shade800,
                        checkColor: Colors.white,
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveSuggestions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                'Añadir Seleccionadas', 
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}