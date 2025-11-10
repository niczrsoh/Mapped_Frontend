import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:mapped_frontend/screens/belt_progress_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1a1d2e),
      ),
      home: const BeltDashboardScreen(),
    );
  }
}

class BeltDashboardScreen extends StatelessWidget {
  const BeltDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1d2e),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            // Belt Cards
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildBeltCard(
                    context: context,
                    beltName: 'White Belt',
                    percentage: 75,
                    trainees: 8,
                    color: Colors.white,
                    runTime: '4h',
                    exerciseTime: '30min',
                  ),
                  const SizedBox(height: 16),
                  _buildBeltCard(
                    context: context,
                    beltName: 'Yellow Belt',
                    percentage: 30,
                    trainees: 3,
                    color: Color(0xFFFFD700),
                    runTime: '4h',
                    exerciseTime: '30min',
                  ),
                  const SizedBox(height: 16),
                  _buildBeltCard(
                    context: context,
                    beltName: 'Green Belt',
                    percentage: 55,
                    trainees: 6,
                    color: Color(0xFF4CAF50),
                    runTime: '4h',
                    exerciseTime: '30min',
                  ),
                  const SizedBox(height: 16),
                  _buildBeltCard(
                    context: context,
                    beltName: 'Blue Belt',
                    percentage: 85,
                    trainees: 12,
                    color: Color(0xFF2196F3),
                    runTime: '4h',
                    exerciseTime: '30min',
                  ),
                  const SizedBox(height: 16),
                  _buildBeltCard(
                    context: context,
                    beltName: 'Red Belt',
                    percentage: 45,
                    trainees: 4,
                    color: Color(0xFFE53935),
                    runTime: '4h',
                    exerciseTime: '30min',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeltCard({
    required BuildContext context,
    required String beltName,
    required int percentage,
    required int trainees,
    required Color color,
    required String runTime,
    required String exerciseTime,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BeltProgressScreen(
            ),
          ),
        );
      },
      child: BeltCard(
        beltName: beltName,
        percentage: percentage,
        trainees: trainees,
        color: color,
        runTime: runTime,
        exerciseTime: exerciseTime,
      ),
    );
  }
}

class BeltCard extends StatelessWidget {
  final String beltName;
  final int percentage;
  final int trainees;
  final Color color;
  final String runTime;
  final String exerciseTime;

  const BeltCard({
    Key? key,
    required this.beltName,
    required this.percentage,
    required this.trainees,
    required this.color,
    required this.runTime,
    required this.exerciseTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Circular Progress Indicator and Trainees Count in a Column
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Progress
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(80, 80),
                      painter: CircularProgressPainter(
                        percentage: percentage,
                        color: color,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Trainees Count below the circular progress
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$trainees Trainees',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Belt Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  beltName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.directions_run,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Run ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      runTime,
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.fitness_center,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Exercises ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      exerciseTime,
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final int percentage;
  final Color color;

  CircularProgressPainter({
    required this.percentage,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 4, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}