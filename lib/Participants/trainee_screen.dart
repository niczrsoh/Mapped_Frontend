import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'trainee_controller.dart';
import 'add_trainee.dart';
import 'trainee_detail_screen.dart';
import '../TProgress/data/belt_definitions.dart';
import '../controller/controller/trainer_controller.dart';

class TraineesScreen extends StatefulWidget {
  const TraineesScreen({Key? key}) : super(key: key);

  @override
  State<TraineesScreen> createState() => _TraineesScreenState();
}

class _TraineesScreenState extends State<TraineesScreen> {
  // Store the raw belt code ('all', 'W', 'Y', etc.) — never a translated string
  String selectedFilter = 'all';
  String searchQuery = '';

  final TraineeController traineeController = Get.put(TraineeController());
  final TrainerController trainerController = Get.put(TrainerController());

  static const double borderThickness = 1.5;
  final LinearGradient customGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x1AFFFFFF), Color(0xFA00FFA6)],
  );
  static const Color innerCardBackgroundColor = Color(0x8A72777A);
  static const Color accentColor = Color(0xFF00FFB9);

  @override
  void initState() {
    super.initState();
    traineeController.fetchTrainees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1d2e),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'home'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
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
                    borderRadius: BorderRadius.circular(20 - borderThickness),
                  ),
                  padding: EdgeInsets.all(20 - borderThickness),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'participants'.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Reactive count
                          Obx(
                            () => Text(
                              'trainees_lbl_active_count'.tr(
                                namedArgs: {
                                  'count': traineeController.traineeList.length
                                      .toString(),
                                },
                              ),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddTraineeScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const RadialGradient(
                              center: Alignment(0.0, -1.0),
                              radius: 1.0,
                              colors: [Color(0xFF88D0B7), Color(0xFF00FFA6)],
                              stops: [0.0, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.22),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _outlinedText(
                                '+',
                                GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                strokeWidth: 1.0,
                              ),
                              const SizedBox(width: 6),
                              _outlinedText(
                                'add'.tr(),
                                GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                strokeWidth: 1.0,
                              ),
                            ],
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
                height: 50,
                decoration: BoxDecoration(
                  gradient: customGradient,
                  borderRadius: BorderRadius.circular(30),
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
                    borderRadius: BorderRadius.circular(30 - borderThickness),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'trainees_hint_search'.tr(),
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(right: 20, left: 12),
                        child: Icon(Icons.search, color: accentColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', 'all'.tr()),
                    const SizedBox(width: 12),
                    ...BeltDefinitions.belts.map(
                      (b) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _buildFilterChip(b.id, b.name.tr()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: Obx(() {
                  if (traineeController.loading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: accentColor),
                    );
                  }

                  var displayList = traineeController.traineeList.toList();
                  if (selectedFilter != 'all') {
                    displayList = displayList
                        .where((t) => t['belt'].toString() == selectedFilter)
                        .toList();
                  }

                  if (searchQuery.isNotEmpty) {
                    displayList = displayList.where((t) {
                      final name = (t['name'] ?? '').toString().toLowerCase();
                      return name.contains(searchQuery.toLowerCase());
                    }).toList();
                  }

                  if (displayList.isEmpty) {
                    return Center(
                      child: Text(
                        'trainees_empty_state'.tr(),
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final trainee = displayList[index];
                      return _buildTraineeCard(trainee);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _outlinedText(
    String text,
    TextStyle baseStyle, {
    double strokeWidth = 1.0,
  }) {
    return Stack(
      children: [
        Text(
          text,
          style: baseStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = Colors.black,
          ),
        ),
        Text(text, style: baseStyle.copyWith(color: Colors.white)),
      ],
    );
  }

  Widget _buildFilterChip(String code, String label) {
    final isSelected = selectedFilter == code;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = code;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withOpacity(0.2)
              : innerCardBackgroundColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: borderThickness,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? accentColor : Colors.white,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            height: 1.0,
            letterSpacing: 0.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTraineeCard(Map<String, dynamic> trainee) {
    final String belt = trainee['belt'] ?? 'White';
    String? imgData = trainee['image'];
    if (imgData == null || imgData.isEmpty) {
      imgData = trainee['imagePath'];
    }

    ImageProvider? avatarImage;

    if (imgData != null && imgData.isNotEmpty) {
      if (imgData.startsWith('http')) {
        avatarImage = NetworkImage(imgData);
      } else if (imgData.startsWith('assets/')) {
        avatarImage = AssetImage(imgData);
      } else {
        try {
          final file = File(imgData);
          if (file.existsSync()) {
            avatarImage = FileImage(file);
          } else {
            avatarImage = null;
          }
        } catch (e) {
          avatarImage = null;
        }
      }
    }

    return GestureDetector(
      onTap: () {
        Get.to(() => TraineeDetailScreen(trainee: trainee));
      },

      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
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
            borderRadius: BorderRadius.circular(20 - borderThickness),
          ),
          padding: EdgeInsets.all(16 - borderThickness),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[700],
                backgroundImage: avatarImage,
                child: avatarImage == null
                    ? Icon(Icons.person, color: Colors.grey[400], size: 32)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trainee['name'] ?? 'unknown'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 84,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0x8A72777A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              belt,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'note'.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              () {
                                var conditions = trainee['conditions'];
                                if (conditions == null) return 'none'.tr();

                                if (conditions is List) {
                                  if (conditions.isEmpty) return 'none'.tr();
                                  return conditions.join(", ");
                                }

                                // Handle String data with required formatting
                                String text = conditions.toString().trim();
                                if (text.isEmpty || text == 'null')
                                  return 'none'.tr();

                                // Detect and format bullet points ( -item )
                                if (text.contains('-')) {
                                  final parts = text
                                      .split('-')
                                      .map((e) => e.trim())
                                      .where((e) => e.isNotEmpty)
                                      .toList();

                                  if (parts.isNotEmpty) {
                                    return parts.join(", ");
                                  }
                                }

                                return text;
                              }(),
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
