import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'dart:ui';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // Controladores y variables de estado
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'gasto';
  
  // Guardamos el objeto completo de la categoría para acceder a su expense_type
  Map<String, dynamic>? _selectedCategory; 
  String? _manualExpenseType; // Para cuando no se selecciona categoría
  DateTime _selectedDate = DateTime.now();

  late Future<List<dynamic>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _apiService.getCategories();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String? finalExpenseType;

      if (_selectedType == 'gasto') {
        if (_selectedCategory != null) {
          // Si hay categoría, usa su tipo de gasto
          finalExpenseType = _selectedCategory!['expense_type'];
        } else {
          // Si no hay categoría, usa el tipo manual
          finalExpenseType = _manualExpenseType;
        }
      }

      final success = await _apiService.storeTransaction({
        'type': _selectedType,
        'amount': _amountController.text,
        'description': _descriptionController.text,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'category_id': _selectedCategory?['id'],
        'expense_type': finalExpenseType,
      });

      if (success && mounted) {
        Navigator.of(context).pop(true); // Devuelve 'true' para indicar éxito
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar la transacción')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        'Añadir Transacción',
                        style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Form Fields
                  _buildDropdownField(
                    hint: 'Tipo de Transacción',
                    value: _selectedType,
                    items: const [
                      DropdownMenuItem(value: 'gasto', child: Text('Gasto')),
                      DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                        _selectedCategory = null; // Resetea la categoría
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _amountController, hint: 'Monto', keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _descriptionController, hint: 'Descripción'),
                  const SizedBox(height: 16),
                  _buildDateField(),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(),
                  
                  // --- LÓGICA CONDICIONAL ---
                  if (_selectedType == 'gasto' && _selectedCategory == null) ...[
                    const SizedBox(height: 16),
                    _buildExpenseTypeDropdown(),
                  ],

                  const SizedBox(height: 32),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3D99F5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Guardar', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(hint),
      validator: (value) => value == null || value.isEmpty ? 'Este campo es requerido' : null,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: DateFormat('MMMM d, yyyy', 'es_ES').format(_selectedDate)),
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration('Fecha'),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
          });
        }
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return FutureBuilder<List<dynamic>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        final categories = snapshot.data!.where((cat) => cat['type'] == _selectedType).toList();
        return _buildDropdownField<Map<String, dynamic>>(
          hint: 'Categoría (Opcional)',
          value: _selectedCategory,
          items: categories.map((cat) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: cat,
              child: Text(cat['name']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        );
      },
    );
  }

  Widget _buildExpenseTypeDropdown() {
    return _buildDropdownField<String>(
      hint: 'Tipo de Gasto (50/30/20)',
      value: _manualExpenseType,
      items: const [
        DropdownMenuItem(value: 'básico', child: Text('Básico (Necesidad)')),
        DropdownMenuItem(value: 'lujo', child: Text('Lujo (Deseo)')),
        DropdownMenuItem(value: 'ahorro', child: Text('Ahorro / Inversión')),
      ],
      onChanged: (value) {
        setState(() {
          _manualExpenseType = value;
        });
      },
    );
  }
  
  Widget _buildDropdownField<T>({required String hint, T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(hint),
      dropdownColor: Colors.deepPurple.shade400,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
      validator: (value) {
        // Validación especial para el tipo de gasto manual
        if (hint.contains('Tipo de Gasto') && value == null) {
          return 'Debes justificar el gasto';
        }
        return null;
      },
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
