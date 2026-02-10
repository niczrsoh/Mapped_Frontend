import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/TProgress/belt_progress_modelV2.dart';
import 'package:mapped_frontend/helper/colorConstant.dart';
import 'package:mapped_frontend/controller/user_controller';

import '../../controller/controller/trainer_controller.dart';
import 'belt_progress_ring_controller.dart';
import '../session/session_controller.dart';
import '../../resource/resource_controller.dart';
import '../../comment/comment_controller.dart';
import '../../create_post/create_post_controller.dart';
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

class _BeltProgressScreenState extends State<BeltProgressScreen>
    with WidgetsBindingObserver {
  final TrainerController controller = Get.put(TrainerController());
  late BeltProgressRingController ringController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    ringController = Get.isRegistered<BeltProgressRingController>()
        ? Get.find<BeltProgressRingController>()
        : Get.put(BeltProgressRingController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    ringController.isLoading.value = true;

    try {
      if (Get.isRegistered<UserController>()) {
        final userCtrl = Get.find<UserController>();
        if (userCtrl.userId.value.isNotEmpty) {
          controller.currentUserId.value = userCtrl.userId.value;
        }
      }

      await controller.updateActiveDays();
      await ringController.fetchBeltProgress();

      final resourceController = Get.isRegistered<ResourceController>()
          ? Get.find<ResourceController>()
          : Get.put(ResourceController());
      await resourceController.fetchOpenResourceCount();

      int maxImpliedPosts = 0;
      for (var belt in ringController.detailedBeltData) {
        final req = BeltRequirementsData.getFor(belt.beltColor);

        if (belt.progress.postCount > 0) {
          int impliedPosts = belt.progress.postCount + req.cumulativePostOffset;
          if (impliedPosts > maxImpliedPosts) maxImpliedPosts = impliedPosts;
        }
      }

      // 5. FINAL SYNC
      final sessionController = Get.find<SessionController>();
      await sessionController.fetchDashboardData();
      controller.cumulativePostCount.value = maxImpliedPosts;

      await _syncAllBelts();
    } catch (e) {
      print("❌ Error during refresh: $e");
    } finally {
      ringController.isLoading.value = false;
    }
  }

  Map<String, dynamic> _calculateBeltStats(
    BeltRequirement req,
    int totalSessions,
    int totalActiveDays,
    int openResources,
    int totalPosts,
    int totalShareTips,
    int totalReflections,
    BeltProgressModelV2? beltData,
  ) {
    if ((req.beltId == BeltDefinitions.black ||
            widget.beltName.contains('Black')) &&
        req.beltId != BeltDefinitions.brown &&
        req.beltId != 'Brown') {
      // 1. Find Brown Belt Data to check strict progression
      BeltProgressModelV2? brownData;
      for (var b in ringController.detailedBeltData) {
        if (b.beltColor == BeltDefinitions.brown || b.beltColor == 'Brown') {
          brownData = b;
          break;
        }
      }

      final brownReq = BeltRequirementsData.getFor(BeltDefinitions.brown);

      var brownStats = _calculateBeltStats(
        brownReq,
        totalSessions,
        totalActiveDays,
        openResources,
        totalPosts,
        totalShareTips,
        totalReflections,
        brownData,
      );

      double brownProgress = brownStats['progress'] ?? 0.0;
      double blackProgress = (brownProgress >= 0.9999) ? 1.0 : 0.0;

      return {
        'sessions': 0,
        'days': 0,
        'progress': blackProgress,
        'resources': 0,
      };
    }

    int currentSess = (totalSessions - req.cumulativeSessionOffset).clamp(
      0,
      _getTaskTarget(req, RequirementType.session),
    );

    int currentDays = (totalActiveDays - req.cumulativeDayOffset).clamp(
      0,
      _getTaskTarget(req, RequirementType.activeDay),
    );

    int currentPosts = (totalPosts - req.cumulativePostOffset).clamp(
      0,
      _getTaskTarget(req, RequirementType.forumPost),
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
        case RequirementType.forumPost:
          val = currentPosts;
          break;
        case RequirementType.recommendation:
          val = (beltData?.progress.recommendationCount ?? 0).clamp(
            0,
            task.target,
          );
          break;
        case RequirementType.reflection:
          val = totalReflections.clamp(0, task.target);
          break;
        case RequirementType.shareTip:
          int shareTipOffset = 0;
          if (widget.beltName == 'Brown') {
            shareTipOffset = 1;
          }
          val = (totalShareTips - shareTipOffset).clamp(0, task.target);
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
    final commentsController = Get.isRegistered<CommentsController>()
        ? Get.find<CommentsController>()
        : Get.put(CommentsController());
    final createPostController = Get.isRegistered<CreatePostController>()
        ? Get.find<CreatePostController>()
        : Get.put(CreatePostController());

    int totalSessions = sessionController.totalSessionsCount.value;
    int totalActiveDays = controller.activeDaysCount.value;
    int totalPosts = commentsController.submittedPostIds.length;
    int totalShareTips = createPostController.sharedTipPostIds.length;
    // Use submittedReflectionSessionIds for progress
    int totalReflections =
        sessionController.submittedReflectionSessionIds.length;
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

    // Cap resources at White belt target (3)
    const int resourceTarget = 3;
    int currentOpenResources = (localResources > backendResources)
        ? localResources
        : backendResources;
    currentOpenResources = currentOpenResources.clamp(0, resourceTarget);

    BeltProgressModelV2? whiteBeltData,
        yellowBeltData,
        greenBeltData,
        blueBeltData,
        brownBeltData;
    for (var b in ringController.detailedBeltData) {
      if (b.beltColor == 'W' || b.beltColor == 'White') whiteBeltData = b;
      if (b.beltColor == 'Y' || b.beltColor == 'Yellow') yellowBeltData = b;
      if (b.beltColor == 'G' || b.beltColor == 'Green') greenBeltData = b;
      if (b.beltColor == 'B' || b.beltColor == 'Blue') blueBeltData = b;
      if (b.beltColor == 'R' || b.beltColor == 'Brown') brownBeltData = b;
    }

    var wReq = BeltRequirementsData.getFor('White');
    var wStats = _calculateBeltStats(
      wReq,
      totalSessions,
      totalActiveDays,
      currentOpenResources,
      totalPosts,
      totalShareTips,
      totalReflections,
      whiteBeltData,
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
      totalPosts,
      totalShareTips,
      totalReflections,
      yellowBeltData,
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
      totalPosts,
      totalShareTips,
      totalReflections,
      greenBeltData,
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
      totalPosts,
      totalShareTips,
      totalReflections,
      blueBeltData,
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
      totalPosts,
      totalShareTips,
      totalReflections,
      brownBeltData,
    );
    await ringController.syncCalculatedProgress(
      beltColor: 'Brown',
      sessionCount: brStats['sessions'],
      activeDayCount: brStats['days'],
      progressPercentage: (brStats['progress'] * 100).toDouble(),
    );

    double brownProgress = (brStats['progress'] ?? 0.0);
    if (brownProgress >= 0.9999) {
      await ringController.syncCalculatedProgress(
        beltColor: 'Black',
        progressPercentage: 100.0,
        sessionCount: 0,
        activeDayCount: 0,
      );
    }
  }

  String _getBeltAssetPath(String beltName) {
    return BeltDefinitions.getByName(beltName).assetPath;
  }

  @override
  Widget build(BuildContext context) {
    final SessionController sessionController = Get.put(SessionController());
    // use the controller field declared on the state class
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
          onPressed: () async {
            if (Get.isRegistered<BeltProgressRingController>()) {
              await Get.find<BeltProgressRingController>().fetchBeltProgress();
            }
            try {
              Get.back();
            } catch (e) {
              Navigator.of(context).pop();
            }
          },
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
        if (ringController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        int totalSessions = sessionController.totalSessionsCount.value;
        final tController = Get.isRegistered<TrainerController>()
            ? Get.find<TrainerController>()
            : Get.put(TrainerController());
        final commentsController = Get.isRegistered<CommentsController>()
            ? Get.find<CommentsController>()
            : Get.put(CommentsController());
        final createPostController = Get.isRegistered<CreatePostController>()
            ? Get.find<CreatePostController>()
            : Get.put(CreatePostController());
        int totalActiveDays = tController.activeDaysCount.value;
        int totalPosts = commentsController.submittedPostIds.length;
        int totalShareTips = createPostController.sharedTipPostIds.length;
        int totalReflections =
            sessionController.submittedReflectionSessionIds.length;
        int localResources = resourceController.viewedResourceIds.length;
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

        const int resourceTarget = 3;
        int currentOpenResources = (localResources > backendResources)
            ? localResources
            : backendResources;
        currentOpenResources = currentOpenResources.clamp(0, resourceTarget);

        final beltReq = BeltRequirementsData.getFor(widget.beltName);

        int currentPlannedCount =
            (totalSessions - beltReq.cumulativeSessionOffset).clamp(
              0,
              _getTaskTarget(beltReq, RequirementType.session),
            );
        int currentActiveDays = (totalActiveDays - beltReq.cumulativeDayOffset)
            .clamp(0, _getTaskTarget(beltReq, RequirementType.activeDay));

        BeltProgressModelV2? currentBeltData;
        try {
          final beltDef = BeltDefinitions.getByName(widget.beltName);
          for (var b in ringController.detailedBeltData) {
            if (b.beltColor == beltDef.id || b.beltColor == widget.beltName) {
              currentBeltData = b;
              break;
            }
          }
        } catch (e) {
          print("Error finding current belt data: $e");
        }

        var stats = _calculateBeltStats(
          beltReq,
          totalSessions,
          totalActiveDays,
          currentOpenResources,
          totalPosts,
          totalShareTips,
          totalReflections,
          currentBeltData,
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
                            if (!widget.beltName.contains('Black')) ...[
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
                            ],

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

                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                itemCount: beltReq.tasks.length,
                                itemBuilder: (context, index) {
                                  final task = beltReq.tasks[index];

                                  BeltProgressModelV2? currentBeltData;
                                  try {
                                    for (var b
                                        in ringController.detailedBeltData) {
                                      final beltDef = BeltDefinitions.getByName(
                                        widget.beltName,
                                      );
                                      if (b.beltColor == beltDef.id ||
                                          b.beltColor == widget.beltName) {
                                        currentBeltData = b;
                                        break;
                                      }
                                    }
                                  } catch (e) {
                                    print("Error finding belt data: $e");
                                  }
                                  int currentValue = 0;
                                  int currentPosts =
                                      (totalPosts -
                                              beltReq.cumulativePostOffset)
                                          .clamp(
                                            0,
                                            _getTaskTarget(
                                              beltReq,
                                              RequirementType.forumPost,
                                            ),
                                          );
                                  int shareTipOffset = 0;
                                  if (widget.beltName == 'Brown') {
                                    shareTipOffset = 1;
                                  }
                                  int currentShareTips =
                                      (totalShareTips - shareTipOffset).clamp(
                                        0,
                                        _getTaskTarget(
                                          beltReq,
                                          RequirementType.shareTip,
                                        ),
                                      );
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
                                    case RequirementType.forumPost:
                                      currentValue = currentPosts;
                                      break;
                                    case RequirementType.recommendation:
                                      currentValue =
                                          currentBeltData
                                              ?.progress
                                              .recommendationCount ??
                                          0;
                                      break;
                                    case RequirementType.shareTip:
                                      currentValue = currentShareTips;
                                      break;
                                    case RequirementType.reflection:
                                      currentValue = totalReflections.clamp(
                                        0,
                                        task.target,
                                      );
                                      break;
                                  }

                                  Color displayColor = widget.beltColor;

                                  String progressText =
                                      (widget.beltName.contains('Black') &&
                                          task.target == 0)
                                      ? "0" // Hide for Black Belt mastery
                                      : "$currentValue / ${task.target}";

                                  return Column(
                                    children: [
                                      _buildRequirementRow(
                                        task.icon,
                                        task.progressLabel,
                                        progressText,
                                        highlightColor: displayColor,
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 20),

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

  Widget _buildBeltHeaderItem(String name, Color color) {
    return Row(
      children: [
        Image.asset(_getBeltAssetPath(name), height: 24, fit: BoxFit.contain),
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
