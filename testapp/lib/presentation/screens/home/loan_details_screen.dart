import 'package:flutter/material.dart';
import 'package:testapp/presentation/screens/loan/loan_model.dart';
import 'package:testapp/presentation/screens/loan/loan_service.dart';
import 'package:intl/intl.dart';

class LoanDetailsScreen extends StatefulWidget {
  final String loanId;

  const LoanDetailsScreen({super.key, required this.loanId});

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  final _loanService = LoanService();
  late Loan? _loan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoan();
  }

  Future<void> _loadLoan() async {
    setState(() {
      _isLoading = true;
    });

    // Simular carga de datos
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _loan = _loanService.getLoanById(widget.loanId);
      _isLoading = false;
    });
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'Aprobado';
      case 'pending':
        return 'Pendiente';
      case 'rejected':
        return 'Rechazado';
      default:
        return 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF293431),
        foregroundColor: Colors.white,
        title: const Text('Detalles del Préstamo'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF05CEA8)),
                )
                : _loan == null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Préstamo no encontrado',
                        style: TextStyle(
                          color: Color(0xFF293431),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No se pudo encontrar el préstamo con ID: ${widget.loanId}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF05CEA8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Volver'),
                      ),
                    ],
                  ),
                )
                : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Estado del préstamo
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              _loan!.status,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: _getStatusColor(_loan!.status),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _loan!.status == 'approved'
                                    ? Icons.check_circle
                                    : _loan!.status == 'pending'
                                    ? Icons.hourglass_empty
                                    : Icons.cancel,
                                color: _getStatusColor(_loan!.status),
                                size: 30,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Estado: ${_getStatusText(_loan!.status)}',
                                      style: TextStyle(
                                        color: _getStatusColor(_loan!.status),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (_loan!.status == 'approved') ...[
                                      const SizedBox(height: 5),
                                      Text(
                                        'Tu préstamo ha sido aprobado y depositado en tu cuenta.',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ] else if (_loan!.status == 'pending') ...[
                                      const SizedBox(height: 5),
                                      Text(
                                        'Tu solicitud está siendo procesada. Te notificaremos cuando haya una actualización.',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ] else ...[
                                      const SizedBox(height: 5),
                                      Text(
                                        'Lo sentimos, tu solicitud de préstamo ha sido rechazada. Contacta a soporte para más información.',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Detalles del préstamo
                        Container(
                          padding: const EdgeInsets.all(20),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Detalles del Préstamo',
                                style: TextStyle(
                                  color: Color(0xFF293431),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),

                              _buildDetailRow('ID del préstamo:', _loan!.id),
                              _buildDetailRow(
                                'Monto del préstamo:',
                                _formatCurrency(_loan!.amount),
                              ),
                              _buildDetailRow(
                                'Tasa de interés:',
                                '${_loan!.interestRate.toStringAsFixed(1)}%',
                              ),
                              _buildDetailRow(
                                'Plazo:',
                                '${_loan!.termMonths} meses',
                              ),
                              _buildDetailRow(
                                'Fecha de solicitud:',
                                _formatDate(_loan!.date),
                              ),
                              _buildDetailRow(
                                'Fecha de finalización:',
                                _formatDate(_loan!.endDate),
                              ),
                              _buildDetailRow('Propósito:', _loan!.purpose),
                              _buildDetailRow(
                                'Pago mensual:',
                                _formatCurrency(_loan!.monthlyPayment),
                              ),
                              _buildDetailRow(
                                'Total a pagar:',
                                _formatCurrency(_loan!.totalPayment),
                              ),
                              _buildDetailRow(
                                'Interés total:',
                                _formatCurrency(_loan!.totalInterest),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Progreso del préstamo (solo si está aprobado)
                        if (_loan!.status == 'approved') ...[
                          Container(
                            padding: const EdgeInsets.all(20),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Progreso del Préstamo',
                                  style: TextStyle(
                                    color: Color(0xFF293431),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Barra de progreso
                                LinearProgressIndicator(
                                  value: _loan!.getProgress() / 100,
                                  backgroundColor: Colors.grey[300],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF05CEA8),
                                      ),
                                  minHeight: 10,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                const SizedBox(height: 10),

                                // Texto de progreso
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Progreso: ${_loan!.getProgress().toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        color: Color(0xFF293431),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Restante: ${(100 - _loan!.getProgress()).toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Botón para realizar pago
                                SizedBox(
                                  width: double.infinity,
                                  height: 45,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Mostrar diálogo para realizar pago
                                      _showPaymentDialog(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF05CEA8),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Realizar Pago',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 25),

                        // Botón volver
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF45AA96),
                              side: const BorderSide(color: Color(0xFF45AA96)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Volver',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF293431),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Realizar Pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pago mensual: ${_formatCurrency(_loan!.monthlyPayment)}',
                style: const TextStyle(
                  color: Color(0xFF293431),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '¿Deseas realizar el pago mensual de tu préstamo?',
                style: TextStyle(color: Color(0xFF293431), fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Realizar el pago
                _loanService.makePayment(_loan!.id, _loan!.monthlyPayment);

                Navigator.of(context).pop();

                // Mostrar mensaje de éxito
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pago realizado con éxito'),
                    backgroundColor: Color(0xFF05CEA8),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF05CEA8),
                foregroundColor: Colors.white,
              ),
              child: const Text('Pagar'),
            ),
          ],
        );
      },
    );
  }
}
