import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class YellowBeltProgressScreen extends StatelessWidget {
  const YellowBeltProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBg = const Color(0xFF0F1114);
    final double progress = 0.50;
    final double dialSize = 160;
    final double dialStroke = 22.0;
    final double dialRadiusOffset = 6.0;
    final double barWidth = 240;
    final double thumbSize = 24;

    // Yellow color used for progress
    const yellowPrimary = Color(0xFFF5FB32);

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

                Center(
                  child: Container(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: dialSize,
                          height: dialSize,
                          child: CustomPaint(
                            painter: _YellowBeltDialPainter(
                              progress: progress.clamp(0.0, 1.0),
                              strokeWidth: dialStroke,
                              thumbSize: thumbSize,
                              ringOffset: dialRadiusOffset,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(progress * 100).round()}%',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'YELLOW',
                              style: GoogleFonts.poppins(
                                color: yellowPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'BELT',
                              style: GoogleFonts.poppins(
                                color: yellowPrimary,
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

                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: barWidth,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0x33F5FB32),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: const Color(0x33F5FB32),
                            width: 1,
                          ),
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
                                        Color(0xFFF5FB32),
                                        Color(0xFFF1C40F),
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
                                      color: yellowPrimary,
                                      boxShadow: [
                                        BoxShadow(
                                          color: yellowPrimary.withOpacity(
                                            0.25,
                                          ),
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

                Container(
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141823),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x33F5FB32)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 16, 8),
                        child: Text(
                          'Yellow Belt',
                          style: GoogleFonts.poppins(
                            color: yellowPrimary,
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
                        avatar: 'assets/images/y1.png',
                      ),
                      _tableRowWithAvatar(
                        'Siti Zaleha',
                        '85%',
                        avatar: 'assets/images/y2.png',
                      ),
                      _tableRowWithAvatar(
                        'Ahmad Firdaus',
                        '55%',
                        avatar: 'assets/images/y3.png',
                      ),
                      _tableRowWithAvatar(
                        'Nisa Nuraini',
                        '40%',
                        avatar: 'assets/images/y4.png',
                      ),
                      _tableRowWithAvatar(
                        'Mohd Faisal',
                        '30%',
                        avatar: 'assets/images/y5.png',
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

class _YellowBeltDialPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final double thumbSize;
  final double ringOffset;

  const _YellowBeltDialPainter({
    required this.progress,
    required this.strokeWidth,
    required this.thumbSize,
    this.ringOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2) + ringOffset;

    // outer soft glow (yellow)
    final glowPaint = Paint()
      ..color = const Color(0xFFF5FB32).withOpacity(0.06)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(center, radius + strokeWidth * 0.4, glowPaint);

    // base ring (non-progress): keep neutral grey
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFF343333);
    canvas.drawCircle(center, radius, basePaint);

    // inner vignette
    final innerRadius = radius - strokeWidth * 0.6;
    final innerShader = ui.Gradient.radial(
      center,
      innerRadius,
      [const Color(0x00000000), const Color(0xFF000000).withOpacity(0.4)],
      [0.0, 1.0],
    );
    final innerPaint = Paint()..shader = innerShader;
    canvas.drawCircle(center, innerRadius, innerPaint);

    // progress arc (yellow)
    final arcRect = Rect.fromCircle(center: center, radius: radius);
    final sweep = progress * 2 * math.pi;
    final sweepGradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * math.pi,
      colors: [
        const Color(0xFFF5FB32).withOpacity(0.98),
        const Color(0xFFF1C40F).withOpacity(0.9),
      ],
    );
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..shader = sweepGradient.createShader(arcRect);
    canvas.drawArc(arcRect, 0, sweep, false, arcPaint);

    // end cap (glowing, yellow)
    final double angle = sweep;
    final capCenter = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );

    final capGlow = Paint()
      ..color = const Color(0xFFF5FB32).withOpacity(0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(capCenter, thumbSize * 0.8, capGlow);

    final capPaint = Paint()..color = const Color(0xFFF5FB32);
    canvas.drawCircle(capCenter, thumbSize * 0.45, capPaint);
  }

  @override
  bool shouldRepaint(covariant _YellowBeltDialPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.ringOffset != ringOffset;
  }
}
