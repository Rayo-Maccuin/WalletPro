import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:simple_animations/simple_animations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF05CEA8),
          primary: const Color(0xFF05CEA8),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _documentController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showDocumentError = false;
  bool _showPasswordError = false;
  bool _showInvalidCredentialsError = false;

  // Correct credentials
  final String _correctDocument = '123456789';
  final String _correctPassword = 'admin';

  @override
  void dispose() {
    _documentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    setState(() {
      _showDocumentError = _documentController.text.isEmpty;
      _showPasswordError = _passwordController.text.isEmpty;
      _showInvalidCredentialsError = false;
    });

    // If fields are not empty, check credentials
    if (!_showDocumentError && !_showPasswordError) {
      if (_documentController.text == _correctDocument &&
          _passwordController.text == _correctPassword) {
        // Successful login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inicio de sesión exitoso'),
            backgroundColor: const Color(0xFF05CEA8),
          ),
        );
        // Navigate to home screen or dashboard
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        // Invalid credentials
        setState(() {
          _showInvalidCredentialsError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          const BankingAnimationBackground(),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF293431),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.account_balance,
                                color: const Color(0xFF05CEA8),
                                size: 30,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'WalletPro',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Login form with white background for better readability
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Show invalid credentials error if needed
                            if (_showInvalidCredentialsError)
                              Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red),
                                ),
                                child: Text(
                                  'Credenciales inválidas. Por favor, intente nuevamente.',
                                  style: TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                            // Document ID field
                            TextField(
                              controller: _documentController,
                              decoration: InputDecoration(
                                labelText: 'Documento de Identificación',
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: const Color(0xFF45AA96),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFF151616,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF05CEA8),
                                  ),
                                ),
                                errorText:
                                    _showDocumentError
                                        ? 'El campo Documento de Identificación es obligatorio'
                                        : null,
                                hintText: 'Ingrese solo números',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Password field
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: const Color(0xFF45AA96),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFF151616,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF05CEA8),
                                  ),
                                ),
                                errorText:
                                    _showPasswordError
                                        ? 'El campo Contraseña es obligatorio'
                                        : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/forgot-password',
                                  );
                                },
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                    color: const Color(0xFF45AA96),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Login button
                            ElevatedButton(
                              onPressed: _validateAndSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF05CEA8),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Credentials hint
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Documento: 123456789 | Contraseña: admin',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Register link
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF293431),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: TextButton(
                            onPressed: () {
                              // Handle registration
                            },
                            child: Text(
                              'No tienes Cuenta? Regístrate',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BankingAnimationBackground extends StatelessWidget {
  const BankingAnimationBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF293431).withOpacity(0.2),
                const Color(0xFF45AA96).withOpacity(0.3),
              ],
            ),
          ),
        ),

        // Digital wave pattern
        DigitalWaveAnimation(),

        // Falling money animation
        FallingMoneyAnimation(),

        // Credit card animation
        CreditCardAnimation(),
      ],
    );
  }
}

class DigitalWaveAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 2 * math.pi),
        duration: const Duration(seconds: 100),
        builder: (context, value, child) {
          return CustomPaint(
            painter: DigitalWavePainter(
              animation: value,
              waveColor: const Color(0xFF05CEA8).withOpacity(0.4),
            ),
          );
        },
      ),
    );
  }
}

class DigitalWavePainter extends CustomPainter {
  final double animation;
  final Color waveColor;

