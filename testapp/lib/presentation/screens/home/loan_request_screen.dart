import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class LoanRequestScreen extends StatefulWidget {
  const LoanRequestScreen({super.key});

  @override
  State<LoanRequestScreen> createState() => _LoanRequestScreenState();
}

class _LoanRequestScreenState extends State<LoanRequestScreen> {
  double _loanAmount = 5000;
  int _loanTerm = 12;
  final double _interestRate = 0.12; // 12% anual
  bool _termsAccepted = false;

  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  final _incomeController = TextEditingController();

  @override
  void dispose() {
    _purposeController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  double get _monthlyPayment {
    // Cálculo de cuota mensual: P = A * r * (1 + r)^n / ((1 + r)^n - 1)
    // Donde: A = monto del préstamo, r = tasa de interés mensual, n = plazo en meses
    double monthlyRate = _interestRate / 12;
    return _loanAmount *
        monthlyRate *
        math.pow(1 + monthlyRate, _loanTerm) /
        (math.pow(1 + monthlyRate, _loanTerm) - 1);
  }

  double get _totalPayment {
    return _monthlyPayment * _loanTerm;
  }

  double get _totalInterest {
    return _totalPayment - _loanAmount;
  }

  void _submitLoanRequest() {
    if (_formKey.currentState!.validate() && _termsAccepted) {
      // Mostrar diálogo de confirmación
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Solicitud Enviada'),
              content: const Text(
                'Tu solicitud de préstamo ha sido enviada con éxito. Recibirás una notificación con la respuesta en las próximas 24 horas.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(color: Color(0xFF05CEA8)),
                  ),
                ),
              ],
            ),
      );
    } else if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Solicitud de Préstamo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF293431),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF293431).withOpacity(0.9),
              const Color(0xFF45AA96).withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Loan amount card
                  _buildSectionCard(
                    title: 'Monto del Préstamo',
                    icon: Icons.attach_money,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              '\$${_loanAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Slider(
                              value: _loanAmount,
                              min: 1000,
                              max: 50000,
                              divisions: 49,
                              activeColor: const Color(0xFF05CEA8),
                              inactiveColor: Colors.white30,
                              label: '\$${_loanAmount.toStringAsFixed(0)}',
                              onChanged: (value) {
                                setState(() {
                                  _loanAmount = value;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '\$1,000',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const Text(
                                  '\$50,000',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Loan term card
                  _buildSectionCard(
                    title: 'Plazo del Préstamo',
                    icon: Icons.calendar_today,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              '$_loanTerm meses',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Slider(
                              value: _loanTerm.toDouble(),
                              min: 3,
                              max: 60,
                              divisions: 19,
                              activeColor: const Color(0xFF05CEA8),
                              inactiveColor: Colors.white30,
                              label: '$_loanTerm meses',
                              onChanged: (value) {
                                setState(() {
                                  _loanTerm = value.toInt();
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '3 meses',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const Text(
                                  '60 meses',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Loan summary card
                  _buildSectionCard(
                    title: 'Resumen del Préstamo',
                    icon: Icons.summarize,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildSummaryRow(
                              'Tasa de Interés Anual',
                              '${(_interestRate * 100).toStringAsFixed(1)}%',
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              'Pago Mensual',
                              '\$${_monthlyPayment.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              'Total a Pagar',
                              '\$${_totalPayment.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              'Interés Total',
                              '\$${_totalInterest.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Personal information card
                  _buildSectionCard(
                    title: 'Información Personal',
                    icon: Icons.person,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _purposeController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Propósito del Préstamo',
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                hintText:
                                    'Ej. Compra de vehículo, Educación...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.white30,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF05CEA8),
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                errorStyle: const TextStyle(color: Colors.red),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa el propósito del préstamo';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _incomeController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: 'Ingreso Mensual (USD)',
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                hintText: 'Ej. 3000',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                prefixText: '\$ ',
                                prefixStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.white30,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF05CEA8),
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                errorStyle: const TextStyle(color: Colors.red),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu ingreso mensual';
                                }
                                final income = int.tryParse(value);
                                if (income == null || income < 1000) {
                                  return 'El ingreso debe ser al menos \$1,000';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Terms and conditions
                  Row(
                    children: [
                      Checkbox(
                        value: _termsAccepted,
                        onChanged: (value) {
                          setState(() {
                            _termsAccepted = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF05CEA8),
                        checkColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _termsAccepted = !_termsAccepted;
                            });
                          },
                          child: const Text(
                            'Acepto los términos y condiciones del préstamo',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  ElevatedButton(
                    onPressed: _submitLoanRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF05CEA8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Enviar Solicitud',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF293431).withOpacity(0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF05CEA8), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF45AA96), thickness: 1, height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
