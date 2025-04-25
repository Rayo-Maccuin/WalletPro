import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class GeometricGradientScreen extends StatefulWidget {
  const GeometricGradientScreen({super.key});

  @override
  State<GeometricGradientScreen> createState() =>
      _GeometricGradientScreenState();
}

class _GeometricGradientScreenState extends State<GeometricGradientScreen> {
  final _initialPaymentController = TextEditingController();
  final _growthRateController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _presentValueController = TextEditingController();
  final _futureValueController = TextEditingController();

  final _yearsController = TextEditingController();
  final _monthsController = TextEditingController();
  final _daysController = TextEditingController();

  double _calculatedValue = 0.0;
  bool _hasCalculated = false;

  final ScrollController _scrollController = ScrollController();

  bool _advancedTimeMode = false;

  String _variableToCalculate = 'presentValue';

  final List<Map<String, dynamic>> _timeUnits = [
    {'label': 'Años', 'value': 'years', 'factor': 1.0},
    {'label': 'Semestres', 'value': 'semesters', 'factor': 0.5},
    {'label': 'Trimestres', 'value': 'quarters', 'factor': 0.25},
    {'label': 'Meses', 'value': 'months', 'factor': 1 / 12},
    {'label': 'Días', 'value': 'days', 'factor': 1 / 360},
  ];

  Map<String, dynamic> _selectedTimeUnit = {
    'label': 'Años',
    'value': 'years',
    'factor': 1.0,
  };

  final _simpleTimeController = TextEditingController();

