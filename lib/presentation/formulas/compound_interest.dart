import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class CompoundInterestScreen extends StatefulWidget {
  const CompoundInterestScreen({super.key});

  @override
  State<CompoundInterestScreen> createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends State<CompoundInterestScreen> {
  final _capitalController = TextEditingController(); // Capital (C)
  final _tasaController = TextEditingController(); // Tasa de interés (i)
  final _interesController = TextEditingController(); // Interés compuesto (IC)
  final _montoController = TextEditingController(); // Monto compuesto (MC)

  final _yearsController = TextEditingController();
  final _monthsController = TextEditingController();
  final _daysController = TextEditingController();

  double _calculatedValue = 0.0;
  double _totalAmount = 0.0;
  bool _hasCalculated = false;

  final ScrollController _scrollController = ScrollController();

  bool _advancedTimeMode = false;

  String _variableToCalculate = 'interes';

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

  final List<Map<String, dynamic>> _compoundingFrequencies = [
    {'label': 'Anual', 'value': 'annual', 'periods': 1},
    {'label': 'Semestral', 'value': 'semiannual', 'periods': 2},
    {'label': 'Trimestral', 'value': 'quarterly', 'periods': 4},
    {'label': 'Mensual', 'value': 'monthly', 'periods': 12},
    {'label': 'Diaria', 'value': 'daily', 'periods': 365},
  ];

  Map<String, dynamic> _selectedFrequency = {
    'label': 'Anual',
    'value': 'annual',
    'periods': 1,
  };

  final List<Map<String, dynamic>> _interestRateFormats = [
    {'label': 'Anual', 'value': 'annual', 'factor': 1.0},
    {'label': 'Semestral', 'value': 'semiannual', 'factor': 2.0},
    {'label': 'Trimestral', 'value': 'quarterly', 'factor': 4.0},
    {'label': 'Mensual', 'value': 'monthly', 'factor': 12.0},
    {'label': 'Diaria', 'value': 'daily', 'factor': 365.0},
  ];

  Map<String, dynamic> _selectedRateFormat = {
    'label': 'Anual',
    'value': 'annual',
    'factor': 1.0,
  };

  final _simpleTimeController = TextEditingController();

  @override
  void dispose() {
    _capitalController.dispose();
    _tasaController.dispose();
    _interesController.dispose();
    _montoController.dispose();
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

  double _getAnnualRate() {
    if (_tasaController.text.isEmpty) return 0;

    double inputRate =
        double.parse(_tasaController.text.replaceAll(',', '.')) / 100;
    double annualRate;

    if (_selectedRateFormat['value'] == 'annual') {
      annualRate = inputRate;
    } else {
      annualRate = pow(1 + inputRate, _selectedRateFormat['factor']) - 1;
    }

    return annualRate;
  }

  double _getPeriodicRate() {
    double annualRate = _getAnnualRate();
    int periodsPerYear = _selectedFrequency['periods'];

    return pow(1 + annualRate, 1 / periodsPerYear) - 1;
  }

  void _calculate() {
    FocusScope.of(context).unfocus();

    try {
      switch (_variableToCalculate) {
        case 'interes':
          _calculateInteres();
          break;
        case 'capital':
          _calculateCapital();
          break;
        case 'tasa':
          _calculateTasa();
          break;
        case 'tiempo':
          _calculateTiempo();
          break;
        case 'monto':
          _calculateMonto();
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

  void _calculateInteres() {
    if (_capitalController.text.isEmpty || _montoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa los campos de capital y monto compuesto',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final capital = double.parse(_capitalController.text.replaceAll(',', '.'));
    final montoCompuesto = double.parse(
      _montoController.text.replaceAll(',', '.'),
    );

    final interesCompuesto = montoCompuesto - capital;

    setState(() {
      _calculatedValue = interesCompuesto;
      _totalAmount = montoCompuesto;
      _hasCalculated = true;
    });

    _scrollToResults();
  }

  void _calculateCapital() {
    if (_montoController.text.isEmpty || _tasaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa los campos de monto compuesto y tasa',
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

    final montoCompuesto = double.parse(
      _montoController.text.replaceAll(',', '.'),
    );

    final timeInYears = _calculateTimeInYears();

    final periodsPerYear = _selectedFrequency['periods'];
    final totalPeriods = timeInYears * periodsPerYear;

    final tasaPorPeriodo = _getPeriodicRate();

    final capital = montoCompuesto / pow(1 + tasaPorPeriodo, totalPeriods);

    final interesCompuesto = montoCompuesto - capital;

    setState(() {
      _calculatedValue = capital;
      _totalAmount = montoCompuesto;
      _hasCalculated = true;
    });

    _scrollToResults();
  }

  void _calculateTasa() {
    if (_capitalController.text.isEmpty || _montoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa los campos de capital y monto compuesto',
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

    final capital = double.parse(_capitalController.text.replaceAll(',', '.'));
    final montoCompuesto = double.parse(
      _montoController.text.replaceAll(',', '.'),
    );

    final timeInYears = _calculateTimeInYears();

    final periodsPerYear = _selectedFrequency['periods'];
    final totalPeriods = timeInYears * periodsPerYear;

    final tasaPorPeriodo = pow(montoCompuesto / capital, 1 / totalPeriods) - 1;

    double tasaEnFormatoSeleccionado;
    if (_selectedRateFormat['value'] == 'annual') {
      tasaEnFormatoSeleccionado = pow(1 + tasaPorPeriodo, periodsPerYear) - 1;
    } else {
      tasaEnFormatoSeleccionado =
          pow(
            1 + pow(1 + tasaPorPeriodo, periodsPerYear) - 1,
            1 / _selectedRateFormat['factor'],
          ) -
          1;
    }

    final interesCompuesto = montoCompuesto - capital;

    setState(() {
      _calculatedValue = tasaEnFormatoSeleccionado * 100;
      _totalAmount = montoCompuesto;
      _hasCalculated = true;
    });
    _scrollToResults();
  }

  void _calculateTiempo() {
    if (_capitalController.text.isEmpty ||
        _tasaController.text.isEmpty ||
        _montoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa los campos de capital, tasa y monto compuesto',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final capital = double.parse(_capitalController.text.replaceAll(',', '.'));
    final montoCompuesto = double.parse(
      _montoController.text.replaceAll(',', '.'),
    );

    final periodsPerYear = _selectedFrequency['periods'];

    final tasaPorPeriodo = _getPeriodicRate();

    final periodsTime =
        (log(montoCompuesto) - log(capital)) / log(1 + tasaPorPeriodo);

    final timeInYears = periodsTime / periodsPerYear;

    final interesCompuesto = montoCompuesto - capital;

    setState(() {
      _calculatedValue = timeInYears;
      _totalAmount = montoCompuesto;
      _hasCalculated = true;
    });

    _scrollToResults();
  }

  void _calculateMonto() {
    if (_capitalController.text.isEmpty || _tasaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor completa los campos de capital y tasa'),
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

    final capital = double.parse(_capitalController.text.replaceAll(',', '.'));

    final timeInYears = _calculateTimeInYears();

    final periodsPerYear = _selectedFrequency['periods'];
    final totalPeriods = timeInYears * periodsPerYear;

    final tasaPorPeriodo = _getPeriodicRate();

    final montoCompuesto = capital * pow(1 + tasaPorPeriodo, totalPeriods);

    final interesCompuesto = montoCompuesto - capital;

    setState(() {
      _calculatedValue = montoCompuesto;
      _totalAmount = montoCompuesto;
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
      _capitalController.clear();
      _tasaController.clear();
      _interesController.clear();
      _montoController.clear();
      _simpleTimeController.clear();
      _yearsController.clear();
      _monthsController.clear();
      _daysController.clear();
      _calculatedValue = 0.0;
      _totalAmount = 0.0;
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
    if (_variableToCalculate == 'tiempo') {
      double years = _calculatedValue;
      int fullYears = years.floor();
      double remainingMonths = (years - fullYears) * 12;
      int months = remainingMonths.floor();
      double remainingDays = (remainingMonths - months) * 30;
      int days = remainingDays.round();

      List<String> parts = [];
      if (fullYears > 0) {
        parts.add('$fullYears año${fullYears == 1 ? '' : 's'}');
      }
      if (months > 0) {
        parts.add('$months mes${months == 1 ? '' : 'es'}');
      }
      if (days > 0) {
        parts.add('$days día${days == 1 ? '' : 's'}');
      }

      return parts.join(', ');
    } else {
      if (_advancedTimeMode) {
        List<String> parts = [];

        if (_yearsController.text.isNotEmpty &&
            double.parse(_yearsController.text.replaceAll(',', '.')) > 0) {
          double years = double.parse(
            _yearsController.text.replaceAll(',', '.'),
          );
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
  }

  String _getResultTitle() {
    switch (_variableToCalculate) {
      case 'interes':
        return 'Interés compuesto (IC):';
      case 'capital':
        return 'Capital (C):';
      case 'tasa':
        return 'Tasa de interés ${_selectedRateFormat['label'].toLowerCase()} (i):';
      case 'tiempo':
        return 'Tiempo (n):';
      case 'monto':
        return 'Monto compuesto (MC):';
      default:
        return '';
    }
  }

  String _getFormattedResult() {
    switch (_variableToCalculate) {
      case 'interes':
      case 'capital':
      case 'monto':
        return '\$${_formatNumber(_calculatedValue)}';
      case 'tasa':
        return '${_formatNumber(_calculatedValue)}%';
      case 'tiempo':
        return '${_formatNumber(_calculatedValue)} años';
      default:
        return '';
    }
  }

  IconData _getResultIcon() {
    switch (_variableToCalculate) {
      case 'interes':
        return Icons.trending_up;
      case 'capital':
        return Icons.attach_money;
      case 'tasa':
        return Icons.percent;
      case 'tiempo':
        return Icons.access_time;
      case 'monto':
        return Icons.account_balance_wallet;
      default:
        return Icons.calculate;
    }
  }

  double _getInterestAmount() {
    try {
      if (_variableToCalculate == 'interes') {
        return _calculatedValue;
      } else if (_variableToCalculate == 'monto') {
        return _calculatedValue -
            double.parse(_capitalController.text.replaceAll(',', '.'));
      } else {
        return _totalAmount -
            (_variableToCalculate == 'capital'
                ? _calculatedValue
                : double.parse(_capitalController.text.replaceAll(',', '.')));
      }
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Interés Compuesto',
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
                    '¿Qué es el Interés Compuesto?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'El Interés compuesto es la acumulación de intereses que se generan en un período determinado de tiempo por un capital inicial o principal a una tasa de interés durante determinados periodos de imposición, de manera que los intereses que se obtienen al final de los períodos de inversión no se reinvierten al capital inicial, o sea, se capitalizan.',
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Tasa de interés: i = (MC/C)^(1/n) - 1',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Interés compuesto: IC = MC - C',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Monto compuesto: MC = C(1+i)^n',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Capital: C = MC / (1+i)^n',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tiempo: n = (Log MC - Log C) / Log(1+i)',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Donde:',
                    style: TextStyle(
                      color: const Color(0xFF151616),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'MC = Monto compuesto\nC = Capital\ni = Tasa de interés\nn = Tiempo\nIC = Interés compuesto',
                    style: TextStyle(
                      color: const Color(0xFF151616),
                      fontSize: 14,
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
                              title: Text('Interés compuesto (IC)'),
                              value: 'interes',
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
                              title: Text('Capital (C)'),
                              value: 'capital',
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
                              title: Text('Tasa de interés (i)'),
                              value: 'tasa',
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
                              title: Text('Tiempo (n)'),
                              value: 'tiempo',
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
                              title: Text('Monto compuesto (MC)'),
                              value: 'monto',
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

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frecuencia de capitalización (n)',
                        style: TextStyle(
                          color: const Color(0xFF293431),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                          color: Colors.grey[50],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedFrequency['value'],
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: const Color(0xFF45AA96),
                            ),
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(10),
                            items:
                                _compoundingFrequencies.map((frequency) {
                                  return DropdownMenuItem<String>(
                                    value: frequency['value'],
                                    child: Text(
                                      frequency['label'],
                                      style: TextStyle(
                                        color: const Color(0xFF151616),
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedFrequency = _compoundingFrequencies
                                    .firstWhere(
                                      (frequency) =>
                                          frequency['value'] == newValue,
                                    );
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  if (_variableToCalculate != 'capital') ...[
                    _buildInputField(
                      controller: _capitalController,
                      label: 'Capital (C)',
                      hint: 'Ej: 1000000',
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  if (_variableToCalculate != 'monto') ...[
                    _buildInputField(
                      controller: _montoController,
                      label: 'Monto compuesto (MC)',
                      hint: 'Ej: 1200000',
                      prefixIcon: Icons.account_balance_wallet,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  if (_variableToCalculate != 'tasa') ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tasa de interés (i)',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _tasaController,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Ej: 5',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  prefixIcon: Icon(
                                    Icons.percent,
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
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey[300]!),
                                  color: Colors.grey[50],
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedRateFormat['value'],
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
                                        _interestRateFormats.map((format) {
                                          return DropdownMenuItem<String>(
                                            value: format['value'],
                                            child: Text(
                                              format['label'],
                                              style: TextStyle(
                                                color: const Color(0xFF151616),
                                                fontSize: 16,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedRateFormat =
                                            _interestRateFormats.firstWhere(
                                              (format) =>
                                                  format['value'] == newValue,
                                            );
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Ingresa la tasa en formato ${_selectedRateFormat['label'].toLowerCase()}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],

                  if (_variableToCalculate != 'tiempo') ...[
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

                    _buildResultItem(
                      label: 'Monto total:',
                      value: '\$${_formatNumber(_totalAmount)}',
                      icon: Icons.account_balance_wallet,
                      color: const Color(0xFF293431),
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

                          if (_variableToCalculate != 'capital' &&
                              _capitalController.text.isNotEmpty) ...[
                            Text(
                              'Capital (C): \$${_formatNumber(double.parse(_capitalController.text.replaceAll(',', '.')))}',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                          ],

                          if (_variableToCalculate != 'monto' &&
                              _montoController.text.isNotEmpty) ...[
                            Text(
                              'Monto compuesto (MC): \$${_formatNumber(double.parse(_montoController.text.replaceAll(',', '.')))}',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                          ],

                          if (_variableToCalculate != 'tasa' &&
                              _tasaController.text.isNotEmpty) ...[
                            Text(
                              'Tasa de interés ${_selectedRateFormat['label'].toLowerCase()}: ${_tasaController.text.replaceAll(',', '.')}%',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Tasa de interés anual equivalente: ${(_getAnnualRate() * 100).toStringAsFixed(4)}%',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                          ],

                          Text(
                            'Frecuencia de capitalización: ${_selectedFrequency['label']} (${_selectedFrequency['periods']} período(s) por año)',
                            style: TextStyle(
                              color: const Color(0xFF293431),
                              fontSize: 14,
                            ),
                          ),

                          if (_variableToCalculate != 'interes') ...[
                            Text(
                              'Interés compuesto (IC): \$${_formatNumber(_getInterestAmount())}',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                          ],

                          if (_variableToCalculate != 'tiempo') ...[
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
                            Text(
                              'Número total de períodos: ${(_calculateTimeInYears() * _selectedFrequency['periods']).toStringAsFixed(2)}',
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
                              'El interés compuesto genera "interés sobre interés", lo que resulta en un crecimiento exponencial del capital a lo largo del tiempo.',
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
