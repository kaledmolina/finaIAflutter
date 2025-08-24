import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'home_screen.dart'; // Para usar GlassCard
import 'add_transaction_screen.dart';
import 'dart:ui';

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
      builder: (_) => const AddTransactionScreen(),
    ).then((result) {
      if (result == true) {
        setState(() {
          _transactionsFuture = _apiService.getTransactions();
        });
      }
    });
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
    // --- SE ELIMINÓ EL SCAFFOLD Y SE REEMPLAZÓ POR UN STACK ---
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Transacciones',
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
                  future: _transactionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay transacciones.',
                          style: GoogleFonts.manrope(color: Colors.white70),
                        ),
                      );
                    }
                    final groupedTransactions = _groupTransactionsByDate(snapshot.data!);
                    final dates = groupedTransactions.keys.toList();
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...transactionsOnDate.map((tx) => TransactionTile(transaction: tx)),
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
        // --- BOTÓN FLOTANTE POSICIONADO DENTRO DEL STACK ---
        Positioned(
          bottom: 90,
          right: 16,
          child: FloatingActionButton(
            onPressed: _openAddTransactionModal,
            backgroundColor: const Color(0xFF3D99F5),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class TransactionTile extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionTile({super.key, required this.transaction});
  
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
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['description'] ?? 'Sin descripción',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction['category']?['name'] ?? 'Sin categoría',
                    style: GoogleFonts.manrope(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                '${isIncome ? '+' : '-'}${currencyFormat.format(amount)}',
                style: GoogleFonts.manrope(
                  color: isIncome ? Colors.greenAccent.shade400 : Colors.redAccent.shade200,
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
