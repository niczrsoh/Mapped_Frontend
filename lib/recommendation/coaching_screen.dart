import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:mapped_frontend/coachBot/coachBot_chat_screen.dart';
import 'package:mapped_frontend/controller/controller/trainer_controller.dart';
import 'recommendation_controller.dart';
import 'recommendation_details_screen.dart';

class DailyCoachingScreen extends StatelessWidget {
  const DailyCoachingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get both controllers
    final TrainerController trainerController =
        Get.isRegistered<TrainerController>()
        ? Get.find<TrainerController>()
        : Get.put(TrainerController());

    // Initialize RecommendationController
    final RecommendationController recommendationController =
        Get.isRegistered<RecommendationController>()
        ? Get.find<RecommendationController>()
        : Get.put(RecommendationController());

    // Load recommendation on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (recommendationController.currentRecommendation.value == null) {
        recommendationController.loadTodayRecommendation();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1a1d2e),
      body: SafeArea(
        child: Obx(() {
          // Show loading state
          if (recommendationController.isLoading.value ||
              recommendationController.isGenerating.value) {
            return _buildLoadingState();
          }

          // Show error state
          if (recommendationController.errorMessage.value.isNotEmpty &&
              !recommendationController.hasRecommendation) {
            return _buildErrorState(recommendationController);
          }

          // Show main content
          return _buildMainContent(
            context,
            recommendationController,
            trainerController,
          );
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child:
      Column(
      crossAxisAlignment: CrossAxisAlignment.center,  
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5eead4)),
        ),
        const SizedBox(height: 24),
        Text(
          'daily_coaching_loading_main'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'daily_coaching_loading_sub'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    ));
  }

  Widget _buildErrorState(RecommendationController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'daily_coaching_error_title'.tr(),
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.loadTodayRecommendation(),
              icon: const Icon(Icons.refresh),
              label: Text('daily_coaching_error_btn_retry'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5eead4),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    RecommendationController recommendationController,
    TrainerController trainerController,
  ) {
    return RefreshIndicator(
      onRefresh: () => recommendationController.refresh(),
      color: const Color(0xFF5eead4),
      backgroundColor: const Color(0xFF252836),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'home'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  // Refresh button
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF5eead4)),
                    onPressed: () =>
                        recommendationController.forceNewRecommendation(),
                    tooltip: 'daily_coaching_refresh_tooltip'.tr(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title with date
              Center(
                child: Column(
                  children: [
                    Text(
                      'daily_coaching_title'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            recommendationController
                                    .lastGeneratedDate
                                    .value
                                    .isEmpty
                                ? 'today'.tr()
                                : recommendationController
                                      .lastGeneratedDate
                                      .value,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                          if (recommendationController.isCached.value) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5eead4).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'daily_coaching_cached'.tr(),
                                style: TextStyle(
                                  color: Color(0xFF5eead4),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Session Info Cards
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.trending_up,
                        label: 'level'.tr(),
                        value: recommendationController.suggestedLevel,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.timer,
                        label: 'duration'.tr(),
                        value:
                            '${recommendationController.suggestedDuration} min',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Today's Focus Card
              Obx(() => _buildTodayFocusCard(recommendationController)),

              const SizedBox(height: 24),

              // Motivational Message
              Obx(() {
                final message = recommendationController.motivationalMessage;
                if (message.isNotEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF5eead4).withOpacity(0.1),
                          const Color(0xFF5eead4).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF5eead4).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('💪', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            message,
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.to(() => const RecommendationDetailsScreen());
                      },
                      icon: const Icon(Icons.info_outline, size: 20),
                      label: Text('daily_coaching_btn_details'.tr()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5eead4),
                        side: const BorderSide(color: Color(0xFF5eead4)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await trainerController.incrementRecommendationCount();
                        // Navigate to CoachBot or show dialog
                        _showCoachBotDialog(context);
                      },
                      icon: const Icon(Icons.smart_toy, size: 20),
                      label: Text('daily_coaching_btn_coachbot'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5eead4),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Use This Plan Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _useRecommendationForSession(
                      context,
                      recommendationController,
                    );
                  },
                  icon: const Icon(Icons.check_circle, size: 24),
                  label: Text(
                    'daily_coaching_btn_use_plan'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
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

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF5eead4).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF5eead4), size: 24),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayFocusCard(RecommendationController controller) {
    final focusPoints = controller.getTodayFocusPoints();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF5eead4).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'daily_coaching_lbl_focus'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text('🥋', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 20),
          ...focusPoints.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            return Column(
              children: [
                if (index > 0) const SizedBox(height: 12),
                _buildFocusPoint(point.emoji, point.title),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFocusPoint(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$emoji  ', style: const TextStyle(fontSize: 18)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  void _showCoachBotDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF252836),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.smart_toy, color: Color(0xFF5eead4), size: 48),
              const SizedBox(height: 16),
              Text(
                'daily_coaching_dialog_bot_title'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'daily_coaching_dialog_bot_msg'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text('cancel'.tr()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.to(() => CoachBotChatScreen());
                      },
                      child: Text('daily_coaching_dialog_bot_btn_open'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5eead4),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _useRecommendationForSession(
    BuildContext context,
    RecommendationController controller,
  ) {
    if (controller.currentRecommendation.value == null) {
      Get.snackbar(
        'daily_coaching_snackbar_no_rec_title'.tr(),
        'daily_coaching_snackbar_no_rec_msg'.tr(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Mark as implemented
    final recId = controller.currentRecommendation.value!.id;
    controller.markAsImplemented(recId);

    // Show feedback dialog
    _showFeedbackDialog(context, controller, recId);

    // Navigate to session creation screen with pre-filled data
    // You can pass the recommendation data to pre-fill the form
    // Get.to(() => CreateSessionScreen(
    //   recommendation: controller.currentRecommendation.value,
    // ));
  }

  void _showFeedbackDialog(
    BuildContext context,
    RecommendationController controller,
    String recommendationId,
  ) {
    int rating = 5;

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF252836),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Color(0xFF5eead4), size: 48),
              const SizedBox(height: 16),
              Text(
                'daily_coaching_dialog_feedback_title'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFF5eead4),
                      size: 32,
                    ),
                    onPressed: () {
                      rating = index + 1;
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text('daily_coaching_btn_skip'.tr()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.submitFeedback(
                          recommendationId: recommendationId,
                          wasUseful: true,
                          rating: rating,
                          wasImplemented: true,
                        );
                        Get.back();
                      },
                      child: Text('submit'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5eead4),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
