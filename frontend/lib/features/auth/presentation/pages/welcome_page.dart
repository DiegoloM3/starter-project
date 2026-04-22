import 'dart:math';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

class WelcomePage extends StatefulWidget {
  final UserEntity user;
  const WelcomePage({super.key, required this.user});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Auto-navigate to Feed after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/DailyNews');
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
    return Scaffold(
      backgroundColor: const Color(0xFF03050F),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Pulse
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: CyberPulsePainter(_controller.value),
                size: Size.infinite,
              );
            },
          ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Hero(
                tag: 'logo',
                child: Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 80),
              ),
              const SizedBox(height: 30),
              Text(
                'BIENVENIDO, ${widget.user.displayName?.toUpperCase() ?? "AGENTE"}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  fontFamily: 'Muli',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'SINCRONIZANDO CON LA RED SYMMETRY...',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CyberPulsePainter extends CustomPainter {
  final double animationValue;
  CyberPulsePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.8;

    for (int i = 0; i < 5; i++) {
      final pulseValue = (animationValue + (i / 5.0)) % 1.0;
      final radius = pulseValue * maxRadius;
      final opacity = (1.0 - pulseValue).clamp(0.0, 1.0);
      
      final paint = Paint()
        ..color = Colors.cyanAccent.withOpacity(opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius, paint);
      
      // Add neon glow effect dots
      for(int j = 0; j < 8; j++) {
        double angle = (j * pi / 4) + (animationValue * pi);
        Offset dotPos = Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle)
        );
        canvas.drawCircle(dotPos, 2, Paint()..color = Colors.cyanAccent.withOpacity(opacity));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
