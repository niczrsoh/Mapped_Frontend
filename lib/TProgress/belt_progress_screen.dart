import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/TProgress/belt_progress_modelV2.dart';
import 'package:mapped_frontend/helper/colorConstant.dart';
import 'package:mapped_frontend/controller/user_controller';

import '../../controller/controller/trainer_controller.dart';
import 'belt_progress_ring_controller.dart';
import '../session/session_controller.dart';
import '../../controller/controller/resource_controller.dart';
import 'package:mapped_frontend/TProgress/data/belt_definitions.dart';
import 'package:mapped_frontend/TProgress/data/belt_requirements.dart';

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
  final TrainerController controller = Get.put(TrainerController());
  late BeltProgressRingController ringController;

  @override
  void initState() {
    ringController = Get.isRegistered<BeltProgressRingController>()
        ? Get.find<BeltProgressRingController>()
        : Get.put(BeltProgressRingController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
    super.initState();
  }

  Future<void> _refreshData() async {
    // 1. Try to sync User ID from UserController (most reliable source)
    if (Get.isRegistered<UserController>()) {
      final userCtrl = Get.find<UserController>();
      if (userCtrl.userId.value.isNotEmpty) {
        controller.currentUserId.value = userCtrl.userId.value;
        print(
          "🔗 TrainerController synced with UserController ID: ${userCtrl.userId.value}",
        );
      }
    }

    if (controller.currentUserId.value.isEmpty) {
      print("⏳ Waiting for User ID...");
      int retries = 0;
      while (controller.currentUserId.value.isEmpty && retries < 10) {
        // Try checking Get.find<UserController> again in loop
        if (Get.isRegistered<UserController>() &&
            controller.currentUserId.value.isEmpty) {
          final u = Get.find<UserController>();
          if (u.userId.value.isNotEmpty)
            controller.currentUserId.value = u.userId.value;
        }
        await Future.delayed(const Duration(milliseconds: 200));
        retries++;
      }
    }

    // 0. Ensure Resources & Active Days are loaded/updated
    final resourceController = Get.isRegistered<ResourceController>()
        ? Get.find<ResourceController>()
        : Get.put(ResourceController());
    await resourceController.fetchOpenResourceCount();
    await controller.updateActiveDays();

    // 1. Fetch the ring percentages
    await ringController.fetchBeltProgress();

    int maxImpliedDays = 0;
    try {
      for (var belt in ringController.detailedBeltData) {
        final req = BeltRequirementsData.getFor(belt.beltColor);
        int beltActiveDays = belt.progress.activeDayCount;

        if (beltActiveDays > 0) {
          int implied = beltActiveDays + req.cumulativeDayOffset;
          if (implied > maxImpliedDays) maxImpliedDays = implied;
        }
      }

      if (maxImpliedDays > controller.activeDaysCount.value) {
        print(
          "🩹 Self-Healing: Found $maxImpliedDays active days in Belt History (vs ${controller.activeDaysCount.value} in Profile). Updating.",
        );
        controller.activeDaysCount.value = maxImpliedDays;
      }
    } catch (e) {
      print("Self-Healing Error: $e");
    }

    // 2. Fetch the session count for the specific user
    final sessionController = Get.find<SessionController>();
    await sessionController.fetchDashboardData();

    // 3. Sync Active Counts to Backend (to persist progress)
    await _syncAllBelts();
  }

  Map<String, dynamic> _calculateBeltStats(
    BeltRequirement req,
    int totalSessions,
    int totalActiveDays,
    int openResources,
  ) {
    int currentSess = (totalSessions - req.cumulativeSessionOffset).clamp(
      0,
      _getTaskTarget(req, RequirementType.session),
    );

    int currentDays = (totalActiveDays - req.cumulativeDayOffset).clamp(
      0,
      _getTaskTarget(req, RequirementType.activeDay),
    );

    double currentProgressSum = 0;
    double targetProgressSum = 0;

    for (var task in req.tasks) {
      targetProgressSum += task.target;

      int val = 0;
      switch (task.type) {
        case RequirementType.session:
          val = currentSess;
          break;
        case RequirementType.activeDay:
          val = currentDays;
          break;
        case RequirementType.resource:
          val = openResources.clamp(0, task.target);
          break;
        case RequirementType.recommendation:
        case RequirementType.uploadPhoto:
        case RequirementType.reflection:
        case RequirementType.forumPost:
        case RequirementType.shareTip:
          val = 0;
          break;
      }
      currentProgressSum += val;
    }

    double progressPct = targetProgressSum > 0
        ? (currentProgressSum / targetProgressSum).clamp(0.0, 1.0)
        : 0.0;

    return {
      'sessions': currentSess,
      'days': currentDays,
      'progress': progressPct,
      'resources': openResources.clamp(
        0,
        _getTaskTarget(req, RequirementType.resource),
      ),
    };
  }

  int _getTaskTarget(BeltRequirement req, RequirementType type) {
    try {
      return req.tasks.firstWhere((t) => t.type == type).target;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _syncAllBelts() async {
    final SessionController sessionController = Get.find<SessionController>();
    final ResourceController resourceController =
        Get.find<ResourceController>();

    int totalSessions = sessionController.totalSessionsCount.value;
    int totalActiveDays = controller.activeDaysCount.value;

    if (totalActiveDays > 100) {
      print("⚠️ WARNING: Suspiciously high Active Days count!");
    }
    // CRITICAL FIX: Double-check controller active count is not 0 (e.g. if updateActiveDays missed a cycle)
    // If controller is suspiciously low (1) but we know backend usually higher, try to trust a re-fetch or ensure updateActiveDays finished.
    print("DEBUG: _syncAllBelts see Active Days: $totalActiveDays");

    int localResources = resourceController.viewedResourceIds.length;
    int backendResources = 0;

    try {
      BeltProgressModelV2? whiteBelt;
      for (var b in ringController.detailedBeltData) {
        if (b.beltColor == 'W' || b.beltColor == 'White') {
          whiteBelt = b;
          break;
        }
      }
      if (whiteBelt != null) {
        backendResources = whiteBelt.progress.openResourceCount;
      }
    } catch (e) {
      print("Error reading backend resource count: $e");
    }

    int currentOpenResources = (localResources > backendResources)
        ? localResources
        : backendResources;

    var wReq = BeltRequirementsData.getFor('White');
    var wStats = _calculateBeltStats(
      wReq,
      totalSessions,
      totalActiveDays,
      currentOpenResources,
    );
    await ringController.syncCalculatedProgress(
      beltColor: 'White',
      sessionCount: wStats['sessions'],
      activeDayCount: wStats['days'],
      progressPercentage: (wStats['progress'] * 100).toDouble(),
      openResourceCount: wStats['resources'],
    );

    // Yellow
    var yReq = BeltRequirementsData.getFor('Yellow');
    var yStats = _calculateBeltStats(
      yReq,
      totalSessions,
      totalActiveDays,
      currentOpenResources,
    );
    await ringController.syncCalculatedProgress(
      beltColor: 'Yellow',
      sessionCount: yStats['sessions'],
      activeDayCount: yStats['days'],
      progressPercentage: (yStats['progress'] * 100).toDouble(),
    );

    // Green
    var gReq = BeltRequirementsData.getFor('Green');
    var gStats = _calculateBeltStats(
      gReq,
      totalSessions,
      totalActiveDays,
      currentOpenResources,
    );
    await ringController.syncCalculatedProgress(
      beltColor: 'Green',
      sessionCount: gStats['sessions'],
      activeDayCount: gStats['days'],
      progressPercentage: (gStats['progress'] * 100).toDouble(),
    );

    // Blue
    var bReq = BeltRequirementsData.getFor('Blue');
    var bStats = _calculateBeltStats(
      bReq,
      totalSessions,
      totalActiveDays,
      currentOpenResources,
    );
    await ringController.syncCalculatedProgress(
      beltColor: 'Blue',
      sessionCount: bStats['sessions'],
      activeDayCount: bStats['days'],
      progressPercentage: (bStats['progress'] * 100).toDouble(),
    );

    // Brown
    var brReq = BeltRequirementsData.getFor('Brown');
    var brStats = _calculateBeltStats(
      brReq,
      totalSessions,
      totalActiveDays,
      currentOpenResources,
    );
    await ringController.syncCalculatedProgress(
      beltColor: 'Brown',
      sessionCount: brStats['sessions'],
      activeDayCount: brStats['days'],
      progressPercentage: (brStats['progress'] * 100).toDouble(),
    );
  }

  String _getBeltAssetPath(String beltName) {
    return BeltDefinitions.getByName(beltName).assetPath;
  }

  @override
  Widget build(BuildContext context) {
    final SessionController sessionController = Get.put(SessionController());
    final TrainerController controller = Get.put(TrainerController());
    final resourceController = Get.isRegistered<ResourceController>()
        ? Get.find<ResourceController>()
        : Get.put(ResourceController());
    final themeBg = ColorConstant.themeBg;
    final cardBgColor = const Color(0xFF151725);

    final currentBeltDef = BeltDefinitions.getByName(widget.beltName);
    final String nextBeltName = (currentBeltDef.nextBeltId != null)
        ? BeltDefinitions.getByCode(currentBeltDef.nextBeltId!).name
        : 'Mastery';
    final Color nextBeltColor = (currentBeltDef.nextBeltId != null)
        ? BeltDefinitions.getByCode(currentBeltDef.nextBeltId!).color
        : const Color(0xFF1A1A1A);

    final double barWidth = 240;
    final double thumbSize = 24;

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
        int totalSessions = sessionController.totalSessionsCount.value;
        // Use local controller reference or the one from build
        final tController = Get.isRegistered<TrainerController>()
            ? Get.find<TrainerController>()
            : Get.put(TrainerController());
        int totalActiveDays = tController.activeDaysCount.value;
        int localResources = resourceController.viewedResourceIds.length;

        // 2. Get Backend Count (Fetched from API)
        int backendResources = 0;
        try {
          for (var b in ringController.detailedBeltData) {
            if (b.beltColor == 'W' || b.beltColor == 'White') {
              backendResources = b.progress.openResourceCount;
              break;
            }
          }
        } catch (e) {
          print("Error finding backend resources: $e");
        }

        int currentOpenResources = (localResources > backendResources)
            ? localResources
            : backendResources;

        final beltReq = BeltRequirementsData.getFor(widget.beltName);

        int currentPlannedCount =
            (totalSessions - beltReq.cumulativeSessionOffset).clamp(
              0,
              _getTaskTarget(beltReq, RequirementType.session),
            );
        int currentActiveDays = (totalActiveDays - beltReq.cumulativeDayOffset)
            .clamp(0, _getTaskTarget(beltReq, RequirementType.activeDay));

        var stats = _calculateBeltStats(
          beltReq,
          totalSessions,
          totalActiveDays,
          currentOpenResources,
        );
        double liveProgress = stats['progress'];

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: widget.beltColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: 220,
                        height: 180,
                        child: Image.asset(
                          _getBeltAssetPath(widget.beltName),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              color: widget.beltColor,
                              size: 100,
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // The Gradient Bar
                          Container(
                            width: barWidth,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: Colors.white24,
                                width: 1,
                              ),
                            ),
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
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${(liveProgress * 100).round()}%',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                    Container(
                      width: double.infinity,
                      height: 400,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (liveProgress >= 1.0)
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.white,
                                              widget.beltColor,
                                              Colors.black,
                                            ],
                                            center: const Alignment(-0.3, -0.3),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        widget.beltName,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  Text(
                                    "Congratulation",
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "You already finished all\nthe certification.",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildBeltHeaderItem(
                                  widget.beltName,
                                  widget.beltColor,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.white54,
                                  ),
                                ),
                                _buildBeltHeaderItem(
                                  nextBeltName,
                                  nextBeltColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // 2. Column Titles
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Requirement",
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "Progress",
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 3. Requirements List (Dynamic from belt_requirements.dart)
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                itemCount: beltReq.tasks.length,
                                itemBuilder: (context, index) {
                                  final task = beltReq.tasks[index];

                                  // Determine Current Value
                                  int currentValue = 0;
                                  switch (task.type) {
                                    case RequirementType.session:
                                      currentValue = currentPlannedCount;
                                      break;
                                    case RequirementType.activeDay:
                                      currentValue = currentActiveDays;
                                      break;
                                    case RequirementType.resource:
                                      currentValue = currentOpenResources.clamp(
                                        0,
                                        task.target,
                                      );
                                      break;
                                    default:
                                      // Others are currently not tracked in controller, default to 0
                                      currentValue = 0;
                                  }

                                  // Highlight Logic (Matches original code for White belt session completion)
                                  Color? highlight;
                                  if (widget.beltName == 'White' &&
                                      task.type == RequirementType.session &&
                                      currentValue >= task.target) {
                                    highlight = const Color(0xFF00E676);
                                  } else {
                                    highlight = widget.beltColor;
                                  }

                                  Color displayColor = widget.beltColor;
                                  if (widget.beltName == 'White' &&
                                      task.type == RequirementType.session &&
                                      currentValue >= task.target) {
                                    displayColor = const Color(0xFF00E676);
                                  } else if (widget.beltName == 'White') {
                                    // White belt generic items didn't have specific color in original else block unless specified
                                    displayColor = Colors.white;
                                  }

                                  if (widget.beltName != 'White') {
                                    displayColor = widget.beltColor;
                                  } else {
                                    // For White belt, only session gets green, others white unless specified
                                    if (task.type == RequirementType.session &&
                                        currentValue >= task.target) {
                                      displayColor = const Color(0xFF00E676);
                                    } else {
                                      displayColor = Colors.white;
                                    }
                                  }

                                  return Column(
                                    children: [
                                      _buildRequirementRow(
                                        task.icon,
                                        task.progressLabel,
                                        "$currentValue / ${task.target}",
                                        highlightColor: displayColor,
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 20),

                            // 4. Level Up Helper Text
                            Center(
                              child: Text(
                                "Ready to level up? Start the course now",
                                style: GoogleFonts.inter(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 5. Start Course Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.snackbar(
                                    "Info",
                                    "This feature is currently in development.",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.white24,
                                    colorText: Colors.white,
                                    margin: const EdgeInsets.all(10),
                                    borderRadius: 10,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(
                                    0.15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  "Start Course",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
      }),
    );
  }

  // --- Helper Widgets ---
  Widget _buildBeltHeaderItem(String name, Color color) {
    return Row(
      children: [
        Image.asset(
          _getBeltAssetPath(name),
          height: 24, // Matches typical icon size
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: GoogleFonts.inter(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementRow(
    IconData icon,
    String title,
    String progress, {
    Color? highlightColor,
  }) {
    final progressColor = highlightColor ?? Colors.white;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          progress,
          style: GoogleFonts.inter(
            color: progressColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
