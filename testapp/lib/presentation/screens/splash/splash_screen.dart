import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({Key? key, required this.nextScreen}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _waveController;
  late AnimationController _particleController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideUpAnimation;
  late Animation<double> _slideDownAnimation;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fadeInAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_mainController);

    _slideUpAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _slideDownAnimation = Tween<double>(begin: -30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _mainController.forward();

    Timer(const Duration(milliseconds: 3500), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => widget.nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _waveController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF151616),
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(size.width, size.height),
                painter: WaveBackgroundPainter(
                  animation: _waveController.value,
                  primaryColor: const Color(0xFF293431),
                  accentColor: const Color(0xFF05CEA8),
                ),
              );
            },
          ),

          // Animated particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(size.width, size.height),
                painter: ParticlesPainter(
                  animation: _particleController.value,
                  color: const Color(0xFF05CEA8),
                ),
              );
            },
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeInAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: _buildLogo(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Title
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeInAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideUpAnimation.value),
                        child: _buildTitle(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                // Features
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeInAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideDownAnimation.value),
                        child: _buildFeatures(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Progress indicator
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeInAnimation.value,
                  child: Center(child: _buildProgressIndicator()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF293431), const Color(0xFF151616)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF05CEA8).withOpacity(0.3),
            blurRadius: 25,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Outer ring
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF05CEA8).withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
          ),

          // Inner ring
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF05CEA8).withOpacity(0.7),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // Center icon
          Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF151616),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(40, 40),
                  painter: DigitalWalletPainter(color: const Color(0xFF05CEA8)),
                ),
              ),
            ),
          ),

          // Animated dots
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(130, 130),
                painter: OrbitingDotsPainter(
                  animation: _particleController.value,
                  color: const Color(0xFF05CEA8),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF05CEA8), Color(0xFF45AA96)],
            ).createShader(bounds);
          },
          child: const Text(
            'WalletPro',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF293431),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF05CEA8).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Text(
            'Finanzas Digitales Inteligentes',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF05CEA8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFeatureItem(Icons.security, 'Seguridad'),
        const SizedBox(width: 30),
        _buildFeatureItem(Icons.speed, 'Rapidez'),
        const SizedBox(width: 30),
        _buildFeatureItem(Icons.trending_up, 'Crecimiento'),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF293431),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF05CEA8).withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF05CEA8), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 200,
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              backgroundColor: const Color(0xFF293431),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF05CEA8),
              ),
              value: _mainController.value,
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Cargando tu experiencia financiera',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class WaveBackgroundPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;

  WaveBackgroundPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Background gradient
    final backgroundPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, const Color(0xFF151616)],
          ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), backgroundPaint);

    // Draw waves
    final wavePaint =
        Paint()
          ..color = accentColor.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    // Top wave
    final topWavePath = Path();
    topWavePath.moveTo(0, 0);
    topWavePath.lineTo(0, height * 0.3);

    for (double x = 0; x <= width; x += width / 10) {
      final waveHeight = height * 0.05;
      final y =
          height * 0.3 +
          math.sin((x / width * 2 * math.pi) + animation * 2 * math.pi) *
              waveHeight;
      topWavePath.lineTo(x, y);
    }

    topWavePath.lineTo(width, height * 0.3);
    topWavePath.lineTo(width, 0);
    topWavePath.close();

    canvas.drawPath(topWavePath, wavePaint);

    // Bottom wave
    final bottomWavePath = Path();
    bottomWavePath.moveTo(0, height);
    bottomWavePath.lineTo(0, height * 0.7);

    for (double x = 0; x <= width; x += width / 10) {
      final waveHeight = height * 0.05;
      final y =
          height * 0.7 +
          math.sin(
                (x / width * 2 * math.pi) + animation * 2 * math.pi + math.pi,
              ) *
              waveHeight;
      bottomWavePath.lineTo(x, y);
    }

    bottomWavePath.lineTo(width, height * 0.7);
    bottomWavePath.lineTo(width, height);
    bottomWavePath.close();

    canvas.drawPath(bottomWavePath, wavePaint);

    // Draw grid lines
    final gridPaint =
        Paint()
          ..color = accentColor.withOpacity(0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    // Horizontal grid lines
    for (int i = 0; i < 10; i++) {
      final y = i * height / 10;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Vertical grid lines
    for (int i = 0; i < 10; i++) {
      final x = i * width / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }

    // Draw data points
    final dotPaint =
        Paint()
          ..color = accentColor.withOpacity(0.2)
          ..style = PaintingStyle.fill;

    final random = math.Random(42);
    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * width;
      final y = random.nextDouble() * height;
      final radius = 1.0 + random.nextDouble() * 1.5;

      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(WaveBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class ParticlesPainter extends CustomPainter {
  final double animation;
  final Color color;
  final int particleCount = 20;

  ParticlesPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final random = math.Random(42);

    for (int i = 0; i < particleCount; i++) {
      final seed = i * 1000;
      final particleRandom = math.Random(seed);

      final baseX = particleRandom.nextDouble() * width;
      final baseY = particleRandom.nextDouble() * height;

      final amplitude = 20.0 + particleRandom.nextDouble() * 30.0;
      final period = 3.0 + particleRandom.nextDouble() * 5.0;
      final phase = particleRandom.nextDouble() * 2 * math.pi;

      final x =
          baseX +
          math.sin(animation * 2 * math.pi / period + phase) * amplitude;
      final y =
          baseY +
          math.cos(animation * 2 * math.pi / period + phase) * amplitude;

      final size = 1.0 + particleRandom.nextDouble() * 2.0;
      final opacity =
          0.1 + 0.2 * math.cos(math.sin(animation * 2 * math.pi + i));

      final particlePaint =
          Paint()
            ..color = color.withOpacity(opacity)
            ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), size, particlePaint);

      // Draw connecting lines between some particles
      if (i > 0 && i % 3 == 0) {
        final prevSeed = (i - 1) * 1000;
        final prevRandom = math.Random(prevSeed);

        final prevBaseX = prevRandom.nextDouble() * width;
        final prevBaseY = prevRandom.nextDouble() * height;

        final prevAmplitude = 20.0 + prevRandom.nextDouble() * 30.0;
        final prevPeriod = 3.0 + prevRandom.nextDouble() * 5.0;
        final prevPhase = prevRandom.nextDouble() * 2 * math.pi;

        final prevX =
            prevBaseX +
            math.sin(animation * 2 * math.pi / prevPeriod + prevPhase) *
                prevAmplitude;
        final prevY =
            prevBaseY +
            math.cos(animation * 2 * math.pi / prevPeriod + prevPhase) *
                prevAmplitude;

        final distance = math.sqrt(
          math.pow(x - prevX, 2) + math.pow(y - prevY, 2),
        );

        if (distance < 100) {
          final linePaint =
              Paint()
                ..color = color.withOpacity(
                  opacity * 0.3 * (1 - distance / 100),
                )
                ..style = PaintingStyle.stroke
                ..strokeWidth = 0.5;

          canvas.drawLine(Offset(x, y), Offset(prevX, prevY), linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class DigitalWalletPainter extends CustomPainter {
  final Color color;

  DigitalWalletPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;

    final fillPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.7)],
          ).createShader(Rect.fromLTWH(0, 0, width, height))
          ..style = PaintingStyle.fill;

    // Draw digital wallet icon
    final walletPath = Path();

    // Main wallet body
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(width * 0.15, height * 0.25, width * 0.7, height * 0.5),
      Radius.circular(width * 0.05),
    );

    // Card inside wallet
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(width * 0.25, height * 0.35, width * 0.5, height * 0.25),
      Radius.circular(width * 0.03),
    );

    // Draw wallet
    canvas.drawRRect(rect, paint);

    // Draw card
    canvas.drawRRect(cardRect, fillPaint);

    // Draw digital elements
    final dotSize = width * 0.03;

    // Digital dots on card
    canvas.drawCircle(Offset(width * 0.35, height * 0.47), dotSize, paint);

    canvas.drawCircle(Offset(width * 0.45, height * 0.47), dotSize, paint);

    canvas.drawCircle(Offset(width * 0.55, height * 0.47), dotSize, paint);

    canvas.drawCircle(Offset(width * 0.65, height * 0.47), dotSize, paint);

    // Digital signal
    final signalPath = Path();
    signalPath.moveTo(width * 0.3, height * 0.65);
    signalPath.lineTo(width * 0.4, height * 0.65);
    signalPath.moveTo(width * 0.45, height * 0.65);
    signalPath.lineTo(width * 0.7, height * 0.65);

    canvas.drawPath(signalPath, paint);

    // Digital arrow (growth)
    final arrowPath = Path();
    arrowPath.moveTo(width * 0.7, height * 0.3);
    arrowPath.lineTo(width * 0.7, height * 0.2);
    arrowPath.lineTo(width * 0.8, height * 0.2);

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(DigitalWalletPainter oldDelegate) {
    return false;
  }
}

class OrbitingDotsPainter extends CustomPainter {
  final double animation;
  final Color color;

  OrbitingDotsPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height / 2);
    final radius = width / 2;

    final dotCount = 8;
    final dotPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    for (int i = 0; i < dotCount; i++) {
      final angle = 2 * math.pi * i / dotCount + animation * 2 * math.pi;
      final dotRadius = 3.0;
      final distance = radius - 5;

      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      final opacity = 0.3 + 0.7 * ((i / dotCount + animation) % 1.0);
      dotPaint.color = color.withOpacity(opacity);

      canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(OrbitingDotsPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
