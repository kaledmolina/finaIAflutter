import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import 'home_screen.dart'; // Para usar GlassCard
import 'login_screen.dart'; // Para navegar al login

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = ApiService();
  Future<Map<String, dynamic>>? _dashboardDataFuture;
  final _incomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _apiService.getDashboardData();
  }

  void _addIncome() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
         margin: const EdgeInsets.all(16),
         child: GlassCard(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Añadir Ingreso Mensual', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                TextField(
                  controller: _incomeController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Monto',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixText: '\$ ',
                    prefixStyle: const TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.5))),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (_incomeController.text.isEmpty) return;
                    final success = await _apiService.addMonthlyIncome(_incomeController.text);
                    if (success && mounted) {
                      Navigator.of(ctx).pop();
                      setState(() {
                        _dashboardDataFuture = _apiService.getDashboardData();
                        _incomeController.clear();
                      });
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error al guardar el ingreso')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D99F5),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: const Text('Guardar Ingreso', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _handleLogout() async {
    await _apiService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Error al cargar los datos', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _dashboardDataFuture = _apiService.getDashboardData();
                    });
                  },
                  child: const Text('Reintentar'),
                )
              ],
            ),
          );
        }
        final data = snapshot.data!;
        final bool hasIncome = data['hasIncome'] ?? false;
        if (!hasIncome) {
          return IncomeReminderView(
            userName: data['userName'] ?? 'Usuario',
            onAddIncome: _addIncome,
          );
        } else {
          return DashboardView(
            dashboardData: data,
            onLogout: _handleLogout,
          );
        }
      },
    );
  }
}

// --- VISTA 1: Recordatorio para añadir Ingresos ---
class IncomeReminderView extends StatelessWidget {
  final String userName;
  final VoidCallback onAddIncome;

