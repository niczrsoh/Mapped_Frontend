import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:mapped_frontend/TProgress/belt_progress_modelV2.dart';
import 'package:mapped_frontend/helper/colorConstant.dart';
import 'package:mapped_frontend/controller/user_controller';
import '../../controller/controller/trainer_controller.dart';
import 'belt_progress_ring_controller.dart';
import 'package:mapped_frontend/TProgress/data/belt_definitions.dart';
import 'package:mapped_frontend/TProgress/data/belt_requirements.dart';

class BeltProgressScreen extends StatefulWidget {
  final String beltName;
  final Color beltColor;

  const BeltProgressScreen({
    super.key,
    required this.beltName,
    required this.beltColor,
  });

  @override
  State<BeltProgressScreen> createState() => _BeltProgressScreenState();
}

class _BeltProgressScreenState extends State<BeltProgressScreen>
    with WidgetsBindingObserver {
  final TrainerController controller = Get.put(TrainerController());
  late BeltProgressRingController ringController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    ringController = Get.isRegistered<BeltProgressRingController>()
        ? Get.find<BeltProgressRingController>()
        : Get.put(BeltProgressRingController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    ringController.isLoading.value = true;
    try {
      if (Get.isRegistered<UserController>()) {
        final userCtrl = Get.find<UserController>();
        if (userCtrl.userId.value.isNotEmpty) {
          controller.currentUserId.value = userCtrl.userId.value;
        }
      }

      await controller.updateActiveDays();
      await ringController.fetchBeltProgress();
    } catch (e) {
      print("❌ Error during refresh: $e");
    } finally {
      ringController.isLoading.value = false;
    }
  }

  Map<String, dynamic> _calculateBeltStats(
    BeltRequirement req,
    BeltProgressModelV2? beltData,
  ) {
    if (widget.beltName.contains('Black')) {
      BeltProgressModelV2? brownData;

      for (var b in ringController.detailedBeltData) {
        if (b.beltColor == 'Brown' || b.beltColor == 'R') {
          brownData = b;
          break;
        }
      }

      if (brownData != null && brownData.isCompleted) {
        return {'sessions': 0, 'days': 0, 'progress': 1.0, 'resources': 0};
      } else {
        return {'sessions': 0, 'days': 0, 'progress': 0.0, 'resources': 0};
      }
    }

    if (beltData == null) {
      return {'sessions': 0, 'days': 0, 'progress': 0.0, 'resources': 0};
    }

    if (beltData.isCompleted) {
      int targetSess =
          req.tasks
              .firstWhereOrNull((t) => t.type == RequirementType.session)
              ?.target ??
          0;
      int targetDays =
          req.tasks
              .firstWhereOrNull((t) => t.type == RequirementType.activeDay)
              ?.target ??
          0;
      int targetRes =
          req.tasks
              .firstWhereOrNull((t) => t.type == RequirementType.resource)
              ?.target ??
          0;

      return {
        'sessions': beltData.planSessionCount > 0
            ? beltData.planSessionCount
            : targetSess,
        'days': beltData.progress.activeDayCount > 0
            ? beltData.progress.activeDayCount
            : targetDays,
        'progress': 1.0,
        'resources': beltData.progress.openResourceCount > 0
            ? beltData.progress.openResourceCount
            : targetRes,
      };
    }

    double currentProgressSum = 0;
    double targetProgressSum = 0;

    int currentSess = beltData.planSessionCount;
    int currentDays = beltData.progress.activeDayCount;
    int openResources = beltData.progress.openResourceCount;
    int currentPosts = beltData.progress.postCount;
    int currentTips = beltData.progress.shareTipCount;
    int currentRecs = beltData.progress.recommendationCount;
    int currentReflect = beltData.progress.reflectionCount;

    for (var task in req.tasks) {
      targetProgressSum += task.target;
      int val = 0;
      switch (task.type) {
        case RequirementType.session:
          val = currentSess.clamp(0, task.target);
          break;
        case RequirementType.activeDay:
          val = currentDays.clamp(0, task.target);
          break;
        case RequirementType.resource:
          val = openResources.clamp(0, task.target);
          break;
        case RequirementType.forumPost:
          val = currentPosts.clamp(0, task.target);
          break;
        case RequirementType.recommendation:
          val = currentRecs.clamp(0, task.target);
          break;
        case RequirementType.reflection:
          val = currentReflect.clamp(0, task.target);
          break;
        case RequirementType.shareTip:
          val = currentTips.clamp(0, task.target);
          break;
        case RequirementType.mastery:
          val = 1;
          break;
      }
      currentProgressSum += val;
    }

    double progressPct = targetProgressSum > 0
        ? (currentProgressSum / targetProgressSum).clamp(0.0, 1.0)
        : 0.0;

    return {
      'sessions': currentSess,
      'days': currentDays,
      'progress': progressPct,
      'resources': openResources,
    };
  }

  String _getBeltAssetPath(String beltName) {
    return BeltDefinitions.getByName(beltName).assetPath;
  }


  @override
  Widget build(BuildContext context) {
    final themeBg = ColorConstant.themeBg;
    final cardBgColor = const Color(0xFF151725);

    final currentBeltDef = BeltDefinitions.getByName(widget.beltName);
    final String nextBeltName = (currentBeltDef.nextBeltId != null)
        ? BeltDefinitions.getByCode(currentBeltDef.nextBeltId!).name
        : 'home_lbl_mastery'.tr();
    final Color nextBeltColor = (currentBeltDef.nextBeltId != null)
        ? BeltDefinitions.getByCode(currentBeltDef.nextBeltId!).color
        : const Color(0xFF1A1A1A);

    final double barWidth = 240;
    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'belt_dash_title'.tr(),
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: Obx(() {
        if (ringController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        BeltProgressModelV2? currentBeltData;
        try {
          final beltDef = BeltDefinitions.getByName(widget.beltName);
          for (var b in ringController.detailedBeltData) {
            if (b.beltColor == beltDef.id || b.beltColor == widget.beltName) {
              currentBeltData = b;
              break;
            }
          }
        } catch (e) {
          print("Error finding current belt data: $e");
        }

        final beltReq = BeltRequirementsData.getFor(widget.beltName);

        var stats = _calculateBeltStats(beltReq, currentBeltData);
        double liveProgress = stats['progress'];

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: widget.beltColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: 220,
                        height: 180,
                        child: Image.asset(
                          _getBeltAssetPath(widget.beltName),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              color: widget.beltColor,
                              size: 100,
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Progress Bar
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: barWidth,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                FractionallySizedBox(
                                  widthFactor: liveProgress.clamp(0.0, 1.0),
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          widget.beltColor.withOpacity(1.0),
                                          widget.beltColor.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${(liveProgress * 100).round()}%',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    Container(
                      width: double.infinity,
                      height: liveProgress >= 1.0 ? 400 : null,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (liveProgress >= 1.0)
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.white,
                                              widget.beltColor,
                                              Colors.black,
                                            ],
                                            center: const Alignment(-0.3, -0.3),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        widget.beltName.tr(),
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  Text(
                                    'belt_prog_congrats_title'.tr(),
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'belt_prog_congrats_msg'.tr(),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else ...[
                            if (!widget.beltName.contains('Black')) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildBeltHeaderItem(
                                    widget.beltName,
                                    widget.beltColor,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.white54,
                                    ),
                                  ),
                                  _buildBeltHeaderItem(
                                    nextBeltName,
                                    nextBeltColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Column Titles
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'belt_prog_col_requirement'.tr(),
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'belt_prog_col_progress'.tr(),
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: beltReq.tasks.length,
                                itemBuilder: (context, index) {
                                  final task = beltReq.tasks[index];
                                  int currentValue = 0;

                                  if (currentBeltData != null) {
                                    switch (task.type) {
                                      case RequirementType.session:
                                        currentValue =
                                            currentBeltData.planSessionCount;
                                        break;
                                      case RequirementType.activeDay:
                                        currentValue = currentBeltData
                                            .progress
                                            .activeDayCount;
                                        break;
                                      case RequirementType.resource:
                                        currentValue = currentBeltData
                                            .progress
                                            .openResourceCount;
                                        break;
                                      case RequirementType.forumPost:
                                        currentValue =
                                            currentBeltData.progress.postCount;
                                        break;
                                      case RequirementType.shareTip:
                                        currentValue = currentBeltData
                                            .progress
                                            .shareTipCount;
                                        break;
                                      case RequirementType.recommendation:
                                        currentValue = currentBeltData
                                            .progress
                                            .recommendationCount;
                                        break;
                                      case RequirementType.reflection:
                                        currentValue = currentBeltData
                                            .progress
                                            .reflectionCount;
                                        break;

                                      case RequirementType.mastery:
                                        currentValue = 1;
                                        break;
                                    }
                                  }

                                  Color displayColor = widget.beltColor;
                                  String progressText =
                                      "$currentValue / ${task.target}";

                                  if (widget.beltName.contains('Black') &&
                                      task.target == 0) {
                                    progressText = 'home_lbl_mastery'.tr();
                                  }

                                  return Column(
                                    children: [
                                      _buildRequirementRow(
                                        task.icon,
                                        task.progressLabel.tr(),
                                        progressText,
                                        highlightColor: displayColor,
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Call to Action
                    Center(
                      child: Text(
                        "Need help? Visit our online course to learn more about inclusive practice in martial arts.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.snackbar(
                            'belt_prog_snackbar_info'.tr(),
                            'belt_prog_snackbar_dev_msg'.tr(),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.white24,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(10),
                            borderRadius: 10,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'belt_prog_btn_start'.tr(),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBeltHeaderItem(String name, Color color) {
    return Row(
      children: [
        Image.asset(_getBeltAssetPath(name), height: 24, fit: BoxFit.contain),
        const SizedBox(width: 8),
        Text(
          name.tr(),
          style: GoogleFonts.inter(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementRow(
    IconData icon,
    String title,
    String progress, {
    Color? highlightColor,
  }) {
    final progressColor = highlightColor ?? Colors.white;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          progress,
          style: GoogleFonts.inter(
            color: progressColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
