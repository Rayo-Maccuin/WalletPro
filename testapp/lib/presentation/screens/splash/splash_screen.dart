import 'dart:async';
import 'package:flutter/material.dart';
import 'package:testapp/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key, required LoginScreen nextScreen})
    : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool showSplash = true;
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pathAnimation;

  // Definición de la nueva paleta de colores
  final Color backgroundColor = const Color(0xFF151616);
  final Color darkGreen = const Color(0xFF293431);
  final Color mediumTurquoise = const Color(0xFF45AA96);
  final Color brightTurquoise = const Color(0xFF05CEA8);

  final List<int> chartData = [25, 40, 30, 50, 35, 60, 45, 70, 55, 80];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.elasticOut),
      ),
    );

    _pathAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() {
          showSplash = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!showSplash) {
      return const LoginScreen();
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 256,
                      height: 128,
                      margin: const EdgeInsets.only(bottom: 32),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(
                                chartData.length,
                                (index) => AnimatedContainer(
                                  duration: Duration(
                                    milliseconds: 500 + (index * 50),
                                  ),
                                  width: 8,
                                  height:
                                      chartData[index] * _fadeInAnimation.value,
                                  decoration: BoxDecoration(
                                    color: brightTurquoise,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(2),
                                      topRight: Radius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          CustomPaint(
                            size: const Size(256, 128),
                            painter: ChartLinePainter(
                              chartData: chartData,
                              progress: _pathAnimation.value,
                              lineColor: brightTurquoise,
                            ),
                          ),

                          Center(
                            child: Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.attach_money,
                                    size: 40,
                                    color: mediumTurquoise,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.7, 1.0),
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Wallet',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: 'Pro',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: brightTurquoise,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.8, 1.0),
                      ),
                      child: Text(
                        'Análisis financiero empresarial',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.9, 1.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFeatureIcon(Icons.bar_chart, 'Inversiones', 0),
                          const SizedBox(width: 24),
                          _buildFeatureIcon(
                            Icons.show_chart,
                            'Presupuestos',
                            1,
                          ),
                          const SizedBox(width: 24),
                          _buildFeatureIcon(Icons.pie_chart, 'Reportes', 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 20, end: 0),
      duration: const Duration(milliseconds: 500),
      onEnd: () {},
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Opacity(
            opacity: 1 - (value / 20),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: darkGreen,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: brightTurquoise.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Icon(icon, size: 24, color: brightTurquoise),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ChartLinePainter extends CustomPainter {
  final List<int> chartData;
  final double progress;
  final Color lineColor;

  ChartLinePainter({
    required this.chartData,
    required this.progress,
    this.lineColor = const Color(0xFF05CEA8),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;

    final segmentWidth = width / (chartData.length - 1);

    path.moveTo(0, height - (chartData[0] / 100 * height));

    for (int i = 1; i < chartData.length; i++) {
      path.lineTo(i * segmentWidth, height - (chartData[i] / 100 * height));
    }

    final pathMetrics = path.computeMetrics().first;
    final extractPath = pathMetrics.extractPath(
      0,
      pathMetrics.length * progress,
    );

    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(ChartLinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.lineColor != lineColor;
  }
}
