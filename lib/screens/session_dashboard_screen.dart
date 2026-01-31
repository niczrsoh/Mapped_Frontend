import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/screens/main_navigation_screen.dart';
import 'package:mapped_frontend/screens/session_upcoming_screen.dart';
import 'session_current_screen.dart';
import 'session_history_screen.dart';
// Import Controller
import '../controller/controller/session_controller.dart';

class SessionDashboardScreen extends StatelessWidget {
  const SessionDashboardScreen({super.key});

  Widget _sessionCard({
    required String title,
    required String date,
    required String time,
    required String venue,
    required String trainees,
    required String trainer,
    bool isEmpty = false, // Added param to handle empty states
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x1AFFFFFF), Color(0xFA00FFA6)],
        ),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF141823),
          borderRadius: BorderRadius.circular(18),
        ),
        child: isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "No $title Sessions Available",
                    style: GoogleFonts.roboto(color: Colors.white54),
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ UNCOMMENTED TITLE HERE
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          date,
                          style: GoogleFonts.roboto(
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          time,
                          style: GoogleFonts.roboto(
                            color: Colors.white54,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          venue,
                          style: GoogleFonts.roboto(
                            color: Colors.white54,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.group_outlined,
                        size: 14,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        trainees,
                        style: GoogleFonts.roboto(
                          color: Colors.white54,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          trainer,
                          style: GoogleFonts.roboto(
                            color: Colors.white54,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeBg = const Color(0xFF141823);

    // Inject Controller
    final SessionController controller = Get.put(SessionController());

    // 2. 🛑 FORCE REFRESH: Ensure we get fresh data every time this screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDashboardData();
    });

    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Session Dashboard',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.fetchDashboardData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const SizedBox(
                  height: 400,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF00FFA6)),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF26282B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Session Dashboard',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- CURRENT SESSION CARD ---
                  GestureDetector(
                    onTap: () {
                      // Navigates to the full list screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SessionCurrentScreen(),
                        ),
                      );
                    },
                    child: _sessionCard(
                      title: 'Current',
                      // ✅ THIS VARIABLE (currentSession.value) NOW ONLY HOLDS THE SINGLE LATEST SESSION
                      isEmpty: controller.currentList.isEmpty,
                      // date: controller.currentSession.value?['uiDate'] ?? '-',
                      // time: controller.currentSession.value?['time'] ?? '-',
                      // venue: controller.currentSession.value?['venue'] ?? '-',
                      // trainees:
                      //     '${controller.currentSession.value?['totalTrainees'] ?? 0} Trainees',
                      // trainer:
                      //     'Trainer: Sir ${controller.currentSession.value?['trainer'] ?? '-'}',
                      date: controller.currentList.isNotEmpty
                          ? controller.currentList[0]['uiDate'] ?? '-'
                          : '-',
                      time: controller.currentList.isNotEmpty
                          ? controller.currentList[0]['time'] ?? '-'
                          : '-',
                      venue: controller.currentList.isNotEmpty
                          ? controller.currentList[0]['venue'] ?? '-'
                          : '-',
                      trainees: controller.currentList.isNotEmpty
                          ? '${controller.currentList[0]['totalTrainees']} Trainees'
                          : '0 Trainees',
                      trainer: controller.currentList.isNotEmpty
                          ? 'Trainer: Sir ${controller.currentList[0]['trainer'] ?? '-'}'
                          : 'Trainer: Sir -',
                    ),
                  ),

                  // --- UPCOMING SESSION CARD ---
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpcomingSessionsScreen(),
                        ),
                      );
                    },
                    child: _sessionCard(
                      title: 'Upcoming',
                      isEmpty: controller.upcomingSession.value == null,
                      date: controller.upcomingSession.value?['uiDate'] ?? '-',
                      time: controller.upcomingSession.value?['time'] ?? '-',
                      venue: controller.upcomingSession.value?['venue'] ?? '-',
                      trainees:
                          '${controller.upcomingSession.value?['totalTrainees'] ?? 0} Trainees',
                      trainer:
                          'Trainer: Sir ${controller.upcomingSession.value?['trainer'] ?? '-'}',
                    ),
                  ),

                  // --- HISTORY SESSION CARD ---
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SessionHistoryScreen(),
                        ),
                      );
                    },
                    child: _sessionCard(
                      title: 'History',
                      isEmpty: controller.historySession.value == null,
                      date: controller.historySession.value?['uiDate'] ?? '-',
                      time: controller.historySession.value?['time'] ?? '-',
                      venue: controller.historySession.value?['venue'] ?? '-',
                      trainees:
                          '${controller.historySession.value?['totalTrainees'] ?? 0} Trainees',
                      trainer:
                          'Trainer: Sir ${controller.historySession.value?['trainer'] ?? '-'}',
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
