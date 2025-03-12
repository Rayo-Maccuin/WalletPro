import 'dart:math';

class Loan {
  final String id;
  final double amount;
  final double interestRate;
  final int termMonths;
  final DateTime date;
  final String status; // 'pending', 'approved', 'rejected'
  final double monthlyPayment;
  final String purpose;

  Loan({
    required this.id,
    required this.amount,
    required this.interestRate,
    required this.termMonths,
    required this.date,
    required this.status,
    required this.monthlyPayment,
    required this.purpose,
  });

  // Método para calcular el pago mensual
  static double calculateMonthlyPayment(
    double amount,
    double interestRate,
    int termMonths,
  ) {
    // Convertir tasa de interés anual a mensual
    double monthlyRate = interestRate / 100 / 12;

    // Fórmula de amortización: P = A * r * (1 + r)^n / ((1 + r)^n - 1)
    double numerator = monthlyRate * pow((1 + monthlyRate), termMonths);
    double denominator = pow((1 + monthlyRate), termMonths) - 1;

    return amount * (numerator / denominator);
  }

  // Método para calcular el total a pagar
  double get totalPayment => monthlyPayment * termMonths;

  // Método para calcular el interés total
  double get totalInterest => totalPayment - amount;

  // Método para obtener la fecha de finalización del préstamo
  DateTime get endDate {
    return DateTime(date.year, date.month + termMonths, date.day);
  }

  // Método para obtener el progreso del préstamo (0-100%)
  double getProgress() {
    if (status != 'approved') return 0;

    final now = DateTime.now();
    if (now.isBefore(date)) return 0;
    if (now.isAfter(endDate)) return 100;

    final totalDays = endDate.difference(date).inDays;
    final daysElapsed = now.difference(date).inDays;

    return (daysElapsed / totalDays) * 100;
  }
}
