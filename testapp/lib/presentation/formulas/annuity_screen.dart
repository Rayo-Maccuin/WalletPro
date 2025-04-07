import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class AnnuityScreen extends StatefulWidget {
  const AnnuityScreen({super.key});

  @override
  State<AnnuityScreen> createState() => _AnnuityScreenState();
}

class _AnnuityScreenState extends State<AnnuityScreen> {
  final _presentValueController = TextEditingController();
  final _futureValueController = TextEditingController();
  final _paymentController = TextEditingController();
  final _rateController = TextEditingController();
  final _periodsController = TextEditingController();

  double _calculatedValue = 0.0;
  bool _hasCalculated = false;

  final ScrollController _scrollController = ScrollController();

  String _variableToCalculate = 'payment';

  String _annuityType = 'ordinary';

  final List<Map<String, dynamic>> _paymentFrequencies = [
    {'label': 'Anual', 'value': 'annual', 'periods': 1},
    {'label': 'Semestral', 'value': 'semiannual', 'periods': 2},
    {'label': 'Trimestral', 'value': 'quarterly', 'periods': 4},
    {'label': 'Mensual', 'value': 'monthly', 'periods': 12},
  ];

  Map<String, dynamic> _selectedFrequency = {
    'label': 'Anual',
    'value': 'annual',
    'periods': 1,
  };