  @override
  void dispose() {
    _initialPaymentController.dispose();
    _growthRateController.dispose();
    _interestRateController.dispose();
    _presentValueController.dispose();
    _futureValueController.dispose();
    _simpleTimeController.dispose();
    _yearsController.dispose();
    _monthsController.dispose();
    _daysController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  double _calculateTimeInYears() {
    if (_advancedTimeMode) {
      double years =
          _yearsController.text.isEmpty
              ? 0
              : double.parse(_yearsController.text.replaceAll(',', '.'));
      double months =
          _monthsController.text.isEmpty
              ? 0
              : double.parse(_monthsController.text.replaceAll(',', '.'));
      double days =
          _daysController.text.isEmpty
              ? 0
              : double.parse(_daysController.text.replaceAll(',', '.'));

      return years + (months / 12) + (days / 365);
    } else {
      if (_simpleTimeController.text.isEmpty) return 0;
      double timeValue = double.parse(
        _simpleTimeController.text.replaceAll(',', '.'),
      );
      return timeValue * _selectedTimeUnit['factor'];
    }
  }

  void _calculate() {
    FocusScope.of(context).unfocus();

    try {
      switch (_variableToCalculate) {
        case 'presentValue':
          _calculatePresentValue();
          break;
        case 'futureValue':
          _calculateFutureValue();
          break;
        case 'initialPayment':
          _calculateInitialPayment();
          break;
        case 'growthRate':
          _calculateGrowthRate();
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en el cálculo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _calculatePresentValue() {
    if (_initialPaymentController.text.isEmpty ||
        _growthRateController.text.isEmpty ||
        _interestRateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa los campos de pago inicial, tasa de crecimiento y tasa de interés',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_advancedTimeMode) {
      if (_yearsController.text.isEmpty &&
          _monthsController.text.isEmpty &&
          _daysController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor ingresa al menos un valor de tiempo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      if (_simpleTimeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor ingresa el valor de tiempo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final initialPayment = double.parse(
      _initialPaymentController.text.replaceAll(',', '.'),
    );
    final growthRate =
        double.parse(_growthRateController.text.replaceAll(',', '.')) / 100;
    final interestRate =
        double.parse(_interestRateController.text.replaceAll(',', '.')) / 100;
    final timeInYears = _calculateTimeInYears();
    final n = timeInYears;

    // Fórmula para el valor presente de una gradiente geométrica
    // Si i ≠ j: P = A * [1 - (1+j)^n * (1+i)^-n] / (i-j)
    // Si i = j: P = A * n / (1+i)

    double presentValue;
    if ((interestRate - growthRate).abs() < 0.0000001) {
      // Caso especial cuando i = j
      presentValue = initialPayment * n / (1 + interestRate);
    } else {
      // Caso general cuando i ≠ j
      presentValue =
          initialPayment *
          (1 - pow(1 + growthRate, n) * pow(1 + interestRate, -n)) /
          (interestRate - growthRate);
    }

    setState(() {
      _calculatedValue = presentValue;
      _hasCalculated = true;
    });

    _scrollToResults();
  }

  void _calculateFutureValue() {
    if (_initialPaymentController.text.isEmpty ||
        _growthRateController.text.isEmpty ||
        _interestRateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa los campos de pago inicial, tasa de crecimiento y tasa de interés',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_advancedTimeMode) {
      if (_yearsController.text.isEmpty &&
          _monthsController.text.isEmpty &&
          _daysController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor ingresa al menos un valor de tiempo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      if (_simpleTimeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor ingresa el valor de tiempo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final initialPayment = double.parse(
      _initialPaymentController.text.replaceAll(',', '.'),
    );
    final growthRate =
        double.parse(_growthRateController.text.replaceAll(',', '.')) / 100;
    final interestRate =
        double.parse(_interestRateController.text.replaceAll(',', '.')) / 100;
    final timeInYears = _calculateTimeInYears();
    final n = timeInYears;

    // Fórmula para el valor futuro de una gradiente geométrica
    // Si i ≠ j: F = A * [(1+i)^n - (1+j)^n] / (i-j)
    // Si i = j: F = A * n * (1+i)^(n-1)

    double futureValue;
    if ((interestRate - growthRate).abs() < 0.0000001) {
      // Caso especial cuando i = j
      futureValue = initialPayment * n * pow(1 + interestRate, n - 1);
    } else {
      // Caso general cuando i ≠ j
      futureValue =
          initialPayment *
          (pow(1 + interestRate, n) - pow(1 + growthRate, n)) /
          (interestRate - growthRate);
    }

    setState(() {
      _calculatedValue = futureValue;
      _hasCalculated = true;
    });

    _scrollToResults();
  }

  void _calculateInitialPayment() {
    if (_presentValueController.text.isEmpty ||
        _growthRateController.text.isEmpty ||
        _interestRateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa los campos de valor presente, tasa de crecimiento y tasa de interés',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_advancedTimeMode) {
      if (_yearsController.text.isEmpty &&
          _monthsController.text.isEmpty &&
          _daysController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor ingresa al menos un valor de tiempo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      if (_simpleTimeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor ingresa el valor de tiempo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final presentValue = double.parse(
      _presentValueController.text.replaceAll(',', '.'),
    );
    final growthRate =
        double.parse(_growthRateController.text.replaceAll(',', '.')) / 100;
    final interestRate =
        double.parse(_interestRateController.text.replaceAll(',', '.')) / 100;
    final timeInYears = _calculateTimeInYears();
    final n = timeInYears;

    // Despejando A de la fórmula del valor presente
    double initialPayment;
    if ((interestRate - growthRate).abs() < 0.0000001) {
      // Caso especial cuando i = j
      initialPayment = presentValue * (1 + interestRate) / n;
    } else {
      // Caso general cuando i ≠ j
      initialPayment =
          presentValue *
          (interestRate - growthRate) /
          (1 - pow(1 + growthRate, n) * pow(1 + interestRate, -n));
    }

    setState(() {
      _calculatedValue = initialPayment;
      _hasCalculated = true;
    });

    _scrollToResults();
  }

  void _calculateGrowthRate() {
    if (_initialPaymentController.text.isEmpty ||
        _presentValueController.text.isEmpty ||
        _interestRateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa los campos de pago inicial, valor presente y tasa de interés',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_advancedTimeMode) {
      if (_yearsController.text.isEmpty &&
          _monthsController.text.isEmpty &&
          _daysController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor ingresa al menos un valor de tiempo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      if (_simpleTimeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor ingresa el valor de tiempo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Este cálculo es más complejo y requiere métodos numéricos para resolverlo
    // Implementamos una aproximación simple usando el método de bisección

    final initialPayment = double.parse(
      _initialPaymentController.text.replaceAll(',', '.'),
    );
    final presentValue = double.parse(
      _presentValueController.text.replaceAll(',', '.'),
    );
    final interestRate =
        double.parse(_interestRateController.text.replaceAll(',', '.')) / 100;
    final timeInYears = _calculateTimeInYears();
    final n = timeInYears;

    // Función para calcular el error dado un valor de j (tasa de crecimiento)
    double calculateError(double j) {
      if ((interestRate - j).abs() < 0.0000001) {
        // Caso especial cuando i = j
        return initialPayment * n / (1 + interestRate) - presentValue;
      } else {
        // Caso general cuando i ≠ j
        return initialPayment *
                (1 - pow(1 + j, n) * pow(1 + interestRate, -n)) /
                (interestRate - j) -
            presentValue;
      }
    }

    // Método de bisección para encontrar j
    double lowerBound = -0.5; // Límite inferior para j
    double upperBound = 0.5; // Límite superior para j
    double tolerance = 0.0001; // Tolerancia para la convergencia
    double j = 0;

    if (calculateError(lowerBound) * calculateError(upperBound) > 0) {
      // Si los signos son iguales, no hay solución en este intervalo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo encontrar una solución. Intenta con otros valores.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int maxIterations = 100;
    int iteration = 0;

    while ((upperBound - lowerBound) > tolerance && iteration < maxIterations) {
      j = (lowerBound + upperBound) / 2;
      double error = calculateError(j);

      if (error.abs() < tolerance) {
        break;
      }

      if (error * calculateError(lowerBound) < 0) {
        upperBound = j;
      } else {
        lowerBound = j;
      }

      iteration++;
    }

    setState(() {
      _calculatedValue = j * 100; // Convertir de decimal a porcentaje
      _hasCalculated = true;
    });

    _scrollToResults();
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
      _initialPaymentController.clear();
      _growthRateController.clear();
      _interestRateController.clear();
      _presentValueController.clear();
      _futureValueController.clear();
      _simpleTimeController.clear();
      _yearsController.clear();
      _monthsController.clear();
      _daysController.clear();
      _calculatedValue = 0.0;
      _hasCalculated = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Todos los campos han sido limpiados'),
        backgroundColor: const Color(0xFF293431),
      ),
    );
  }

  String _getTimeDescription() {
    if (_advancedTimeMode) {
      List<String> parts = [];

      if (_yearsController.text.isNotEmpty &&
          double.parse(_yearsController.text.replaceAll(',', '.')) > 0) {
        double years = double.parse(_yearsController.text.replaceAll(',', '.'));
        parts.add(
          '${years.toStringAsFixed(years.truncateToDouble() == years ? 0 : 2)} año${years == 1 ? '' : 's'}',
        );
      }

      if (_monthsController.text.isNotEmpty &&
          double.parse(_monthsController.text.replaceAll(',', '.')) > 0) {
        double months = double.parse(
          _monthsController.text.replaceAll(',', '.'),
        );
        parts.add(
          '${months.toStringAsFixed(months.truncateToDouble() == months ? 0 : 2)} mes${months == 1 ? '' : 'es'}',
        );
      }

      if (_daysController.text.isNotEmpty &&
          double.parse(_daysController.text.replaceAll(',', '.')) > 0) {
        double days = double.parse(_daysController.text.replaceAll(',', '.'));
        parts.add(
          '${days.toStringAsFixed(days.truncateToDouble() == days ? 0 : 2)} día${days == 1 ? '' : 's'}',
        );
      }

      return parts.join(', ');
    } else {
      return '${_simpleTimeController.text.replaceAll(',', '.')} ${_selectedTimeUnit['label'].toLowerCase()}';
    }
  }

  String _getResultTitle() {
    switch (_variableToCalculate) {
      case 'presentValue':
        return 'Valor presente:';
      case 'futureValue':
        return 'Valor futuro:';
      case 'initialPayment':
        return 'Pago inicial:';
      case 'growthRate':
        return 'Tasa de crecimiento:';
      default:
        return '';
    }
  }

  String _getFormattedResult() {
    switch (_variableToCalculate) {
      case 'presentValue':
      case 'futureValue':
      case 'initialPayment':
        return '\$${_formatNumber(_calculatedValue)}';
      case 'growthRate':
        return '${_formatNumber(_calculatedValue)}%';
      default:
        return '';
    }
  }

  IconData _getResultIcon() {
    switch (_variableToCalculate) {
      case 'presentValue':
        return Icons.account_balance_wallet;
      case 'futureValue':
        return Icons.trending_up;
      case 'initialPayment':
        return Icons.attach_money;
      case 'growthRate':
        return Icons.show_chart;
      default:
        return Icons.calculate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Gradiente Geométrica',
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
                    '¿Qué es la Gradiente Geométrica?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'La gradiente geométrica es una serie de flujos de efectivo que aumentan o disminuyen en una tasa constante en cada período. Es útil para modelar pagos que crecen o decrecen a un ritmo porcentual fijo, como salarios con incrementos anuales, inflación, o inversiones con rendimientos compuestos.',
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
                    'Fórmulas',
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
                          'Valor Presente (P) cuando i ≠ j:',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'P = A[1-(1+j)^n*(1+i)^-n]/(i-j)',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Valor Presente (P) cuando i = j:',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'P = A*n/(1+i)',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Valor Futuro (F) cuando i ≠ j:',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'F = A[(1+i)^n-(1+j)^n]/(i-j)',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Valor Futuro (F) cuando i = j:',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'F = A*n*(1+i)^(n-1)',
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
                            _buildFormulaItem('A', 'Pago inicial'),
                            _buildFormulaItem('j', 'Tasa de crecimiento'),
                            _buildFormulaItem('i', 'Tasa de interés'),
                            _buildFormulaItem('n', 'Períodos'),
                          ],
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Qué deseas calcular?',
                        style: TextStyle(
                          color: const Color(0xFF293431),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF05CEA8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              title: Text('Valor Presente (P)'),
                              value: 'presentValue',
                              groupValue: _variableToCalculate,
                              onChanged: (value) {
                                setState(() {
                                  _variableToCalculate = value!;
                                });
                              },
                              activeColor: const Color(0xFF05CEA8),
                              dense: true,
                            ),
                            RadioListTile<String>(
                              title: Text('Valor Futuro (F)'),
                              value: 'futureValue',
                              groupValue: _variableToCalculate,
                              onChanged: (value) {
                                setState(() {
                                  _variableToCalculate = value!;
                                });
                              },
                              activeColor: const Color(0xFF05CEA8),
                              dense: true,
                            ),
                            RadioListTile<String>(
                              title: Text('Pago Inicial (A)'),
                              value: 'initialPayment',
                              groupValue: _variableToCalculate,
                              onChanged: (value) {
                                setState(() {
                                  _variableToCalculate = value!;
                                });
                              },
                              activeColor: const Color(0xFF05CEA8),
                              dense: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (_variableToCalculate != 'initialPayment') ...[
                    _buildInputField(
                      controller: _initialPaymentController,
                      label: 'Pago inicial (A)',
                      hint: 'Ej: 1000000',
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  if (_variableToCalculate != 'growthRate') ...[
                    _buildInputField(
                      controller: _growthRateController,
                      label: 'Tasa de crecimiento (j) %',
                      hint: 'Ej: 5',
                      prefixIcon: Icons.show_chart,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  if (_variableToCalculate != 'interestRate') ...[
                    _buildInputField(
                      controller: _interestRateController,
                      label: 'Tasa de interés anual (i) %',
                      hint: 'Ej: 5',
                      prefixIcon: Icons.percent,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  if (_variableToCalculate != 'presentValue') ...[
                    _buildInputField(
                      controller: _presentValueController,
                      label: 'Valor presente (P)',
                      hint: 'Ej: 5000000',
                      prefixIcon: Icons.account_balance_wallet,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  if (_variableToCalculate != 'futureValue') ...[
                    _buildInputField(
                      controller: _futureValueController,
                      label: 'Valor futuro (F)',
                      hint: 'Ej: 7000000',
                      prefixIcon: Icons.trending_up,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  if (_variableToCalculate != 'time') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tiempo (n)',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Modo avanzado',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            Switch(
                              value: _advancedTimeMode,
                              onChanged: (value) {
                                setState(() {
                                  _advancedTimeMode = value;
                                });
                              },
                              activeColor: const Color(0xFF05CEA8),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (!_advancedTimeMode) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _simpleTimeController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Ej: 2',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: Icon(
                                  Icons.access_time,
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
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 15,
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
                          const SizedBox(width: 10),

                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 56, // Misma altura que el TextField
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey[300]!),
                                color: Colors.grey[50],
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedTimeUnit['value'],
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: const Color(0xFF45AA96),
                                  ),
                                  isExpanded: true,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  items:
                                      _timeUnits.map((unit) {
                                        return DropdownMenuItem<String>(
                                          value: unit['value'],
                                          child: Text(
                                            unit['label'],
                                            style: TextStyle(
                                              color: const Color(0xFF151616),
                                              fontSize: 16,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedTimeUnit = _timeUnits.firstWhere(
                                        (unit) => unit['value'] == newValue,
                                      );
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (_advancedTimeMode) ...[
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
                            // Años
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Años:',
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
                                    controller: _yearsController,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      hintText: 'Ej: 2',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
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
                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Meses:',
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
                                    controller: _monthsController,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      hintText: 'Ej: 6',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
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
                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Días:',
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
                                    controller: _daysController,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      hintText: 'Ej: 15',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
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
                                    'Puedes combinar años, meses y días para un cálculo más preciso.',
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
                        'Calcular',
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
                      label: _getResultTitle(),
                      value: _getFormattedResult(),
                      icon: _getResultIcon(),
                      color: const Color(0xFF05CEA8),
                    ),
                    const SizedBox(height: 15),

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detalles del cálculo:',
                            style: TextStyle(
                              color: const Color(0xFF293431),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (_variableToCalculate != 'initialPayment' &&
                              _initialPaymentController.text.isNotEmpty) ...[
                            Text(
                              'Pago inicial: \$${_formatNumber(double.parse(_initialPaymentController.text.replaceAll(',', '.')))}',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                          ],

                          if (_variableToCalculate != 'growthRate' &&
                              _growthRateController.text.isNotEmpty) ...[
                            Text(
                              'Tasa de crecimiento: ${_growthRateController.text.replaceAll(',', '.')}%',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                          ],

                          if (_variableToCalculate != 'interestRate' &&
                              _interestRateController.text.isNotEmpty) ...[
                            Text(
                              'Tasa de interés anual: ${_interestRateController.text.replaceAll(',', '.')}%',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                          ],

                          if (_variableToCalculate != 'presentValue' &&
                              _presentValueController.text.isNotEmpty) ...[
                            Text(
                              'Valor presente: \$${_formatNumber(double.parse(_presentValueController.text.replaceAll(',', '.')))}',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                          ],

                          if (_variableToCalculate != 'futureValue' &&
                              _futureValueController.text.isNotEmpty) ...[
                            Text(
                              'Valor futuro: \$${_formatNumber(double.parse(_futureValueController.text.replaceAll(',', '.')))}',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                          ],

                          if (_variableToCalculate != 'time') ...[
                            Text(
                              'Tiempo: ${_getTimeDescription()}',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Tiempo en años (para el cálculo): ${_calculateTimeInYears().toStringAsFixed(4)}',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey[700]),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'La gradiente geométrica es útil para modelar flujos de efectivo que aumentan o disminuyen a una tasa porcentual constante, como en casos de inflación o crecimiento económico.',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
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
