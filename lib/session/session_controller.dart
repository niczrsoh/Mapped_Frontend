import 'package:get/get.dart';
import '../services/api_service.dart';
import 'package:mapped_frontend/controller/user_controller';
import 'session_model.dart';

class SessionController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var error = ''.obs;
  var success = false.obs;

  // Use SessionModel? instead of dynamic
  var currentSession = Rxn<SessionModel>();
  var upcomingSession = Rxn<SessionModel>();
  var historySession = Rxn<SessionModel>();

  var totalSessionsCount = 0.obs;

  // Lists of SessionModel
  var upcomingList = <SessionModel>[].obs;
  var historyList = <SessionModel>[].obs;
  var currentList = <SessionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
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

        print("✅ Dashboard Data Updated (Model Mode)");
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
        await fetchDashboardData();
        if (result['data'] != null) {
          return SessionModel.fromJson(result['data']);
        }
      } else {
        error.value = result['msg'] ?? 'Failed to create session';
        success.value = false;
      }
    } catch (e) {
      print('Session Create Error: $e');
      error.value = 'Error: $e';
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
        error.value = result['msg'] ?? 'Failed to update';
        success.value = false;
      }
    } catch (e) {
      print('Update Error: $e');
      error.value = 'Error: $e';
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
        error.value = result['msg'] ?? 'Failed to update';
        success.value = false;
      }
    } catch (e) {
      error.value = 'Error: $e';
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
}
