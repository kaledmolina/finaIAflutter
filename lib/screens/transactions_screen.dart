import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'add_transaction_screen.dart';
import 'dart:ui';
import 'home_screen.dart'; // Importamos GlassCard

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final ApiService _apiService = ApiService();
  Future<List<dynamic>>? _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _apiService.getTransactions();
  }

  void _openAddTransactionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: const AddTransactionScreen(),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {
          _transactionsFuture = _apiService.getTransactions();
        });
      }
    });
  }

  void _openTransactionDetailModal(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TransactionDetailModal(transaction: transaction),
      ),
    );
  }

  Map<String, List<dynamic>> _groupTransactionsByDate(List<dynamic> transactions) {
    final Map<String, List<dynamic>> grouped = {};
    for (var tx in transactions) {
      final date = tx['date'];
      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(tx);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo con gradiente suave
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Transacciones',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _transactionsFuture,
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
                              Icon(Icons.receipt_long, size: 40, color: Colors.blueGrey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'No hay transacciones.',
                                style: GoogleFonts.manrope(color: Colors.blueGrey.shade600),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final groupedTransactions = _groupTransactionsByDate(snapshot.data!);
                    final dates = groupedTransactions.keys.toList();
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100), // Espacio para el FAB
                      itemCount: dates.length,
                      itemBuilder: (context, index) {
                        final date = dates[index];
                        final transactionsOnDate = groupedTransactions[date]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                              child: Text(
                                DateFormat('MMMM d, yyyy', 'es_ES').format(DateTime.parse(date)),
                                style: GoogleFonts.manrope(
                                  color: Colors.blueGrey.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...transactionsOnDate.map((tx) => TransactionTile(
                                  transaction: tx,
                                  onTap: () => _openTransactionDetailModal(tx),
                                )),
                          ],
                        );
                      },
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
          onPressed: _openAddTransactionModal,
          backgroundColor: Colors.blueGrey.shade800,
          foregroundColor: Colors.white,
          elevation: 0,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onTap;

  const TransactionTile({super.key, required this.transaction, required this.onTap});
  
  double _safeConvertToDouble(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction['type'] == 'ingreso';
    final amount = _safeConvertToDouble(transaction['amount']);
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$ ', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['description'] ?? 'Sin descripción',
                      style: GoogleFonts.manrope(
                        color: Colors.blueGrey.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction['category']?['name'] ?? 'Sin categoría',
                      style: GoogleFonts.manrope(
                        color: Colors.blueGrey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}${currencyFormat.format(amount)}',
                style: GoogleFonts.manrope(
                  color: isIncome ? Colors.teal.shade600 : Colors.pink.shade600,
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

// --- MODAL PARA DETALLES DE TRANSACCIÓN CON ESTILO LIQUID GLASS ---
class TransactionDetailModal extends StatelessWidget {
  final Map<String, dynamic> transaction;
  const TransactionDetailModal({super.key, required this.transaction});

  double _safeConvertToDouble(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction['type'] == 'ingreso';
    final amount = _safeConvertToDouble(transaction['amount']);
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$ ', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassCard(
        borderRadius: 20.0,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detalle de Transacción',
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
            _buildDetailRow('Descripción:', transaction['description'] ?? 'N/A'),
            const SizedBox(height: 16),
            _buildDetailRow('Monto:', '${isIncome ? '+' : '-'}${currencyFormat.format(amount)}'),
            const SizedBox(height: 16),
            _buildDetailRow('Fecha:', DateFormat('MMMM d, yyyy', 'es_ES').format(DateTime.parse(transaction['date']))),
            const SizedBox(height: 16),
            _buildDetailRow('Categoría:', transaction['category']?['name'] ?? 'Sin categoría'),
            if (!isIncome && transaction['expense_type'] != null) ...[
              const SizedBox(height: 16),
              _buildDetailRow('Tipo de Gasto:', (transaction['expense_type'] as String).replaceFirst(transaction['expense_type'][0], transaction['expense_type'][0].toUpperCase())),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            color: Colors.blueGrey.shade600, 
            fontSize: 14
          ),
        ),
        const SizedBox(height: 4),
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