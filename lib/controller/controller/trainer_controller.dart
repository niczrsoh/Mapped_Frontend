import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrainerController extends GetxController {
  static const double totalFormCount = 8.0;
  var loading = false.obs;
  var error = ''.obs;
  var success = false.obs;
  var currentUserId = ''.obs;

  var currentUserName = ''.obs;
  var activeDaysCount = 0.obs;
  var trainerList = <dynamic>[].obs;

  var trainerProgressMap = <String, String>{}.obs;

  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    _loadAuthData().then((_) {
      fetchTrainers();
      updateActiveDays();
    });
  }

  Future<void> updateActiveDays() async {
    final prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toString().split(' ')[0];
    String? lastDate = prefs.getString('last_active_date');

    // 1. Ensure we have the ID. If GetX var is empty, try Prefs one last time.
    String userId = currentUserId.value;
    if (userId.isEmpty) {
      userId = prefs.getString('user_id') ?? '';
      if (userId.isNotEmpty) currentUserId.value = userId;
    }

    if (userId.isEmpty) {
      print("⚠️ updateActiveDays skipped: No User ID found.");
      return;
    }

    int currentCount = 0;

    try {
      print("🔄 Fetching Active Count for User: $userId");

      // 2. Fetch from Backend (Source of Truth)
      var profile = await _apiService.getTrainerById(userId);

      // Fallback to profile if trainer endpoint fails
      if (profile['success'] != true) {
        profile = await _apiService.getUserProfile(userId);
      }

      if (profile['success'] == true && profile['data'] != null) {
        var userData = profile['data'];

        // Handle nesting
        if (userData['data'] != null)
          userData = userData['data'];
        else if (userData['user'] != null)
          userData = userData['user'];

        // 3. Parse Backend Count safely
        int backendCount =
            int.tryParse(
              userData['activeCount']?.toString() ??
                  userData['activeDaysCount']?.toString() ??
                  userData['activeDays']?.toString() ??
                  '0',
            ) ??
            0;

        print(
          "📊 Backend says: $backendCount | Local says: ${prefs.getInt('active_days_count')}",
        );

        // 4. SYNC LOGIC: Trust Backend if it is higher than 0
        // We set currentCount to backendCount immediately
        if (backendCount > 0) {
          currentCount = backendCount;
          // Sync local storage to match backend
          await prefs.setInt('active_days_count', currentCount);
        } else {
          // If backend is 0, we check if local is dangerously high (test data)
          int local = prefs.getInt('active_days_count') ?? 0;
          if (local > 100) {
            print(
              "⚠️ Local count ($local) seems invalid. Resetting to 0 match backend.",
            );
            currentCount = 0;
            await prefs.setInt('active_days_count', 0);
          } else {
            currentCount = local;
          }
        }
      }
    } catch (e) {
      print("⚠️ Active Count Sync Failed: $e");
      currentCount = prefs.getInt('active_days_count') ?? 0;
    }

    // 5. Increment Logic (Check if user already logged in today)
    if (lastDate != today) {
      print("📅 New Day Detected! Incrementing count.");
      currentCount++;

      // Save new values locally
      await prefs.setInt('active_days_count', currentCount);
      await prefs.setString('last_active_date', today);

      // Save new value to Backend
      await _apiService.updateTrainer(userId, {
        'activeCount': currentCount,
        'activeDaysCount': currentCount,
      });
    } else {
      print("📅 User already active today. No increment.");
    }

    // 6. Update UI
    activeDaysCount.value = currentCount;
    update();
  }

  Future<void> forceUpdateActiveCount(int newCount) async {
    if (newCount > activeDaysCount.value) {
      print(
        "🚀 Found higher count in Belt Data ($newCount). Updating Local State.",
      );
      activeDaysCount.value = newCount;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('active_days_count', newCount);
      update();
    }
  }

  Future<void> _loadAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? storedId = prefs.getString('user_id');
      final String? storedName = prefs.getString('user_name');

      if (storedId != null && storedName != null) {
        currentUserId.value = storedId;
        currentUserName.value = storedName;
        print("✅ TrainerController: Auth data restored ($storedName)");
      } else {
        print("⚠️ TrainerController: No stored auth data found");
      }
    } catch (e) {
      print("❌ TrainerController: Error loading auth data: $e");
    }
  }

  void setUserInfo(String id, String name) {
    currentUserId.value = id;
    currentUserName.value = name;
    print("👤 Trainer Profile Set: $name ($id)");
  }

  // --- FETCH DATA ---
  Future<void> fetchTrainers() async {
    try {
      loading.value = true;
      final result = await _apiService.getAllTrainers();

      if (result['success'] == true) {
        trainerList.assignAll(result['data']);

        // Optional: Trigger progress load for all fetched trainers immediately
        for (var trainer in result['data']) {
          loadTrainerProgress(trainer['id'], trainer['belt'] ?? 'Black');
        }
      }
    } catch (e) {
      print('Fetch Error: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadTrainerProgress(String trainerId, String beltColor) async {
    try {
      final result = await _apiService.getAllProgress(trainerId, beltColor);

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];

        // SCENARIO 1: Backend sends Map (Best Case)
        if (data is Map<String, dynamic>) {
          double serverAvg = (data['overallAverage'] ?? 0.0).toDouble();
          int percentageInt = (serverAvg * 100).round();
          trainerProgressMap[trainerId] = '$percentageInt %';
        }
        // SCENARIO 2: Backend sends List (Fallback)
        else if (data is List) {
          double totalPercentage = 0.0;
          for (var form in data) {
            totalPercentage += (form['percentage'] ?? 0.0).toDouble();
          }

          // Divide by total form count (8), NOT items count
          double calculatedAvg = totalPercentage / totalFormCount;

          if (calculatedAvg > 1.0) calculatedAvg = 1.0;

          trainerProgressMap[trainerId] = '${(calculatedAvg * 100).round()} %';
        }
      }
    } catch (e) {
      print("Error loading progress: $e");
      trainerProgressMap[trainerId] = '0 %';
    }
  }

  void setTrainerProgressLocally(String id, double value) {
    trainerProgressMap[id] = '${(value * 100).round()} %';
  }

  void resetState() {
    loading.value = false;
    error.value = '';
    success.value = false;
  }
}
