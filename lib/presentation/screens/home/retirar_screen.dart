import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class RetirarScreen extends StatefulWidget {
  const RetirarScreen({Key? key}) : super(key: key);

  @override
  State<RetirarScreen> createState() => _RetirarScreenState();
}

class _RetirarScreenState extends State<RetirarScreen>
    with TickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  String _selectedWithdrawalMethod = 'Cajero Automático';
  bool _isProcessing = false;
  bool _showMap = false;
  late AnimationController _animationController;
  late AnimationController _mapAnimationController;
  late Animation<double> _animation;
  late Animation<double> _mapAnimation;

  final List<String> _withdrawalMethods = [
    'Cajero Automático',
    'Transferencia a Cuenta Bancaria',
    'Punto de Retiro',
    'Corresponsal Bancario',
  ];

  final List<Map<String, dynamic>> _nearbyATMs = [
    {
      'name': 'Cajero Centro Comercial',
      'distance': '0.5 km',
      'address': 'Calle Principal #123',
      'available': true,
    },
    {
      'name': 'Cajero Plaza Central',
      'distance': '1.2 km',
      'address': 'Av. Central #456',
      'available': true,
    },
    {
      'name': 'Cajero Sucursal Norte',
      'distance': '2.3 km',
      'address': 'Calle Norte #789',
      'available': false,
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

    _mapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _mapAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mapAnimationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    _animationController.dispose();
    _mapAnimationController.dispose();
    super.dispose();
  }

  void _processWithdrawal() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el monto a retirar'),
          backgroundColor: Color(0xFF45AA96),
        ),
      );
      return;
    }

    if (_selectedWithdrawalMethod == 'Transferencia a Cuenta Bancaria' &&
        _accountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa la cuenta de destino'),
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

  void _toggleMap() {
    setState(() {
      _showMap = !_showMap;
    });

    if (_showMap) {
      _mapAnimationController.forward();
    } else {
      _mapAnimationController.reverse();
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
                Text('Retiro Procesado', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedWithdrawalMethod == 'Cajero Automático' ||
                          _selectedWithdrawalMethod == 'Punto de Retiro'
                      ? 'Tu solicitud de retiro ha sido procesada. Usa el código generado en el punto de retiro.'
                      : 'Tu solicitud de retiro ha sido procesada exitosamente.',
                  style: const TextStyle(color: Colors.white70),
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
                            'Método:',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            _selectedWithdrawalMethod,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedWithdrawalMethod == 'Cajero Automático' ||
                          _selectedWithdrawalMethod == 'Punto de Retiro') ...[
                        const Divider(color: Colors.white24),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Código:',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              '5872-3914',
                              style: TextStyle(
                                color: Color(0xFF05CEA8),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
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
                  _accountController.clear();
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
          'Retirar Dinero',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_selectedWithdrawalMethod == 'Cajero Automático' ||
              _selectedWithdrawalMethod == 'Punto de Retiro')
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: _toggleMap,
              color: _showMap ? const Color(0xFF05CEA8) : Colors.white,
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
            painter: WithdrawalBackgroundPainter(
              color: const Color(0xFF05CEA8),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 25),
                  if (_showMap) _buildMapSection(),
                  if (!_showMap) ...[
                    _buildWithdrawalForm(),
                    const SizedBox(height: 25),
                    if (_selectedWithdrawalMethod == 'Cajero Automático' ||
                        _selectedWithdrawalMethod == 'Punto de Retiro')
                      _buildNearbyATMs(),
                    const SizedBox(height: 25),
                    _buildWithdrawalButton(),
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

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF45AA96), const Color(0xFF05CEA8)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo Disponible',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '\$2,450,000',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Límite diario: \$1,000,000',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalForm() {
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
            'Información de Retiro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedWithdrawalMethod,
            decoration: InputDecoration(
              labelText: 'Método de Retiro',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(
                Icons.account_balance,
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
            style: const TextStyle(color: Colors.white),
            dropdownColor: const Color(0xFF293431),
            items:
                _withdrawalMethods.map((String method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedWithdrawalMethod = newValue;
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
              labelText: 'Monto a Retirar',
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
          if (_selectedWithdrawalMethod ==
              'Transferencia a Cuenta Bancaria') ...[
            const SizedBox(height: 15),
            TextField(
              controller: _accountController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Cuenta de Destino',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(
                  Icons.account_balance,
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
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF45AA96).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF05CEA8),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información Importante',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _selectedWithdrawalMethod == 'Cajero Automático'
                            ? 'Recibirás un código para usar en el cajero automático.'
                            : _selectedWithdrawalMethod == 'Punto de Retiro'
                            ? 'Recibirás un código para presentar en el punto de retiro.'
                            : 'El retiro se procesará en las próximas 24 horas hábiles.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyATMs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Puntos de Retiro Cercanos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _nearbyATMs.length,
          itemBuilder: (context, index) {
            final atm = _nearbyATMs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF151616),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      atm['available']
                          ? const Color(0xFF45AA96).withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          atm['available']
                              ? const Color(0xFF45AA96).withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      atm['available'] ? Icons.atm : Icons.do_not_disturb,
                      color:
                          atm['available']
                              ? const Color(0xFF05CEA8)
                              : Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          atm['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          atm['address'],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        atm['distance'],
                        style: const TextStyle(
                          color: Color(0xFF05CEA8),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        atm['available'] ? 'Disponible' : 'No Disponible',
                        style: TextStyle(
                          color:
                              atm['available']
                                  ? const Color(0xFF05CEA8)
                                  : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return AnimatedBuilder(
      animation: _mapAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _mapAnimation.value,
          child: Opacity(
            opacity: _mapAnimation.value,
            child: Container(
              width: double.infinity,
              height: 400,
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
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Puntos de Retiro Cercanos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF293431),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Color(0xFF05CEA8),
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text(
                                '3 Encontrados',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      child: CustomPaint(
                        size: const Size(double.infinity, double.infinity),
                        painter: MapPainter(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWithdrawalButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _processWithdrawal,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF05CEA8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: const Text(
          'RETIRAR AHORA',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
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
              'Procesando Retiro...',
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

class WithdrawalBackgroundPainter extends CustomPainter {
  final Color color;

  WithdrawalBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final paint =
        Paint()
          ..color = color.withOpacity(0.05)
          ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(width * 0.7, 0);
    path.quadraticBezierTo(width * 0.9, height * 0.1, width, height * 0.05);
    path.lineTo(width, height * 0.3);
    path.quadraticBezierTo(
      width * 0.8,
      height * 0.25,
      width * 0.5,
      height * 0.3,
    );
    path.quadraticBezierTo(width * 0.2, height * 0.35, 0, height * 0.2);
    path.close();

    canvas.drawPath(path, paint);

    final bottomPath = Path();
    bottomPath.moveTo(width, height);
    bottomPath.lineTo(width * 0.3, height);
    bottomPath.quadraticBezierTo(width * 0.1, height * 0.9, 0, height * 0.95);
    bottomPath.lineTo(0, height * 0.7);
    bottomPath.quadraticBezierTo(
      width * 0.2,
      height * 0.75,
      width * 0.5,
      height * 0.7,
    );
    bottomPath.quadraticBezierTo(
      width * 0.8,
      height * 0.65,
      width,
      height * 0.8,
    );
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
  bool shouldRepaint(WithdrawalBackgroundPainter oldDelegate) {
    return false;
  }
}

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Background
    final backgroundPaint =
        Paint()
          ..color = const Color(0xFF293431)
          ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), backgroundPaint);

    // Grid lines
    final gridPaint =
        Paint()
          ..color = const Color(0xFF45AA96).withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    for (int i = 0; i < 20; i++) {
      final y = i * height / 20;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    for (int i = 0; i < 20; i++) {
      final x = i * width / 20;
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }

    // Roads
    final roadPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8.0;

    // Horizontal road
    canvas.drawLine(
      Offset(0, height * 0.5),
      Offset(width, height * 0.5),
      roadPaint,
    );

    // Vertical road 1
    canvas.drawLine(
      Offset(width * 0.3, 0),
      Offset(width * 0.3, height),
      roadPaint,
    );

    // Vertical road 2
    canvas.drawLine(
      Offset(width * 0.7, 0),
      Offset(width * 0.7, height),
      roadPaint,
    );

    // ATM locations
    final atmPaint =
        Paint()
          ..color = const Color(0xFF05CEA8)
          ..style = PaintingStyle.fill;

    final atmBorderPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    // ATM 1
    canvas.drawCircle(Offset(width * 0.3, height * 0.3), 10, atmPaint);
    canvas.drawCircle(Offset(width * 0.3, height * 0.3), 10, atmBorderPaint);

    // ATM 2
    canvas.drawCircle(Offset(width * 0.7, height * 0.5), 10, atmPaint);
    canvas.drawCircle(Offset(width * 0.7, height * 0.5), 10, atmBorderPaint);

    // ATM 3 (unavailable)
    final unavailablePaint =
        Paint()
          ..color = Colors.red.withOpacity(0.7)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(width * 0.5, height * 0.7), 10, unavailablePaint);
    canvas.drawCircle(Offset(width * 0.5, height * 0.7), 10, atmBorderPaint);

    // Current location
    final locationPaint =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;
    final locationBorderPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(width * 0.5, height * 0.5), 12, locationPaint);
    canvas.drawCircle(
      Offset(width * 0.5, height * 0.5),
      12,
      locationBorderPaint,
    );

    // Pulse effect
    final pulsePaint =
        Paint()
          ..color = Colors.blue.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(width * 0.5, height * 0.5), 20, pulsePaint);
    canvas.drawCircle(
      Offset(width * 0.5, height * 0.5),
      30,
      pulsePaint..color = Colors.blue.withOpacity(0.1),
    );
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) {
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
