import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class CapitalizationSystem extends StatefulWidget {
  const CapitalizationSystem({super.key});

  @override
  State<CapitalizationSystem> createState() => _CapitalizationSystemState();
}

class _CapitalizationSystemState extends State<CapitalizationSystem> {
  // Controllers for input fields
  final _principalController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _timeController = TextEditingController();
  final _periodsPerYearController = TextEditingController();
  final _deferredTimeController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  // Selected capitalization type
  String _selectedCapitalizationType = 'simple';

  // Selected time unit
  Map<String, dynamic> _selectedTimeUnit = {
    'label': 'Años',
    'value': 'years',
    'factor': 1.0,
  };

  // Time units for dropdown
  final List<Map<String, dynamic>> _timeUnits = [
    {'label': 'Años', 'value': 'years', 'factor': 1.0},
    {'label': 'Semestres', 'value': 'semesters', 'factor': 0.5},
    {'label': 'Trimestres', 'value': 'quarters', 'factor': 0.25},
    {'label': 'Meses', 'value': 'months', 'factor': 1 / 12},
    {'label': 'Días', 'value': 'days', 'factor': 1 / 360},
  ];

  // Capitalization types
  final List<Map<String, dynamic>> _capitalizationTypes = [
    {
      'value': 'simple',
      'label': 'Capitalización Simple',
      'icon': Icons.trending_up,
    },
    {
      'value': 'compound',
      'label': 'Capitalización Compuesta',
      'icon': Icons.auto_graph,
    },
    {
      'value': 'continuous',
      'label': 'Capitalización Continua',
      'icon': Icons.timeline,
    },
    {
      'value': 'periodic',
      'label': 'Capitalización Periódica',
      'icon': Icons.date_range,
    },
    {
      'value': 'advance',
      'label': 'Capitalización Anticipada',
      'icon': Icons.fast_forward,
    },
    {
      'value': 'deferred',
      'label': 'Capitalización Diferida',
      'icon': Icons.timer,
    },
  ];

  double _calculatedValue = 0.0;
  bool _hasCalculated = false;
  String _calculationDetails = '';

