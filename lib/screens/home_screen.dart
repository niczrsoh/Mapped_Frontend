import 'package:flutter/material.dart';
import 'dart:math';
import 'package:get/get.dart';
import 'package:mapped_frontend/screens/belt_dashboard_screen.dart';
import 'package:mapped_frontend/screens/coaching_screen.dart';
import 'package:mapped_frontend/screens/resource_screen.dart';
import 'package:mapped_frontend/screens/search_result_screen.dart';
import 'package:mapped_frontend/screens/trainee_screen.dart';
// 1. Import the Unified Progress Screen
import './belt_progress_screen.dart';
import './session_planner_screen.dart';
import './session_dashboard_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/home_controller/controller/home_controller.dart';

// 2. Import TraineeController
import '../controller/controller/trainee_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Inject TraineeController to get access to data
    final TraineeController traineeController = Get.put(TraineeController());

    final themeBg = const Color(0xFF141823);
    final cardBorder = const Color(0xFF00C7A7);

    final LinearGradient customGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x1AFFFFFF), Color(0xFA00FFA6)],
    );

    // Height used for the drawing area of bars (not including labels)
    final chartDrawHeight = min(
      140.0,
      max(100.0, MediaQuery.of(context).size.height * 0.20),
    );

    Widget sectionCard({required Widget child, double radius = 18}) {
      return Container(
        width: double.infinity,
        // The padding here creates the "Border Width" (1.0)
        padding: const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          gradient: customGradient, // The border gradient
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16), // Original content padding
          decoration: BoxDecoration(
            color: const Color(0xFF141823), // Original Card Background
            // Inner radius must be slightly less than outer to prevent corners bleeding
            borderRadius: BorderRadius.circular(radius - 1),
          ),
          child: child,
        ),
      );
    }

    return Scaffold(
      backgroundColor: themeBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Greeting
              Text(
                'Welcome back, Coach Lieyza',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Text(
                    'Wed, Sept 2025',
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
                              hintText: 'Search Students, Sessions, Forums ...',
                              hintStyle: TextStyle(
                                // Fixed: withOpacity deprecated -> withValues
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BeltDashboardScreen(),
                    ),
                  );
                },
                child: sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row with arrows
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Certification Progress',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chevron_left, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                'This week',
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.chevron_right, color: Colors.white),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/traineeLogo.png',
                            width: 16,
                            height: 16,
                            fit: BoxFit.contain,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Trainee',
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Chart area
                      SizedBox(
                        height: chartDrawHeight + 36,
                        child: Column(
                          children: [
                            // Top part: Y labels + drawing area
                            SizedBox(
                              height: chartDrawHeight,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Y-axis labels column
                                  SizedBox(
                                    width: 40,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '15',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                        Text(
                                          '10',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                        Text(
                                          '5',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                        Text(
                                          '0',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Drawing area (grid lines + bars)
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        // Grid lines
                                        Positioned.fill(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: List.generate(4, (index) {
                                              return Container(
                                                height: 1,
                                                width: double.infinity,
                                                color: Colors.white12,
                                              );
                                            }),
                                          ),
                                        ),

                                        // Bars area
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              final availableWidth =
                                                  constraints.maxWidth;
                                              final barWidth = max(
                                                8.0,
                                                (availableWidth - 50) / 6,
                                              );

                                              // 4. Wrap Chart in Obx for Real-time Updates
                                              return Obx(() {
                                                // Helper function to count trainees by belt
                                                int getCount(String belt) {
                                                  return traineeController
                                                      .traineeList
                                                      .where(
                                                        (t) =>
                                                            t['belt']
                                                                .toString()
                                                                .toLowerCase() ==
                                                            belt.toLowerCase(),
                                                      )
                                                      .length;
                                                }

                                                // Real data values
                                                final values = [
                                                  getCount('White').toDouble(),
                                                  getCount('Yellow').toDouble(),
                                                  getCount('Green').toDouble(),
                                                  getCount('Blue').toDouble(),
                                                  getCount('Brown').toDouble(),
                                                  getCount('Black').toDouble(),
                                                ];

                                                // Dynamic Scale: Ensure bars don't overflow if count > 15
                                                // Default maxScale is 15.0 to match labels
                                                double maxDataValue = values
                                                    .reduce(max);
                                                final maxScale =
                                                    maxDataValue > 15.0
                                                    ? maxDataValue
                                                    : 15.0;

                                                return Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: List.generate(6, (
                                                    i,
                                                  ) {
                                                    final normalizedHeight =
                                                        (values[i] / maxScale) *
                                                        chartDrawHeight;

                                                    final barGradients = [
                                                      [
                                                        Color(0xFFF1E1E4),
                                                        Colors.white,
                                                      ],
                                                      [
                                                        Color(0xFFF1E1E4),
                                                        Color(0xFFF5FB32),
                                                      ],
                                                      [
                                                        Color(0xFFF1E1E4),
                                                        Color(0xFF00FFA6),
                                                      ],
                                                      [
                                                        Color(0xFFF1E1E4),
                                                        Color(0xFF1DC4F3),
                                                      ],
                                                      [
                                                        Colors.white,
                                                        Color(0xFFFF0004),
                                                      ],
                                                      [
                                                        Colors.white,
                                                        Color(0xFF000000),
                                                      ],
                                                    ];

                                                    Widget bar = Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                          width: barWidth,
                                                          height:
                                                              normalizedHeight,
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                              colors:
                                                                  barGradients[i],
                                                            ),
                                                            borderRadius:
                                                                const BorderRadius.only(
                                                                  topLeft:
                                                                      Radius.circular(
                                                                        6,
                                                                      ),
                                                                  topRight:
                                                                      Radius.circular(
                                                                        6,
                                                                      ),
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    );

                                                    // --- NAVIGATION LOGIC ---
                                                    if (i == 0) {
                                                      // White
                                                      return GestureDetector(
                                                        onTap: () {
                                                          Get.to(
                                                            () =>
                                                                const BeltProgressScreen(
                                                                  beltName:
                                                                      'White',
                                                                  beltColor:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                          );
                                                        },
                                                        child: bar,
                                                      );
                                                    }
                                                    if (i == 1) {
                                                      // Yellow
                                                      return GestureDetector(
                                                        onTap: () {
                                                          Get.to(
                                                            () => const BeltProgressScreen(
                                                              beltName:
                                                                  'Yellow',
                                                              beltColor: Color(
                                                                0xFFF5FB32,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: bar,
                                                      );
                                                    }
                                                    if (i == 2) {
                                                      // Green
                                                      return GestureDetector(
                                                        onTap: () {
                                                          Get.to(
                                                            () => const BeltProgressScreen(
                                                              beltName: 'Green',
                                                              beltColor: Color(
                                                                0xFF00FFA6,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: bar,
                                                      );
                                                    }
                                                    if (i == 3) {
                                                      // Blue
                                                      return GestureDetector(
                                                        onTap: () {
                                                          Get.to(
                                                            () => const BeltProgressScreen(
                                                              beltName: 'Blue',
                                                              beltColor: Color(
                                                                0xFF2196F3,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: bar,
                                                      );
                                                    }
                                                    if (i == 4) {
                                                      // Brown
                                                      return GestureDetector(
                                                        onTap: () {
                                                          Get.to(
                                                            () => const BeltProgressScreen(
                                                              beltName: 'Brown',
                                                              beltColor: Color(
                                                                0xFFA52A2A,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: bar,
                                                      );
                                                    }
                                                    if (i == 5) {
                                                      // Black
                                                      return GestureDetector(
                                                        onTap: () {
                                                          Get.to(
                                                            () => const BeltProgressScreen(
                                                              beltName: 'Black',
                                                              beltColor: Color(
                                                                0xFF000000,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: bar,
                                                      );
                                                    }
                                                    return bar;
                                                  }),
                                                );
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Labels row
                            Row(
                              children: [
                                const SizedBox(width: 40),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final availableWidth =
                                          constraints.maxWidth;
                                      final barWidth = max(
                                        8.0,
                                        (availableWidth - 50) / 6,
                                      );

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          for (final label in [
                                            'White',
                                            'Yellow',
                                            'Green',
                                            'Blue',
                                            'Brown',
                                            'Black',
                                          ])
                                            SizedBox(
                                              width: barWidth,
                                              child: Text(
                                                label,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                            'Trainee',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Monitor the trainee',
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

              // Today's Recommendation
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
                      builder: (context) => const ResourcesScreen(),
                    ),
                  );
                },
                child: sectionCard(
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
                // 1. Outer Container: The Gradient Border
                padding: const EdgeInsets.all(1.0), // Border Width
                decoration: BoxDecoration(
                  gradient: customGradient, // Uses the variable defined at top
                  borderRadius: BorderRadius.circular(16),
                ),
                // 2. Inner Container: The Background Color
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        themeBg, // Match your screen background (Color(0xFF0F1114))
                    borderRadius: BorderRadius.circular(15), // 16 - 1
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors
                          .transparent, // Button is transparent so inner container color shows
                      shadowColor: Colors.transparent, // Remove default shadow
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
                          builder: (context) => const SessionPlannerScreen(),
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
    );
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
