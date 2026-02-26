import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:mapped_frontend/controller/user_controller';
import 'package:mapped_frontend/services/api_service.dart';
import 'recommendation_service.dart';
import 'recommendation_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecommendationController extends GetxController {
  final RecommendationService _recommendationService = RecommendationService();

  // Observable variables
  final Rx<SessionRecommendation?> currentRecommendation =
      Rx<SessionRecommendation?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isGenerating = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<SessionRecommendation> history = <SessionRecommendation>[].obs;
  final ApiService _apiService = ApiService();
  // Cache management
  final RxBool isCached = false.obs;
  final RxString lastGeneratedDate = ''.obs;

  // User ID (should be set from your auth controller)
  String? _userId;

  @override
  void onInit() {
    super.onInit();
    _loadUserId();
  }

  /// Load user ID from storage or auth controller
  Future<void> _loadUserId() async {
    try {
      // Option 1: Get from SharedPreferences
      // final prefs = await SharedPreferences.getInstance();
      // _userId = prefs.getString('userId');
      final UserController userController = Get.find<UserController>();
      _userId = userController.userId.value as String?;

      if (_userId != null) {
        //get session
        await loadTodayRecommendation();
      }
    } catch (e) {
      print('Error loading user ID: $e');
    }
  }

  /// Set user ID manually if needed
  void setUserId(String userId) {
    _userId = userId;
    loadTodayRecommendation();
  }

  /// Load today's recommendation (cached or generate new)
  Future<void> loadTodayRecommendation({bool forceNew = false}) async {
    if (_userId == null) {
      errorMessage.value = 'error_not_logged_in'.tr();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      //check health
      Future<bool> checkHealth() async {
        final health = await _recommendationService.checkHealth();
        debugPrint(health.toString());
        return health;
      }

      // Try to get latest first
      if (!forceNew) {
        final health = await checkHealth();
        if (health == false) return;
        final latest = await _recommendationService.getLatestRecommendation(
          _userId!,
        );
        if (latest != null) {
          currentRecommendation.value = latest;
          isCached.value = true;
          lastGeneratedDate.value = _formatDate(latest.recommendationDate);
          isLoading.value = false;
          return;
        }
      }

      // Generate new recommendation if none exists or forced
      await generateNewRecommendation(forceNew: forceNew);
    } catch (e) {
      errorMessage.value = 'rec_ctrl_error_load_fail'.tr(args: [e.toString()]);
      print('Error loading recommendation: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Generate a new AI recommendation
  Future<void> generateNewRecommendation({bool forceNew = false}) async {
    if (_userId == null) {
      errorMessage.value = 'error_not_logged_in'.tr();
      return;
    }

    try {
      isGenerating.value = true;
      errorMessage.value = '';

      final recommendation = await _recommendationService
          .generateRecommendation(_userId!, forceNew: forceNew);

      if (recommendation != null) {
        currentRecommendation.value = recommendation;
        isCached.value = recommendation.cached ?? false;
        lastGeneratedDate.value = _formatDate(
          recommendation.recommendationDate,
        );

        // Show success message
        Get.snackbar(
          'rec_ctrl_snackbar_success_title'.tr(),
          forceNew
              ? 'rec_ctrl_snackbar_new_gen'.tr()
              : 'rec_ctrl_snackbar_loaded'.tr(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF5eead4),
          colorText: Colors.black,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      errorMessage.value = 'rec_ctrl_error_gen_fail'.tr();
      Get.snackbar(
        'rec_ctrl_snackbar_error_title'.tr(),
        'rec_ctrl_error_gen_fail'.tr(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Error generating recommendation: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  /// Load recommendation history
  Future<void> loadHistory({int limit = 10}) async {
    if (_userId == null) return;

    try {
      final historyList = await _recommendationService.getHistory(
        _userId!,
        limit: limit,
      );
      history.value = historyList;
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  /// Submit feedback for a recommendation
  Future<void> submitFeedback({
    required String recommendationId,
    required bool wasUseful,
    required int rating,
    String? comments,
    bool wasImplemented = false,
  }) async {
    try {
      await _recommendationService.submitFeedback(
        recommendationId: recommendationId,
        wasUseful: wasUseful,
        rating: rating,
        comments: comments,
        wasImplemented: wasImplemented,
      );

      Get.snackbar(
        'rec_ctrl_snackbar_feedback_title'.tr(),
        'rec_ctrl_snackbar_feedback_msg'.tr(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF5eead4),
        colorText: Colors.black,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error submitting feedback: $e');
    }
  }

  /// Mark recommendation as implemented (used in a session)
  Future<void> markAsImplemented(String recommendationId) async {
    try {
      await _recommendationService.markAsImplemented(recommendationId);

      // Update local state
      if (currentRecommendation.value?.id == recommendationId) {
        currentRecommendation.value = currentRecommendation.value?.copyWith(
          status: 'implemented',
        );
      }
    } catch (e) {
      print('Error marking as implemented: $e');
    }
  }

  /// Dismiss current recommendation
  Future<void> dismissRecommendation(String recommendationId) async {
    try {
      await _recommendationService.dismissRecommendation(recommendationId);

      // Clear current recommendation
      if (currentRecommendation.value?.id == recommendationId) {
        currentRecommendation.value = null;
      }

      Get.snackbar(
        'rec_ctrl_snackbar_dismiss_title'.tr(),
        'rec_ctrl_snackbar_dismiss_msg'.tr(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error dismissing recommendation: $e');
    }
  }

  /// Get analytics
  Future<Map<String, dynamic>?> getAnalytics() async {
    if (_userId == null) return null;

    try {
      return await _recommendationService.getAnalytics(_userId!);
    } catch (e) {
      print('Error getting analytics: $e');
      return null;
    }
  }

  /// Refresh recommendation
  Future<void> refresh() async {
    await loadTodayRecommendation();
  }

  /// Force new recommendation
  Future<void> forceNewRecommendation() async {
    await loadTodayRecommendation(forceNew: true);
  }

  // Helper methods

  /// Check if recommendation is expired
  bool get isExpired {
    if (currentRecommendation.value == null) return true;
    return currentRecommendation.value!.expiresAt.isBefore(DateTime.now());
  }

  /// Check if recommendation exists
  bool get hasRecommendation => currentRecommendation.value != null;

  /// Get primary goal text
  String get primaryGoal {
    return currentRecommendation.value?.recommendation.goals.primary ??
        'rec_ctrl_no_rec_available'.tr();
  }

  /// Get warmup description
  String get warmupDescription {
    return currentRecommendation.value?.recommendation.warmup.description ?? '';
  }

  /// Get warmup exercises
  List<String> get warmupExercises {
    return currentRecommendation.value?.recommendation.warmup.keyExercises ??
        [];
  }

  /// Get activity description
  String get activityDescription {
    return currentRecommendation.value?.recommendation.activity.description ??
        '';
  }

  /// Get activity drills
  List<String> get activityDrills {
    return currentRecommendation.value?.recommendation.activity.drills ?? [];
  }

  /// Get cooldown description
  String get cooldownDescription {
    return currentRecommendation.value?.recommendation.cooldown.description ??
        '';
  }

  /// Get cooldown exercises
  List<String> get cooldownExercises {
    return currentRecommendation.value?.recommendation.cooldown.keyExercises ??
        [];
  }

  /// Get motivational message
  String get motivationalMessage {
    return currentRecommendation.value?.insights.motivationalMessage ??
        'rec_ctrl_default_motive'.tr();
  }

  /// Get tips for today
  List<String> get tipsForToday {
    return currentRecommendation.value?.insights.tipsForToday ?? [];
  }

  /// Get suggested duration
  int get suggestedDuration {
    return currentRecommendation.value?.recommendation.suggestedDuration ?? 60;
  }

  /// Get suggested level
  String get suggestedLevel {
    return currentRecommendation.value?.recommendation.suggestedLevel ??
        'rec_ctrl_beginner_level'.tr();
  }

  /// Format date helper
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'today'.tr();
    } else if (checkDate == today.subtract(const Duration(days: 1))) {
      return 'yesterday'.tr();
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Get all focus points for today (warmup, activity, safety, cooldown)
  List<FocusPoint> getTodayFocusPoints() {
    if (currentRecommendation.value == null) {
      return _getDefaultFocusPoints();
    }

    final rec = currentRecommendation.value!;
    final points = <FocusPoint>[];

    // Warmup
    if (rec.recommendation.warmup.keyExercises.isNotEmpty) {
      final warmupTime = rec.recommendation.warmup.suggestedTime;
      final exercises = rec.recommendation.warmup.keyExercises
          .take(2)
          .join(' + ');
      points.add(
        FocusPoint(
          emoji: '🏃',
          title: 'rec_ctrl_focus_warmup'.tr(
            namedArgs: {'exercises': exercises, 'time': warmupTime.toString()},
          ),
        ),
      );
    }

    // Main activity
    if (rec.recommendation.activity.focusAreas.isNotEmpty) {
      final focus = rec.recommendation.activity.focusAreas.first;
      points.add(
        FocusPoint(
          emoji: '🥋',
          title: 'rec_ctrl_focus_tech'.tr(namedArgs: {'focus': focus}),
        ),
      );
    }

    // Safety
    if (rec.recommendation.riskAssessment.keyRisks.isNotEmpty) {
      final safety =
          rec.recommendation.riskAssessment.mitigationStrategies.first;
      points.add(
        FocusPoint(
          emoji: '⚠️',
          title: 'rec_ctrl_focus_safety'.tr(namedArgs: {'strategy': safety}),
        ),
      );
    }

    // Cooldown
    if (rec.recommendation.cooldown.keyExercises.isNotEmpty) {
      final cooldownTime = rec.recommendation.cooldown.suggestedTime;
      final exercises = rec.recommendation.cooldown.keyExercises
          .take(2)
          .join(' + ');
      points.add(
        FocusPoint(
          emoji: '🧘',
          title: 'rec_ctrl_focus_finish'.tr(
            namedArgs: {
              'exercises': exercises,
              'time': cooldownTime.toString(),
            },
          ),
        ),
      );
    }

    return points;
  }

  /// Default focus points when no recommendation is available
  List<FocusPoint> _getDefaultFocusPoints() {
    return [
      FocusPoint(emoji: '🏃', title: 'rec_ctrl_default_focus_warmup'.tr()),
      FocusPoint(emoji: '🥋', title: 'rec_ctrl_default_focus_tech'.tr()),
      FocusPoint(emoji: '⚠️', title: 'rec_ctrl_default_focus_safety'.tr()),
      FocusPoint(emoji: '🧘', title: 'rec_ctrl_default_focus_finish'.tr()),
    ];
  }
}

/// Helper class for focus points
class FocusPoint {
  final String emoji;
  final String title;

  FocusPoint({required this.emoji, required this.title});
}