  @override
  void dispose() {
    _principalController.dispose();
    _interestRateController.dispose();
    _timeController.dispose();
    _periodsPerYearController.dispose();
    _deferredTimeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _calculate() {
    FocusScope.of(context).unfocus();

    // Validate required fields
    if (_principalController.text.isEmpty ||
        _interestRateController.text.isEmpty ||
        _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor completa los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Additional validation for specific capitalization types
    if (_selectedCapitalizationType == 'periodic' &&
        _periodsPerYearController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor ingresa el número de períodos por año'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCapitalizationType == 'deferred' &&
        _deferredTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor ingresa el tiempo de diferimiento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Parse input values
      double principal = double.parse(
        _principalController.text.replaceAll(',', '.'),
      );
      double interestRate =
          double.parse(_interestRateController.text.replaceAll(',', '.')) /
          100; // Convert percentage to decimal
      double time =
          double.parse(_timeController.text.replaceAll(',', '.')) *
          _selectedTimeUnit['factor']; // Convert to years

      double result = 0.0;
      String details = '';

      // Calculate based on selected capitalization type
      switch (_selectedCapitalizationType) {
        case 'simple':
          result = _calculateSimpleCapitalization(
            principal,
            interestRate,
            time,
          );
          details =
              'Capital inicial: \$${_formatNumber(principal)}\n'
              'Tasa de interés: ${_interestRateController.text}%\n'
              'Tiempo: ${_timeController.text} ${_selectedTimeUnit['label'].toLowerCase()}\n'
              'Interés generado: \$${_formatNumber(result - principal)}';
          break;

        case 'compound':
          result = _calculateCompoundCapitalization(
            principal,
            interestRate,
            time,
          );
          details =
              'Capital inicial: \$${_formatNumber(principal)}\n'
              'Tasa de interés: ${_interestRateController.text}%\n'
              'Tiempo: ${_timeController.text} ${_selectedTimeUnit['label'].toLowerCase()}\n'
              'Interés generado: \$${_formatNumber(result - principal)}';
          break;

        case 'continuous':
          result = _calculateContinuousCapitalization(
            principal,
            interestRate,
            time,
          );
          details =
              'Capital inicial: \$${_formatNumber(principal)}\n'
              'Tasa de interés: ${_interestRateController.text}%\n'
              'Tiempo: ${_timeController.text} ${_selectedTimeUnit['label'].toLowerCase()}\n'
              'Interés generado: \$${_formatNumber(result - principal)}';
          break;

        case 'periodic':
          double periodsPerYear = double.parse(
            _periodsPerYearController.text.replaceAll(',', '.'),
          );
          result = _calculatePeriodicCapitalization(
            principal,
            interestRate,
            time,
            periodsPerYear,
          );
          details =
              'Capital inicial: \$${_formatNumber(principal)}\n'
              'Tasa de interés: ${_interestRateController.text}%\n'
              'Tiempo: ${_timeController.text} ${_selectedTimeUnit['label'].toLowerCase()}\n'
              'Períodos por año: ${_periodsPerYearController.text}\n'
              'Interés generado: \$${_formatNumber(result - principal)}';
          break;

        case 'advance':
          result = _calculateAdvanceCapitalization(
            principal,
            interestRate,
            time,
          );
          details =
              'Capital inicial: \$${_formatNumber(principal)}\n'
              'Tasa de interés: ${_interestRateController.text}%\n'
              'Tiempo: ${_timeController.text} ${_selectedTimeUnit['label'].toLowerCase()}\n'
              'Interés generado: \$${_formatNumber(result - principal)}';
          break;

        case 'deferred':
          double deferredTime =
              double.parse(_deferredTimeController.text.replaceAll(',', '.')) *
              _selectedTimeUnit['factor']; // Convert to years
          result = _calculateDeferredCapitalization(
            principal,
            interestRate,
            time,
            deferredTime,
          );
          details =
              'Capital inicial: \$${_formatNumber(principal)}\n'
              'Tasa de interés: ${_interestRateController.text}%\n'
              'Tiempo total: ${_timeController.text} ${_selectedTimeUnit['label'].toLowerCase()}\n'
              'Tiempo de diferimiento: ${_deferredTimeController.text} ${_selectedTimeUnit['label'].toLowerCase()}\n'
              'Interés generado: \$${_formatNumber(result - principal)}';
          break;
      }

      setState(() {
        _calculatedValue = result;
        _calculationDetails = details;
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

  // Calculation methods for each capitalization type
  double _calculateSimpleCapitalization(
    double principal,
    double rate,
    double time,
  ) {
    return principal * (1 + rate * time);
  }

  double _calculateCompoundCapitalization(
    double principal,
    double rate,
    double time,
  ) {
    return principal * pow(1 + rate, time);
  }

  double _calculateContinuousCapitalization(
    double principal,
    double rate,
    double time,
  ) {
    return principal * exp(rate * time);
  }

  double _calculatePeriodicCapitalization(
    double principal,
    double rate,
    double time,
    double periodsPerYear,
  ) {
    double periodicRate = rate / periodsPerYear;
    double totalPeriods = time * periodsPerYear;
    return principal * pow(1 + periodicRate, totalPeriods);
  }

  double _calculateAdvanceCapitalization(
    double principal,
    double rate,
    double time,
  ) {
    return principal * pow(1 / (1 - rate), time);
  }

  double _calculateDeferredCapitalization(
    double principal,
    double rate,
    double time,
    double deferredTime,
  ) {
    // First calculate the value after the deferment period (no interest)
    // Then apply compound interest for the remaining time
    double remainingTime = time - deferredTime;
    if (remainingTime <= 0)
      return principal; // No interest if deferment exceeds total time

    return principal * pow(1 + rate, remainingTime);
  }

  void _clearFields() {
    setState(() {
      _principalController.clear();
      _interestRateController.clear();
      _timeController.clear();
      _periodsPerYearController.clear();
      _deferredTimeController.clear();
      _calculatedValue = 0.0;
      _hasCalculated = false;
      _calculationDetails = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Todos los campos han sido limpiados'),
        backgroundColor: const Color(0xFF293431),
      ),
    );
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

  String _getCapitalizationTitle() {
    return _capitalizationTypes.firstWhere(
      (type) => type['value'] == _selectedCapitalizationType,
    )['label'];
  }

  String _getCapitalizationDescription() {
    switch (_selectedCapitalizationType) {
      case 'simple':
        return 'La capitalización simple es aquella en la que los intereses se calculan siempre sobre el capital inicial. Los intereses generados no producen nuevos intereses.';
      case 'compound':
        return 'La capitalización compuesta es aquella en la que los intereses generados en cada período se suman al capital para el cálculo de intereses en períodos subsiguientes, generando "interés sobre interés".';
      case 'continuous':
        return 'La capitalización continua es el límite de la capitalización compuesta cuando el número de períodos tiende a infinito. Los intereses se capitalizan de manera instantánea y continua.';
      case 'periodic':
        return 'La capitalización periódica es una forma de capitalización compuesta donde los intereses se capitalizan en intervalos regulares específicos (mensual, trimestral, semestral, etc.).';
      case 'advance':
        return 'La capitalización anticipada es aquella en la que los intereses se pagan al inicio del período, en lugar de al final. También conocida como descuento comercial o bancario.';
      case 'deferred':
        return 'La capitalización diferida es aquella en la que existe un período inicial durante el cual no se generan intereses, y después de este período, comienza la capitalización (generalmente compuesta).';
      default:
        return '';
    }
  }

  String _getCapitalizationFormula() {
    switch (_selectedCapitalizationType) {
      case 'simple':
        return 'F = P(1 + rt)';
      case 'compound':
        return 'F = P(1 + r)^t';
      case 'continuous':
        return 'F = Pe^(rt)';
      case 'periodic':
        return 'F = P(1 + r/m)^(mt)';
      case 'advance':
        return 'F = P(1/(1-r))^t';
      case 'deferred':
        return 'F = P(1 + r)^(t-d)';
      default:
        return '';
    }
  }

  List<Map<String, String>> _getFormulaItems() {
    switch (_selectedCapitalizationType) {
      case 'simple':
        return [
          {'symbol': 'F', 'description': 'Monto final'},
          {'symbol': 'P', 'description': 'Capital inicial'},
          {'symbol': 'r', 'description': 'Tasa de interés'},
          {'symbol': 't', 'description': 'Tiempo'},
        ];
      case 'compound':
        return [
          {'symbol': 'F', 'description': 'Monto final'},
          {'symbol': 'P', 'description': 'Capital inicial'},
          {'symbol': 'r', 'description': 'Tasa de interés'},
          {'symbol': 't', 'description': 'Tiempo'},
        ];
      case 'continuous':
        return [
          {'symbol': 'F', 'description': 'Monto final'},
          {'symbol': 'P', 'description': 'Capital inicial'},
          {'symbol': 'r', 'description': 'Tasa de interés'},
          {'symbol': 't', 'description': 'Tiempo'},
          {'symbol': 'e', 'description': 'Número de Euler'},
        ];
      case 'periodic':
        return [
          {'symbol': 'F', 'description': 'Monto final'},
          {'symbol': 'P', 'description': 'Capital inicial'},
          {'symbol': 'r', 'description': 'Tasa de interés anual'},
          {'symbol': 'm', 'description': 'Períodos por año'},
          {'symbol': 't', 'description': 'Tiempo en años'},
        ];
      case 'advance':
        return [
          {'symbol': 'F', 'description': 'Monto final'},
          {'symbol': 'P', 'description': 'Capital inicial'},
          {'symbol': 'r', 'description': 'Tasa de descuento'},
          {'symbol': 't', 'description': 'Tiempo'},
        ];
      case 'deferred':
        return [
          {'symbol': 'F', 'description': 'Monto final'},
          {'symbol': 'P', 'description': 'Capital inicial'},
          {'symbol': 'r', 'description': 'Tasa de interés'},
          {'symbol': 't', 'description': 'Tiempo total'},
          {'symbol': 'd', 'description': 'Tiempo de diferimiento'},
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Sistema de Capitalización',
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

            // Capitalization type selection
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
                    'Tipo de Capitalización',
                    style: TextStyle(
                      color: const Color(0xFF151616),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF05CEA8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children:
                          _capitalizationTypes.map((type) {
                            return RadioListTile<String>(
                              title: Row(
                                children: [
                                  Icon(
                                    type['icon'],
                                    color: const Color(0xFF45AA96),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(type['label']),
                                ],
                              ),
                              value: type['value'],
                              groupValue: _selectedCapitalizationType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCapitalizationType = value!;
                                  _hasCalculated = false;
                                });
                              },
                              activeColor: const Color(0xFF05CEA8),
                              dense: true,
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Theory section
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
                    '¿Qué es ${_getCapitalizationTitle()}?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _getCapitalizationDescription(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Formula section
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
                          _getCapitalizationTitle(),
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _getCapitalizationFormula(),
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 18,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children:
                              _getFormulaItems().map((item) {
                                return _buildFormulaItem(
                                  item['symbol']!,
                                  item['description']!,
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Calculator section
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

                  // Common input fields
                  _buildInputField(
                    controller: _principalController,
                    label: 'Capital inicial (P)',
                    hint: 'Ej: 1000000',
                    prefixIcon: Icons.attach_money,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildInputField(
                    controller: _interestRateController,
                    label: 'Tasa de interés anual (%)',
                    hint: 'Ej: 5',
                    prefixIcon: Icons.percent,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Time input with unit selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tiempo',
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
                              controller: _timeController,
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
                              height: 56, // Same height as TextField
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
                  ),
                  const SizedBox(height: 15),

                  // Conditional fields based on capitalization type
                  if (_selectedCapitalizationType == 'periodic') ...[
                    _buildInputField(
                      controller: _periodsPerYearController,
                      label: 'Períodos por año (m)',
                      hint: 'Ej: 12',
                      prefixIcon: Icons.date_range,
                      keyboardType: TextInputType.number,
                      helperText:
                          'Número de capitalizaciones por año (12 para mensual, 4 para trimestral, etc.)',
                    ),
                    const SizedBox(height: 15),
                  ],

                  if (_selectedCapitalizationType == 'deferred') ...[
                    _buildInputField(
                      controller: _deferredTimeController,
                      label: 'Tiempo de diferimiento (d)',
                      hint: 'Ej: 1',
                      prefixIcon: Icons.timer,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      helperText: 'Período inicial sin intereses',
                    ),
                    const SizedBox(height: 15),
                  ],

                  const SizedBox(height: 10),

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
                      label: 'Monto final:',
                      value: '\$${_formatNumber(_calculatedValue)}',
                      icon: Icons.account_balance_wallet,
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
                          Text(
                            _calculationDetails,
                            style: TextStyle(
                              color: const Color(0xFF293431),
                              fontSize: 14,
                            ),
                          ),
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
                              'La elección del tipo de capitalización adecuado depende del contexto financiero y los términos acordados en cada operación.',
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
