import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'trainee_controller.dart';
import 'progress_controller.dart';
import 'edit_trainee_screen.dart';

class TraineeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> trainee;

  const TraineeDetailScreen({Key? key, required this.trainee})
    : super(key: key);

  static const double borderThickness = 1.5;
  static const LinearGradient customGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x1AFFFFFF), Color(0xFA00FFA6)],
  );

  String _getNextBelt(String currentBelt) {
    switch (currentBelt) {
      case 'White':
        return 'Yellow';
      case 'Yellow':
        return 'Green';
      case 'Green':
        return 'Blue';
      case 'Blue':
        return 'Brown';
      case 'Brown':
        return 'Black';
      case 'Black':
        return 'Black';
      default:
        return 'White';
    }
  }

  String _formatDob(String? dateString) {
    if (dateString == null ||
        dateString.isEmpty ||
        dateString == 'lbl_na'.tr()) {
      return 'lbl_na'.tr();
    }
    try {
      final DateTime date = DateTime.parse(dateString).toLocal();
      const List<String> months = [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${date.day} ${months[date.month]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  ImageProvider _getAvatarImage(String? imgData) {
    if (imgData != null && imgData.isNotEmpty) {
      if (imgData.startsWith('http')) {
        return NetworkImage(imgData);
      } else if (imgData.startsWith('assets/')) {
        return AssetImage(imgData);
      } else {
        try {
          final file = File(imgData);
          if (file.existsSync()) {
            return FileImage(file);
          }
        } catch (e) {
          // Fallthrough
        }
      }
    }
    return const AssetImage('assets/images/placeholder_avatar.png');
  }

  Widget _formatConditions(dynamic conditions) {
    if (conditions == null) {
      return _DetailRow(text: 'trainee_detail_no_medical_concerns'.tr());
    }

    if (conditions is List) {
      if (conditions.isEmpty) {
        return _DetailRow(text: 'trainee_detail_no_medical_concerns'.tr());
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: conditions.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _DetailRow(text: item.toString().trim()),
          );
        }).toList(),
      );
    }

    // Handle String data
    String text = conditions.toString().trim();
    if (text.isEmpty || text == 'null') {
      return _DetailRow(text: 'trainee_detail_no_medical_concerns'.tr());
    }

    // Detect and format bullet points with hyphens
    if (text.contains('-')) {
      final items = text
          .split('-')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (items.isEmpty) {
        return _DetailRow(text: 'trainee_detail_no_medical_concerns'.tr());
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _DetailRow(text: item),
          );
        }).toList(),
      );
    }

    // Plain text without special formatting
    return _DetailRow(text: text);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final compact = screenWidth < 420.0;
    final double avatarSize = compact ? 60.0 : 72.0;
    final double circleOuter = compact ? 56.0 : 62.0;
    final double circleInner = compact ? 44.0 : 50.0;
    final TraineeController controller = Get.find<TraineeController>();
    final ProgressController progressController = Get.put(ProgressController());
    final String traineeId = trainee['id'];
    final String belt = trainee['belt'] ?? 'White';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      progressController.fetchOverallStats(traineeId, belt);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF141823),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'trainee_detail_belt_progress'.tr(),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(() {
          // ignore: unused_local_variable
          final currentTrainee = controller.traineeList.firstWhere(
            (t) => t['id'] == traineeId,
            orElse: () => trainee,
          );

          final String name = currentTrainee['name'] ?? 'unknown'.tr();
          final String belt = currentTrainee['belt'] ?? 'White';
          final String address =
              currentTrainee['address'] ?? 'trainee_detail_no_address'.tr();
          final String dob = _formatDob(currentTrainee['dateOfBirth']);
          final String phone = currentTrainee['phone'] ?? 'lbl_na'.tr();
          final String email = currentTrainee['email'] ?? 'lbl_na'.tr();

          String? imgData = currentTrainee['image'];
          if (imgData == null || imgData.isEmpty) {
            imgData = currentTrainee['imagePath'];
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: null,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: customGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(borderThickness),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF141823),
                        borderRadius: BorderRadius.circular(
                          20 - borderThickness,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 20,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: avatarSize,
                                height: avatarSize,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.grey.shade800,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image(
                                    image: _getAvatarImage(imgData),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: circleOuter,
                                height: circleOuter,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: circleOuter,
                                      height: circleOuter,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF0f1720),
                                      ),
                                    ),
                          //           SizedBox(
                          //             width: circleInner,
                          //             height: circleInner,
                          //             child: RotatedBox(
                          //               quarterTurns: 1,
                          //               child: Obx(() {
                          //                 final currentTrainee = controller
                          //                     .traineeList
                          //                     .firstWhere(
                          //                       (t) => t['id'] == traineeId,
                          //                       orElse: () => null,
                          //                     );

                          //                 return CircularProgressIndicator(
                          //                   value: progressController
                          //                       .overallAverage
                          //                       .value,
                          //                   strokeWidth: 6,
                          //                   valueColor:
                          //                       const AlwaysStoppedAnimation(
                          //                         Color(0xFF00FFA6),
                          //                       ),
                          //                   backgroundColor:
                          //                       Colors.grey.shade800,
                          //                 );
                          //               }),
                          //             ),
                          //           ),
                          //           Obx(
                          //             // BIND TO OVERALL AVERAGE
                          //             () => Text(
                          //               '${(progressController.overallAverage.value * 100).round()}%',
                          //               style: GoogleFonts.roboto(
                          //                 color: const Color(0xFF00FFA6),
                          //                 fontWeight: FontWeight.w700,
                          //                 fontSize: compact ? 11 : 12,
                          //               ),
                          //             ),
                          //           ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: BackdropFilter(
                                        filter: ui.ImageFilter.blur(
                                          sigmaX: 30,
                                          sigmaY: 30,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0x8A72777A),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0x1A000000),
                                                offset: Offset(0, 4),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            '$belt${'trainee_progress_belt_suffix'.tr()}',
                                            style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            final String oldBelt =
                                                currentTrainee['belt'] ??
                                                'White';
                                            await Get.to(
                                              () => EditTraineeScreen(
                                                trainee: currentTrainee,
                                              ),
                                            );
                                            // Refresh using the LATEST belt from the controller
                                            final updatedTrainee = controller
                                                .traineeList
                                                .firstWhere(
                                                  (t) => t['id'] == traineeId,
                                                  orElse: () => trainee,
                                                );

                                            final String newBelt =
                                                updatedTrainee['belt'] ?? belt;

                                            // If belt changed, reset stats to 0% immediately
                                            if (oldBelt != newBelt) {
                                              print(
                                                "Belt updated from $oldBelt to $newBelt. Resetting stats.",
                                              );
                                              progressController
                                                      .overallAverage
                                                      .value =
                                                  0.0;
                                            }

                                            progressController
                                                .fetchOverallStats(
                                                  traineeId,
                                                  newBelt,
                                                );
                                          },
                                          child: const Icon(
                                            Icons.edit_outlined,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        InkWell(
                                          onTap: () async {
                                            final String oldBelt =
                                                currentTrainee['belt'] ??
                                                'White';
                                            await Get.to(
                                              () => EditTraineeScreen(
                                                trainee: currentTrainee,
                                                showDeleteDialog: true,
                                              ),
                                            );
                                            // Refresh using the LATEST belt from the controller
                                            final updatedTrainee = controller
                                                .traineeList
                                                .firstWhere(
                                                  (t) => t['id'] == traineeId,
                                                  orElse: () => trainee,
                                                );

                                            final String newBelt =
                                                updatedTrainee['belt'] ?? belt;

                                            if (oldBelt != newBelt) {
                                              progressController
                                                      .overallAverage
                                                      .value =
                                                  0.0;
                                            }

                                            progressController
                                                .fetchOverallStats(
                                                  traineeId,
                                                  newBelt,
                                                );
                                          },
                                          child: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Text(
                                //   'trainee_detail_certification_progress'.tr(),
                                //   style: GoogleFonts.roboto(
                                //     color: const Color(0xFF00FFB9),
                                //     fontSize: 14,
                                //     fontWeight: FontWeight.w600,
                                //   ),
                                // ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.directions_run,
                                      color: Colors.grey.shade300,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'trainee_progress_next_belt'
                                                  .tr(),
                                              style: GoogleFonts.roboto(
                                                color: Colors.grey.shade300,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  '${_getNextBelt(belt)}${'trainee_progress_belt_suffix'.tr()}',
                                              style: GoogleFonts.roboto(
                                                color: const Color(0xFF00FFA6),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // const SizedBox(height: 6),
                                // Row(
                                //   children: [
                                //     Icon(
                                //       Icons.fitness_center_outlined,
                                //       color: Colors.grey.shade300,
                                //       size: 16,
                                //     ),
                                //     const SizedBox(width: 8),
                                //     Expanded(
                                //       child: RichText(
                                //         text: TextSpan(
                                //           children: [
                                //             TextSpan(
                                //               text: 'Circular Progress: ',
                                //               style: GoogleFonts.roboto(
                                //                 color: Colors.grey.shade300,
                                //                 fontSize: 12,
                                //                 fontWeight: FontWeight.w400,
                                //               ),
                                //             ),
                                //             TextSpan(
                                //               text:
                                //                   '${(progressController.overallAverage.value * 100).round()}%',
                                //               style: GoogleFonts.roboto(
                                //                 color: const Color(0xFF00FFA6),
                                //                 fontSize: 12,
                                //                 fontWeight: FontWeight.w400,
                                //               ),
                                //             ),
                                //           ],
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: customGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(borderThickness),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF141823),
                      borderRadius: BorderRadius.circular(20 - borderThickness),
                    ),
                    padding: EdgeInsets.all(16 - borderThickness),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'trainee_detail_participant_details'.tr(),
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(text: name),
                        const SizedBox(height: 8),
                        _DetailRow(text: address),
                        const SizedBox(height: 8),
                        _DetailRow(text: dob),
                        const SizedBox(height: 8),
                        _DetailRow(text: phone),
                        const SizedBox(height: 8),
                        _DetailRow(text: email),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: customGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(borderThickness),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF141823),
                      borderRadius: BorderRadius.circular(20 - borderThickness),
                    ),
                    padding: EdgeInsets.all(16 - borderThickness),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'trainee_title_guardian'.tr(),
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          text:
                              currentTrainee['guardianName'] ??
                              'trainee_detail_no_guardian_name'.tr(),
                        ),
                        const SizedBox(height: 8),
                        _DetailRow(
                          text:
                              currentTrainee['guardianAddress'] ??
                              'trainee_detail_no_guardian_address'.tr(),
                        ),
                        const SizedBox(height: 8),
                        _DetailRow(
                          text:
                              currentTrainee['guardianContact'] ??
                              'trainee_detail_no_guardian_contact'.tr(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: customGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(borderThickness),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF141823),
                      borderRadius: BorderRadius.circular(20 - borderThickness),
                    ),
                    padding: EdgeInsets.all(16 - borderThickness),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'trainee_title_goals_long'.tr(),
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentTrainee['goals']?.toString() ??
                              'trainee_detail_no_goals'.tr(),
                          style: GoogleFonts.roboto(
                            color: Colors.grey.shade300,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: customGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(borderThickness),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF141823),
                      borderRadius: BorderRadius.circular(20 - borderThickness),
                    ),
                    padding: EdgeInsets.all(16 - borderThickness),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'trainee_title_medical'.tr(),
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _formatConditions(currentTrainee['conditions']),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: customGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(borderThickness),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF141823),
                      borderRadius: BorderRadius.circular(20 - borderThickness),
                    ),
                    padding: EdgeInsets.all(16 - borderThickness),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'trainee_title_competency'.tr(),
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentTrainee['competency']?.toString() ??
                              'trainee_detail_no_competency'.tr(),
                          style: GoogleFonts.roboto(
                            color: Colors.grey.shade300,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String text;
  const _DetailRow({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check, color: Color(0xFF00FFB9), size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text.tr(),
            style: GoogleFonts.roboto(
              color: Colors.grey.shade300,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
