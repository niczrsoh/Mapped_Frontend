import 'package:flutter/material.dart';
import 'dart:math';
import 'package:get/get.dart';
import 'package:mapped_frontend/TProgress/belt_progress_screen.dart';
import 'package:mapped_frontend/controller/user_controller';
import 'package:mapped_frontend/TProgress/belt_dashboard_screen.dart';
import 'package:mapped_frontend/screens/coaching_screen.dart';
import 'package:mapped_frontend/resource/resource_screen.dart';
import 'package:mapped_frontend/screens/search_result_screen.dart';
import 'package:mapped_frontend/Participants/trainee_screen.dart';
import 'package:mapped_frontend/session/session_planner.dart';
import 'package:mapped_frontend/session/session_dashboard_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/home_controller/controller/home_controller.dart';
import 'package:mapped_frontend/controller/controller/trainer_controller.dart';
import 'package:mapped_frontend/session/session_controller.dart';
import 'package:mapped_frontend/controller/controller/resource_controller.dart';

// - Importing to access belt logic
import 'package:mapped_frontend/TProgress/belt_progress_ring_controller.dart';
import 'package:mapped_frontend/TProgress/belt_progress_modelV2.dart';
import 'package:mapped_frontend/TProgress/data/belt_definitions.dart';
import 'package:mapped_frontend/TProgress/data/belt_requirements.dart';

