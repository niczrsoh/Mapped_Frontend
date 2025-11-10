import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'button_navigationbar_screen.dart';

class BeltProgressScreen extends StatelessWidget {
  const BeltProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBg = const Color(0xFF0F1114);
    final double progress = 0.75;
    // dial sizing
    final double dialSize = 160; // inner dial square used for painting
    final double dialStroke =
        22.0; // reduced thickness of the outer ring (was 28.0)
    final double dialRadiusOffset = 6.0; // positive moves the ring outward
    // horizontal bar sizing
    final double barWidth = 240;
    final double thumbSize = 24;

    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Dashboard',
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
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF141823),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Belt Progress',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Circular progress (custom painted to match reference)
                Center(
                  child: Container(
                    width: 220,
                    height: 220,
                    // removed outermost circular decoration per request so the painter
                    // renders without the extra background circle
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: dialSize,
                          height: dialSize,
                          child: CustomPaint(
                            painter: _BeltDialPainter(
                              progress: progress.clamp(0.0, 1.0),
                              strokeWidth: dialStroke,
                              thumbSize: thumbSize,
                              ringOffset: dialRadiusOffset,
                            ),
                          ),
                        ),
                        // Updated text layout to match the image exactly
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(progress * 100).round()}%',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 24, // Slightly larger for emphasis
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ), // Space between percentage and WHITE
                            Text(
                              'WHITE',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ), // Small space between WHITE and BELT
                            Text(
                              'BELT',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Horizontal progress bar
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: barWidth,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Stack(
                            children: [
                              FractionallySizedBox(
                                widthFactor: progress.clamp(0.0, 1.0),
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xFFFFFFFF),
                                        Color(0xFFDDDDDD),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                              ),
                              Positioned(
                                left:
                                    ((barWidth * progress).clamp(
                                      0.0,
                                      barWidth,
                                    )) -
                                    (thumbSize / 2),
                                top: -4,
                                child: IgnorePointer(
                                  child: Container(
                                    width: thumbSize,
                                    height: thumbSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.25),
                                          blurRadius: 8,
                                          spreadRadius: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Table container without any horizontal lines
                Container(
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141823),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 16, 8),
                        child: Text(
                          'White Belt',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141823),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 56),
                            Expanded(
                              child: Text(
                                'Name',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              'Progress',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _tableRowWithAvatar(
                        'Rayyan Firas',
                        '90%',
                        avatar: 'assets/images/w1.png',
                      ),
                      _tableRowWithAvatar(
                        'Siti Zaleha',
                        '85%',
                        avatar: 'assets/images/w2.png',
                      ),
                      _tableRowWithAvatar(
                        'Ahmad Firdaus',
                        '55%',
                        avatar: 'assets/images/w3.png',
                      ),
                      _tableRowWithAvatar(
                        'Nisa Nuraini',
                        '40%',
                        avatar: 'assets/images/w4.png',
                      ),
                      _tableRowWithAvatar(
                        'Mohd Faisal',
                        '30%',
                        avatar: 'assets/images/w5.png',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: const bottomNav(),
    );
  }

  Widget _tableRowWithAvatar(String name, String progress, {String? avatar}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              avatar ?? 'assets/images/accountLogo.png',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            ),
          ),
          Text(
            progress,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BeltDialPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final double thumbSize;
  final double ringOffset;

  _BeltDialPainter({
    required this.progress,
    required this.strokeWidth,
    required this.thumbSize,
    this.ringOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2) + ringOffset;

    // outer soft glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.06)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(center, radius + strokeWidth * 0.4, glowPaint);

    // base ring (non-progress) — changed to a neutral grey for clarity
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color.fromARGB(
        255,
        52,
        51,
        51,
      ); // grey (Material Grey 400)
    canvas.drawCircle(center, radius, basePaint);

    // inner vignette (dark center)
    final innerRadius = radius - strokeWidth * 0.6;
    final innerShader = ui.Gradient.radial(
      center,
      innerRadius,
      [const Color(0x00000000), const Color(0xFF000000).withOpacity(0.4)],
      [0.0, 1.0],
    );
    final innerPaint = Paint()..shader = innerShader;
    canvas.drawCircle(center, innerRadius, innerPaint);

    // progress arc (clockwise starting at 3 o'clock)
    final arcRect = Rect.fromCircle(center: center, radius: radius);
    final sweep = progress * 2 * math.pi;
    final sweepGradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * math.pi,
      colors: [Colors.white.withOpacity(0.98), Colors.white70.withOpacity(0.9)],
    );
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..shader = sweepGradient.createShader(arcRect);
    canvas.drawArc(arcRect, 0, sweep, false, arcPaint);

    // end cap (glowing)
    final double angle = sweep; // start at 0 (3 o'clock) + sweep clockwise
    final capCenter = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );

    final capGlow = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(capCenter, thumbSize * 0.8, capGlow);

    final capPaint = Paint()..color = Colors.white;
    canvas.drawCircle(capCenter, thumbSize * 0.45, capPaint);
  }

  @override
  bool shouldRepaint(covariant _BeltDialPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.ringOffset != ringOffset;
  }
}