  const IncomeReminderView({
    super.key,
    required this.userName,
    required this.onAddIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () { /* Lógica para abrir menú lateral */ },
                    ),
                    Text(
                      'Resumen',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Bienvenido, $userName',
                  style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "No has registrado tus ingresos de este mes aún. Por favor añade tu ingreso mensual para empezar a usar la aplicación.",
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAddIncome,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D99F5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                'Añadir Ingreso Mensual',
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- VISTA 2: Dashboard Principal ---
class DashboardView extends StatelessWidget {
  final Map<String, dynamic> dashboardData;
  final VoidCallback onLogout;

  const DashboardView({
    super.key,
    required this.dashboardData,
    required this.onLogout,
  });

  double _safeConvertToDouble(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$ ', decimalDigits: 0);

    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(dashboardData['userAvatarUrl'] ?? 'https://via.placeholder.com/100/e7edf4/49739c?text=U'),
                      radius: 20,
                    ),
                    Text(
                      'Panel de Control',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: onLogout,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Resumen Financiero',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                     _buildSummaryRow('Ingresos Totales', _safeConvertToDouble(dashboardData['totalIncome']), currencyFormat),
                      _buildSummaryRow('Gastos Totales', _safeConvertToDouble(dashboardData['totalExpenses']), currencyFormat),
                      _buildSummaryRow('Balance Actual', _safeConvertToDouble(dashboardData['balance']), currencyFormat),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Uso de Presupuesto',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(child: _buildBudgetUsageSection(dashboardData, currencyFormat)), // <-- Se pasa el formateador
              const SizedBox(height: 32),
              Text(
                'Gastos Diarios',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(child: _buildDailySpendingSection(dashboardData)),
              const SizedBox(height: 32),
              Text(
                'Categorías con Más Gastos',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...?(dashboardData['topCategories'] as List?)?.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: GlassCard(child: _buildCategoryRow(category['name'], _safeConvertToDouble(category['total']), currencyFormat)),
                );
              }).toList(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, double amount, NumberFormat format) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          Text(
            format.format(amount),
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String name, double amount, NumberFormat format) {
    IconData iconData;
    switch (name.toLowerCase()) {
      case 'mercado':
      case 'arriendo / hipoteca':
      case 'servicios públicos':
      case 'salud':
        iconData = Icons.home;
        break;
      case 'transporte':
        iconData = Icons.directions_car;
        break;
      case 'restaurantes':
        iconData = Icons.restaurant;
        break;
      case 'entretenimiento':
        iconData = Icons.movie;
        break;
      case 'compras (ropa, etc.)':
        iconData = Icons.shopping_bag;
        break;
      case 'viajes':
        iconData = Icons.flight;
        break;
      case 'ahorro a largo plazo':
      case 'inversiones':
      case 'pago de deudas':
        iconData = Icons.savings;
        break;
      default:
        iconData = Icons.shopping_cart;
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  format.format(amount),
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetUsageSection(Map<String, dynamic> data, NumberFormat format) { // <-- Recibe el formateador
    final totalIncome = _safeConvertToDouble(data['totalIncome']);
    final totalExpenses = _safeConvertToDouble(data['totalExpenses']);
    
    final budgetUsage = data['budgetUsage'] is Map<String, dynamic> 
                      ? data['budgetUsage'] as Map<String, dynamic>
                      : <String, dynamic>{};

    final needsSpent = _safeConvertToDouble(budgetUsage['needs']);
    final wantsSpent = _safeConvertToDouble(budgetUsage['wants']);
    final savingsSpent = _safeConvertToDouble(budgetUsage['savings']);

    final needsBudget = totalIncome * 0.5;
    final wantsBudget = totalIncome * 0.2;
    final savingsBudget = totalIncome * 0.3;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Regla 50/20/30',
            style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '${totalIncome > 0 ? ((totalExpenses / totalIncome) * 100).toStringAsFixed(0) : 0}%',
            style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Utilizado',
            style: GoogleFonts.manrope(fontSize: 16, color: Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: 16),
          _buildProgressBar("Necesidades", needsSpent, needsBudget, Colors.lightBlue.shade200, Colors.red.shade400, format),
          const SizedBox(height: 16),
          _buildProgressBar("Deseos", wantsSpent, wantsBudget, Colors.amber.shade200, Colors.red.shade400, format),
          const SizedBox(height: 16),
          _buildProgressBar("Ahorros", savingsSpent, savingsBudget, Colors.teal.shade200, Colors.red.shade400, format),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String title, double spent, double budget, Color defaultColor, Color overspentColor, NumberFormat format) {
    final factor = budget > 0 ? (spent / budget) : 0.0;
    final isOverspent = factor > 1.0;
    final displayFactor = isOverspent ? 1.0 : factor;
    final barColor = isOverspent ? overspentColor : defaultColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8)),
            ),
             Text(
              'Gastado: ${format.format(spent)} / Rec: ${format.format(budget)}',
              style: GoogleFonts.manrope(fontSize: 12, color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: displayFactor,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
        if (isOverspent)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '¡Has excedido el presupuesto en esta categoría!',
              style: GoogleFonts.manrope(fontSize: 12, color: overspentColor, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildDailySpendingSection(Map<String, dynamic> data) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$ ', decimalDigits: 0);
    final totalExpenses = _safeConvertToDouble(data['totalExpenses']);
    
    final dailySpendingData = data['dailySpending'] is Map<String, dynamic>
                            ? data['dailySpending'] as Map<String, dynamic>
                            : <String, dynamic>{};

    final List<FlSpot> spots = [];
    final daysInMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
    double maxAmount = 0;

    for (int i = 1; i <= daysInMonth; i++) {
        final dateKey = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${i.toString().padLeft(2, '0')}";
        final amount = _safeConvertToDouble(dailySpendingData[dateKey]);
        if (amount > maxAmount) maxAmount = amount;
        spots.add(FlSpot(i.toDouble(), amount));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gastos Diarios',
            style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(totalExpenses),
            style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Este Mes',
            style: GoogleFonts.manrope(fontSize: 16, color: Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade300, Colors.pink.shade300],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.withOpacity(0.3),
                          Colors.pink.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('1', style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8))),
              Text('5', style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8))),
              Text('10', style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8))),
              Text('15', style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8))),
              Text('20', style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8))),
              Text('25', style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8))),
              Text('30', style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8))),
            ],
          ),
        ],
      ),
    );
  }
}