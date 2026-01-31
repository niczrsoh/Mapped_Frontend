import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import 'package:mapped_frontend/controller/user_controller';

class SessionController extends GetxController {
  // Service Injection
  final ApiService _apiService = ApiService();

  // --- STATE VARIABLES ---
  var isLoading = false.obs;
  var error = ''.obs;
  var success = false.obs;

  // --- DASHBOARD DATA HOLDERS ---
  var currentSession = Rxn<dynamic>();
  var upcomingSession = Rxn<dynamic>();
  var historySession = Rxn<dynamic>();
  var totalSessionsCount = 0.obs;

  // List variables (For the Detailed Screens)
  var upcomingList = <dynamic>[].obs;
  var historyList = <dynamic>[].obs;
  var currentList = <dynamic>[]
      .obs; // In case there are multiple overlapping current sessions

  @override
  void onInit() {
    super.onInit();
    // Automatically load data when the controller is initialized
    fetchDashboardData();
  }

  // ==================================================
  // 1. FETCH DASHBOARD DATA (Current, Upcoming, History)
  // ==================================================
  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;

      // Get User Details for API Call
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

        // --- 1. Handle Current Sessions ---
        final currentRaw = data['current'];
        if (currentRaw is List) {
          currentList.assignAll(List.from(currentRaw));
        } else if (currentRaw is Map) {
          currentList.assignAll([currentRaw]);
        } else {
          currentList.clear();
        }
        // Update Singular Variable (For Dashboard Card)
        currentSession.value = currentList.isNotEmpty ? currentList[0] : null;

        // --- 2. Handle Upcoming Sessions ---
        var upcomingRaw = data['upcoming'];
        if (upcomingRaw is List) {
          upcomingList.assignAll(List.from(upcomingRaw));
        } else if (upcomingRaw is Map) {
          upcomingList.assignAll([upcomingRaw]);
        } else {
          upcomingList.clear();
        }
        // Update Singular Variable (For Dashboard Card)
        upcomingSession.value = upcomingList.isNotEmpty
            ? upcomingList[0]
            : null;

        // --- 3. Handle History Sessions ---
        var historyRaw = data['history'];
        if (historyRaw is List) {
          historyList.assignAll(List.from(historyRaw));
        } else if (historyRaw is Map) {
          historyList.assignAll([historyRaw]);
        } else {
          historyList.clear();
        }
        // Update Singular Variable (For Dashboard Card)
        historySession.value = historyList.isNotEmpty ? historyList[0] : null;

        // Calculate Total Sessions
        totalSessionsCount.value =
            currentList.length + upcomingList.length + historyList.length;

        print("✅ Dashboard Data Updated (Robust Mode)");
      } else {
        print("❌ Failed to load dashboard: ${result['msg']}");
      }
    } catch (e) {
      print("💥 Dashboard Controller Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ==================================================
  // 2. CREATE NEW SESSION
  // ==================================================
  Future<void> createSession({
    required String trainer,
    required String date,
    required String startTime, // ✅ NEW
    required String endTime, // ✅ NEW
    required String venue,
    required String totalTrainees,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      success.value = false;

      // Get User Details for API Call
      String tId = '';
      try {
        if (Get.isRegistered<UserController>()) {
          final userController = Get.find<UserController>();
          tId = userController.userId.value;
        }
      } catch (e) {
        print("Could not find UserController: $e");
      }

      final result = await _apiService.createSession(
        trainer: trainer,
        date: date,
        startTime: startTime, // Sending ISO String
        endTime: endTime, // Sending ISO String
        venue: venue,
        totalTrainees: totalTrainees,
        trainerId: tId,
      );

      if (result['success'] == true) {
        success.value = true;
        await fetchDashboardData();
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
  }

  // ==================================================
  // 3. UPDATE SESSION
  // ==================================================
  Future<void> updateSession({
    required String id,
    required String trainer,
    required String date,
    required String startTime,
    required String endTime,
    required String venue,
    required String totalTrainees,
  }) async {
    try {
      isLoading.value = true;
      success.value = false;

      final result = await _apiService.updateSession(
        id: id,
        trainer: trainer,
        date: date,
        startTime: startTime,
        endTime: endTime,
        venue: venue,
        totalTrainees: totalTrainees,
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

  void resetState() {
    isLoading.value = false;
    error.value = '';
    success.value = false;
  }
}
