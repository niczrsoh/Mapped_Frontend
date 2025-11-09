import 'package:flutter/material.dart';
import 'dart:math';
import 'package:get/get.dart';
import './belt_progress_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/home_controller/controller/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBg = const Color(0xFF0F1114);
    final cardBorder = const Color(0xFF00C7A7);
    // final width not needed currently

    // Height used for the drawing area of bars (not including labels)
    final chartDrawHeight = min(
      140.0,
      max(100.0, MediaQuery.of(context).size.height * 0.20),
    );

    Widget _sectionCard({required Widget child, double radius = 18}) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141823),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: cardBorder.withOpacity(0.35)),
        ),
        child: child,
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
                'Welcome back, Coach Sir Ramesh',
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
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1517),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: cardBorder.withOpacity(0.7),
                    width: 1.0,
                  ),
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
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {},
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

              const SizedBox(height: 18),

              // Certification Progress Card
              _sectionCard(
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

                    // Chart area: left Y labels + drawing area (grid lines + bars) + bottom category labels
                    SizedBox(
                      // total area includes drawing area + bottom labels row
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
                                // Drawing area (grid lines + bars)
                                Expanded(
                                  child: Stack(
                                    children: [
                                      // Grid lines: four lines at 15,10,5,0 mapped to spaceBetween
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

                                      // Bars area: align bottom to the bottom grid line (0) - REMOVED BOTTOM PADDING
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

                                            return Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: List.generate(6, (i) {
                                                final values = [
                                                  6.0,
                                                  2.5,
                                                  4.5,
                                                  10.0,
                                                  4.0,
                                                  5.0,
                                                ];
                                                final maxScale = 15.0;
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
                                                      height: normalizedHeight,
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

                                                // Make the first (white) bar tappable to open Belt Progress
                                                if (i == 0) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      Get.to(
                                                        () =>
                                                            const BeltProgressScreen(),
                                                      );
                                                    },
                                                    child: bar,
                                                  );
                                                }

                                                return bar;
                                              }),
                                            );
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

                          // Labels row aligned to the same drawing area as the bars.
                          Row(
                            children: [
                              const SizedBox(width: 40),
                              const SizedBox(width: 8),
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final availableWidth = constraints.maxWidth;
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
                                          'Red',
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

              const SizedBox(height: 14),

              // Trainee Card
              _sectionCard(
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

              const SizedBox(height: 12),

              // Today's Recommendation
              _sectionCard(
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

              const SizedBox(height: 12),

              // Quick Actions
              _sectionCard(
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

              const SizedBox(height: 12),

              // Plan a Session button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: cardBorder.withOpacity(0.8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Plan a Session',
                    style: GoogleFonts.poppins(color: Colors.white),
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

  // (labels are rendered inside the LayoutBuilder so they align to the computed barWidth)
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
