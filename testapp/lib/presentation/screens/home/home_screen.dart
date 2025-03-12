import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:testapp/presentation/formulas/simple_interest_screen.dart';
import 'package:testapp/presentation/formulas/compound_interest.dart';
import 'package:testapp/presentation/formulas/annuity_screen.dart';
import 'package:testapp/presentation/screens/loan/loan_card_widget.dart';
import 'package:testapp/presentation/screens/home/settings_screen.dart';
import 'package:testapp/presentation/screens/home/loan_details_screen.dart';
import 'package:testapp/presentation/screens/home/loan_request_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Método para mostrar el menú de opciones financieras
  void _showFinancialOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Indicador de arrastre
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Título
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Calculadoras Financieras',
                    style: TextStyle(
                      color: const Color(0xFF293431),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Lista de opciones
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildFinancialOption(
                        icon: Icons.calculate,
                        title: 'Interés Simple',
                        description:
                            'Calcula el interés sobre un capital inicial',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const SimpleInterestScreen(),
                            ),
                          );
                        },
                      ),
                      _buildFinancialOption(
                        icon: Icons.show_chart,
                        title: 'Interés Compuesto',
                        description:
                            'Calcula el interés que se suma al capital',
                        onTap: () {
                          Navigator.pop(context);
                          // Navegar a la calculadora de interés compuesto
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const CompoundInterestScreen(),
                            ),
                          );
                        },
                      ),
                      _buildFinancialOption(
                        icon: Icons.trending_up,
                        title: 'Gradiente',
                        description: 'Calcula series de pagos con incrementos',
                        onTap: () {
                          Navigator.pop(context);
                          // Navegar a la calculadora de gradiente
                        },
                      ),
                      _buildFinancialOption(
                        icon: Icons.account_balance,
                        title: 'Amortización',
                        description: 'Calcula el plan de pagos de un préstamo',
                        onTap: () {
                          Navigator.pop(context);
                          // Navegar a la calculadora de amortización
                        },
                      ),
                      _buildFinancialOption(
                        icon: Icons.assessment,
                        title: 'Tasa de Interés de Retorno – TIR',
                        description: 'Calcula la rentabilidad de una inversión',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildFinancialOption(
                        icon: Icons.real_estate_agent,
                        title: 'Unidad de Valor Real – UVR',
                        description: 'Calcula valores ajustados por inflación',
                        onTap: () {
                          Navigator.pop(context);
                          // Navegar a la calculadora de UVR
                        },
                      ),
                      _buildFinancialOption(
                        icon: Icons.compare_arrows,
                        title: 'Evaluación de Alternativas de Inversión',
                        description: 'Compara diferentes opciones de inversión',
                        onTap: () {
                          Navigator.pop(context);
                          // Navegar a la calculadora de alternativas
                        },
                      ),
                      _buildFinancialOption(
                        icon: Icons.description,
                        title: 'Bonos',
                        description: 'Calcula el valor y rendimiento de bonos',
                        onTap: () {
                          Navigator.pop(context);
                          // Navegar a la calculadora de bonos
                        },
                      ),
                      _buildFinancialOption(
                        icon: Icons.money_off,
                        title: 'Inflación',
                        description:
                            'Calcula el impacto de la inflación en el dinero',
                        onTap: () {
                          Navigator.pop(context);
                          // Navegar a la calculadora de inflación
                        },
                      ),
                      _buildFinancialOption(
                        icon: Icons.attach_money,
                        title: 'Tasa de interes',
                        description:
                            'Calcula el dinero adicional que se debe pagar por solicitar un préstamo',
                        onTap: () {
                          Navigator.pop(context);
                          /*Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AnnuityScreen(),
                            ),
                          );*/
                          // Navegar a la calculadora de anualidades
                        },
                      ),
                      _buildFinancialOption(
                        icon: Icons.calendar_today,
                        title: 'Anualidades',
                        description: 'Calcula pagos periódicos iguales',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AnnuityScreen(),
                            ),
                          );
                          // Navegar a la calculadora de anualidades
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Widget para cada opción financiera
  Widget _buildFinancialOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF05CEA8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF05CEA8)),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: const Color(0xFF293431),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: const Color(0xFF45AA96),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF45AA96),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenido',
                            style: TextStyle(
                              color: const Color(0xFF151616),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Usuario',
                            style: TextStyle(
                              color: const Color(0xFF151616),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    color: const Color(0xFF293431),
                    onPressed: () {
                      // Navegar a la pantalla de configuraciones
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Balance Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF293431),
                              const Color(0xFF45AA96),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Balance Total',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  '\$',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  '345,670',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  '.89',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  color: Colors.white,
                                  onPressed: () {
                                    // Actualizar balance
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 100,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(show: false),
                                  titlesData: FlTitlesData(show: false),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: [
                                        FlSpot(0, 3),
                                        FlSpot(2.6, 2),
                                        FlSpot(4.9, 5),
                                        FlSpot(6.8, 3.1),
                                        FlSpot(8, 4),
                                        FlSpot(9.5, 3),
                                        FlSpot(11, 4),
                                      ],
                                      isCurved: true,
                                      color: const Color(0xFF05CEA8),
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: const Color(
                                          0xFF05CEA8,
                                        ).withOpacity(0.2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Loan Request Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Solicitudes de Préstamos',
                              style: TextStyle(
                                color: const Color(0xFF151616),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Revisa si eres apto para solicitar tu prestamo!!!',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Navegar a la pantalla de configuraciones
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const LoanRequestScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF05CEA8),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      '¡Vamos!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      // Navegar a la pantalla de configuraciones
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const LoanDetailsScreen(
                                                    loanId: '',
                                                  ),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      side: BorderSide(
                                        color: const Color(0xFF45AA96),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Detalles',
                                      style: TextStyle(
                                        color: const Color(0xFF45AA96),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Transactions Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transacciones',
                              style: TextStyle(
                                color: const Color(0xFF151616),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildTransactionButton(
                                  icon: Icons.send,
                                  label: 'Consignar',
                                  color: const Color(0xFF05CEA8),
                                ),
                                _buildTransactionButton(
                                  icon: Icons.credit_card,
                                  label: 'Pagar',
                                  color: const Color(0xFF45AA96),
                                ),
                                _buildTransactionButton(
                                  icon: Icons.attach_money,
                                  label: 'Retirar',
                                  color: const Color(0xFF293431),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });

            // Mostrar el menú de opciones financieras cuando se presiona "Nuevo"
            if (index == 1) {
              _showFinancialOptionsMenu(context);
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF05CEA8),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Nuevo',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Historial'),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon),
            color: color,
            iconSize: 30,
            onPressed: () {
              // Manejar la acción del botón
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF151616),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
