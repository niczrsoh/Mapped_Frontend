import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/screens/belt_progress_screen.dart';
import '../../controller/controller/belt_progress_ring_controller.dart';
import '../../controller/controller/trainee_controller.dart';
import 'belt_detail_screen.dart';

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
    // Inject Controller
    final TraineeController controller = Get.put(TraineeController());
    // === NEW CONTROLLER INJECTION ===
    final BeltProgressRingController ringController = Get.put(
      BeltProgressRingController(),
    );
    // Helper to get count
    int _getTraineeCount(String beltName) {
      
      String cleanName = beltName.replaceAll(' Belt', '');

      return controller.traineeList.where((t) {
        return t['belt'].toString().toLowerCase() == cleanName.toLowerCase();
      }).length;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1114),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Home',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      "Dashboard",
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      // Wrap body in Obx to listen to controller changes
      body: Obx(
        () => SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildBeltCard(
                      context: context,
                      beltName: 'White Belt',
                      // === USE CONTROLLER DATA ===
                      percentage: ringController.getPercentage('White'),
                      trainees: _getTraineeCount('White'), // Dynamic Count
                      color: Colors.white,
                      runTime: '4h',
                      exerciseTime: '30min',
                    ),
                    const SizedBox(height: 16),
                    _buildBeltCard(
                      context: context,
                      beltName: 'Yellow Belt',
                      percentage: ringController.getPercentage('Yellow'),
                      trainees: _getTraineeCount('Yellow'), // Dynamic Count
                      color: const Color(0xFFFFD700),
                      runTime: '4h',
                      exerciseTime: '30min',
                    ),
                    const SizedBox(height: 16),
                    _buildBeltCard(
                      context: context,
                      beltName: 'Green Belt',
                      percentage: ringController.getPercentage('Green'),
                      trainees: _getTraineeCount('Green'), // Dynamic Count
                      color: const Color(0xFF4CAF50),
                      runTime: '4h',
                      exerciseTime: '30min',
                    ),
                    const SizedBox(height: 16),
                    _buildBeltCard(
                      context: context,
                      beltName: 'Blue Belt',
                      percentage: ringController.getPercentage('Blue'),
                      trainees: _getTraineeCount('Blue'), // Dynamic Count
                      color: const Color(0xFF2196F3),
                      runTime: '4h',
                      exerciseTime: '30min',
                    ),
                    const SizedBox(height: 16),
                    _buildBeltCard(
                      context: context,
                      beltName: 'Brown Belt',
                      percentage: ringController.getPercentage('Brown'),
                      trainees: _getTraineeCount('Brown'), // Dynamic Count
                      color: const Color(0xFFA52A2A),
                      runTime: '4h',
                      exerciseTime: '30min',
                    ),
                    const SizedBox(height: 16),
                    _buildBeltCard(
                      context: context,
                      beltName: 'Black Belt',
                      percentage: ringController.getPercentage('Black'),
                      trainees: _getTraineeCount('Black'), // Dynamic Count
                      color: const Color(0xFF000000),
                      runTime: '4h',
                      exerciseTime: '30min',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBeltCard({
    required BuildContext context,
    // required BeltProgressRingController ringController, <--- REMOVED THIS LINE (Cause of error)
    required String beltName,
    required int percentage,
    required int trainees,
    required Color color,
    required String runTime,
    required String exerciseTime,
  }) {
    // Helper to get clean name for navigation params
    String cleanName = beltName.replaceAll(' Belt', '');

    return GestureDetector(
      onTap: () {
        Get.to(() => BeltProgressScreen(beltName: cleanName, beltColor: color));
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

  static const double borderThickness = 1.5;
  final LinearGradient customGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.white, Color(0xFA00FFA6)],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: customGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(borderThickness),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141823),
          borderRadius: BorderRadius.circular(24 - borderThickness),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F3238),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SizedBox(
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
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$trainees Trainees',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          beltName,
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_run,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Run ',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        runTime,
                        style: GoogleFonts.roboto(
                          color: const Color(0xFF00FFA6),
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 1.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Exercises ',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        exerciseTime,
                        style: GoogleFonts.roboto(
                          color: const Color(0xFF00FFA6),
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 1.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final int percentage;
  final Color color;

  CircularProgressPainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final basePaint = Paint()
      ..color = Colors.grey.shade800.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, basePaint);

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 10 / 2, backgroundPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (percentage / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10 / 2),
      0,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
