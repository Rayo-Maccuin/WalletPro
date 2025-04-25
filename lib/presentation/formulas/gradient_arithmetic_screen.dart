import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class ArithmeticGradientScreen extends StatefulWidget {
  const ArithmeticGradientScreen({super.key});

  @override
  State<ArithmeticGradientScreen> createState() =>
      _ArithmeticGradientScreenState();
}

class _ArithmeticGradientScreenState extends State<ArithmeticGradientScreen> {
  final _initialPaymentController = TextEditingController();
  final _gradientController = TextEditingController();
  final _rateController = TextEditingController();
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
    _gradientController.dispose();
    _rateController.dispose();
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
        case 'gradient':
          _calculateGradient();
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
        _gradientController.text.isEmpty ||
        _rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa los campos de pago inicial, gradiente y tasa de interés',
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
    final gradient = double.parse(
      _gradientController.text.replaceAll(',', '.'),
    );
    final rate = double.parse(_rateController.text.replaceAll(',', '.')) / 100;
    final timeInYears = _calculateTimeInYears();
    final n = timeInYears;

    // Fórmula para el valor presente de una gradiente aritmética
    // P = A * [(1 - (1 + i)^-n) / i] + G * [(1 - (1 + i)^-n) / i - n / (1 + i)^n] / i

    final part1 = initialPayment * ((1 - pow(1 + rate, -n)) / rate);
    final part2 =
        gradient *
        ((1 - pow(1 + rate, -n)) / rate - n / pow(1 + rate, n)) /
        rate;
    final presentValue = part1 + part2;

    setState(() {
      _calculatedValue = presentValue;
      _hasCalculated = true;
    });

    _scrollToResults();
  }

  void _calculateFutureValue() {
    if (_initialPaymentController.text.isEmpty ||
        _gradientController.text.isEmpty ||
        _rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa los campos de pago inicial, gradiente y tasa de interés',
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
    final gradient = double.parse(
      _gradientController.text.replaceAll(',', '.'),
    );
    final rate = double.parse(_rateController.text.replaceAll(',', '.')) / 100;
    final timeInYears = _calculateTimeInYears();
    final n = timeInYears;

    // Fórmula para el valor futuro de una gradiente aritmética
    // F = A * [(1 + i)^n - 1) / i] + G * [((1 + i)^n - 1) / i - n] / i

    final part1 = initialPayment * ((pow(1 + rate, n) - 1) / rate);
    final part2 = gradient * ((pow(1 + rate, n) - 1) / rate - n) / rate;
    final futureValue = part1 + part2;

    setState(() {
      _calculatedValue = futureValue;
      _hasCalculated = true;
    });

    _scrollToResults();
  }

  void _calculateInitialPayment() {
    if (_presentValueController.text.isEmpty ||
        _gradientController.text.isEmpty ||
        _rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa los campos de valor presente, gradiente y tasa de interés',
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
    final gradient = double.parse(
      _gradientController.text.replaceAll(',', '.'),
    );
    final rate = double.parse(_rateController.text.replaceAll(',', '.')) / 100;
    final timeInYears = _calculateTimeInYears();
    final n = timeInYears;

    // Despejando A de la fórmula del valor presente
    // P = A * [(1 - (1 + i)^-n) / i] + G * [(1 - (1 + i)^-n) / i - n / (1 + i)^n] / i

    final factor1 = (1 - pow(1 + rate, -n)) / rate;
    final factor2 =
        ((1 - pow(1 + rate, -n)) / rate - n / pow(1 + rate, n)) / rate;

    final initialPayment = (presentValue - gradient * factor2) / factor1;

    setState(() {
      _calculatedValue = initialPayment;
      _hasCalculated = true;
    });

    _scrollToResults();
  }

  void _calculateGradient() {
    if (_initialPaymentController.text.isEmpty ||
        _presentValueController.text.isEmpty ||
        _rateController.text.isEmpty) {
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

    final initialPayment = double.parse(
      _initialPaymentController.text.replaceAll(',', '.'),
    );
    final presentValue = double.parse(
      _presentValueController.text.replaceAll(',', '.'),
    );
    final rate = double.parse(_rateController.text.replaceAll(',', '.')) / 100;
    final timeInYears = _calculateTimeInYears();
    final n = timeInYears;

    // Despejando G de la fórmula del valor presente
    // P = A * [(1 - (1 + i)^-n) / i] + G * [(1 - (1 + i)^-n) / i - n / (1 + i)^n] / i

    final factor1 = (1 - pow(1 + rate, -n)) / rate;
    final factor2 =
        ((1 - pow(1 + rate, -n)) / rate - n / pow(1 + rate, n)) / rate;

    final gradient = (presentValue - initialPayment * factor1) / factor2;

    setState(() {
      _calculatedValue = gradient;
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
      _gradientController.clear();
      _rateController.clear();
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
      case 'gradient':
        return 'Gradiente:';
      case 'rate':
        return 'Tasa de interés anual:';
      case 'time':
        return 'Tiempo en años:';
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
      case 'gradient':
        return '\$${_formatNumber(_calculatedValue)}';
      case 'rate':
        return '${_formatNumber(_calculatedValue)}%';
      case 'time':
        return '${_formatNumber(_calculatedValue)} años';
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
      case 'gradient':
        return Icons.trending_up;
      case 'rate':
        return Icons.percent;
      case 'time':
        return Icons.access_time;
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
          'Gradiente Aritmética',
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
                    '¿Qué es la Gradiente Aritmética?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'La gradiente aritmética es una serie de flujos de efectivo que aumentan o disminuyen en una cantidad constante en cada período. Es útil para modelar pagos que crecen o decrecen a un ritmo constante, como alquileres con incrementos fijos anuales o pagos de préstamos con amortización variable.',
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
                          'Valor Presente (P):',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'P = A[(1-(1+i)^-n)/i] + G[(1-(1+i)^-n)/i - n/(1+i)^n]/i',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Valor Futuro (F):',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'F = A[(1+i)^n-1)/i] + G[((1+i)^n-1)/i - n]/i',
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
                            _buildFormulaItem('G', 'Gradiente'),
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
                            RadioListTile<String>(
                              title: Text('Gradiente (G)'),
                              value: 'gradient',
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

                  if (_variableToCalculate != 'gradient') ...[
                    _buildInputField(
                      controller: _gradientController,
                      label: 'Gradiente (G)',
                      hint: 'Ej: 50000',
                      prefixIcon: Icons.trending_up,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  if (_variableToCalculate != 'rate') ...[
                    _buildInputField(
                      controller: _rateController,
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

                          if (_variableToCalculate != 'gradient' &&
                              _gradientController.text.isNotEmpty) ...[
                            Text(
                              'Gradiente: \$${_formatNumber(double.parse(_gradientController.text.replaceAll(',', '.')))}',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                          ],

                          if (_variableToCalculate != 'rate' &&
                              _rateController.text.isNotEmpty) ...[
                            Text(
                              'Tasa de interés anual: ${_rateController.text.replaceAll(',', '.')}%',
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
                              'La gradiente aritmética es útil para modelar flujos de efectivo que aumentan o disminuyen en una cantidad constante en cada período.',
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
