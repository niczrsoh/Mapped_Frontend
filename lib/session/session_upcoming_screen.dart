import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'session_controller.dart';
import 'session_planner.dart';
import 'session_model.dart';
import 'package:mapped_frontend/controller/user_controller';

class UpcomingSessionsScreen extends StatelessWidget {
  const UpcomingSessionsScreen({super.key});

  Widget _upcomingRow({required SessionModel sessionData}) {
    final userController = Get.find<UserController>();
    
    final date = sessionData.uiDate ?? sessionData.date ?? '-';
    final timeStr = () {
      final d = sessionData.duration;
      if (d != null && d.isNotEmpty && d != 'null') {
        return d.toLowerCase().contains('min') ? d : '$d min';
      }
      return '-';
    }();

    final venue = sessionData.venue ?? '-';
    final trainees = '${sessionData.totalTrainees ?? 0} Trainees';
    final trainer = userController.userName;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  date,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  timeStr,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
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
                Icons.location_on_outlined,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  venue,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.group_outlined, size: 14, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trainees,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.person_outline, size: 14, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'coachbot_ctrl_fallback_name'.tr() + ' : $trainer',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {
                Get.to(
                  () => SessionPlannerScreen(initialData: sessionData.toJson()),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                minimumSize: const Size(0, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'session_btn_edit_session'.tr(),
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
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
          'home_nav_session'.tr() +
              ' ' +
              'admin_manage_title_dashboard'.tr().split(' ').last,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
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
                    'session_title_upcoming_sessions'.tr(),
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: Container(
                  width: double.infinity,
                  height: 486,
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
                          'Upcoming',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Obx(() {
                            if (controller.upcomingList.isEmpty) {
                              return Center(
                                child: Text(
                                  'session_empty_upcoming_sessions'.tr(),
                                  style: GoogleFonts.roboto(
                                    color: Colors.white54,
                                  ),
                                ),
                              );
                            }
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (
                                    var i = 0;
                                    i < controller.upcomingList.length;
                                    i++
                                  ) ...[
                                    _upcomingRow(
                                      sessionData: controller.upcomingList[i],
                                    ),
                                    if (i < controller.upcomingList.length - 1)
                                      const Divider(color: Colors.white),
                                  ],
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

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
                        'session_btn_ask_coachbot'.tr(),
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
