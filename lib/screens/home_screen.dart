import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/TProgress/belt_progress_screen.dart';
import 'package:mapped_frontend/controller/user_controller';
import 'package:mapped_frontend/TProgress/belt_dashboard_screen.dart';
import 'package:mapped_frontend/forum/forum_screen.dart';
import 'package:mapped_frontend/forum/forum_controller.dart';
import 'package:mapped_frontend/recommendation/coaching_screen.dart';
import 'package:mapped_frontend/resource/resource_screen.dart';
import 'package:mapped_frontend/Participants/trainee_screen.dart';
import 'package:mapped_frontend/session/session_planner.dart';
import 'package:mapped_frontend/session/session_dashboard_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/controller/controller/trainer_controller.dart';
import 'package:mapped_frontend/session/session_controller.dart';
import 'package:mapped_frontend/resource/resource_controller.dart';
import 'package:mapped_frontend/comment/comment_controller.dart';
import 'package:mapped_frontend/create_post/create_post_controller.dart';
import 'package:mapped_frontend/TProgress/belt_progress_ring_controller.dart';
import 'package:mapped_frontend/TProgress/belt_progress_modelV2.dart';
import 'package:mapped_frontend/TProgress/data/belt_definitions.dart';
import 'package:mapped_frontend/TProgress/data/belt_requirements.dart';
import 'package:mapped_frontend/screens/home_search.dart';

