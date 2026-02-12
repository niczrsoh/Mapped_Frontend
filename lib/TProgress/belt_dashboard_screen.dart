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

  String _calculateCurrentBeltCode() {
    final belts = BeltDefinitions.belts;
    String currentBeltCode = BeltDefinitions.white;

    for (int i = 0; i < belts.length; i++) {
      final code = belts[i].id;
      final data = ringController.detailedBeltData
          .firstWhereOrNull((b) => b.beltColor == code);

      bool isPassed = data?.isCompleted ?? false;

      if (!isPassed) {
        currentBeltCode = code;
        break;
      }
      if (i == belts.length - 1) {
        currentBeltCode = code;
      }
    }
    return currentBeltCode;
  }

  @override
  Widget build(BuildContext context) {
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
        final String currentBeltCode = _calculateCurrentBeltCode();

        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildBeltCard(
                      context: context,
                      beltName: 'White Belt - Get Started',
                      beltId: BeltDefinitions.white,
                      color: Colors.white,
                      currentBeltCode: currentBeltCode,
                    ),
                    const SizedBox(height: 16),
                    _buildBeltCard(
                      context: context,
                      beltName: 'Yellow Belt - Build Consistency',
                      beltId: BeltDefinitions.yellow,
                      color: const Color(0xFFFFD700),
                      currentBeltCode: currentBeltCode,
                    ),
                    const SizedBox(height: 16),
                    _buildBeltCard(
                      context: context,
                      beltName: 'Green Belt - Start Adapting',
                      beltId: BeltDefinitions.green,
                      color: const Color(0xFF4CAF50),
                      currentBeltCode: currentBeltCode,
                    ),
                    const SizedBox(height: 16),
                    _buildBeltCard(
                      context: context,
                      beltName: 'Blue Belt - Support Others',
                      beltId: BeltDefinitions.blue,
                      color: const Color(0xFF2196F3),
                      currentBeltCode: currentBeltCode,
                    ),
                    const SizedBox(height: 16),
                    _buildBeltCard(
                      context: context,
                      beltName: 'Brown Belt - Lead by Example',
                      beltId: BeltDefinitions.brown,
                      color: const Color(0xFFA52A2A),
                      currentBeltCode: currentBeltCode,
                    ),
                    const SizedBox(height: 16),
                    _buildBeltCard(
                      context: context,
                      beltName: 'Black Belt - Master',
                      beltId: BeltDefinitions.black,
                      color: const Color(0xFF000000),
                      currentBeltCode: currentBeltCode,
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
    required BeltProgressModelV2? beltData,
  }) {
    if (beltId == BeltDefinitions.black) {
      bool achieved = beltData?.isCompleted ?? false;

      return BeltDataResult(
        [
          BeltTask(
            icon: Icons.star,
            label: achieved ? "Mastery Achieved" : "Not yet achieved",
            value: "",
          ),
        ],
        achieved ? 100 : 0, 
      );
    }

    final requirement = BeltRequirementsData.getFor(beltId);
    List<BeltTask> tasks = [];

    int currentSess = beltData?.planSessionCount ?? 0;
    int currentDays = beltData?.progress.activeDayCount ?? 0;
    int openResources = beltData?.progress.openResourceCount ?? 0;
    int currentRecs = beltData?.progress.recommendationCount ?? 0;
    int currentPosts = beltData?.progress.postCount ?? 0;
    int currentTips = beltData?.progress.shareTipCount ?? 0;
    int currentReflect = beltData?.progress.reflectionCount ?? 0;


    double totalCurrentScore = 0.0;
    double totalTargetScore = 0.0;

    for (var taskDef in requirement.tasks) {
      String valueText = "";
      int currentMetricValue = 0;

      switch (taskDef.type) {
        case RequirementType.session:
          currentMetricValue = currentSess;
          valueText = "$currentSess Sessions";
          break;
        case RequirementType.activeDay:
          currentMetricValue = currentDays;
          valueText = "$currentDays Days";
          break;
        case RequirementType.resource:
          currentMetricValue = openResources;
          valueText = "$openResources Resources";
          break;
        case RequirementType.recommendation:
          currentMetricValue = currentRecs;
          valueText = "$currentRecs Times";
          break;
        case RequirementType.reflection:
          currentMetricValue = beltData?.progress.reflectionCount ?? 0;
          valueText = "$currentReflect Short Reflection";
          break;
        case RequirementType.forumPost:
          currentMetricValue = currentPosts;
          valueText = "$currentPosts time";
          break;
        case RequirementType.shareTip:
          currentMetricValue = currentTips;
          valueText = "$currentTips Tip/ Res";
          break;
        case RequirementType.mastery:
          currentMetricValue = 1; // Arbitrary value, doesn't matter since target is 0
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
    }
    
    if (beltData != null && beltData.isCompleted) finalPercent = 100;

    return BeltDataResult(tasks, finalPercent);
  }

  Widget _buildBeltCard({
    required BuildContext context,
    required String beltName,
    required String beltId,
    required Color color,
    required String currentBeltCode,
  }) {
    String cleanName = beltName.split(' ')[0];
    
    BeltProgressModelV2? beltData;
    try {
      beltData = ringController.detailedBeltData.firstWhereOrNull(
        (b) => b.beltColor == beltId || b.beltColor == cleanName
      );
    } catch (e) {
      // no data found
    }

    final result = _buildBeltTasks(
      beltId: beltId,
      beltData: beltData,
    );

    int displayPercentage = result.percentage;
    if (displayPercentage >= 100) displayPercentage = 100;

    // Lock Logic matching Home Screen
    bool isLocked = false;
    if (beltId == BeltDefinitions.black && currentBeltCode != BeltDefinitions.black) {
      isLocked = true;
    }

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

class BeltDataResult {
  final List<BeltTask> tasks;
  final int percentage;
  BeltDataResult(this.tasks, this.percentage);
}

class BeltCard extends StatelessWidget {
  final String beltName;
  final int percentage;
  final Color color;
  final List<BeltTask> tasks;

  const BeltCard({
    super.key,
    required this.beltName,
    required this.percentage,
    required this.color,
    required this.tasks,
  });

  String _getBeltImagePath(String name) {
    final coreName = name.split(' - ').first;
    return BeltDefinitions.getByName(coreName).assetPath;
  }

  Widget _buildBeltBadge(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
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
        // Visual Style: White -> Green gradient
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
          color: const Color(0xFF141823), // Dark Inner background
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
                                          // Visual Style: Specific Green for values
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