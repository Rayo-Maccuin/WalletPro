import 'package:testapp/presentation/screens/loan/loan_model.dart';
import 'dart:math';

class LoanService {
  // Singleton pattern
  static final LoanService _instance = LoanService._internal();

  factory LoanService() {
    return _instance;
  }

  LoanService._internal();

  // Lista de préstamos
  final List<Loan> _loans = [];

  // Balance total (simulado)
  double _balance = 345670.89;

  // Getter para obtener todos los préstamos
  List<Loan> get loans => _loans;

  // Getter para obtener el balance
  double get balance => _balance;

  // Modificar el método requestLoan para que actualice el balance inmediatamente
  Future<Loan> requestLoan({
    required double amount,
    required double interestRate,
    required int termMonths,
    required String purpose,
  }) async {
    // Generar un ID único
    final id =
        'LOAN-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000)}';

    // Calcular el pago mensual
    final monthlyPayment = Loan.calculateMonthlyPayment(
      amount,
      interestRate,
      termMonths,
    );

    // Crear el préstamo con estado pendiente
    final loan = Loan(
      id: id,
      amount: amount,
      interestRate: interestRate,
      termMonths: termMonths,
      date: DateTime.now(),
      status: 'pending',
      monthlyPayment: monthlyPayment,
      purpose: purpose,
    );

    // Añadir el préstamo a la lista
    _loans.add(loan);

    // Simular un proceso de aprobación (en una app real, esto sería un proceso más complejo)
    await Future.delayed(const Duration(seconds: 1));

    // Aprobar el préstamo (en una app real, esto dependería de varios factores)
    final index = _loans.indexWhere((l) => l.id == id);
    if (index != -1) {
      final approvedLoan = Loan(
        id: id,
        amount: amount,
        interestRate: interestRate,
        termMonths: termMonths,
        date: DateTime.now(),
        status: 'approved',
        monthlyPayment: monthlyPayment,
        purpose: purpose,
      );

      _loans[index] = approvedLoan;

      // Actualizar el balance inmediatamente
      _balance += amount;

      return approvedLoan;
    }

    return loan;
  }

  // Método para obtener un préstamo por ID
  Loan? getLoanById(String id) {
    try {
      return _loans.firstWhere((loan) => loan.id == id);
    } catch (e) {
      return null;
    }
  }

  // Método para obtener préstamos por estado
  List<Loan> getLoansByStatus(String status) {
    return _loans.where((loan) => loan.status == status).toList();
  }

  // Método para obtener préstamos aprobados
  List<Loan> get approvedLoans => getLoansByStatus('approved');

  // Método para obtener préstamos pendientes
  List<Loan> get pendingLoans => getLoansByStatus('pending');

  // Método para obtener préstamos rechazados
  List<Loan> get rejectedLoans => getLoansByStatus('rejected');

  // Método para obtener el total de préstamos
  double get totalLoansAmount {
    return approvedLoans.fold(0, (sum, loan) => sum + loan.amount);
  }

  // Método para obtener el total de pagos mensuales
  double get totalMonthlyPayments {
    return approvedLoans.fold(0, (sum, loan) => sum + loan.monthlyPayment);
  }

  // Método para simular un pago de préstamo
  void makePayment(String loanId, double amount) {
    // En una app real, aquí se procesaría el pago y se actualizaría el estado del préstamo
    // Para esta simulación, simplemente actualizamos el balance
    _balance -= amount;
  }
}
