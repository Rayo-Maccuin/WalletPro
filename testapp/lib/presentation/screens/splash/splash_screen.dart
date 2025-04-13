import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:simple_animations/simple_animations.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({Key? key, required this.nextScreen}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _particleAnimationController;
  late AnimationController _waveAnimationController;
  late AnimationController _textAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _fadeAnimation;

  final List<CurrencyParticle> _particles = [];
  final int _numParticles = 30;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _initParticles();

    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();

    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_logoAnimationController);

    _logoRotateAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -0.1,
          end: 0.1,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.1,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_logoAnimationController);

    _textSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeIn),
    );

    _logoAnimationController.forward().then((_) {
      _textAnimationController.forward();
    });

    Timer(const Duration(milliseconds: 4500), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => widget.nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            const curve = Curves.easeInOut;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var fadeAnimation = animation.drive(tween);

            return FadeTransition(opacity: fadeAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  void _initParticles() {
    final random = math.Random();
    for (int i = 0; i < _numParticles; i++) {
      _particles.add(
        CurrencyParticle(
          x: random.nextDouble() * 400 - 200,
          y: random.nextDouble() * 400 - 200,
          size: 5 + random.nextDouble() * 15,
          speed: 0.5 + random.nextDouble() * 1.5,
          angle: random.nextDouble() * 2 * math.pi,
          symbol: _getRandomCurrencySymbol(random),
          opacity: 0.1 + random.nextDouble() * 0.4,
          rotationSpeed: (random.nextDouble() - 0.5) * 0.05,
        ),
      );
    }
  }

  String _getRandomCurrencySymbol(math.Random random) {
    final symbols = ['₿', '€', '\$', '£', '¥', '₽', '₹', '₺', '₴', '₸'];
    return symbols[random.nextInt(symbols.length)];
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _particleAnimationController.dispose();
    _waveAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF151616),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _waveAnimationController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(size.width, size.height),
                painter: WavePainter(
                  animation: _waveAnimationController.value,
                  color1: const Color(0xFF293431),
                  color2: const Color(0xFF151616),
                  accentColor: const Color(0xFF05CEA8),
                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: _particleAnimationController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(size.width, size.height),
                painter: ParticlesPainter(
                  particles: _particles,
                  animation: _particleAnimationController.value,
                  primaryColor: const Color(0xFF45AA96),
                  accentColor: const Color(0xFF05CEA8),
                ),
              );
            },
          ),

          CustomPaint(
            size: Size(size.width, size.height),
            painter: NetworkLinesPainter(
              color: const Color(0xFF45AA96).withOpacity(0.15),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _logoAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Transform.rotate(
                        angle: _logoRotateAnimation.value,
                        child: _buildFinancialLogo(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                AnimatedBuilder(
                  animation: _textAnimationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _textSlideAnimation.value),
                        child: _buildText(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                AnimatedBuilder(
                  animation: _textAnimationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: _buildLoadingIndicator(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF151616),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF05CEA8).withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF05CEA8).withOpacity(0.7),
                    const Color(0xFF05CEA8).withOpacity(0.0),
                  ],
                  stops: const [0.1, 1.0],
                ),
              ),
            ),
          ),

          Center(
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF05CEA8), const Color(0xFF45AA96)],
                ).createShader(bounds);
              },
              child: CustomPaint(
                size: const Size(60, 60),
                painter: FinancialGraphPainter(),
              ),
            ),
          ),

          ...List.generate(8, (index) {
            final angle = index * (math.pi / 4);
            return AnimatedBuilder(
              animation: _logoAnimationController,
              builder: (context, child) {
                final progress = _logoAnimationController.value;
                final delay = index * 0.1;
                final animationValue = (progress - delay).clamp(0.0, 1.0);

                return Positioned(
                  left: 60 + math.cos(angle) * 50 * animationValue,
                  top: 60 + math.sin(angle) * 50 * animationValue,
                  child: Opacity(
                    opacity: animationValue,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF05CEA8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF05CEA8).withOpacity(0.5),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildText() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF05CEA8), const Color(0xFF45AA96)],
            ).createShader(bounds);
          },
          child: const Text(
            'WalletPro',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Tu dinero, tu control',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: LoadingIndicatorPainter(
          animation: _textAnimationController.value,
          color: const Color(0xFF05CEA8),
        ),
      ),
    );
  }
}

class FinancialGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;

    final path = Path();

    path.moveTo(0, height * 0.7);
    path.lineTo(width * 0.2, height * 0.5);
    path.lineTo(width * 0.4, height * 0.8);
    path.lineTo(width * 0.6, height * 0.2);
    path.lineTo(width * 0.8, height * 0.4);
    path.lineTo(width, height * 0.3);

    canvas.drawPath(path, paint);

    final circlePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(width * 0.6, height * 0.2), 4, circlePaint);

    final gridPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    for (int i = 1; i < 4; i++) {
      final y = height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    for (int i = 1; i < 4; i++) {
      final x = width * (i / 4);
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class WavePainter extends CustomPainter {
  final double animation;
  final Color color1;
  final Color color2;
  final Color accentColor;

  WavePainter({
    required this.animation,
    required this.color1,
    required this.color2,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color1, color2],
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    final wavePaint =
        Paint()
          ..color = accentColor.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final path = Path();
      final waveHeight = 100.0 - (i * 20.0);
      final frequency = 0.015 - (i * 0.002);
      final phase = animation * 2 * math.pi + (i * math.pi / 2);

      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x++) {
        final y =
            size.height * 0.5 +
            math.sin(x * frequency + phase) * waveHeight +
            (i * 50.0);
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(path, wavePaint);
    }

    final accentPath = Path();
    final accentPaint =
        Paint()
          ..color = accentColor.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    accentPath.moveTo(0, size.height * 0.5);

    for (double x = 0; x <= size.width; x++) {
      final y =
          size.height * 0.5 +
          math.sin(x * 0.01 + animation * 2 * math.pi) * 50.0;
      accentPath.lineTo(x, y);
    }

    canvas.drawPath(accentPath, accentPaint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class CurrencyParticle {
  double x;
  double y;
  double size;
  double speed;
  double angle;
  String symbol;
  double opacity;
  double rotation = 0;
  double rotationSpeed;

  CurrencyParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
    required this.symbol,
    required this.opacity,
    required this.rotationSpeed,
  });

  void update(double delta, Size size) {
    x += math.cos(angle) * speed * delta * 60;
    y += math.sin(angle) * speed * delta * 60;
    rotation += rotationSpeed * delta * 60;

    if (x < -size.width / 2) x = size.width / 2;
    if (x > size.width / 2) x = -size.width / 2;
    if (y < -size.height / 2) y = size.height / 2;
    if (y > size.height / 2) y = -size.height / 2;
  }
}

class ParticlesPainter extends CustomPainter {
  final List<CurrencyParticle> particles;
  final double animation;
  final Color primaryColor;
  final Color accentColor;

  ParticlesPainter({
    required this.particles,
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    for (var particle in particles) {
      particle.update(0.016, size);

      final textPainter = TextPainter(
        text: TextSpan(
          text: particle.symbol,
          style: TextStyle(
            color: _getParticleColor(particle).withOpacity(particle.opacity),
            fontSize: particle.size,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    canvas.restore();
  }

  Color _getParticleColor(CurrencyParticle particle) {
    final t = (math.sin(animation * 2 * math.pi + particle.x * 0.01) + 1) / 2;
    return Color.lerp(primaryColor, accentColor, t)!;
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class NetworkLinesPainter extends CustomPainter {
  final Color color;
  final int numPoints = 20;
  final int numConnections = 40;

  NetworkLinesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final points = <Offset>[];

    for (int i = 0; i < numPoints; i++) {
      points.add(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
      );
    }

    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    for (int i = 0; i < numConnections; i++) {
      final p1 = points[random.nextInt(points.length)];
      final p2 = points[random.nextInt(points.length)];

      if ((p1 - p2).distance < size.width * 0.3) {
        canvas.drawLine(p1, p2, paint);
      }
    }

    final pointPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    for (var point in points) {
      canvas.drawCircle(point, 2.0, pointPaint);
    }
  }

  @override
  bool shouldRepaint(NetworkLinesPainter oldDelegate) {
    return false;
  }
}

class LoadingIndicatorPainter extends CustomPainter {
  final double animation;
  final Color color;

  LoadingIndicatorPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bgPaint =
        Paint()
          ..color = color.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;

    final progressRect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * animation;

    canvas.drawArc(progressRect, startAngle, sweepAngle, false, progressPaint);

    final numDots = 8;
    final dotPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    for (int i = 0; i < numDots; i++) {
      final angle = 2 * math.pi * i / numDots - math.pi / 2;
      final dotRadius =
          2.0 + (i == (animation * numDots).floor() % numDots ? 2.0 : 0.0);
      final dotCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      canvas.drawCircle(dotCenter, dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(LoadingIndicatorPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
