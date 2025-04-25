import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class AmortizationCalculator extends StatefulWidget {
  const AmortizationCalculator({super.key});

  @override
  State<AmortizationCalculator> createState() => _AmortizationCalculatorState();
}

class _AmortizationCalculatorState extends State<AmortizationCalculator> {
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _periodsController = TextEditingController();

  String _amortizationMethod = 'french';

  List<Map<String, dynamic>> _amortizationSchedule = [];
  bool _hasCalculated = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _periodsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _calculate() {
    FocusScope.of(context).unfocus();

    try {
      if (_principalController.text.isEmpty ||
          _rateController.text.isEmpty ||
          _periodsController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor completa todos los campos requeridos'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final principal = double.parse(
        _principalController.text.replaceAll(',', '.'),
      );
      final rate =
          double.parse(_rateController.text.replaceAll(',', '.')) / 100;
      final periods = int.parse(_periodsController.text);

      switch (_amortizationMethod) {
        case 'french':
          _calculateFrenchAmortization(principal, rate, periods);
          break;
        case 'german':
          _calculateGermanAmortization(principal, rate, periods);
          break;
        case 'american':
          _calculateAmericanAmortization(principal, rate, periods);
          break;
      }

      setState(() {
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

  void _calculateFrenchAmortization(
    double principal,
    double rate,
    int periods,
  ) {
    double periodicRate = rate / 12;
    double payment =
        principal *
        periodicRate *
        pow(1 + periodicRate, periods) /
        (pow(1 + periodicRate, periods) - 1);

    List<Map<String, dynamic>> schedule = [];
    double remainingPrincipal = principal;

    for (int i = 1; i <= periods; i++) {
      double interestPayment = remainingPrincipal * periodicRate;
      double principalPayment = payment - interestPayment;

      if (i == periods) {
        principalPayment = remainingPrincipal;
        payment = principalPayment + interestPayment;
      }

      remainingPrincipal -= principalPayment;

      if (i == periods) {
        remainingPrincipal = 0;
      }

      schedule.add({
        'period': i,
        'payment': payment,
        'principalPayment': principalPayment,
        'interestPayment': interestPayment,
        'remainingPrincipal': remainingPrincipal,
      });
    }

    setState(() {
      _amortizationSchedule = schedule;
    });
  }

  void _calculateGermanAmortization(
    double principal,
    double rate,
    int periods,
  ) {
    double periodicRate = rate / 12;
    double constantPrincipalPayment = principal / periods;

    List<Map<String, dynamic>> schedule = [];
    double remainingPrincipal = principal;

    for (int i = 1; i <= periods; i++) {
      double interestPayment = remainingPrincipal * periodicRate;
      double payment = constantPrincipalPayment + interestPayment;

      remainingPrincipal -= constantPrincipalPayment;

      if (i == periods) {
        remainingPrincipal = 0;
      }

      schedule.add({
        'period': i,
        'payment': payment,
        'principalPayment': constantPrincipalPayment,
        'interestPayment': interestPayment,
        'remainingPrincipal': remainingPrincipal,
      });
    }

    setState(() {
      _amortizationSchedule = schedule;
    });
  }

  void _calculateAmericanAmortization(
    double principal,
    double rate,
    int periods,
  ) {
    double periodicRate = rate / 12;
    double interestPayment = principal * periodicRate;

    List<Map<String, dynamic>> schedule = [];
    double remainingPrincipal = principal;

    for (int i = 1; i <= periods; i++) {
      double principalPayment = 0;
      double payment = interestPayment;

      if (i == periods) {
        principalPayment = principal;
        payment = principalPayment + interestPayment;
        remainingPrincipal = 0;
      }

      schedule.add({
        'period': i,
        'payment': payment,
        'principalPayment': principalPayment,
        'interestPayment': interestPayment,
        'remainingPrincipal': remainingPrincipal,
      });
    }

    setState(() {
      _amortizationSchedule = schedule;
    });
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
      _principalController.clear();
      _rateController.clear();
      _periodsController.clear();
      _amortizationSchedule = [];
      _hasCalculated = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Todos los campos han sido limpiados'),
        backgroundColor: const Color(0xFF293431),
      ),
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

  String _getAmortizationMethodTitle() {
    switch (_amortizationMethod) {
      case 'french':
        return 'Amortización Francesa';
      case 'german':
        return 'Amortización Alemana';
      case 'american':
        return 'Amortización Americana';
      default:
        return '';
    }
  }

  String _getAmortizationMethodDescription() {
    switch (_amortizationMethod) {
      case 'french':
        return 'Cuota fija durante todo el préstamo. La parte de interés disminuye y la de capital aumenta con cada pago.';
      case 'german':
        return 'Amortización constante de capital. La cuota total disminuye con el tiempo ya que los intereses se reducen.';
      case 'american':
        return 'Solo se pagan intereses durante el plazo y el capital se devuelve íntegramente al final.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Calculadora de Amortización',
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
                    '¿Qué es la Amortización?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'La amortización es el proceso de pago de una deuda a través de pagos regulares que cubren tanto el capital prestado como los intereses. Existen diferentes métodos de amortización que determinan cómo se distribuyen estos pagos a lo largo del tiempo.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

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
                          'A = P × r × (1 + r)^n /(1+ r)^n -1',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
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
                        'Método de Amortización',
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
                              title: Text('Amortización Francesa (cuota fija)'),
                              subtitle: Text(
                                'Cuota constante durante todo el préstamo',
                                style: TextStyle(fontSize: 12),
                              ),
                              value: 'french',
                              groupValue: _amortizationMethod,
                              onChanged: (value) {
                                setState(() {
                                  _amortizationMethod = value!;
                                });
                              },
                              activeColor: const Color(0xFF05CEA8),
                              dense: true,
                            ),
                            RadioListTile<String>(
                              title: Text(
                                'Amortización Alemana (capital constante)',
                              ),
                              subtitle: Text(
                                'Amortización constante de capital',
                                style: TextStyle(fontSize: 12),
                              ),
                              value: 'german',
                              groupValue: _amortizationMethod,
                              onChanged: (value) {
                                setState(() {
                                  _amortizationMethod = value!;
                                });
                              },
                              activeColor: const Color(0xFF05CEA8),
                              dense: true,
                            ),
                            RadioListTile<String>(
                              title: Text(
                                'Amortización Americana (capital al final)',
                              ),
                              subtitle: Text(
                                'Solo intereses y capital al vencimiento',
                                style: TextStyle(fontSize: 12),
                              ),
                              value: 'american',
                              groupValue: _amortizationMethod,
                              onChanged: (value) {
                                setState(() {
                                  _amortizationMethod = value!;
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

                  _buildInputField(
                    controller: _principalController,
                    label: 'Capital inicial',
                    hint: 'Ej: 1000000',
                    prefixIcon: Icons.attach_money,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildInputField(
                    controller: _rateController,
                    label: 'Tasa de interés anual (%)',
                    hint: 'Ej: 5',
                    prefixIcon: Icons.percent,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildInputField(
                    controller: _periodsController,
                    label: 'Número de períodos (meses)',
                    hint: 'Ej: 12',
                    prefixIcon: Icons.calendar_month,
                    keyboardType: TextInputType.number,
                  ),
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

            if (_hasCalculated && _amortizationSchedule.isNotEmpty) ...[
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
                      'Resultados: ${_getAmortizationMethodTitle()}',
                      style: TextStyle(
                        color: const Color(0xFF151616),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                      child: Text(
                        _getAmortizationMethodDescription(),
                        style: TextStyle(
                          color: const Color(0xFF293431),
                          fontSize: 14,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumen del préstamo:',
                            style: TextStyle(
                              color: const Color(0xFF293431),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Capital inicial:',
                                style: TextStyle(
                                  color: const Color(0xFF293431),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '\$${_formatNumber(double.parse(_principalController.text.replaceAll(',', '.')))}',
                                style: TextStyle(
                                  color: const Color(0xFF293431),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tasa de interés anual:',
                                style: TextStyle(
                                  color: const Color(0xFF293431),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${_rateController.text.replaceAll(',', '.')}%',
                                style: TextStyle(
                                  color: const Color(0xFF293431),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Número de períodos:',
                                style: TextStyle(
                                  color: const Color(0xFF293431),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${_periodsController.text} meses',
                                style: TextStyle(
                                  color: const Color(0xFF293431),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total intereses:',
                                style: TextStyle(
                                  color: const Color(0xFF293431),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '\$${_formatNumber(_amortizationSchedule.fold(0.0, (sum, item) => sum + item['interestPayment']))}',
                                style: TextStyle(
                                  color: const Color(0xFF05CEA8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total pagado:',
                                style: TextStyle(
                                  color: const Color(0xFF293431),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '\$${_formatNumber(_amortizationSchedule.fold(0.0, (sum, item) => sum + item['payment']))}',
                                style: TextStyle(
                                  color: const Color(0xFF293431),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Tabla de Amortización',
                      style: TextStyle(
                        color: const Color(0xFF151616),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF293431),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'N°',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Cuota',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Capital',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Interés',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Saldo',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _amortizationSchedule.length,
                        itemBuilder: (context, index) {
                          final item = _amortizationSchedule[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 5,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  index % 2 == 0
                                      ? Colors.white
                                      : Colors.grey[50],
                              border: Border(
                                bottom:
                                    index < _amortizationSchedule.length - 1
                                        ? BorderSide(color: Colors.grey[200]!)
                                        : BorderSide.none,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '${item['period']}',
                                    style: TextStyle(
                                      color: const Color(0xFF293431),
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '\$${_formatNumber(item['payment'])}',
                                    style: TextStyle(
                                      color: const Color(0xFF293431),
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '\$${_formatNumber(item['principalPayment'])}',
                                    style: TextStyle(
                                      color: const Color(0xFF293431),
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '\$${_formatNumber(item['interestPayment'])}',
                                    style: TextStyle(
                                      color: const Color(0xFF05CEA8),
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '\$${_formatNumber(item['remainingPrincipal'])}',
                                    style: TextStyle(
                                      color: const Color(0xFF293431),
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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
                              'Esta tabla muestra cómo se distribuyen los pagos a lo largo del tiempo. Cada método de amortización tiene características diferentes que pueden afectar el costo total del préstamo.',
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
}
