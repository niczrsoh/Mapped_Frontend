import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/TProgress/belt_progress_modelV2.dart';
import 'package:mapped_frontend/TProgress/belt_progress_screen.dart';
import 'belt_progress_ring_controller.dart';
import '../../controller/controller/trainer_controller.dart';
import '../session/session_controller.dart';
import '../../resource/resource_controller.dart';
import '../../comment/comment_controller.dart';
import '../../create_post/create_post_controller.dart';
import 'package:mapped_frontend/TProgress/data/belt_definitions.dart';
import 'package:mapped_frontend/TProgress/data/belt_requirements.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

class BeltDashboardScreen extends StatefulWidget {
  const BeltDashboardScreen({super.key});

  @override
  State<BeltDashboardScreen> createState() => _BeltDashboardScreenState();
}

class _BeltDashboardScreenState extends State<BeltDashboardScreen> {
  late BeltProgressRingController ringController;

  @override
  void initState() {
    super.initState();
    Get.put(TrainerController());
    Get.put(SessionController());
    Get.put(ResourceController());
    Get.put(CommentsController());
    Get.put(CreatePostController());

    ringController = Get.put(BeltProgressRingController());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      await ringController.fetchBeltProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final TrainerController trainerController = Get.find<TrainerController>();
    final SessionController sessionController = Get.find<SessionController>();
    final resourceController = Get.find<ResourceController>();
    final commentsController = Get.find<CommentsController>();
    final createPostController = Get.find<CreatePostController>();

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
      body: Obx(() {
        int totalSessions = sessionController.totalSessionsCount.value;
        int totalActiveDays = trainerController.activeDaysCount.value;
        int totalPosts = commentsController.submittedPostIds.length;
        int totalShareTips = createPostController.sharedTipPostIds.length;
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

        // Cap resources at White belt target (3)
        const int resourceTarget = 3;
        int resourcesOpened = (localResources > backendResources)
            ? localResources
            : backendResources;
        resourcesOpened = resourcesOpened.clamp(0, resourceTarget);

        int getSyncedPercentage(String beltLabel) {
          try {
            var b = ringController.detailedBeltData.firstWhereOrNull((belt) {
              final definition = BeltDefinitions.getByName(beltLabel);
              return belt.beltColor == definition.id ||
                  belt.beltColor == definition.id ||
                  belt.beltColor == beltLabel;
            });

            if (b != null) {
              return (b.progressPercentage ?? 0.0).round();
            }
          } catch (e) {
            print("Error fetching backend percentage for $beltLabel: $e");
          }
          return ringController.getPercentage(beltLabel);
        }

        int brownPercentage = getSyncedPercentage('Brown');
        bool isBlackLocked = brownPercentage < 100;

        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // WHITE BELT
                    _buildBeltCard(
                      context: context,
                      beltName: 'White Belt - Get Started',
                      beltId: BeltDefinitions.white,
                      percentage: getSyncedPercentage('White'),
                      color: Colors.white,
                      totalSessions: totalSessions,
                      totalActiveDays: totalActiveDays,
                      resourcesOpened: resourcesOpened,
                    ),
                    const SizedBox(height: 16),


                    _buildBeltCard(
                      context: context,
                      beltName: 'Yellow Belt - Build Consistency',
                      beltId: BeltDefinitions.yellow,
                      percentage: getSyncedPercentage('Yellow'),
                      color: const Color(0xFFFFD700),
                      totalSessions: totalSessions,
                      totalActiveDays: totalActiveDays,
                    ),
                    const SizedBox(height: 16),

                    _buildBeltCard(
                      context: context,
                      beltName: 'Green Belt - Start Adapting',
                      beltId: BeltDefinitions.green,
                      percentage: getSyncedPercentage('Green'),
                      color: const Color(0xFF4CAF50),
                      totalSessions: totalSessions,
                      totalActiveDays: totalActiveDays,
                      totalPosts: totalPosts,
                    ),
                    const SizedBox(height: 16),

                    // --- BLUE BELT ---
                    _buildBeltCard(
                      context: context,
                      beltName: 'Blue Belt - Support Others',
                      beltId: BeltDefinitions.blue,
                      percentage: getSyncedPercentage('Blue'),
                      color: const Color(0xFF2196F3),
                      totalSessions: totalSessions,
                      totalActiveDays: totalActiveDays,
                      totalPosts: totalPosts,
                      totalShareTips: totalShareTips,
                    ),
                    const SizedBox(height: 16),

                    _buildBeltCard(
                      context: context,
                      beltName: 'Brown Belt - Lead by Example',
                      beltId: BeltDefinitions.brown,
                      percentage: brownPercentage,
                      color: const Color(0xFFA52A2A),
                      totalSessions: totalSessions,
                      totalActiveDays: totalActiveDays,
                      totalShareTips: totalShareTips,
                    ),
                    const SizedBox(height: 16),

                    _buildBeltCard(
                      context: context,
                      beltName: 'Black Belt - Master',
                      beltId: BeltDefinitions.black,
                      percentage: brownPercentage >= 100
                          ? 100
                          : getSyncedPercentage('Black'),
                      color: const Color(0xFF000000),
                      isLocked: brownPercentage < 100,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  BeltDataResult _buildBeltTasks({
    required String beltId,
    required int totalSessions,
    required int totalActiveDays,
    required int totalPosts,
    required int totalShareTips,
    required int resourcesOpened,
    bool isLocked = false,
  }) {
    if (beltId == BeltDefinitions.black) {
      return BeltDataResult(
        [
          BeltTask(
            icon: Icons.star,
            label: isLocked ? "Not yet achieved" : "Mastery Achieved",
            value: "",
          ),
        ],
        isLocked ? 0 : 100, 
      );
    }

    final requirement = BeltRequirementsData.getFor(beltId);

    BeltProgressModelV2? beltData;
    try {
      for (var b in ringController.detailedBeltData) {
        if (b.beltColor == beltId) {
          beltData = b;
          break;
        }
      }
    } catch (e) {
      print("Error finding belt data for $beltId: $e");
    }

    List<BeltTask> tasks = [];

    double totalCurrentScore = 0.0;
    double totalTargetScore = 0.0;

    for (var taskDef in requirement.tasks) {
      String valueText = "";
      int currentMetricValue = 0;

      switch (taskDef.type) {
        case RequirementType.session:
          int calculated = (totalSessions - requirement.cumulativeSessionOffset)
              .clamp(0, taskDef.target);
          currentMetricValue = calculated;
          valueText = "$calculated Sessions";
          break;

        case RequirementType.activeDay:
          int calculated = (totalActiveDays - requirement.cumulativeDayOffset)
              .clamp(0, taskDef.target);
          currentMetricValue = calculated;
          valueText = "$calculated Days";
          break;

        case RequirementType.resource:
          currentMetricValue = resourcesOpened;
          valueText = "$resourcesOpened Resources";
          break;

        case RequirementType.recommendation:
          int currentCount = beltData?.progress.recommendationCount ?? 0;
          currentMetricValue = currentCount;
          valueText = "$currentCount Times";
          break;

        case RequirementType.reflection:
          int currentCount = 0;
          if (Get.isRegistered<SessionController>()) {
            final sessionCtrl = Get.find<SessionController>();
            currentCount = sessionCtrl.submittedReflectionSessionIds.length;
          }
          currentMetricValue = currentCount;
          valueText = "$currentCount Short Reflection";
          break;

        case RequirementType.forumPost:
          int calculated = (totalPosts - requirement.cumulativePostOffset)
              .clamp(0, taskDef.target);
          currentMetricValue = calculated;
          valueText = "$calculated time";
          break;

        case RequirementType.shareTip:
          int shareTipOffset = 0;
          if (beltId == BeltDefinitions.brown) {
            shareTipOffset = 1;
          }
          int currentCount = (totalShareTips - shareTipOffset).clamp(
            0,
            taskDef.target,
          );
          currentMetricValue = currentCount;
          valueText = "$currentCount Tip/ Res";
          break;
      }

      totalTargetScore += taskDef.target;
      totalCurrentScore += currentMetricValue.clamp(0, taskDef.target);

      tasks.add(
        BeltTask(
          icon: taskDef.icon,
          label: taskDef.dashboardLabel,
          value: valueText,
        ),
      );
    }

    int finalPercent = 0;
    if (totalTargetScore > 0) {
      finalPercent = ((totalCurrentScore / totalTargetScore) * 100).round();
    } else if (requirement.tasks.isEmpty) {
      finalPercent = 0;
    }

    return BeltDataResult(tasks, finalPercent);
  }

  Widget _buildBeltCard({
    required BuildContext context,
    required String beltName,
    required String beltId,
    required int percentage,
    required Color color,
    int totalSessions = 0,
    int totalActiveDays = 0,
    int resourcesOpened = 0,
    int totalPosts = 0,
    int totalShareTips = 0,
    bool isLocked = false,
  }) {
    String cleanName = beltName.split(' ')[0];

    final result = _buildBeltTasks(
      beltId: beltId,
      totalSessions: totalSessions,
      totalActiveDays: totalActiveDays,
      totalPosts: totalPosts,
      totalShareTips: totalShareTips,
      resourcesOpened: resourcesOpened,
      isLocked: isLocked,
    );

    int displayPercentage = isLocked ? 0 : result.percentage;

    if (percentage >= 100) displayPercentage = 100;

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          Get.snackbar(
            "Locked",
            "Complete the Brown Belt to unlock Mastery.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.white10,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
        } else {
          Get.to(
            () => BeltProgressScreen(beltName: cleanName, beltColor: color),
          );
        }
      },
      child: BeltCard(
        beltName: beltName,
        percentage: displayPercentage, 
        color: color,
        tasks: result.tasks,
        isLocked: isLocked,
      ),
    );
  }
}

class BeltTask {
  final IconData icon;
  final String label;
  final String value;
  BeltTask({required this.icon, required this.label, required this.value});
}

class BeltCard extends StatelessWidget {
  final String beltName;
  final int percentage;
  final Color color;
  final List<BeltTask> tasks;
  final bool isLocked;

  const BeltCard({
    super.key,
    required this.beltName,
    required this.percentage,
    required this.color,
    required this.tasks,
    this.isLocked = false,
  });

  String _getBeltImagePath(String name) {
    final coreName = name.split(' - ').first;
    return BeltDefinitions.getByName(coreName).assetPath;
  }

  Widget _buildBeltBadge(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name,
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: 11,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int percentageLeft = 100 - percentage;
    String progressLabel = percentage >= 100
        ? "Achieved"
        : "$percentageLeft% Left";

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFA00FFA6)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141823),
          borderRadius: BorderRadius.circular(22.5),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset(
                    _getBeltImagePath(beltName),
                    width: 85,
                    height: 85,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  progressLabel,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBeltBadge(beltName),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 80),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: tasks.map((task) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(task.icon, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                    children: [
                                      TextSpan(text: '${task.label} '),
                                      TextSpan(
                                        text: task.value,
                                        style: const TextStyle(
                                          color: Color(0xFF00FFA6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
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

class BeltDataResult {
  final List<BeltTask> tasks;
  final int percentage;
  BeltDataResult(this.tasks, this.percentage);
}