final customGradient = const LinearGradient(
  colors: [Color(0xFF00C7A7), Color(0xFF00FF66)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isLoading = true; // 👈 Loading flag

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Ensure ForumController is registered before controllers that depend on it
    Get.put(ForumController());
    Get.put(TrainerController());
    Get.put(SessionController());
    Get.put(ResourceController());
    Get.put(CommentsController());
    Get.put(CreatePostController());
    Get.put(BeltProgressRingController());

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
    if (mounted) setState(() => _isLoading = true); // 👈 Show loader

    try {
      final trainerCtrl = Get.find<TrainerController>();
      final beltCtrl = Get.find<BeltProgressRingController>();
      final sessionCtrl = Get.isRegistered<SessionController>()
          ? Get.find<SessionController>()
          : Get.put(SessionController());

      await trainerCtrl.updateActiveDays();
      // Ensure server-side daily-check completes, then refresh belt progress before sessions
      await beltCtrl.fetchBeltProgress();
      await sessionCtrl.fetchDashboardData();
    } catch (e) {
      print("Error refreshing home data: $e");
      // Optionally show a snackbar here
    } finally {
      if (mounted) setState(() => _isLoading = false); // 👈 Hide loader
    }
  }

  @override
  Widget build(BuildContext context) {
    // If still loading, show a centered progress indicator
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF141823),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00FF66),
          ),
        ),
      );
    }

    // Otherwise, show the normal content
    final sessionController = Get.isRegistered<SessionController>()
        ? Get.find<SessionController>()
        : Get.put(SessionController());
    final themeBg = const Color(0xFF141823);
    final UserController userController = Get.find<UserController>();
    final BeltProgressRingController beltController =
        Get.find<BeltProgressRingController>();

    Widget sectionCard({required Widget child, double radius = 18}) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          gradient: customGradient,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF141823),
            borderRadius: BorderRadius.circular(radius - 1),
          ),
          child: child,
        ),
      );
    }

    return Scaffold(
      backgroundColor: themeBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData, // 👈 Now uses the same refresh method
          color: const Color.fromARGB(255, 255, 255, 255),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Greeting
                Obx(() {
                  final userName = userController.userName;
                  return Text(
                    'Welcome back, Coach $userName',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Text(
                      _getCurrentDate(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(' - ', style: TextStyle(color: Colors.white24)),
                    const SizedBox(width: 8),
                    Obx(() {
                      final count = sessionController.currentList.length;
                      final label =
                          "$count ${count == 1 ? 'session' : 'sessions'} today";
                      return Text(
                        label,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 18),
                // Search bar
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeSearchScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.all(1.0),
                    decoration: BoxDecoration(
                      gradient: customGradient,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E1517),
                        borderRadius: BorderRadius.circular(39),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              enabled: false,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                isCollapsed: true,
                                hintText:
                                    'Search Students, Sessions, Forums ...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                              ),
                              readOnly: true,
                              onTap: () {
                                Get.snackbar(
                                  'Coming Soon',
                                  'Search feature will be available soon',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Belt Progress Card
                GestureDetector(
                  onTap: () {
                    Get.to(
                      () => const BeltDashboardScreen(),
                    )?.then((_) => _refreshData());
                  },
                  child: sectionCard(
                    child: Obx(() {
                      final belts = BeltDefinitions.belts;
                      final beltOrder = belts.map((b) => b.id).toList();

                      BeltProgressModelV2? currentBeltData;
                      String currentBeltCode = BeltDefinitions.white;
                      int currentBeltIndex = 0;

                      for (int i = 0; i < belts.length; i++) {
                        final beltDef = belts[i];
                        final code = beltDef.id;

                        final data = beltController.detailedBeltData
                            .firstWhereOrNull((b) => b.beltColor == code);
                            
                        bool isPassed = data?.isCompleted ?? false;

                        if (!isPassed) {
                          currentBeltData = data;
                          currentBeltCode = code;
                          currentBeltIndex = i;
                          break;
                        }
                        if (i == belts.length - 1) {
                          currentBeltData = data;
                          currentBeltCode = code;
                          currentBeltIndex = i;
                        }
                      }

                      final requirement = BeltRequirementsData.getFor(
                        currentBeltCode,
                      );
                      double progress = 0.0;

                      if (currentBeltData != null) {
                        progress = _calculateProgressPercentageFromModel(
                          requirement,
                          currentBeltData,
                        );
                      }

                      final currentBeltDef = BeltDefinitions.getByCode(
                        currentBeltCode,
                      );
                      final String beltName = currentBeltDef.name;
                      final Color beltColor = currentBeltDef.color;

                      final String nextBeltName =
                          (currentBeltIndex < belts.length - 1)
                          ? belts[currentBeltIndex + 1].name
                          : "Mastery";

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Certification Progress',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_run,
                                color: Color.fromARGB(255, 255, 255, 255),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Current Belt: ',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                beltName,
                                style: GoogleFonts.poppins(
                                  color: beltColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(beltOrder.length, (index) {
                              final thisCode = beltOrder[index];

                              bool isLocked = false;
                              if (thisCode == BeltDefinitions.black &&
                                  currentBeltCode != BeltDefinitions.black) {
                                isLocked = true;
                              }

                              return GestureDetector(
                                onTap: () {
                                  if (isLocked) {
                                    Get.snackbar(
                                      "Locked",
                                      "Complete the Brown Belt to unlock Mastery.",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.white12,
                                      colorText: Colors.white,
                                      margin: const EdgeInsets.all(16),
                                    );
                                  } else {
                                    Get.to(
                                      () => BeltProgressScreen(
                                        beltName: _getBeltName(thisCode),
                                        beltColor: _getBeltColor(thisCode),
                                      ),
                                    )?.then((_) => _refreshData());
                                  }
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      _getBeltImage(thisCode),
                                      width: 34,
                                      height: 34,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getBeltName(thisCode),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress to $nextBeltName Belt',
                                style: GoogleFonts.poppins(
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${progress.round()}%',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress / 100,
                              minHeight: 8,
                              backgroundColor: Colors.grey[800],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                beltColor,
                              ),
                            ),
                          ),
                          if (currentBeltCode != BeltDefinitions.black) ...[
                            const SizedBox(height: 20),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  'Remaining Requirements',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    String nextCode;
                                    if (currentBeltIndex < belts.length - 1) {
                                      nextCode = belts[currentBeltIndex + 1].id;
                                    } else {
                                      nextCode = belts.last.id;
                                    }
                                    final nextColor = _getBeltColor(nextCode);
                                    final nextName = _getBeltName(nextCode);
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          _getBeltImage(currentBeltCode),
                                          width: 18,
                                          height: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          beltName,
                                          style: GoogleFonts.poppins(
                                            color: beltColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.arrow_right_alt_rounded,
                                          color: Colors.white54,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Image.asset(
                                          _getBeltImage(nextCode),
                                          width: 18,
                                          height: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          nextName,
                                          style: GoogleFonts.poppins(
                                            color: nextColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildRequirementText(
                              currentBeltCode,
                              currentBeltData,
                            ),
                          ] else ...[
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFF00FF66),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Mastery Achieved",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF00FF66),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 14),
                // Trainee Card
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TraineesScreen(),
                      ),
                    );
                  },
                  child: sectionCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Participants',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Participant information',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: Center(
                            child: Icon(
                              Icons.people_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => const DailyCoachingScreen(),
                          ),
                        )
                        .then((_) => _refreshData());
                  },
                  child: sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Recommendation",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Adapting warm-up for all abilities',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (context) => ResourceScreen(),
                                      ),
                                    )
                                    .then((_) => _refreshData());
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Resource',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.book, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (context) => ForumScreen(),
                                      ),
                                    )
                                    .then((_) => _refreshData());
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Forum',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.forum_outlined,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(1.0),
                  decoration: BoxDecoration(
                    gradient: customGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Container(
                    decoration: BoxDecoration(
                      color: themeBg,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SessionPlannerScreen(),
                          ),
                        ).then((_) => _refreshData());
                      },
                      child: Text(
                        'Plan a Session',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // All helper methods remain unchanged
  String _getCurrentDate() {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day} ${now.year}';
  }

  Widget _buildRequirementText(String code, BeltProgressModelV2? data) {
    final requirement = BeltRequirementsData.getFor(code);

    List<Widget> reqs = [];

    for (var task in requirement.tasks) {
      int currentValue = _getProgressValue(task, data, requirement);

      String text = "${task.homeLabel}: $currentValue / ${task.target}";

      if (task.type == RequirementType.activeDay) {
        text += " days";
      }

      reqs.add(_reqLine(text));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: reqs);
  }

  Widget _reqLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  int _getProgressValue(
    BeltTaskDef task,
    BeltProgressModelV2? data,
    BeltRequirement requirement,
  ) {
    if (data == null) return 0;

    switch (task.type) {
      case RequirementType.session:
        return data.planSessionCount.clamp(0, task.target);

      case RequirementType.activeDay:
        final trainerCtrl = Get.find<TrainerController>();
        int modelCount = data.progress.activeDayCount;
        int freshCount = trainerCtrl.activeDaysCount.value;
        int displayCount = (freshCount > modelCount) ? freshCount : modelCount;

        return displayCount.clamp(0, task.target);

      case RequirementType.resource:
        return data.progress.openResourceCount.clamp(0, task.target);

      case RequirementType.recommendation:
        return data.progress.recommendationCount.clamp(0, task.target);

      case RequirementType.reflection:
        return data.progress.reflectionCount.clamp(0, task.target);

      case RequirementType.forumPost:
        return data.progress.postCount.clamp(0, task.target);

      case RequirementType.shareTip:
        return data.progress.shareTipCount.clamp(0, task.target);

      case RequirementType.mastery:
        return 1;
    }
  }

  double _calculateProgressPercentageFromModel(
    BeltRequirement req,
    BeltProgressModelV2 data,
  ) {
    if (req.beltId == BeltDefinitions.black) {
      return 100.0;
    }

    if (data.progressPercentage != null && data.progressPercentage! > 0) {
      return data.progressPercentage!;
    }

    final trainerCtrl = Get.find<TrainerController>();
    double currentProgressSum = 0;
    double targetProgressSum = 0;

    for (var task in req.tasks) {
      targetProgressSum += task.target;
      int val = 0;

      switch (task.type) {
        case RequirementType.session:
          val = data.planSessionCount;
          break;
        case RequirementType.activeDay:
          int modelCount = data.progress.activeDayCount;
          int freshCount = trainerCtrl.activeDaysCount.value;
          val = (freshCount > modelCount) ? freshCount : modelCount;
          break;
        case RequirementType.resource:
          val = data.progress.openResourceCount;
          break;
        case RequirementType.recommendation:
          val = data.progress.recommendationCount;
          break;
        case RequirementType.reflection:
          val = data.progress.reflectionCount;
          break;
        case RequirementType.forumPost:
          val = data.progress.postCount;
          break;
        case RequirementType.shareTip:
          val = data.progress.shareTipCount;
          break;
        case RequirementType.mastery:
          val = 1;
          break;
      }
      currentProgressSum += val.clamp(0, task.target);
    }

    return targetProgressSum > 0
        ? ((currentProgressSum / targetProgressSum) * 100).clamp(0.0, 100.0)
        : 0.0;
  }

  String _getBeltName(String code) {
    return BeltDefinitions.getByCode(code).name;
  }

  Color _getBeltColor(String code) {
    return BeltDefinitions.getByCode(code).color;
  }

  String _getBeltImage(String code) {
    return BeltDefinitions.getByCode(code).assetPath;
  }
}

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Get.to(() => const SessionDashboardScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C23),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.sports_gymnastics_outlined, "Home", 0),
          _buildNavItem(Icons.fitness_center_outlined, "Session", 1),
          _buildNavItem(Icons.forum_outlined, "Forum", 2),
          _buildNavItem(Icons.smart_toy_outlined, "Coach Bot", 3),
          _buildNavItem(Icons.account_circle_outlined, "Account", 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: isSelected
                ? const Color(0xFF00FF66)
                : const Color(0xFFEFE4F8),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isSelected
                  ? const Color(0xFF00FF66)
                  : const Color(0xFFEFE4F8),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}