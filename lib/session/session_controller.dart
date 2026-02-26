import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import '../services/api_service.dart';
import 'package:mapped_frontend/controller/user_controller';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mapped_frontend/TProgress/belt_progress_ring_controller.dart';
import 'session_model.dart';

class SessionController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var error = ''.obs;
  var success = false.obs;
  var currentSession = Rxn<SessionModel>();
  var upcomingSession = Rxn<SessionModel>();
  var historySession = Rxn<SessionModel>();
  var totalSessionsCount = 0.obs;
  var upcomingList = <SessionModel>[].obs;
  var historyList = <SessionModel>[].obs;
  var currentList = <SessionModel>[].obs;
  var submittedReflectionSessionIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
    fetchSubmittedReflections();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      String tId = '';
      String tName = '';

      try {
        if (Get.isRegistered<UserController>()) {
          final userController = Get.find<UserController>();
          tId = userController.userId.value;
          tName = userController.userName;
        }
      } catch (e) {
        print("Could not find UserController: $e");
      }

      // Fallback: if UserController wasn't ready, try stored prefs
      if (tId.isEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          tId = prefs.getString('user_id') ?? '';
        } catch (e) {
          print('Could not read stored user_id: $e');
        }
      }

      final result = await _apiService.getSessionDashboard(
        trainerId: tId,
        trainerName: tName,
      );

      if (result['success'] == true) {
        final data = result['data'];

        final currentRaw = data['current'];
        if (currentRaw is List) {
          currentList.assignAll(
            currentRaw.map((e) => SessionModel.fromJson(e)).toList(),
          );
        } else if (currentRaw is Map) {
          currentList.assignAll([
            SessionModel.fromJson(currentRaw as Map<String, dynamic>),
          ]);
        } else {
          currentList.clear();
        }
        currentSession.value = currentList.isNotEmpty ? currentList[0] : null;

        // 2. Parse Upcoming List
        var upcomingRaw = data['upcoming'];
        if (upcomingRaw is List) {
          upcomingList.assignAll(
            upcomingRaw.map((e) => SessionModel.fromJson(e)).toList(),
          );
        } else if (upcomingRaw is Map) {
          upcomingList.assignAll([
            SessionModel.fromJson(upcomingRaw as Map<String, dynamic>),
          ]);
        } else {
          upcomingList.clear();
        }
        upcomingSession.value = upcomingList.isNotEmpty
            ? upcomingList[0]
            : null;

        // 3. Parse History List
        var historyRaw = data['history'];
        if (historyRaw is List) {
          historyList.assignAll(
            historyRaw.map((e) => SessionModel.fromJson(e)).toList(),
          );
        } else if (historyRaw is Map) {
          historyList.assignAll([
            SessionModel.fromJson(historyRaw as Map<String, dynamic>),
          ]);
        } else {
          historyList.clear();
        }
        historySession.value = historyList.isNotEmpty ? historyList[0] : null;

        totalSessionsCount.value =
            currentList.length + upcomingList.length + historyList.length;

        _syncReflectionsFromSessions([
          ...currentList,
          ...historyList,
          ...upcomingList,
        ]);

        print("✅ Dashboard Data Updated");
      } else {
        print("❌ Failed to load dashboard: ${result['msg']}");
      }
    } catch (e) {
      print("💥 Dashboard Controller Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<SessionModel?> createSession(SessionModel session) async {
    try {
      isLoading.value = true;
      error.value = '';
      success.value = false;
      String tId = '';
      String tName = '';

      if (Get.isRegistered<UserController>()) {
        final userController = Get.find<UserController>();
        tId = userController.userId.value;
        tName = userController.userName;
      }

      if (session.trainerId == null || session.trainerId!.isEmpty) {
        session.trainerId = tId;
      }
      if (session.trainer == null || session.trainer!.isEmpty) {
        session.trainer = tName;
      }

      if (session.duration == null) {
        session.duration = "0 min";
      }

      final result = await _apiService.createSession(session);

      if (result['success'] == true) {
        success.value = true;

        if (session.trainerId != null && session.trainerId!.isNotEmpty) {
          try {
            await _apiService.updateBeltProgress(
              userId: session.trainerId!,
              beltColor: 'W',
              actionType: 'session',
            );

            if (Get.isRegistered<BeltProgressRingController>()) {
              Get.find<BeltProgressRingController>().fetchBeltProgress();
            }
          } catch (e) {
            print("⚠️ Failed to update belt progress: $e");
          }
        }

        await fetchDashboardData();

        if (result['data'] != null) {
          return SessionModel.fromJson(result['data']);
        }
      } else {
        error.value = result['msg'] ?? 'error'.tr();
        success.value = false;
      }
    } catch (e) {
      print('Session Create Error: $e');
      error.value = 'error_connection'.tr(namedArgs: {'error': e.toString()});
      success.value = false;
    } finally {
      isLoading.value = false;
    }
    return null;
  }

  Future<void> updateSession({
    required String id,
    required String trainer,
    required String date,
    required String duration,
    required String venue,
    required String totalTrainees,
  }) async {
    try {
      isLoading.value = true;
      success.value = false;

      final result = await _apiService.updateSession(
        id: id,
        data: {
          'trainer': trainer,
          'date': date,
          'duration': duration,
          'venue': venue,
          'totalTrainees': totalTrainees,
        },
      );

      if (result['success'] == true) {
        success.value = true;

        await fetchDashboardData();
      } else {
        error.value = result['msg'] ?? 'error'.tr();
        success.value = false;
      }
    } catch (e) {
      print('Update Error: $e');
      error.value = 'error_connection'.tr(namedArgs: {'error': e.toString()});
      success.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSessionGeneric(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      isLoading.value = true;
      success.value = false;

      final Map<String, dynamic> updateData = Map.from(data);
      updateData.remove('_id');
      updateData.remove('id');
      updateData.remove('createdAt');
      updateData.remove('updatedAt');

      final result = await _apiService.updateSession(id: id, data: updateData);

      if (result['success'] == true) {
        success.value = true;
        await fetchDashboardData();
      } else {
        error.value = result['msg'] ?? 'error'.tr();
        success.value = false;
      }
    } catch (e) {
      error.value = 'error_connection'.tr(namedArgs: {'error': e.toString()});
      success.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void resetState() {
    isLoading.value = false;
    error.value = '';
    success.value = false;
  }

  Future<void> fetchSubmittedReflections() async {
    try {
      String userId = '';
      if (Get.isRegistered<UserController>()) {
        final userController = Get.find<UserController>();
        userId = userController.userId.value;
      }

      if (userId.isEmpty) return;

      final result = await _apiService.getUserReflectionProgress(userId);

      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> sessionIds = result['data'] as List<dynamic>;
        final Set<String> ids = sessionIds
            .map((id) => id.toString())
            .where((id) => id.isNotEmpty)
            .toSet();
        submittedReflectionSessionIds.clear();
        submittedReflectionSessionIds.addAll(ids);
      }
    } catch (e) {
      // Silent fail - user can still submit reflections
    }
  }

  void _syncReflectionsFromSessions(List<SessionModel> sessions) {
    for (var session in sessions) {
      if (session.id != null && session.reflection != null) {
        if (session.reflection!.isNotEmpty) {
          submittedReflectionSessionIds.add(session.id!);
        }
      }
    }

    submittedReflectionSessionIds.refresh();
  }

  void markReflectionAsSubmitted(String sessionId) async {
    String userId = '';
    if (Get.isRegistered<UserController>()) {
      final userController = Get.find<UserController>();
      userId = userController.userId.value;
    }

    if (userId.isEmpty || sessionId.isEmpty) {
      return;
    }

    if (submittedReflectionSessionIds.contains(sessionId)) {
      return;
    }

    submittedReflectionSessionIds.add(sessionId);

    try {
      final result = await _apiService.recordReflectionSubmission(
        sessionId,
        userId,
      );

      if (result['success'] == true) {
        try {
          await _apiService.updateBeltProgress(
            userId: userId,
            beltColor: 'W',
            actionType: 'reflection',
          );
        } catch (e) {
          print("⚠️ Belt update failed: $e");
        }

        if (Get.isRegistered<BeltProgressRingController>()) {
          await Get.find<BeltProgressRingController>().fetchBeltProgress();
        }
      } else {
        submittedReflectionSessionIds.remove(sessionId);
      }
    } catch (e) {
      submittedReflectionSessionIds.remove(sessionId);
    }
  }
}