final customGradient = const LinearGradient(
  colors: [Color(0xFF00C7A7), Color(0xFF00FF66)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TrainerController trainerController = Get.put(TrainerController());

    final themeBg = const Color(0xFF141823);

    final UserController userController = Get.find<UserController>();
    final BeltProgressRingController beltController = Get.put(
      BeltProgressRingController(),
    );
    final SessionController sessionController = Get.put(SessionController());
    final ResourceController resourceController = Get.put(ResourceController());

    final chartDrawHeight = min(
      140.0,
      max(100.0, MediaQuery.of(context).size.height * 0.20),
    );

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
          onRefresh: () async {
            await beltController.fetchBeltProgress();
          },
          color: const Color.fromARGB(255, 255, 255, 255),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Greeting - Using actual user name
                Obx(() {
                  final userName = userController.userName;
                  print('👤 HomeScreen - User name: $userName');

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
                    // Display current date
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
                    Text(
                      '3 sessions today',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                // Search bar
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SearchResultsScreen(),
                      ),
                    );
                  },

                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.all(1.0), // Border Width
                    decoration: BoxDecoration(
                      gradient: customGradient,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E1517),
                        borderRadius: BorderRadius.circular(39), // 40 - 1
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
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
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SearchResultsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SearchResultsScreen(),
                                ),
                              );
                            },
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: const Center(
                                child: Icon(
                                  Icons.search,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () {
                    // Navigate to detailed dashboard on tap
                    Get.to(() => const BeltDashboardScreen());
                  },
                  child: sectionCard(
                    child: Obx(() {
                      final belts = BeltDefinitions.belts;
                      final beltOrder = belts.map((b) => b.id).toList();

                      final int totalSessions =
                          sessionController.totalSessionsCount.value;
                      final int totalDays =
                          trainerController.activeDaysCount.value;
                      final int totalResources =
                          resourceController.viewedResourceIds.length;

                      BeltProgressModelV2? currentBeltData;
                      String currentBeltCode = BeltDefinitions.white;
                      int currentBeltIndex = 0;

                      // Loop through to find the first belt that is NOT 100% completed
                      for (int i = 0; i < belts.length; i++) {
                        final beltDef = belts[i];
                        final code = beltDef.id;

                        // Get backend data object if exists (for some metadata)
                        final data = beltController.detailedBeltData
                            .firstWhereOrNull((b) => b.beltColor == code);
                        bool isPassed = false;
                        if (data != null) {
                          final reqCheck = BeltRequirementsData.getFor(code);
                          isPassed = _isBeltStrictlyPassed(reqCheck, data);
                        }

                        // If NOT passed, this is our current belt.
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

                      // --- CALCULATE PROGRESS FROM MODEL DATA ---
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
                          // A. Header Title
                          Text(
                            'My Certification Progress',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // B. Current Belt Indicator (Icon + Name)
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
                              final code = beltOrder[index];
                              final isActive = index == currentBeltIndex;

                              return GestureDetector(
                                onTap: () {
                                  Get.to(
                                    () => BeltProgressScreen(
                                      beltName: _getBeltName(code),
                                      beltColor: _getBeltColor(code),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      _getBeltImage(code),
                                      width: 34,
                                      height: 34,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getBeltName(code),
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
                                '${progress.toInt()}%',
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
                              value: progress / 100, // Normalized 0.0 to 1.0
                              minHeight: 8,
                              backgroundColor: Colors.grey[800],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                beltColor,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // E. Requirements Section
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
                                  if (currentBeltIndex < beltOrder.length - 1) {
                                    nextCode = beltOrder[currentBeltIndex + 1];
                                  } else {
                                    nextCode = beltOrder.last;
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DailyCoachingScreen(),
                      ),
                    );
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

              // Quick Actions
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ResourceScreen(),
                    ),
                  );
                },
                child: _sectionCard(
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
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                        ],
                      ),
                    ],
                  ),
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
                        );
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
      int currentValue = _getProgressValue(task.type, data);
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

  int _getProgressValue(RequirementType type, BeltProgressModelV2? data) {
    if (data == null) return 0;

    switch (type) {
      case RequirementType.session:
        return data.planSessionCount;
      case RequirementType.activeDay:
        return data.progress.activeDayCount;
      case RequirementType.resource:
        return data.progress.openResourceCount;
      case RequirementType.recommendation:
        return data.progress.recommendationCount;
      case RequirementType.uploadPhoto:
        return data.progress.sessionPhotoCount;
      case RequirementType.reflection:
        return data.progress.writeShortDescriptionCount;
      case RequirementType.forumPost:
        return data.progress.postCount;
      case RequirementType.shareTip:
        return data.progress.shareTipCount;
      default:
        return 0;
    }
  }

  bool _isBeltStrictlyPassed(BeltRequirement req, BeltProgressModelV2 data) {
    for (var task in req.tasks) {
      int val = 0;
      switch (task.type) {
        case RequirementType.session:
          val = data.planSessionCount;
          break;
        case RequirementType.activeDay:
          val = data.progress.activeDayCount;
          break;
        case RequirementType.resource:
          val = data.progress.openResourceCount;
          break;
        case RequirementType.recommendation:
          val = data.progress.recommendationCount;
          break;
        case RequirementType.uploadPhoto:
          val = data.progress.sessionPhotoCount;
          break;
        case RequirementType.reflection:
          val = data.progress.writeShortDescriptionCount;
          break;
        case RequirementType.forumPost:
          val = data.progress.postCount;
          break;
        case RequirementType.shareTip:
          val = data.progress.shareTipCount;
          break;
      }

      // If any single task is not met, the belt is NOT passed.
      if (val < task.target) {
        return false;
      }
    }
    return true;
  }

  double _calculateProgressPercentageFromModel(
    BeltRequirement req,
    BeltProgressModelV2 data,
  ) {
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
          val = data.progress.activeDayCount;
          break;
        case RequirementType.resource:
          val = data.progress.openResourceCount;
          break;
        case RequirementType.recommendation:
          val = data.progress.recommendationCount;
          break;
        case RequirementType.uploadPhoto:
          val = data.progress.sessionPhotoCount;
          break;
        case RequirementType.reflection:
          val = data.progress.writeShortDescriptionCount;
          break;
        case RequirementType.forumPost:
          val = data.progress.postCount;
          break;
        case RequirementType.shareTip:
          val = data.progress.shareTipCount;
          break;
      }
      currentProgressSum += val.clamp(0, task.target);
    }

    return targetProgressSum > 0
        ? ((currentProgressSum / targetProgressSum) * 100).clamp(0.0, 100.0)
        : 0.0;
  }

  int _getTaskTarget(BeltRequirement req, RequirementType type) {
    try {
      return req.tasks.firstWhere((t) => t.type == type).target;
    } catch (e) {
      return 0;
    }
  }

  // --- [MOVED] Constant Helpers for Belt Colors & Data ---
  String _getBeltName(String code) {
    return BeltDefinitions.getByCode(code).name;
  }

  Color _getBeltColor(String code) {
    return BeltDefinitions.getByCode(code).color;
  }

  // Map belt code to your asset images
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
    // if Session tab tapped, navigate to Session Dashboard
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
