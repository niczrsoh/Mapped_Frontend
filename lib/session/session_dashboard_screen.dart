import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/session/session_upcoming_screen.dart';
import 'session_current_screen.dart';
import 'session_history_screen.dart';
import 'session_controller.dart';
import 'session_model.dart';

class SessionDashboardScreen extends StatelessWidget {
  const SessionDashboardScreen({super.key});

  String _formatDuration(dynamic duration) {
    if (duration == null) return '0 Mins';
    final d = duration.toString();
    if (d.toLowerCase().contains('min')) return d;
    return '$d Mins';
  }

  Widget _buildSessionContentRows({
    required String date,
    required String time,
    required String venue,
    required String trainees,
    required String trainer,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.calendar_today, size: 14, color: Colors.white54),
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
            const Icon(Icons.access_time, size: 14, color: Colors.white54),
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
            const Icon(Icons.group_outlined, size: 14, color: Colors.white54),
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
            const Icon(Icons.person_outline, size: 14, color: Colors.white54),
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
    );
  }

  // --- REUSABLE SCROLLABLE BOX WIDGET ---
  Widget _buildScrollableSessionBox({
    required BuildContext context,
    required String title,
    required List<SessionModel> sessions,
    required Widget Function() navigationTarget,
    double maxHeight = 105,
  }) {
    bool isEmpty = sessions.isEmpty;

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
                  // --- Header Row (Title + Notification) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // --- Scrollable List ---
                  Container(
                    constraints: BoxConstraints(
                      maxHeight:
                          maxHeight, // Limits height to make it scrollable
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: sessions.length,
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(
                          color: Colors.white.withOpacity(0.1),
                          height: 1,
                        ),
                      ),
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => navigationTarget(),
                              ),
                            );
                          },
                          // Transparent container to catch taps
                          child: Container(
                            color: Colors.transparent,
                            child: _buildSessionContentRows(
                              date: session.uiDate ?? session.date ?? '-',
                              time: _formatDuration(session.duration),
                              venue: session.venue ?? '-',
                              trainees: '${session.totalTrainees} Trainees',
                              trainer: 'Coach: Sir ${session.trainer ?? '-'}',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeBg = const Color(0xFF141823);
    final SessionController controller = Get.put(SessionController());

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

                  _buildScrollableSessionBox(
                    context: context,
                    title: 'Current',
                    sessions: controller.currentList,
                    navigationTarget: () => const SessionCurrentScreen(),
                  ),


                  _buildScrollableSessionBox(
                    context: context,
                    title: 'Upcoming',
                    sessions: controller.upcomingList,
                    navigationTarget: () => UpcomingSessionsScreen(),
                  ),

                  _buildScrollableSessionBox(
                    context: context,
                    title: 'History',
                    sessions: controller.historyList,
                    navigationTarget: () => const SessionHistoryScreen(),
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
