import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart'; // Needed for Obx and Get.find
import 'dart:ui' as ui;
import 'dart:io';
import '../controller/controller/trainee_controller.dart';
import '../controller/controller/progress_controller.dart'; // Import ProgressController
import 'edit_trainee_screen.dart';
import 'trainee_progress.dart';

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

  // --- NEW: Helper to calculate Next Belt ---
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
      default:
        return 'White';
    }
  }

  // Formats date to '23 January 2015'
  String _formatDob(String? dateString) {
    if (dateString == null || dateString.isEmpty || dateString == 'N/A') {
      return 'N/A';
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final compact = screenWidth < 420.0;
    final double avatarSize = compact ? 60.0 : 72.0;
    final double circleOuter = compact ? 56.0 : 62.0;
    final double circleInner = compact ? 44.0 : 50.0;

    // 1. Find TraineeController
    final TraineeController controller = Get.find<TraineeController>();

    // 2. Initialize ProgressController to fetch backend data
    final ProgressController progressController = Get.put(ProgressController());

    final String traineeId = trainee['id'];

    // 3. Trigger Fetch for this Trainee (Get Average of all forms)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      progressController.fetchOverallStats(traineeId);
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
          'Dashboard',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      "Belt Progress",
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final currentTrainee = controller.traineeList.firstWhere(
            (t) => t['id'] == traineeId,
            orElse: () => trainee,
          );

          final String name = currentTrainee['name'] ?? 'Unknown';
          final String belt = currentTrainee['belt'] ?? 'White';
          final String address = currentTrainee['address'] ?? 'No Address';
          final String dob = _formatDob(currentTrainee['dateOfBirth']);
          final String phone = currentTrainee['phone'] ?? 'N/A';
          final String email = currentTrainee['email'] ?? 'N/A';
          final String? imgData = currentTrainee['image'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Get.to(() => EditTraineeScreen(trainee: currentTrainee));
                    // Get.to(
                    //   () => TraineeProgressScreen(
                    //     traineeId: currentTrainee['id'],
                    //     traineeName: currentTrainee['name'] ?? 'Trainee',
                    //   ),
                    // );
                  },
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
                              // DYNAMIC PROGRESS CIRCLE
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
                                    SizedBox(
                                      width: circleInner,
                                      height: circleInner,
                                      child: RotatedBox(
                                        quarterTurns: 1,
                                        child: Obx(
                                          // BIND TO OVERALL AVERAGE
                                          () => CircularProgressIndicator(
                                            value: progressController
                                                .overallAverage
                                                .value,
                                            strokeWidth: 6,
                                            valueColor:
                                                const AlwaysStoppedAnimation(
                                                  Color(0xFF00FFA6),
                                                ),
                                            backgroundColor:
                                                Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Obx(
                                      // BIND TO OVERALL AVERAGE
                                      () => Text(
                                        '${(progressController.overallAverage.value * 100).round()}%',
                                        style: GoogleFonts.roboto(
                                          color: const Color(0xFF00FFA6),
                                          fontWeight: FontWeight.w700,
                                          fontSize: compact ? 11 : 12,
                                        ),
                                      ),
                                    ),
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
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x1A000000),
                                            offset: Offset(0, 4),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '$belt Belt',
                                        style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
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
                                Text(
                                  'Certification Progress',
                                  style: GoogleFonts.roboto(
                                    color: const Color(0xFF00FFB9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                                              text: 'Next Belt: ',
                                              style: GoogleFonts.roboto(
                                                color: Colors.grey.shade300,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  '${_getNextBelt(belt)} Belt',
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
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.fitness_center_outlined,
                                      color: Colors.grey.shade300,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Circular Progress: ',
                                              style: GoogleFonts.roboto(
                                                color: Colors.grey.shade300,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            TextSpan(
                                              // BIND TO OVERALL AVERAGE
                                              text:
                                                  '${(progressController.overallAverage.value * 100).round()}%',
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Milestones and Details remain unchanged...
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
                          'Milestones',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _CheckItem(text: 'Blocks and Strikes Good'),
                        const SizedBox(height: 8),
                        const _CheckItem(text: 'Master Form 1'),
                        const SizedBox(height: 8),
                        const _CheckItem(text: 'Improve Side Kick'),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            // --- UPDATED NAVIGATION LOGIC ---
                            onTap: () async {
                              // 1. Await the navigation to finish
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => TraineeProgressScreen(
                                    traineeId: currentTrainee['id'],
                                    traineeName:
                                        currentTrainee['name'] ?? 'Trainee',
                                    currentBelt:
                                        currentTrainee['belt'] ?? 'White',
                                  ),
                                ),
                              );

                              // 2. Refresh the stats immediately upon return
                              progressController.fetchOverallStats(traineeId);
                            },
                            // --------------------------------
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x33FFFFFF),
                                    Color(0x33604E5C),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.military_tech,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Progress',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                          'Student Details',
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
                const SizedBox(height: 32),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ... _CheckItem and _DetailRow classes remain exactly the same ...
class _CheckItem extends StatelessWidget {
  final String text;
  const _CheckItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check, color: Color(0xFF00FFB9), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
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
            text,
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
