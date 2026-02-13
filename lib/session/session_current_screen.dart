import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'session_controller.dart';

class SessionCurrentScreen extends StatelessWidget {
  const SessionCurrentScreen({super.key});

  Widget _smallSessionRow({
    required String date,
    required String time,
    required String venue,
    required String trainees,
    required String trainer,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
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
                    color: Colors.white,
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
                    color: Colors.white,
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
                    color: Colors.white,
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
                  color: Colors.white,
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
                  'Coach : $trainer',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
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
    );
  }

  Widget _planCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF141823),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ai Success for Plan Today',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Warm-up (10 min)',
              style: GoogleFonts.roboto(
                color: const Color(0xFF00FFA6),
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Line drills with seated option\n• Elastic band mobility',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Drill 1 (15 min)',
              style: GoogleFonts.roboto(
                color: const Color(0xFF00FFA6),
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Straight punch combos (L/R)\n• Partner pads - pair by strength',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cooldown (5 min)',
              style: GoogleFonts.roboto(
                color: const Color(0xFF00FFA6),
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Breathing + wrist/ankle circles\n• Reflection prompt',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SessionController controller = Get.put(SessionController());
    final themeBg = const Color(0xFF141823);

    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
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
                    'Current Session',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Obx(() {
                return Container(
                  key: const ValueKey('list_state'),
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 299),
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0x1AFFFFFF), Color(0xFA00FFA6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141823),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (controller.currentList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(
                              child: Text(
                                "No Current Sessions Available",
                                style: GoogleFonts.roboto(color: Colors.white),
                              ),
                            ),
                          )
                        else
                          // Make the sessions list scrollable inside the card
                          SizedBox(
                            height: 260,
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: controller.currentList.length,
                              separatorBuilder: (_, __) => const Divider(
                                color: Colors.white24,
                                height: 24,
                              ),
                              itemBuilder: (context, i) {
                                final session = controller.currentList[i];
                                return _smallSessionRow(
                                  date: session.uiDate ?? session.date ?? '-',
                                  time: () {
                                    final d = session.duration;
                                    if (d != null &&
                                        d.isNotEmpty &&
                                        d != 'null') {
                                      final numMatch = RegExp(
                                        r"(\d+)",
                                      ).firstMatch(d);
                                      if (numMatch != null) {
                                        final n =
                                            int.tryParse(numMatch.group(0)!) ??
                                            0;
                                        return n == 1 ? '$n Min' : '$n Mins';
                                      }
                                      if (d.toLowerCase().contains('min')) {
                                        return d.replaceAllMapped(
                                          RegExp(
                                            r'mins?',
                                            caseSensitive: false,
                                          ),
                                          (m) {
                                            final g =
                                                m.group(0)?.toLowerCase() ?? '';
                                            return g == 'mins' ? 'Mins' : 'Min';
                                          },
                                        );
                                      }
                                      return '$d Mins';
                                    }
                                    return '-';
                                  }(),
                                  venue: session.venue ?? '-',
                                  trainees: '${session.totalTrainees} Trainees',
                                  trainer: session.trainer ?? '-',
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 18),

              _planCard(),

              const SizedBox(height: 22),

              Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFFFFFFFF), Color(0xFF666E6D)],
                      stops: [0.195, 0.8461],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: SizedBox(
                    width: 220,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const SizedBox(
                        width: 20,
                        height: 20,
                        child: Icon(
                          Icons.smart_toy_outlined,
                          size: 20,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      label: Text(
                        'ASK COACHBOT',
                        style: GoogleFonts.roboto(
                          color: const Color(0xFF062A20),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FFA6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                      ),
                    ),
                  ),
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
