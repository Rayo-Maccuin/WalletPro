import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../home/loan_details_screen.dart';

class LoanCard extends StatelessWidget {
  final Map<String, dynamic> loan;

  const LoanCard({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy');

    Color statusColor;
    String statusText;

    switch (loan['status']) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pendiente';
        break;
      case 'approved':
        statusColor = Colors.blue;
        statusText = 'Aprobado';
        break;
      case 'active':
        statusColor = const Color(0xFF05CEA8);
        statusText = 'Activo';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Completado';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Rechazado';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Desconocido';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF293431),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF05CEA8).withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Préstamo #${loan['id']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow('Monto:', currencyFormat.format(loan['amount'])),
                const SizedBox(height: 8),
                _buildInfoRow('Plazo:', '${loan['term']} meses'),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Pago Mensual:',
                  currencyFormat.format(loan['monthlyPayment']),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Fecha de Solicitud:',
                  dateFormat.format(loan['requestDate']),
                ),
                const SizedBox(height: 8),
                if (loan['status'] == 'active')
                  _buildInfoRow(
                    'Próximo Pago:',
                    dateFormat.format(loan['nextPaymentDate']),
                  ),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoanDetailsScreen(loanId: ''),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF05CEA8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Detalles'),
                  ),
                ),
                const SizedBox(width: 8),
                if (loan['status'] == 'active')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Lógica para realizar un pago
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF05CEA8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Pagar'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
