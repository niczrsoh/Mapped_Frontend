import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/screens/session_upcoming_screen.dart';
import 'session_current_screen.dart';
import 'session_history_screen.dart';

class SessionDashboardScreen extends StatelessWidget {
  const SessionDashboardScreen({super.key});

  Widget _sessionCard({
    required String title,
    required String date,
    required String time,
    required String venue,
    required String trainees,
    required String trainer,
  }) {
    // Match the 'Current' card style from SessionCurrentScreen:
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(1), // simulate 1px gradient border
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            // Date with calendar icon (restored)
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
                    'Trainer : $trainer',
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
    final themeBg = const Color(0xFF0F1114);

    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // leading: IconButton(
        //   padding: EdgeInsets.zero,
        //   constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        //   icon: const Icon(Icons.chevron_left, color: Colors.white),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
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

              GestureDetector(
                onTap: () => Get.to(() => const SessionCurrentScreen()),
                child: _sessionCard(
                  title: 'Current',
                  date: 'Wed, Sept 21, 2025',
                  time: '6:00 - 7:00 PM',
                  venue: 'Dewan Sekolah Rendah Sri Gading, Main Hall',
                  trainees: '25 Trainees',
                  trainer: 'Sir Ramesh',
                ),
              ),

              GestureDetector(
                onTap: () => Get.to(() => UpcomingSessionsScreen()),
                child: _sessionCard(
                  title: 'Upcoming',
                  date: 'Wed, Sept 21, 2025',
                  time: '6:00 - 7:00 PM',
                  venue: 'Dewan Sekolah Rendah Sri Gading, Main Hall',
                  trainees: '25 Trainees',
                  trainer: 'Sir Ramesh',
                ),
              ),

              GestureDetector(
                onTap: () => Get.to(() => const SessionHistoryScreen()),
                child: _sessionCard(
                  title: 'History',
                  date: 'Wed, Sept 21, 2025',
                  time: '6:00 - 7:00 PM',
                  venue: 'Dewan Sekolah Rendah Sri Gading, Main Hall',
                  trainees: '25 Trainees',
                  trainer: 'Sir Ramesh',
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
