import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'session_controller.dart';
import 'session_details.dart';
import 'session_reflect.dart';
import 'session_model.dart';
import 'session_reflect_preview.dart';
import 'package:mapped_frontend/controller/user_controller';

class SessionHistoryScreen extends StatelessWidget {
  const SessionHistoryScreen({super.key});

  Widget _historyRow({
    required String date,
    required String time,
    required String venue,
    required String trainees,
    required String trainer,
    required SessionModel sessionData,
    required SessionController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0, bottom: 0.0),
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
                  time,
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
                  'session_history_coach_prefix'.tr(
                    namedArgs: {'name': trainer},
                  ),
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          Transform.translate(
            offset: const Offset(0, -12),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.to(
                        () => SessionDetailsScreen(
                          sessionData: sessionData.toJson(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 0,
                      ),
                      minimumSize: const Size(0, 24),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'session_history_btn_view'.tr(),
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

                  TextButton(
                    onPressed: () async {
                      await controller.fetchDashboardData();

                      final upToDateSession = controller.historyList.firstWhere(
                        (s) => s.id == sessionData.id,
                        orElse: () => sessionData,
                      );

                      final sessionMap = upToDateSession.toJson();
                      final reflection = sessionMap['reflection'];

                      bool hasReflection =
                          reflection != null &&
                          reflection is Map &&
                          reflection.isNotEmpty;

                      if (hasReflection) {
                        Get.to(
                          () => SessionReflectionsPreviewScreen(
                            sessionData: sessionMap,
                          ),
                        );
                      } else {
                        Get.to(
                          () =>
                              SessionReflectionsScreen(sessionData: sessionMap),
                        );
                      }
                    },

                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 0,
                      ),
                      minimumSize: const Size(0, 24),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'session_history_btn_reflect'.tr(),
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
    final UserController userController = Get.find<UserController>();
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
          'session_history_title'.tr(),
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
                    'session_history_header_badge'.tr(),
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
                          'session_history_lbl_history'.tr(),
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Obx(() {
                            if (controller.historyList.isEmpty) {
                              return Center(
                                child: Text(
                                  "session_history_empty".tr(),
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
                                    i < controller.historyList.length;
                                    i++
                                  ) ...[
                                    _historyRow(
                                      date:
                                          controller.historyList[i].uiDate ??
                                          '-',
                                      time: () {
                                        final val = controller.historyList[i];
                                        final d = val.duration;
                                        if (d != null &&
                                            d.isNotEmpty &&
                                            d != 'null') {
                                          return d.toLowerCase().contains('min')
                                              ? d
                                              : 'session_history_unit_min'.tr(
                                                  namedArgs: {'count': d},
                                                );
                                        }
                                        return '-';
                                      }(),
                                      controller: controller,
                                      venue:
                                          controller.historyList[i].venue ??
                                          '-',
                                      trainees: 'session_history_trainees_count'.tr(
                                        namedArgs: {
                                          'count':
                                              '${controller.historyList[i].totalTrainees}',
                                        },
                                      ),
                                      trainer: userController.userName,
                                      sessionData: controller.historyList[i],
                                    ),
                                    if (i < controller.historyList.length - 1)
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

              const SizedBox(height: 40),

              // [KEEP BUTTON CODE]
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
                        'btn_coachbot'.tr(),
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
            ],
          ),
        ),
      ),
    );
  }
}
