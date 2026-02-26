import 'package:mapped_frontend/session/session_reflect.dart';
import 'package:mapped_frontend/session/session_reflect_preview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'session_controller.dart';

class SessionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> sessionData;

  const SessionDetailsScreen({Key? key, required this.sessionData})
    : super(key: key);

  final Color bgColor = const Color(0xFF141823);
  final Color cardColor = const Color(0xFF1C1C1E);
  final Color accentGreen = const Color(0xFF00C875);
  final Color accentCyan = const Color(0xFF00C2FF);
  final Color accentRed = const Color(0xFFFF4D4D);
  final Color textColor = Colors.white;
  final Color secondaryTextColor = const Color(0xFFB8A0B3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: textColor, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'home_nav_session'.tr() +
              ' ' +
              'home_subtitle_participant_info'.tr().split(' ').last,
          style: GoogleFonts.poppins(color: textColor, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Overview Card ---
            _buildCard(
              title:
                  'home_subtitle_participant_info'.tr().split(' ').first +
                  ': ${sessionData['level'] ?? 'Intermediate'}',
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildOverviewItem(
                        'trainee_lbl_dob'.tr().split(' ').first,
                        _formatSessionDate(sessionData),
                      ),
                      const SizedBox(width: 16),
                      _buildOverviewItem(
                        'session_lbl_venue'.tr(),
                        '${sessionData['venue'] ?? 'lbl_na'.tr()}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildOverviewItem(
                        'session_lbl_total_duration'.tr(),
                        '${sessionData['duration'] ?? 'lbl_na'.tr()} ' +
                            'duration'.tr(),
                      ),
                      const SizedBox(width: 16),
                      _buildOverviewItem(
                        'participants'.tr(),
                        '${sessionData['totalTrainees'] ?? sessionData['pax'] ?? '0'} Pax (Age ${sessionData['ageRange'] ?? 'lbl_na'.tr()})',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildOverviewItem(
                        'home_nav_session'.tr() +
                            ' ' +
                            'session_lbl_number'.tr(),
                        () {
                          final sn = (sessionData['sessionNo'] ?? '1')
                              .toString();
                          if (sn.contains('/')) {
                            return sn.replaceAll('/', ' of ');
                          }
                          return sn;
                        }(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildCard(
              title: 'session_title_prereq_safety'.tr(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'session_header_safety_notes'.tr().toUpperCase(),
                    accentGreen,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${sessionData['riskAssessment']?.toString().isNotEmpty == true ? sessionData['riskAssessment'] : 'session_msg_no_safety_notes'.tr()}',
                    style: GoogleFonts.poppins(color: textColor, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              'session_header_resources'.tr().toUpperCase(),
                              accentGreen,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${sessionData['resources']?.toString().isNotEmpty == true ? sessionData['resources'] : 'none'.tr()}',
                              style: GoogleFonts.poppins(
                                color: textColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              'session_header_support_staff'.tr().toUpperCase(),
                              accentGreen,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${sessionData['othersInvolved']?.toString().isNotEmpty == true ? sessionData['othersInvolved'] : 'none'.tr()}',
                              style: GoogleFonts.poppins(
                                color: textColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Session Agenda Card ---
            _buildCard(
              title:
                  'home_nav_session'.tr() + ' ' + 'session_title_agenda'.tr(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'session_header_primary_goal'.tr().toUpperCase(),
                    secondaryTextColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${sessionData['goals'] ?? 'lbl_na'.tr()}',
                    style: GoogleFonts.poppins(color: textColor, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // Timeline
                  if (sessionData['warmup'] != null)
                    _buildTimelineItem(
                      duration: '${sessionData['warmup']['time'] ?? '0'} m',
                      title: 'session_lbl_warmup'.tr(),
                      description:
                          '${sessionData['warmup']['desc'] ?? 'lbl_na'.tr()}',
                      dotColor: accentCyan,
                      isFirst: true,
                    ),
                  if (sessionData['activity'] != null)
                    _buildTimelineItem(
                      duration: '${sessionData['activity']['time'] ?? '0'} m',
                      title: 'session_lbl_main_activity'.tr(),
                      description:
                          '${sessionData['activity']['desc'] ?? 'lbl_na'.tr()}',
                      dotColor: accentGreen,
                    ),
                  if (sessionData['cooldown'] != null)
                    _buildTimelineItem(
                      duration: '${sessionData['cooldown']['time'] ?? '0'} m',
                      title: 'session_lbl_cooldown'.tr(),
                      description:
                          '${sessionData['cooldown']['desc'] ?? 'lbl_na'.tr()}',
                      dotColor: accentCyan,
                      isLast: true,
                    ),
                  const SizedBox(height: 24),

                  // Contingency Plan
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          'session_header_contingency_plan'.tr().toUpperCase(),
                          accentRed,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${sessionData['contingencies']?.toString().isNotEmpty == true ? sessionData['contingencies'] : 'session_msg_no_contingency_plan'.tr()}',
                          style: GoogleFonts.poppins(
                            color: textColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Center(
              child: GestureDetector(
                onTap: () async {
                  final controller = Get.put(SessionController());

                  await controller.fetchDashboardData();

                  final id = sessionData['_id'] ?? sessionData['id'];
                  dynamic upToDateSession;
                  if (id != null) {
                    try {
                      final matches = controller.historyList.where((s) {
                        final sid = s.id?.toString() ?? '';
                        return sid == id.toString();
                      });
                      upToDateSession = matches.isNotEmpty
                          ? matches.first
                          : null;
                    } catch (_) {
                      upToDateSession = null;
                    }
                  }

                  Map<String, dynamic> sessionMap;
                  if (upToDateSession != null) {
                    try {
                      sessionMap = upToDateSession.toJson();
                    } catch (_) {
                      sessionMap = Map<String, dynamic>.from(sessionData);
                    }
                  } else {
                    sessionMap = Map<String, dynamic>.from(sessionData);
                  }

                  final reflection = sessionMap['reflection'];
                  final bool hasReflection =
                      reflection != null &&
                      reflection is Map &&
                      reflection.isNotEmpty;

                  if (hasReflection) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SessionReflectionsPreviewScreen(
                          sessionData: sessionMap,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SessionReflectionsScreen(sessionData: sessionMap),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const RadialGradient(
                      center: Alignment(0.0, -1.0),
                      radius: 1.0,
                      colors: [Color(0xFF88D0B7), Color(0xFF00FFA6)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.22),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Text(
                        'session_btn_reflect'.tr(),
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 1.0
                            ..color = const Color(0xFF141823),
                        ),
                      ),
                      Text(
                        'session_btn_reflect'.tr(),
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _formatSessionDate(Map<String, dynamic> data) {
    final dateStr = data['date']?.toString();
    const months = [
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

    String fmt(DateTime dt) => '${dt.day} ${months[dt.month - 1]} ${dt.year}';

    if (dateStr != null) {
      try {
        return fmt(DateTime.parse(dateStr));
      } catch (_) {}

      if (dateStr.contains('/')) {
        try {
          final parts = dateStr.split('/');
          if (parts.length == 3) {
            return fmt(
              DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              ),
            );
          }
        } catch (_) {}
      }
    }

    final uiDate = data['uiDate']?.toString();
    if (uiDate != null && uiDate.contains(',')) {
      try {
        final parts = uiDate.split(',');
        if (parts.length >= 3) {
          final monthDay = parts[1].trim().split(' ');
          if (monthDay.length >= 2) {
            final mon = monthDay[0];
            final day = monthDay[1];
            final year = parts[2].trim();

            final monCap = mon.isNotEmpty
                ? '${mon[0].toUpperCase()}${mon.substring(1).toLowerCase()}'
                : mon;

            return '$day $monCap $year';
          }
        }
      } catch (_) {}
    }

    return uiDate ?? dateStr ?? 'lbl_na'.tr();
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: secondaryTextColor, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTimelineItem({
    required String duration,
    required String title,
    required String description,
    required Color dotColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              duration,
              style: GoogleFonts.poppins(
                color: secondaryTextColor,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: const Color(0xFF2C2C2E)),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      color: secondaryTextColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
