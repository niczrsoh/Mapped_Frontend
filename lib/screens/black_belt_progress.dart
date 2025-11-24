import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/screens/belt_dashboard_screen.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class BlackBeltProgressScreen extends StatelessWidget {
  const BlackBeltProgressScreen({super.key});

  static const Color blackPrimary = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    final themeBg = const Color(0xFF0F1114);
    final double progress = 0.80;
    final double dialSize = 160;
    final double dialStroke = 22.0;
    final double dialRadiusOffset = 6.0;
    final double barWidth = 240;
    final double thumbSize = 24;

    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const BeltDashboardScreen(),
            ),
            (route) => route.isFirst,
          ),
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
              child: ClipRRect(
                //belt progress style
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05), // SAME glass color
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), // SAME shadow
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      "Belt Progress",
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
                            painter: _BlackBeltDialPainter(
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
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  'BLACK',
                                  style: GoogleFonts.roboto(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 3
                                      ..color = blackPrimary,
                                    height: 1.2,
                                  ),
                                ),
                                Text(
                                  'BLACK',
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0,
                                    height: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.grey.withOpacity(0.6),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  'BELT',
                                  style: GoogleFonts.roboto(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 3
                                      ..color = blackPrimary,
                                    height: 1.2,
                                  ),
                                ),
                                Text(
                                  'BELT',
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0,
                                    height: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.grey.withOpacity(0.6),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                          color: Colors
                              .white, // non-progress track should be white
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.white, width: 1),
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
                                        Color(0xFF000000),
                                        Color(0xFF000000),
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
                                      color: blackPrimary,
                                      boxShadow: [
                                        BoxShadow(
                                          color: blackPrimary.withOpacity(0.25),
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

                // Outer gradient border (1px) to mimic CSS border-image gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(255, 255, 255, 0.1),
                        Color(0xFF000000),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(1), // 1px border
                  child: Container(
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: const Color(0xFF141823),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 16, 8),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Black ',
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Belt',
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                'Progress',
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _tableRowWithAvatar(
                          'Aiman Lee',
                          '90%',
                          avatar: 'assets/images/b1.png',
                        ),
                        _tableRowWithAvatar(
                          'Nurul Hana',
                          '85%',
                          avatar: 'assets/images/b1.png',
                        ),
                        _tableRowWithAvatar(
                          'Daniel Wong',
                          '55%',
                          avatar: 'assets/images/b1.png',
                        ),
                        _tableRowWithAvatar(
                          'Siti Rahman',
                          '53%',
                          avatar: 'assets/images/b1.png',
                        ),
                        _tableRowWithAvatar(
                          'John Doe',
                          '42%',
                          avatar: 'assets/images/y5.png',
                        ),
                      ],
                    ),
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
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            progress,
            style: GoogleFonts.roboto(
              color: blackPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlackBeltDialPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final double thumbSize;
  final double ringOffset;

  const _BlackBeltDialPainter({
    required this.progress,
    required this.strokeWidth,
    required this.thumbSize,
    this.ringOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2) + ringOffset;

    // outer soft glow (accent)
    final glowPaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.06)
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

    // progress arc (green)
    final arcRect = Rect.fromCircle(center: center, radius: radius);
    final sweep = progress * 2 * math.pi;
    final sweepGradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * math.pi,
      colors: [
        const Color(0xFF000000).withOpacity(0.98),
        const Color(0xFF000000).withOpacity(0.9),
      ],
    );
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..shader = sweepGradient.createShader(arcRect);
    canvas.drawArc(arcRect, 0, sweep, false, arcPaint);

    // end cap (glowing, green)
    final double angle = sweep;
    final capCenter = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );

    final capGlow = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(capCenter, thumbSize * 0.8, capGlow);

    final capPaint = Paint()..color = const Color(0xFF000000);
    canvas.drawCircle(capCenter, thumbSize * 0.45, capPaint);
  }

  @override
  bool shouldRepaint(covariant _BlackBeltDialPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.ringOffset != ringOffset;
  }
}