  DigitalWavePainter({required this.animation, required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = waveColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    final dashPaint =
        Paint()
          ..color = waveColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Draw digital wave patterns
    for (int i = 0; i < 3; i++) {
      final path = Path();
      final yOffset = size.height * (0.3 + (i * 0.2));

      path.moveTo(0, yOffset);

      double lastY = yOffset;
      double segmentLength = 20 + (i * 10);

      for (double x = 0; x < size.width; x += segmentLength) {
        final direction = math.Random(i + (animation * 10).toInt()).nextBool();
        final newY = direction ? lastY - (10 + i * 5) : lastY + (10 + i * 5);

        path.lineTo(x + segmentLength, newY);
        lastY = newY;
      }

      canvas.drawPath(path, paint);

      // Draw data points
      for (double x = segmentLength; x < size.width; x += segmentLength) {
        final y =
            path.computeMetrics().first.getTangentForOffset(x)?.position.dy ??
            yOffset;
        canvas.drawCircle(Offset(x, y), 4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DigitalWavePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class FallingMoneyAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(seconds: 100),
        builder: (context, value, child) {
          return CustomPaint(
            painter: FallingMoneyPainter(
              animation: value,
              moneyColor: const Color(0xFF45AA96),
            ),
          );
        },
      ),
    );
  }
}

class FallingMoneyPainter extends CustomPainter {
  final double animation;
  final Color moneyColor;
  final List<String> symbols = ['₿', '€', '₿'];

  FallingMoneyPainter({required this.animation, required this.moneyColor});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final numBills = 15;

    for (int i = 0; i < numBills; i++) {
      // Calculate position with animation
      final speed = 0.3 + random.nextDouble() * 0.7;
      final x = (random.nextDouble() * size.width);
      final startY = -100.0 - (i * 50);
      final y =
          (startY + (animation * speed * size.height * 2)) %
              (size.height + 200) -
          100;

      // Draw bill
      final billRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 40 + random.nextDouble() * 20,
          height: 20 + random.nextDouble() * 10,
        ),
        Radius.circular(4),
      );

      final billPaint =
          Paint()
            ..color = moneyColor.withOpacity(0.7 + random.nextDouble() * 0.3)
            ..style = PaintingStyle.fill;

      canvas.drawRRect(billRect, billPaint);

      // Draw symbol on bill
      final symbolIndex = i % symbols.length;
      final textPainter = TextPainter(
        text: TextSpan(
          text: symbols[symbolIndex],
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      final symbolX = x - textPainter.width / 2;
      final symbolY = y - textPainter.height / 2;
      textPainter.paint(canvas, Offset(symbolX, symbolY));
    }
  }

  @override
  bool shouldRepaint(FallingMoneyPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class CreditCardAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 2 * math.pi),
        duration: const Duration(seconds: 100),
        builder: (context, value, child) {
          return CustomPaint(
            painter: CreditCardPainter(
              animation: value,
              cardColor: const Color(0xFF293431),
            ),
          );
        },
      ),
    );
  }
}

class CreditCardPainter extends CustomPainter {
  final double animation;
  final Color cardColor;

  CreditCardPainter({required this.animation, required this.cardColor});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);

    // Draw multiple credit cards
    for (int i = 0; i < 3; i++) {
      final cardWidth = 120.0 + random.nextDouble() * 40;
      final cardHeight = cardWidth * 0.6;

      // Calculate position with animation
      final angle = animation + (i * math.pi * 2 / 3);
      final radius = size.width * 0.3;
      final x = (size.width / 2) + math.cos(angle) * radius;
      final y = (size.height / 2) + math.sin(angle) * radius;

      // Apply 3D rotation effect
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle * 0.5);

      // Scale based on position to create 3D effect
      final scale = 0.7 + 0.3 * math.sin(angle + animation);
      canvas.scale(scale, scale);

      // Draw card body
      final cardRect = Rect.fromCenter(
        center: Offset.zero,
        width: cardWidth,
        height: cardHeight,
      );

      final rrect = RRect.fromRectAndRadius(cardRect, Radius.circular(10));

      final cardPaint =
          Paint()
            ..color = cardColor.withOpacity(0.8)
            ..style = PaintingStyle.fill;

      canvas.drawRRect(rrect, cardPaint);

      // Draw card details
      // Magnetic stripe
      final stripePaint =
          Paint()
            ..color = const Color(0xFF05CEA8).withOpacity(0.8)
            ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(
          -cardWidth / 2,
          -cardHeight / 4,
          cardWidth,
          cardHeight / 5,
        ),
        stripePaint,
      );

      // Chip
      final chipPaint =
          Paint()
            ..color = const Color(0xFF45AA96)
            ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            -cardWidth / 3,
            -cardHeight / 3,
            cardWidth / 5,
            cardHeight / 5,
          ),
          Radius.circular(2),
        ),
        chipPaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CreditCardPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
