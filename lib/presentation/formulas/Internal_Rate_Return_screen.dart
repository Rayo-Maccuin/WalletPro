import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class IRRCalculator extends StatefulWidget {
  const IRRCalculator({super.key});

  @override
  State<IRRCalculator> createState() => _IRRCalculatorState();
}

class _IRRCalculatorState extends State<IRRCalculator> {
  final _initialInvestmentController = TextEditingController();
  final _projectDurationController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // List to store cash flow controllers
  List<TextEditingController> _cashFlowControllers = [];

  double _calculatedIRR = 0.0;
  bool _hasCalculated = false;
  List<Map<String, dynamic>> _cashFlowTable = [];

  @override
  void initState() {
    super.initState();
    _projectDurationController.addListener(_updateCashFlowFields);
  }

  @override
  void dispose() {
    _initialInvestmentController.dispose();
    _projectDurationController.dispose();
    for (var controller in _cashFlowControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _updateCashFlowFields() {
    if (_projectDurationController.text.isEmpty) {
      setState(() {
        _cashFlowControllers = [];
      });
      return;
    }

    try {
      int duration = int.parse(_projectDurationController.text);
      if (duration <= 0 || duration > 50) {
        // Limit to reasonable number of periods
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('La duración debe estar entre 1 y 50 períodos'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        // Keep existing controllers if possible
        if (_cashFlowControllers.length < duration) {
          // Add new controllers
          int additionalControllers = duration - _cashFlowControllers.length;
          for (int i = 0; i < additionalControllers; i++) {
            _cashFlowControllers.add(TextEditingController());
          }
        } else if (_cashFlowControllers.length > duration) {
          // Remove excess controllers
          for (int i = _cashFlowControllers.length - 1; i >= duration; i--) {
            _cashFlowControllers[i].dispose();
          }
          _cashFlowControllers = _cashFlowControllers.sublist(0, duration);
        }
      });
    } catch (e) {
      // Handle parsing error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor ingresa un número válido de períodos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _calculate() {
    FocusScope.of(context).unfocus();

    if (_initialInvestmentController.text.isEmpty ||
        _projectDurationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa la inversión inicial y la duración del proyecto',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if all cash flow fields are filled
    for (int i = 0; i < _cashFlowControllers.length; i++) {
      if (_cashFlowControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor completa todos los flujos de caja'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    try {
      // Parse initial investment (should be negative)
      double initialInvestment =
          -1 *
          double.parse(
            _initialInvestmentController.text.replaceAll(',', '.'),
          ).abs(); // Ensure it's negative

      // Create cash flow array starting with initial investment
      List<double> cashFlows = [initialInvestment];

      // Add all other cash flows
      for (var controller in _cashFlowControllers) {
        cashFlows.add(double.parse(controller.text.replaceAll(',', '.')));
      }

      // Calculate IRR
      double irr = _calculateIRR(cashFlows);

      // Create cash flow table for display
      List<Map<String, dynamic>> table = [];
      for (int i = 0; i < cashFlows.length; i++) {
        table.add({
          'period': i,
          'cashFlow': cashFlows[i],
          'presentValue': _calculatePresentValue(cashFlows[i], irr, i),
        });
      }

      setState(() {
        _calculatedIRR = irr * 100; // Convert to percentage
        _cashFlowTable = table;
        _hasCalculated = true;
      });

      _scrollToResults();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en el cálculo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Calculate IRR using Newton-Raphson method
  double _calculateIRR(List<double> cashFlows) {
    // Initial guess
    double guess = 0.1; // 10%
    double previousGuess;
    int maxIterations = 100;
    double tolerance = 0.0000001;

    // Newton-Raphson iteration
    for (int i = 0; i < maxIterations; i++) {
      double npv = _calculateNPV(cashFlows, guess);
      double derivative = _calculateNPVDerivative(cashFlows, guess);

      // Check if derivative is too close to zero to avoid division by zero
      if (derivative.abs() < tolerance) {
        break;
      }

      previousGuess = guess;
      guess = guess - npv / derivative;

      // Check for convergence
      if ((guess - previousGuess).abs() < tolerance) {
        break;
      }

      // Check for non-convergence or invalid result
      if (guess.isNaN || guess.isInfinite || guess < -1.0) {
        // If we can't find a valid IRR, try a different starting point
        guess = 0.05;
        continue;
      }
    }

    return guess;
  }

  // Calculate Net Present Value for a given discount rate
  double _calculateNPV(List<double> cashFlows, double rate) {
    double npv = 0;
    for (int i = 0; i < cashFlows.length; i++) {
      npv += cashFlows[i] / pow(1 + rate, i);
    }
    return npv;
  }

  // Calculate derivative of NPV function for Newton-Raphson method
  double _calculateNPVDerivative(List<double> cashFlows, double rate) {
    double derivative = 0;
    for (int i = 1; i < cashFlows.length; i++) {
      derivative -= i * cashFlows[i] / pow(1 + rate, i + 1);
    }
    return derivative;
  }

  // Calculate present value of a single cash flow
  double _calculatePresentValue(double cashFlow, double rate, int period) {
    return cashFlow / pow(1 + rate, period);
  }

  void _scrollToResults() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _clearFields() {
    setState(() {
      _initialInvestmentController.clear();
      _projectDurationController.clear();
      for (var controller in _cashFlowControllers) {
        controller.dispose();
      }
      _cashFlowControllers = [];
      _calculatedIRR = 0.0;
      _hasCalculated = false;
      _cashFlowTable = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Todos los campos han sido limpiados'),
        backgroundColor: const Color(0xFF293431),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Tasa Interna de Retorno (TIR)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF293431),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calculate_rounded,
                    color: const Color(0xFF05CEA8),
                    size: 32,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'WalletPro',
                    style: TextStyle(
                      color: const Color(0xFF293431),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF293431), const Color(0xFF45AA96)],
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
                  Text(
                    '¿Qué es la Tasa Interna de Retorno?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'La Tasa Interna de Retorno (TIR) es la tasa de interés o rentabilidad que ofrece una inversión. Es decir, es el porcentaje de beneficio o pérdida que tendrá una inversión para las cantidades que no se han retirado del proyecto. Es una medida utilizada en la evaluación de proyectos de inversión que está muy relacionada con el Valor Presente Neto (VPN).',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Criterio de decisión: Si la TIR es mayor que la tasa de descuento, el proyecto es aceptable. Si la TIR es igual a la tasa de descuento, el proyecto es indiferente. Si la TIR es menor que la tasa de descuento, el proyecto debe rechazarse.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
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
                    'Fórmula',
                    style: TextStyle(
                      color: const Color(0xFF151616),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF05CEA8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF05CEA8).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'La TIR es la tasa r que satisface:',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '0 = CF₀ + CF₁/(1+r)¹ + CF₂/(1+r)² + ... + CFₙ/(1+r)ⁿ',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            _buildFormulaItem('CF₀', 'Inversión inicial'),
                            _buildFormulaItem(
                              'CFᵢ',
                              'Flujo de caja del período i',
                            ),
                            _buildFormulaItem('r', 'TIR'),
                            _buildFormulaItem('n', 'Último período'),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'La TIR es la tasa de descuento que hace que el Valor Presente Neto (VPN) de todos los flujos de efectivo de un proyecto sea igual a cero.',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Calculadora',
                        style: TextStyle(
                          color: const Color(0xFF151616),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _clearFields,
                        icon: Icon(
                          Icons.cleaning_services_rounded,
                          color: const Color(0xFF45AA96),
                          size: 18,
                        ),
                        label: Text(
                          'Limpiar',
                          style: TextStyle(
                            color: const Color(0xFF45AA96),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          backgroundColor: const Color(
                            0xFF45AA96,
                          ).withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildInputField(
                    controller: _initialInvestmentController,
                    label: 'Inversión inicial',
                    hint: 'Ej: 1000000',
                    prefixIcon: Icons.money_off,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    helperText: 'Ingresa el valor sin signo negativo',
                  ),
                  const SizedBox(height: 15),

                  _buildInputField(
                    controller: _projectDurationController,
                    label: 'Duración del proyecto (períodos)',
                    hint: 'Ej: 5',
                    prefixIcon: Icons.calendar_today,
                    keyboardType: TextInputType.number,
                    helperText:
                        'Número de períodos después de la inversión inicial',
                  ),
                  const SizedBox(height: 20),

                  if (_cashFlowControllers.isNotEmpty) ...[
                    Text(
                      'Flujos de caja',
                      style: TextStyle(
                        color: const Color(0xFF293431),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF05CEA8).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF05CEA8).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          for (
                            int i = 0;
                            i < _cashFlowControllers.length;
                            i++
                          ) ...[
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Período ${i + 1}:',
                                    style: TextStyle(
                                      color: const Color(0xFF293431),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 7,
                                  child: TextField(
                                    controller: _cashFlowControllers[i],
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      hintText: 'Ej: 250000',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                      ),
                                      prefixIcon: Icon(
                                        Icons.attach_money,
                                        color: const Color(0xFF45AA96),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: const Color(0xFF05CEA8),
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 10,
                                          ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: const Color(0xFF151616),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.,]'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (i < _cashFlowControllers.length - 1)
                              const SizedBox(height: 10),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: const Color(0xFF45AA96),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Ingresa los flujos de caja positivos (ingresos) o negativos (egresos) para cada período.',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF05CEA8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Calcular TIR',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_hasCalculated) ...[
              const SizedBox(height: 25),

              Container(
                width: double.infinity,
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
                      'Resultados',
                      style: TextStyle(
                        color: const Color(0xFF151616),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildResultItem(
                      label: 'Tasa Interna de Retorno (TIR):',
                      value: '${_formatNumber(_calculatedIRR)}%',
                      icon: Icons.trending_up,
                      color: const Color(0xFF05CEA8),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Detalle de flujos de caja:',
                      style: TextStyle(
                        color: const Color(0xFF293431),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            const Color(0xFF05CEA8).withOpacity(0.1),
                          ),
                          columns: [
                            DataColumn(
                              label: Text(
                                'Período',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF293431),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Flujo de Caja',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF293431),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Valor Presente',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF293431),
                                ),
                              ),
                            ),
                          ],
                          rows:
                              _cashFlowTable.map((flow) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        flow['period'] == 0
                                            ? 'Inicial'
                                            : flow['period'].toString(),
                                        style: TextStyle(
                                          color:
                                              flow['period'] == 0
                                                  ? Colors.red
                                                  : const Color(0xFF293431),
                                          fontWeight:
                                              flow['period'] == 0
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '\$${_formatNumber(flow['cashFlow'])}',
                                        style: TextStyle(
                                          color:
                                              flow['cashFlow'] < 0
                                                  ? Colors.red
                                                  : Colors.green[700],
                                          fontWeight:
                                              flow['period'] == 0
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '\$${_formatNumber(flow['presentValue'])}',
                                        style: TextStyle(
                                          color:
                                              flow['presentValue'] < 0
                                                  ? Colors.red
                                                  : Colors.green[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, color: Colors.grey[700]),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Interpretación:',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _calculatedIRR > 0
                                ? 'La TIR de ${_formatNumber(_calculatedIRR)}% representa la tasa de rendimiento interno del proyecto. Si esta tasa es mayor que el costo de capital o tasa mínima de rendimiento requerida, el proyecto podría ser financieramente viable.'
                                : 'La TIR calculada es negativa o cero, lo que indica que el proyecto no genera rendimientos positivos y podría no ser financieramente viable.',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Recuerda que la TIR debe compararse con la tasa de descuento o costo de oportunidad para tomar decisiones de inversión.',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaItem(String symbol, String description) {
    return Expanded(
      child: Column(
        children: [
          Text(
            symbol,
            style: TextStyle(
              color: const Color(0xFF05CEA8),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required TextInputType keyboardType,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF293431),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(prefixIcon, color: const Color(0xFF45AA96)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: const Color(0xFF05CEA8), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            helperText: helperText,
            helperStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          style: TextStyle(fontSize: 16, color: const Color(0xFF151616)),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
        ),
      ],
    );
  }

  Widget _buildResultItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            Text(
              value,
              style: TextStyle(
                color: const Color(0xFF151616),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatNumber(double number) {
    return number
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
