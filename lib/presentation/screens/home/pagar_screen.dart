import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class PagarScreen extends StatefulWidget {
  const PagarScreen({Key? key}) : super(key: key);

  @override
  State<PagarScreen> createState() => _PagarScreenState();
}

class _PagarScreenState extends State<PagarScreen>
    with TickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  String _selectedPaymentType = 'Transferencia';
  bool _isProcessing = false;
  bool _showQR = false;
  late AnimationController _animationController;
  late AnimationController _qrAnimationController;
  late Animation<double> _animation;
  late Animation<double> _qrAnimation;

  final List<String> _paymentTypes = [
    'Transferencia',
    'Pago de Servicios',
    'Pago de Impuestos',
    'Pago a Comercios',
    'Pago de Tarjeta de Crédito',
  ];

  final List<Map<String, dynamic>> _recentContacts = [
    {
      'name': 'Carlos Rodríguez',
      'account': '**** 5678',
      'avatar': 'CR',
      'color': const Color(0xFF45AA96),
    },
    {
      'name': 'María López',
      'account': '**** 1234',
      'avatar': 'ML',
      'color': const Color(0xFF05CEA8),
    },
    {
      'name': 'Juan Pérez',
      'account': '**** 9012',
      'avatar': 'JP',
      'color': const Color(0xFF45AA96),
    },
    {
      'name': 'Ana Gómez',
      'account': '**** 3456',
      'avatar': 'AG',
      'color': const Color(0xFF05CEA8),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);

    _qrAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _qrAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _qrAnimationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    _referenceController.dispose();
    _animationController.dispose();
    _qrAnimationController.dispose();
    super.dispose();
  }

  void _processPayment() {
    if (_amountController.text.isEmpty || _recipientController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: Color(0xFF45AA96),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _showSuccessDialog();
      }
    });
  }

  void _toggleQRCode() {
    setState(() {
      _showQR = !_showQR;
    });

    if (_showQR) {
      _qrAnimationController.forward();
    } else {
      _qrAnimationController.reverse();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF293431),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF05CEA8), size: 28),
                SizedBox(width: 10),
                Text('Pago Exitoso', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tu pago ha sido procesado exitosamente.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151616),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Monto:',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            '\$${_amountController.text}',
                            style: const TextStyle(
                              color: Color(0xFF05CEA8),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Destinatario:',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            _recipientController.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Fecha:',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const Text(
                            '25/04/2023',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _amountController.clear();
                  _recipientController.clear();
                  _referenceController.clear();
                },
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: Color(0xFF05CEA8)),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF293431),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151616),
        title: const Text(
          'Realizar Pago',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _toggleQRCode,
            color: _showQR ? const Color(0xFF05CEA8) : Colors.white,
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomPaint(
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
            painter: PaymentBackgroundPainter(color: const Color(0xFF05CEA8)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_showQR) _buildQRCodeSection(),
                  if (!_showQR) ...[
                    _buildRecentContacts(),
                    const SizedBox(height: 25),
                    _buildPaymentForm(),
                    const SizedBox(height: 25),
                    _buildPaymentButton(),
                  ],
                ],
              ),
            ),
          ),
          if (_isProcessing) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildRecentContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contactos Recientes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recentContacts.length,
            itemBuilder: (context, index) {
              final contact = _recentContacts[index];
              return Container(
                margin: const EdgeInsets.only(right: 15),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: contact['color'],
                      child: Text(
                        contact['avatar'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      contact['name'].split(' ')[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      contact['account'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151616),
        borderRadius: BorderRadius.circular(15),
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
          const Text(
            'Información de Pago',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedPaymentType,
            decoration: InputDecoration(
              labelText: 'Tipo de Pago',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.payments, color: Color(0xFF45AA96)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF05CEA8)),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
            ),
            style: const TextStyle(color: Colors.white),
            dropdownColor: const Color(0xFF293431),
            items:
                _paymentTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedPaymentType = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Monto a Pagar',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(
                Icons.attach_money,
                color: Color(0xFF45AA96),
              ),
              prefixText: '\$ ',
              prefixStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF05CEA8)),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _recipientController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Destinatario / Número de Cuenta',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.person, color: Color(0xFF45AA96)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF05CEA8)),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _referenceController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Referencia / Concepto',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(
                Icons.description,
                color: Color(0xFF45AA96),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF05CEA8)),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF05CEA8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: const Text(
          'REALIZAR PAGO',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildQRCodeSection() {
    return AnimatedBuilder(
      animation: _qrAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _qrAnimation.value,
          child: Opacity(
            opacity: _qrAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151616),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Escanea para Pagar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CustomPaint(
                      size: const Size(180, 180),
                      painter: QRCodePainter(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'WalletPro - Pago Rápido',
                    style: TextStyle(
                      color: Color(0xFF05CEA8),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Comparte este código QR para recibir pagos',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildQRActionButton(Icons.share, 'Compartir'),
                      const SizedBox(width: 20),
                      _buildQRActionButton(Icons.download, 'Guardar'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQRActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF293431),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF05CEA8), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(80, 80),
                  painter: LoadingPainter(
                    animation: _animation.value,
                    color: const Color(0xFF05CEA8),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Procesando Pago...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentBackgroundPainter extends CustomPainter {
  final Color color;

  PaymentBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final paint =
        Paint()
          ..color = color.withOpacity(0.05)
          ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(width, 0);
    path.lineTo(width, height * 0.3);
    path.quadraticBezierTo(
      width * 0.75,
      height * 0.35,
      width * 0.5,
      height * 0.3,
    );
    path.quadraticBezierTo(width * 0.25, height * 0.25, 0, height * 0.3);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);

    final bottomPath = Path();
    bottomPath.moveTo(0, height * 0.7);
    bottomPath.quadraticBezierTo(
      width * 0.25,
      height * 0.75,
      width * 0.5,
      height * 0.7,
    );
    bottomPath.quadraticBezierTo(
      width * 0.75,
      height * 0.65,
      width,
      height * 0.7,
    );
    bottomPath.lineTo(width, height);
    bottomPath.lineTo(0, height);
    bottomPath.close();

    canvas.drawPath(bottomPath, paint);

    final dotPaint =
        Paint()
          ..color = color.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    final random = math.Random(42);
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * width;
      final y = random.nextDouble() * height;
      final radius = 1.0 + random.nextDouble() * 2.0;

      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(PaymentBackgroundPainter oldDelegate) {
    return false;
  }
}

class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;

    final cellSize = size.width / 25;

    // Draw QR code pattern (simplified)
    // Position detection patterns (corners)
    _drawPositionDetectionPattern(canvas, 0, 0, cellSize, paint);
    _drawPositionDetectionPattern(
      canvas,
      0,
      size.height - 7 * cellSize,
      cellSize,
      paint,
    );
    _drawPositionDetectionPattern(
      canvas,
      size.width - 7 * cellSize,
      0,
      cellSize,
      paint,
    );

    // Draw random data cells
    final random = math.Random(42);
    for (int i = 0; i < 25; i++) {
      for (int j = 0; j < 25; j++) {
        // Skip position detection patterns
        if ((i < 7 && j < 7) || (i < 7 && j > 17) || (i > 17 && j < 7)) {
          continue;
        }

        if (random.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(i * cellSize, j * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }
  }

  void _drawPositionDetectionPattern(
    Canvas canvas,
    double x,
    double y,
    double cellSize,
    Paint paint,
  ) {
    // Outer square
    canvas.drawRect(Rect.fromLTWH(x, y, cellSize * 7, cellSize * 7), paint);

    // Inner white square
    final whitePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(x + cellSize, y + cellSize, cellSize * 5, cellSize * 5),
      whitePaint,
    );

    // Inner black square
    canvas.drawRect(
      Rect.fromLTWH(
        x + cellSize * 2,
        y + cellSize * 2,
        cellSize * 3,
        cellSize * 3,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(QRCodePainter oldDelegate) {
    return false;
  }
}

class LoadingPainter extends CustomPainter {
  final double animation;
  final Color color;

  LoadingPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      animation * 2 * math.pi,
      false,
      paint,
    );

    final dotPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final angle = animation * 2 * math.pi - math.pi / 2;
    final x = center.dx + radius * math.cos(angle);
    final y = center.dy + radius * math.sin(angle);

    canvas.drawCircle(Offset(x, y), 6.0, dotPaint);
  }

  @override
  bool shouldRepaint(LoadingPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
