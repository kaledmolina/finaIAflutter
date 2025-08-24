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

  void _openAddCategoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddCategoryModal(),
    ).then((result) {
      if (result == true) {
        setState(() {
          _categoriesFuture = _apiService.getCategories();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Categorías',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No has creado categorías.',
                          style: GoogleFonts.manrope(color: Colors.white70),
                        ),
                      );
                    }

                    final incomeCategories = snapshot.data!.where((c) => c['type'] == 'ingreso').toList();
                    final expenseCategories = snapshot.data!.where((c) => c['type'] == 'gasto').toList();

                    return ListView(
                      padding: const EdgeInsets.only(bottom: 90),
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
        Positioned(
          bottom: 90,
          right: 16,
          child: FloatingActionButton(
            onPressed: _openAddCategoryModal,
            backgroundColor: const Color(0xFF3D99F5),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
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
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        ...categories.map((cat) => CategoryTile(category: cat)),
      ],
    );
  }
}

class CategoryTile extends StatelessWidget {
  final Map<String, dynamic> category;
  const CategoryTile({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                category['name'] ?? 'Sin nombre',
                style: GoogleFonts.manrope(
                  color: Colors.white,
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
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20, left: 20, right: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nueva Categoría', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                    backgroundColor: const Color(0xFF3D99F5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Guardar', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(hint),
      validator: (value) => value == null || value.isEmpty ? 'Este campo es requerido' : null,
    );
  }
  
  Widget _buildDropdownField<T>({required String hint, T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged, FormFieldValidator<T>? validator}) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(hint),
      dropdownColor: Colors.deepPurple.shade400,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    );
  }
}