  @override
  void dispose() {
    _presentValueController.dispose();
    _futureValueController.dispose();
    _paymentController.dispose();
    _rateController.dispose();
    _periodsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _calculate() {
    // Ocultar el teclado
    FocusScope.of(context).unfocus();

    try {
      switch (_variableToCalculate) {
        case 'payment':
          _calculatePayment();
          break;
        case 'presentValue':
          _calculatePresentValue();
          break;
        case 'futureValue':
          _calculateFutureValue();
          break;
        case 'rate':
          _calculateRate();
          break;
        case 'periods':
          _calculatePeriods();
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

  // Obtener la tasa efectiva por período
  double _getEffectiveRatePerPeriod() {
    if (_rateController.text.isEmpty) return 0;

    double inputRate =
        double.parse(_rateController.text.replaceAll(',', '.')) /
        100; // Convertir a decimal

    // Convertir tasa anual a tasa por período
    int periodsPerYear = _selectedFrequency['periods'];
    return inputRate / periodsPerYear;
  }

  void _calculatePayment() {
    // Validar que los campos necesarios tengan valores
    if (_rateController.text.isEmpty || _periodsController.text.isEmpty) {
      _showValidationError('tasa de interés y número de períodos');
      return;
    }

    if (_presentValueController.text.isEmpty &&
        _futureValueController.text.isEmpty) {
      _showValidationError('valor presente o valor futuro');
      return;
    }

    // Obtener tasa efectiva por período
    final ratePerPeriod = _getEffectiveRatePerPeriod();

    // Convertir valores a números
    final periods = double.parse(_periodsController.text.replaceAll(',', '.'));

    double payment = 0.0;

    // Calcular el pago periódico
    if (_presentValueController.text.isNotEmpty &&
        _futureValueController.text.isEmpty) {
      // Caso de valor presente (préstamo)
      final presentValue = double.parse(
        _presentValueController.text.replaceAll(',', '.'),
      );

      if (_annuityType == 'ordinary') {
        // Anualidad ordinaria: A = VA * [i / (1 - (1+i)^-n)]
        payment =
            presentValue *
            ratePerPeriod /
            (1 - pow(1 + ratePerPeriod, -periods));
      } else if (_annuityType == 'due') {
        // Anualidad anticipada: A = VA * [i / ((1 - (1+i)^-n) * (1+i))]
        payment =
            presentValue *
            ratePerPeriod /
            ((1 - pow(1 + ratePerPeriod, -periods)) * (1 + ratePerPeriod));
      }
    } else if (_futureValueController.text.isNotEmpty &&
        _presentValueController.text.isEmpty) {
      // Caso de valor futuro (ahorro)
      final futureValue = double.parse(
        _futureValueController.text.replaceAll(',', '.'),
      );

      if (_annuityType == 'ordinary') {
        // Anualidad ordinaria: A = VF * [i / ((1+i)^n - 1)]
        payment =
            futureValue * ratePerPeriod / (pow(1 + ratePerPeriod, periods) - 1);
      } else if (_annuityType == 'due') {
        // Anualidad anticipada: A = VF * [i / (((1+i)^n - 1) * (1+i))]
        payment =
            futureValue *
            ratePerPeriod /
            ((pow(1 + ratePerPeriod, periods) - 1) * (1 + ratePerPeriod));
      }
    } else if (_futureValueController.text.isNotEmpty &&
        _presentValueController.text.isNotEmpty) {
      // Caso de valor presente y futuro
      final presentValue = double.parse(
        _presentValueController.text.replaceAll(',', '.'),
      );
      final futureValue = double.parse(
        _futureValueController.text.replaceAll(',', '.'),
      );

      if (_annuityType == 'ordinary') {
        // Anualidad ordinaria
        payment =
            (futureValue - presentValue * pow(1 + ratePerPeriod, periods)) /
            ((pow(1 + ratePerPeriod, periods) - 1) / ratePerPeriod);
      } else if (_annuityType == 'due') {
        // Anualidad anticipada
        payment =
            (futureValue - presentValue * pow(1 + ratePerPeriod, periods)) /
            ((pow(1 + ratePerPeriod, periods) - 1) *
                (1 + ratePerPeriod) /
                ratePerPeriod);
      }
    }

    setState(() {
      _calculatedValue = payment;
      _hasCalculated = true;
    });

    // Desplazar hacia abajo para mostrar los resultados
    _scrollToResults();
  }

  void _calculatePresentValue() {
    // Validar que los campos necesarios tengan valores
    if (_rateController.text.isEmpty ||
        _periodsController.text.isEmpty ||
        _paymentController.text.isEmpty) {
      _showValidationError(
        'tasa de interés, número de períodos y pago periódico',
      );
      return;
    }

    // Obtener tasa efectiva por período
    final ratePerPeriod = _getEffectiveRatePerPeriod();

    // Convertir valores a números
    final periods = double.parse(_periodsController.text.replaceAll(',', '.'));
    final payment = double.parse(_paymentController.text.replaceAll(',', '.'));

    double presentValue = 0.0;

    // Calcular el valor presente usando la fórmula: VA = A * [(1 - (1+i)^-n) / i]
    if (_annuityType == 'ordinary') {
      // Anualidad ordinaria
      presentValue =
          payment * (1 - pow(1 + ratePerPeriod, -periods)) / ratePerPeriod;
    } else if (_annuityType == 'due') {
      // Anualidad anticipada: VA = A * [(1 - (1+i)^-n) / i] * (1+i)
      presentValue =
          payment *
          (1 - pow(1 + ratePerPeriod, -periods)) /
          ratePerPeriod *
          (1 + ratePerPeriod);
    }

    // Si hay un valor futuro, ajustar el cálculo
    if (_futureValueController.text.isNotEmpty) {
      final futureValue = double.parse(
        _futureValueController.text.replaceAll(',', '.'),
      );
      presentValue =
          presentValue + futureValue / pow(1 + ratePerPeriod, periods);
    }

    setState(() {
      _calculatedValue = presentValue;
      _hasCalculated = true;
    });

    // Desplazar hacia abajo para mostrar los resultados
    _scrollToResults();
  }

  void _calculateFutureValue() {
    // Validar que los campos necesarios tengan valores
    if (_rateController.text.isEmpty ||
        _periodsController.text.isEmpty ||
        _paymentController.text.isEmpty) {
      _showValidationError(
        'tasa de interés, número de períodos y pago periódico',
      );
      return;
    }

    // Obtener tasa efectiva por período
    final ratePerPeriod = _getEffectiveRatePerPeriod();

    // Convertir valores a números
    final periods = double.parse(_periodsController.text.replaceAll(',', '.'));
    final payment = double.parse(_paymentController.text.replaceAll(',', '.'));

    double futureValue = 0.0;

    // Calcular el valor futuro usando la fórmula: VF = A * [(1+i)^n - 1) / i]
    if (_annuityType == 'ordinary') {
      // Anualidad ordinaria
      futureValue =
          payment * (pow(1 + ratePerPeriod, periods) - 1) / ratePerPeriod;
    } else if (_annuityType == 'due') {
      // Anualidad anticipada: VF = A * [(1+i)^n - 1) / i] * (1+i)
      futureValue =
          payment *
          (pow(1 + ratePerPeriod, periods) - 1) /
          ratePerPeriod *
          (1 + ratePerPeriod);
    }

    // Si hay un valor presente, ajustar el cálculo
    if (_presentValueController.text.isNotEmpty) {
      final presentValue = double.parse(
        _presentValueController.text.replaceAll(',', '.'),
      );
      futureValue =
          futureValue + presentValue * pow(1 + ratePerPeriod, periods);
    }

    setState(() {
      _calculatedValue = futureValue;
      _hasCalculated = true;
    });

    // Desplazar hacia abajo para mostrar los resultados
    _scrollToResults();
  }

  void _calculateRate() {
    // Validar que los campos necesarios tengan valores
    if (_periodsController.text.isEmpty || _paymentController.text.isEmpty) {
      _showValidationError('número de períodos y pago periódico');
      return;
    }

    if (_presentValueController.text.isEmpty &&
        _futureValueController.text.isEmpty) {
      _showValidationError('valor presente o valor futuro');
      return;
    }

    // Convertir valores a números
    final periods = double.parse(_periodsController.text.replaceAll(',', '.'));
    final payment = double.parse(_paymentController.text.replaceAll(',', '.'));

    double presentValue = 0;
    if (_presentValueController.text.isNotEmpty) {
      presentValue = double.parse(
        _presentValueController.text.replaceAll(',', '.'),
      );
    }

    double futureValue = 0;
    if (_futureValueController.text.isNotEmpty) {
      futureValue = double.parse(
        _futureValueController.text.replaceAll(',', '.'),
      );
    }

    // Estimación inicial de la tasa
    double rateGuess = 0.1; // 10%
    double tolerance = 0.0001;
    int maxIterations = 100;

    // Método iterativo para encontrar la tasa
    double ratePerPeriod = _findRateNumerically(
      presentValue,
      futureValue,
      payment,
      periods,
      rateGuess,
      tolerance,
      maxIterations,
      _annuityType,
    );

    // En _calculateRate, reemplazar:
    // Convertir a tasa anual efectiva
    double annualRate = ratePerPeriod * _selectedFrequency['periods'];

    setState(() {
      _calculatedValue = annualRate * 100; // Convertir a porcentaje
      _hasCalculated = true;
    });

    // Desplazar hacia abajo para mostrar los resultados
    _scrollToResults();
  }

  double _findRateNumerically(
    double presentValue,
    double futureValue,
    double payment,
    double periods,
    double rateGuess,
    double tolerance,
    int maxIterations,
    String annuityType,
  ) {
    double rate = rateGuess;

    for (int i = 0; i < maxIterations; i++) {
      double f = 0.0, fPrime = 0.0;

      if (annuityType == 'ordinary') {
        // Anualidad ordinaria
        if (presentValue > 0 && futureValue == 0) {
          f = presentValue - payment * (1 - pow(1 + rate, -periods)) / rate;
          fPrime =
              payment *
              ((1 - pow(1 + rate, -periods)) / (rate * rate) -
                  periods * pow(1 + rate, -periods - 1) / rate);
        } else if (futureValue > 0 && presentValue == 0) {
          f = futureValue - payment * (pow(1 + rate, periods) - 1) / rate;
          fPrime =
              payment *
              (periods * pow(1 + rate, periods - 1) / rate -
                  (pow(1 + rate, periods) - 1) / (rate * rate));
        } else {
          f =
              presentValue * pow(1 + rate, periods) +
              payment * (pow(1 + rate, periods) - 1) / rate -
              futureValue;
          fPrime =
              presentValue * periods * pow(1 + rate, periods - 1) +
              payment *
                  (periods * pow(1 + rate, periods - 1) / rate -
                      (pow(1 + rate, periods) - 1) / (rate * rate));
        }
      } else if (annuityType == 'due') {
        // Anualidad anticipada
        if (presentValue > 0 && futureValue == 0) {
          f =
              presentValue -
              payment * (1 - pow(1 + rate, -periods)) / rate * (1 + rate);
          fPrime =
              payment *
              ((1 - pow(1 + rate, -periods)) / (rate * rate) * (1 + rate) +
                  (1 - pow(1 + rate, -periods)) / rate -
                  periods * pow(1 + rate, -periods - 1) / rate * (1 + rate));
        } else if (futureValue > 0 && presentValue == 0) {
          f =
              futureValue -
              payment * (pow(1 + rate, periods) - 1) / rate * (1 + rate);
          fPrime =
              payment *
              (periods * pow(1 + rate, periods - 1) / rate * (1 + rate) +
                  (pow(1 + rate, periods) - 1) / rate -
                  (pow(1 + rate, periods) - 1) / (rate * rate) * (1 + rate));
        } else {
          f =
              presentValue * pow(1 + rate, periods) +
              payment * (pow(1 + rate, periods) - 1) / rate * (1 + rate) -
              futureValue;
          fPrime =
              presentValue * periods * pow(1 + rate, periods - 1) +
              payment *
                  (periods * pow(1 + rate, periods - 1) / rate * (1 + rate) +
                      (pow(1 + rate, periods) - 1) / rate -
                      (pow(1 + rate, periods) - 1) /
                          (rate * rate) *
                          (1 + rate));
        }
      }

      // Evitar división por cero o valores muy pequeños
      if (fPrime.abs() < 1e-8) {
        // Usar un valor pequeño pero no cero para evitar la división por cero
        fPrime = fPrime.sign * 1e-8;
      }

      double newRate = rate - f / fPrime;

      // Verificar convergencia
      if ((newRate - rate).abs() < tolerance) {
        rate = newRate;
        break;
      }

      rate = newRate;

      // Evitar tasas negativas o muy grandes
      if (rate < 0) {
        rate = 0.01;
      } else if (rate > 1) {
        rate = 0.5; // Reiniciar si la tasa se vuelve muy grande
      }
    }

    return rate;
  }

  void _calculatePeriods() {
    // Validar que los campos necesarios tengan valores
    if (_rateController.text.isEmpty || _paymentController.text.isEmpty) {
      _showValidationError('tasa de interés y pago periódico');
      return;
    }

    if (_presentValueController.text.isEmpty &&
        _futureValueController.text.isEmpty) {
      _showValidationError('valor presente o valor futuro');
      return;
    }

    // Obtener tasa efectiva por período
    final ratePerPeriod = _getEffectiveRatePerPeriod();

    // Convertir valores a números
    final payment = double.parse(_paymentController.text.replaceAll(',', '.'));

    double periods = 0.0;

    // Calcular el número de períodos
    if (_presentValueController.text.isNotEmpty &&
        _futureValueController.text.isEmpty) {
      // Caso de valor presente (préstamo)
      final presentValue = double.parse(
        _presentValueController.text.replaceAll(',', '.'),
      );

      if (_annuityType == 'ordinary') {
        // Anualidad ordinaria: n = -ln(1 - VA*i/A) / ln(1+i)
        periods =
            -log(1 - presentValue * ratePerPeriod / payment) /
            log(1 + ratePerPeriod);
      } else if (_annuityType == 'due') {
        // Anualidad anticipada: ajuste para pago al inicio
        periods =
            -log(
              1 -
                  presentValue *
                      ratePerPeriod /
                      (payment * (1 + ratePerPeriod)),
            ) /
            log(1 + ratePerPeriod);
      }
    } else if (_futureValueController.text.isNotEmpty &&
        _presentValueController.text.isEmpty) {
      // Caso de valor futuro (ahorro)
      final futureValue = double.parse(
        _futureValueController.text.replaceAll(',', '.'),
      );

      if (_annuityType == 'ordinary') {
        // Anualidad ordinaria: n = ln(1 + VF*i/A) / ln(1+i)
        periods =
            log(1 + futureValue * ratePerPeriod / payment) /
            log(1 + ratePerPeriod);
      } else if (_annuityType == 'due') {
        // Anualidad anticipada: ajuste para pago al inicio
        periods =
            log(
              1 + futureValue * ratePerPeriod / (payment * (1 + ratePerPeriod)),
            ) /
            log(1 + ratePerPeriod);
      }
    } else if (_futureValueController.text.isNotEmpty &&
        _presentValueController.text.isNotEmpty) {
      final presentValue = double.parse(
        _presentValueController.text.replaceAll(',', '.'),
      );
      final futureValue = double.parse(
        _futureValueController.text.replaceAll(',', '.'),
      );

      // Estimación inicial de períodos
      double periodsGuess = 10;
      double tolerance = 0.0001;
      int maxIterations = 100;

      periods = _findPeriodsNumerically(
        presentValue,
        futureValue,
        payment,
        ratePerPeriod,
        periodsGuess,
        tolerance,
        maxIterations,
        _annuityType,
      );
    }

    setState(() {
      _calculatedValue = periods;
      _hasCalculated = true;
    });

    // Desplazar hacia abajo para mostrar los resultados
    _scrollToResults();
  }

  double _findPeriodsNumerically(
    double presentValue,
    double futureValue,
    double payment,
    double rate,
    double periodsGuess,
    double tolerance,
    int maxIterations,
    String annuityType,
  ) {
    double n = periodsGuess;

    for (int i = 0; i < maxIterations; i++) {
      double f = 0.0, fPrime = 0.0;

      if (annuityType == 'ordinary') {
        // Anualidad ordinaria
        f =
            presentValue * pow(1 + rate, n) +
            payment * (pow(1 + rate, n) - 1) / rate -
            futureValue;
        fPrime =
            presentValue * log(1 + rate) * pow(1 + rate, n) +
            payment * log(1 + rate) * pow(1 + rate, n) / rate;
      } else if (annuityType == 'due') {
        // Anualidad anticipada
        f =
            presentValue * pow(1 + rate, n) +
            payment * (pow(1 + rate, n) - 1) / rate * (1 + rate) -
            futureValue;
        fPrime =
            presentValue * log(1 + rate) * pow(1 + rate, n) +
            payment * log(1 + rate) * pow(1 + rate, n) / rate * (1 + rate);
      }

      // Evitar división por cero o valores muy pequeños
      if (fPrime.abs() < 1e-8) {
        // Usar un valor pequeño pero no cero para evitar la división por cero
        fPrime = fPrime.sign * 1e-8;
      }

      double newN = n - f / fPrime;

      // Verificar convergencia
      if ((newN - n).abs() < tolerance) {
        n = newN;
        break;
      }

      n = newN;

      // Evitar períodos negativos
      if (n < 0) {
        n = 1;
      }
    }

    return n;
  }

  void _showValidationError(String fields) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Por favor completa los campos de $fields'),
        backgroundColor: Colors.red,
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

  // Limpiar todos los campos
  void _clearFields() {
    setState(() {
      _presentValueController.clear();
      _futureValueController.clear();
      _paymentController.clear();
      _rateController.clear();
      _periodsController.clear();
      _calculatedValue = 0.0;
      _hasCalculated = false;
    });

    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Todos los campos han sido limpiados'),
        backgroundColor: const Color(0xFF293431),
      ),
    );
  }

  // Obtener el título del resultado según la variable calculada
  String _getResultTitle() {
    switch (_variableToCalculate) {
      case 'payment':
        return 'Anualidad (A):';
      case 'presentValue':
        return 'Valor Actual (VA):';
      case 'futureValue':
        return 'Valor Futuro (VF):';
      case 'rate':
        return 'Tasa de interés (i):';
      case 'periods':
        return 'Número de períodos (n):';
      default:
        return '';
    }
  }

  // Obtener el valor formateado del resultado
  String _getFormattedResult() {
    switch (_variableToCalculate) {
      case 'payment':
      case 'presentValue':
      case 'futureValue':
        return '\$${_formatNumber(_calculatedValue)}';
      case 'rate':
        return '${_formatNumber(_calculatedValue)}%';
      case 'periods':
        return '${_formatNumber(_calculatedValue)} períodos';
      default:
        return '';
    }
  }

  // Obtener el ícono para el resultado
  IconData _getResultIcon() {
    switch (_variableToCalculate) {
      case 'payment':
        return Icons.payments;
      case 'presentValue':
        return Icons.account_balance_wallet;
      case 'futureValue':
        return Icons.trending_up;
      case 'rate':
        return Icons.percent;
      case 'periods':
        return Icons.calendar_today;
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
          'Anualidades',
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
            // Título de la app
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

            // Tarjeta de información
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
                    '¿Qué son las Anualidades?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Las anualidades son series de pagos iguales realizados a intervalos regulares de tiempo. Se utilizan para préstamos, inversiones, planes de ahorro y pensiones. Pueden ser ordinarias (pagos al final de cada período) o anticipadas (pagos al inicio de cada período).',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Tarjeta de fórmulas
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
                          'Tipos de Anualidades',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Valor Futuro: VF = A[(1+i)^n - 1)/i]',
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
                          'Valor Actual: VA = A[(1-(1+i)^-n)/i]',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            _buildFormulaItem('VA', 'Valor actual'),
                            _buildFormulaItem('VF', 'Valor futuro'),
                            _buildFormulaItem('A', 'Anualidad'),
                            _buildFormulaItem('i', 'Tasa por período'),
                            _buildFormulaItem('n', 'Número de períodos'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Tarjeta de calculadora
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

                  // Selector de variable a calcular
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
                              title: Text('Anualidad (A)'),
                              value: 'payment',
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
                              title: Text('Valor Actual (VA)'),
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
                              title: Text('Valor Futuro (VF)'),
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
                              title: Text('Tasa de interés (i)'),
                              value: 'rate',
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
                              title: Text('Número de períodos (n)'),
                              value: 'periods',
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

                  // Tipo de anualidad
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tipo de anualidad',
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
                              title: Text('Ordinaria'),
                              subtitle: Text('Pagos al final'),
                              value: 'ordinary',
                              groupValue: _annuityType,
                              onChanged: (value) {
                                setState(() {
                                  _annuityType = value!;
                                });
                              },
                              activeColor: const Color(0xFF05CEA8),
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            RadioListTile<String>(
                              title: Text('Anticipada'),
                              subtitle: Text('Pagos al inicio'),
                              value: 'due',
                              groupValue: _annuityType,
                              onChanged: (value) {
                                setState(() {
                                  _annuityType = value!;
                                });
                              },
                              activeColor: const Color(0xFF05CEA8),
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Frecuencia de pago
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frecuencia de pago',
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
                                _paymentFrequencies.map((frequency) {
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
                                _selectedFrequency = _paymentFrequencies
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
                  const SizedBox(height: 20),

                  // Campo de valor presente (excepto cuando se calcula PV)
                  if (_variableToCalculate != 'presentValue') ...[
                    _buildInputField(
                      controller: _presentValueController,
                      label: 'Valor Actual (VA)',
                      hint: 'Ej: 1000000',
                      prefixIcon: Icons.account_balance_wallet,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  // Campo de valor futuro (excepto cuando se calcula FV)
                  if (_variableToCalculate != 'futureValue') ...[
                    _buildInputField(
                      controller: _futureValueController,
                      label: 'Valor Futuro (VF)',
                      hint: 'Ej: 1500000',
                      prefixIcon: Icons.trending_up,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  // Campo de pago periódico (excepto cuando se calcula PMT)
                  if (_variableToCalculate != 'payment') ...[
                    _buildInputField(
                      controller: _paymentController,
                      label: 'Anualidad (A)',
                      hint: 'Ej: 10000',
                      prefixIcon: Icons.payments,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  // Campo de tasa de interés (excepto cuando se calcula r)
                  if (_variableToCalculate != 'rate') ...[
                    _buildInputField(
                      controller: _rateController,
                      label: 'Tasa de interés (i) %',
                      hint: 'Ej: 5',
                      prefixIcon: Icons.percent,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  // Campo de número de períodos (excepto cuando se calcula n)
                  if (_variableToCalculate != 'periods') ...[
                    _buildInputField(
                      controller: _periodsController,
                      label: 'Número de períodos (n)',
                      hint: 'Ej: 12',
                      prefixIcon: Icons.calendar_today,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  const SizedBox(height: 10),

                  // Botón de calcular
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
                    const SizedBox(height: 20),

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
                            'Tipo de anualidad: ${_annuityType == 'ordinary' ? 'Ordinaria (pagos al final)' : 'Anticipada (pagos al inicio)'}',
                            style: TextStyle(
                              color: const Color(0xFF293431),
                              fontSize: 14,
                            ),
                          ),

                          Text(
                            'Frecuencia de pago: ${_selectedFrequency['label']} (${_selectedFrequency['periods']} período(s) por año)',
                            style: TextStyle(
                              color: const Color(0xFF293431),
                              fontSize: 14,
                            ),
                          ),

                          if (_variableToCalculate != 'presentValue' &&
                              _presentValueController.text.isNotEmpty) ...[
                            Text(
                              'Valor Actual: \$${_formatNumber(double.parse(_presentValueController.text.replaceAll(',', '.')))}',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                          ],

                          if (_variableToCalculate != 'futureValue' &&
                              _futureValueController.text.isNotEmpty) ...[
                            Text(
                              'Valor Futuro: \$${_formatNumber(double.parse(_futureValueController.text.replaceAll(',', '.')))}',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                          ],

                          if (_variableToCalculate != 'payment' &&
                              _paymentController.text.isNotEmpty) ...[
                            Text(
                              'Anualidad: \$${_formatNumber(double.parse(_paymentController.text.replaceAll(',', '.')))}',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                          ],

                          if (_variableToCalculate != 'rate' &&
                              _rateController.text.isNotEmpty) ...[
                            Text(
                              'Tasa de interés: ${_rateController.text.replaceAll(',', '.')}%',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Tasa efectiva por período: ${(_getEffectiveRatePerPeriod() * 100).toStringAsFixed(4)}%',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                          ],

                          if (_variableToCalculate != 'periods' &&
                              _periodsController.text.isNotEmpty) ...[
                            Text(
                              'Número de períodos: ${_periodsController.text.replaceAll(',', '.')}',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Tiempo en años: ${(double.parse(_periodsController.text.replaceAll(',', '.')) / _selectedFrequency['periods']).toStringAsFixed(2)} años',
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
                              'Las anualidades son útiles para calcular préstamos, planes de ahorro, inversiones y pensiones. El tipo de anualidad afecta significativamente los resultados.',
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
