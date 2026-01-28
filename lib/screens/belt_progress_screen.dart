import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/helper/colorConstant.dart';
import 'package:mapped_frontend/screens/belt_dashboard_screen.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:mapped_frontend/screens/belt_detail_screen.dart';
import '../../controller/controller/trainee_controller.dart';
import '../../controller/controller/belt_progress_ring_controller.dart';

class BeltProgressScreen extends StatefulWidget {
  final String beltName;
  final Color beltColor;

  const BeltProgressScreen({
    super.key,
    required this.beltName,
    required this.beltColor,
  });

  @override
  State<BeltProgressScreen> createState() => _BeltProgressScreenState();
}

class _BeltProgressScreenState extends State<BeltProgressScreen> {
  // Use Get.find to get the existing controller instance
  final TraineeController controller = Get.put(TraineeController());

  late BeltProgressRingController ringController;

  @override
  void initState() {
    super.initState();

    // Initialize Ring Controller safely
    ringController = Get.isRegistered<BeltProgressRingController>()
        ? Get.find<BeltProgressRingController>()
        : Get.put(BeltProgressRingController());

    // Initial Load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  // --- NEW: Centralized Refresh Logic ---
  Future<void> _refreshData() async {
    // 1. Refresh the Ring Data (Global Stats)
    await ringController.fetchBeltProgress();

    // 2. Refresh the Trainee List Data
    String cleanName = widget.beltName.replaceAll(' Belt', '');

    final filteredTrainees = controller.traineeList.where((t) {
      final b = t['belt'].toString().toLowerCase();
      return b == cleanName.toLowerCase();
    }).toList();

    for (var trainee in filteredTrainees) {
      // Force reload from API
      await controller.loadTraineeProgress(trainee['id']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBg = ColorConstant.themeBg;
    final double progress = 0.75;
    // dial sizing
    final double dialSize = 160; // inner dial square used for painting
    final double dialStroke =
        22.0; // reduced thickness of the outer ring (was 28.0)
    final double dialRadiusOffset = 6.0; // positive moves the ring outward
    // horizontal bar sizing
    final double barWidth = 240;
    final double thumbSize = 24;
    final bool isBlackBelt = widget.beltName == 'Black';

    // Shadows
    final List<Shadow> ringTextShadows = [
      const Shadow(
        offset: Offset(0, 4),
        blurRadius: 4.0,
        color: Color(0x40000000),
      ),
    ];
    final List<Shadow> coloredBeltShadows = [
      const Shadow(
        offset: Offset(0, 4),
        blurRadius: 4.0,
        color: Color(0x80000000),
      ),
    ];

    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Dashboard',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        // 2. GET LIVE PROGRESS
        String cleanName = widget.beltName.replaceAll(' Belt', '');
        int pctInt = ringController.getPercentage(cleanName);
        double liveProgress = pctInt / 100.0;

        final filteredTrainees = controller.traineeList.where((t) {
          final b = t['belt'].toString().toLowerCase();
          return b == cleanName.toLowerCase();
        }).toList();

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // --- 1. CIRCULAR DIAL ---
                  Center(
                    // child: GestureDetector(
                    //   // --- UPDATED NAVIGATION LOGIC ---
                    //   onTap: () async {
                    //     // 1. Wait for user to come back from the detail/edit screens
                    //     await Get.to(
                    //       () => BeltDetailListScreen(beltName: widget.beltName),
                    //     );

                    //     // 2. Wait a tiny bit for Backend DB to finish writing the new score
                    //     await Future.delayed(const Duration(milliseconds: 300));

                    //     // 3. Force refresh UI with the new data
                    //     if (mounted) {
                    //       _refreshData();
                    //     }
                    //   },
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
                              painter: _GenericBeltDialPainter(
                                progress: liveProgress.clamp(0.0, 1.0),
                                strokeWidth: dialStroke,
                                thumbSize: thumbSize,
                                ringOffset: dialRadiusOffset,
                                accentColor: widget.beltColor,
                                isBlackBelt: isBlackBelt,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // PERCENTAGE TEXT
                              Text(
                                '${(liveProgress * 100).round()}%',
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                  shadows: ringTextShadows,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // BELT TEXT
                              _buildOutlinedText(
                                widget.beltName.toUpperCase(),
                                isBlackBelt
                                    ? ringTextShadows
                                    : coloredBeltShadows,
                              ),
                              const SizedBox(height: 2),
                              _buildOutlinedText(
                                'BELT',
                                isBlackBelt
                                    ? ringTextShadows
                                    : coloredBeltShadows,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // --- 2. HORIZONTAL PROGRESS BAR ---
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
                                  widthFactor: liveProgress.clamp(0.0, 1.0),
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          widget.beltColor.withOpacity(1.0),
                                          widget.beltColor.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left:
                                      ((barWidth * liveProgress).clamp(
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
                                        color: widget.beltColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: widget.beltColor.withOpacity(
                                              0.4,
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

                  // --- 3. TRAINEE LIST CONTAINER ---
                  GestureDetector(
                    onTap: () async {
                      // Simple navigation logic
                      await Get.to(
                        () => BeltDetailListScreen(beltName: widget.beltName),
                      );

                      // Refresh data when user comes back
                      if (mounted) {
                        _refreshData();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            widget.beltColor.withOpacity(0.05),
                            widget.beltColor.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(1),
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
                                      text: '${widget.beltName} ',
                                      style: GoogleFonts.roboto(
                                        color: isBlackBelt
                                            ? Colors.white
                                            : widget.beltColor,
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

                            if (filteredTrainees.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Center(
                                  child: Text(
                                    "No ${widget.beltName} belt trainees found.",
                                    style: GoogleFonts.roboto(
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...filteredTrainees.take(5).map((trainee) {
                                return _tableRowWithAvatar(
                                  trainee['name'] ?? 'Unknown',
                                  trainee['id'],
                                  beltColor: widget.beltColor,
                                  avatar: trainee['image'],
                                );
                              }).toList(),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ... (The rest of your build methods like _buildOutlinedText remain the same) ...

  Widget _buildOutlinedText(String text, List<Shadow> shadows) {
    if (widget.beltName == 'Black') {
      return Stack(
        children: [
          Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              height: 1.2,
              shadows: shadows,
            ),
          ),
          Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3
                ..color = Colors.black,
              height: 1.2,
            ),
          ),
          Text(
            text,
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: GoogleFonts.roboto(
        color: widget.beltColor,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.2,
        shadows: shadows,
      ),
    );
  }

  Widget _tableRowWithAvatar(
    String name,
    String traineeId, {
    required Color beltColor,
    String? avatar,
  }) {
    ImageProvider? avatarImage;

    if (avatar != null && avatar.isNotEmpty) {
      if (avatar.startsWith('http')) {
        avatarImage = NetworkImage(avatar);
      } else if (avatar.startsWith('assets/')) {
        avatarImage = AssetImage(avatar);
      } else {
        try {
          final file = File(avatar);
          if (file.existsSync()) {
            avatarImage = FileImage(file);
          } else {
            avatarImage = null;
          }
        } catch (e) {
          avatarImage = null;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 36,
              height: 36,
              child: avatarImage != null
                  ? Image(
                      image: avatarImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/accountLogo.png',
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/accountLogo.png',
                      fit: BoxFit.cover,
                    ),
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
          Obx(() {
            return Text(
              controller.traineeProgressMap[traineeId] ?? '...',
              style: GoogleFonts.roboto(
                color: beltColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ... (_GenericBeltDialPainter remains the same) ...
class _GenericBeltDialPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final double thumbSize;
  final double ringOffset;
  final Color accentColor;
  final bool isBlackBelt;

  _GenericBeltDialPainter({
    required this.progress,
    required this.strokeWidth,
    required this.thumbSize,
    required this.accentColor,
    required this.isBlackBelt,
    this.ringOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2) + ringOffset;

    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(center, radius + strokeWidth * 0.4, glowPaint);

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFF343333);
    canvas.drawCircle(center, radius, basePaint);

    final innerRadius = radius - strokeWidth * 0.6;
    final innerShader = ui.Gradient.radial(
      center,
      innerRadius,
      [Colors.transparent, Colors.black.withOpacity(0.4)],
      [0.0, 1.0],
    );
    final innerPaint = Paint()..shader = innerShader;
    canvas.drawCircle(center, innerRadius, innerPaint);

    final arcRect = Rect.fromCircle(center: center, radius: radius);
    final sweep = progress * 2 * math.pi;

    SweepGradient sweepGradient;
    if (isBlackBelt) {
      sweepGradient = const SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: [Color(0xFF000000), Color(0xFF3A3A3A)],
      );
    } else {
      sweepGradient = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: [accentColor.withOpacity(0.98), accentColor.withOpacity(0.8)],
      );
    }

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..shader = sweepGradient.createShader(arcRect);
    canvas.drawArc(arcRect, 0, sweep, false, arcPaint);

    final double angle = sweep;
    final capCenter = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );

    final capGlow = Paint()
      ..color = accentColor.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(capCenter, thumbSize * 0.8, capGlow);

    final capPaint = Paint()..color = accentColor;
    canvas.drawCircle(capCenter, thumbSize * 0.45, capPaint);
  }

  @override
  bool shouldRepaint(covariant _GenericBeltDialPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.ringOffset != ringOffset ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isBlackBelt != isBlackBelt;
  }
}
