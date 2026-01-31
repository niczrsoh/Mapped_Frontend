import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TraineeController extends GetxController {
  static const double totalFormCount = 8.0;
  var loading = false.obs;
  var error = ''.obs;
  var success = false.obs;
  var currentUserId = ''.obs;

  var currentUserName = ''.obs;
  var activeDaysCount = 0.obs;

  // Observable list to update UI automatically
  var traineeList = <dynamic>[].obs;

  // 1. ADD THIS: A reactive map to store "ID -> Percentage String"
  var traineeProgressMap = <String, String>{}.obs;

  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    _loadAuthData();
    fetchTrainees();
    updateActiveDays();
  }

  Future<void> updateActiveDays() async {
    final prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toString().split(' ')[0];
    String? lastDate = prefs.getString('last_active_date');
    int currentCount = prefs.getInt('active_days_count') ?? 0;
    String? userId = prefs.getString('user_id');

    if (lastDate != today) {
      currentCount++;
      await prefs.setInt('active_days_count', currentCount);
      await prefs.setString('last_active_date', today);
    }

    activeDaysCount.value = currentCount;

    if (userId != null && userId.isNotEmpty) {
      await _apiService.updateTrainee(userId, {'activeCount': currentCount});
      print('✅ Active Count synced to backend: $currentCount');
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
        print("✅ TraineeController: Auth data restored ($storedName)");
      } else {
        print("⚠️ TraineeController: No stored auth data found");
      }
    } catch (e) {
      print("❌ TraineeController: Error loading auth data: $e");
    }
  }

  void setUserInfo(String id, String name) {
    currentUserId.value = id;
    currentUserName.value = name;
    print("👤 Trainer Profile Set: $name ($id)");
  }

  // --- FETCH DATA ---
  Future<void> fetchTrainees() async {
    try {
      loading.value = true;
      final result = await _apiService.getAllTrainees();

      if (result['success'] == true) {
        traineeList.assignAll(result['data']);

        // Optional: Trigger progress load for all fetched trainees immediately
        for (var trainee in result['data']) {
          loadTraineeProgress(trainee['id']);
        }
      }
    } catch (e) {
      print('Fetch Error: $e');
    } finally {
      loading.value = false;
    }
  }

  // --- ADD TRAINEE ---
  Future<void> addTrainee({
    required String name,
    required String belt,
    required String dateOfBirth,
    required String gender,
    required String phone,
    required String email,
    required String address,
    required String guardianName,
    required String guardianContact,
    required String guardianAddress,
    String? imagePath,
  }) async {
    try {
      loading.value = true;
      error.value = '';

      final result = await _apiService.addTrainee(
        name: name,
        belt: belt,
        dateOfBirth: dateOfBirth,
        gender: gender,
        phone: phone,
        email: email,
        address: address,
        guardianName: guardianName,
        guardianContact: guardianContact,
        guardianAddress: guardianAddress,
        imagePath: imagePath,
      );

      if (result['success'] == true) {
        success.value = true;
        await fetchTrainees();
      } else {
        error.value = result['error'] ?? 'Failed to add trainee';
        success.value = false;
      }
    } catch (e) {
      print('Trainee Controller Error: $e');
      error.value = 'Error: $e';
      success.value = false;
    } finally {
      loading.value = false;
    }
  }

  // --- UPDATE TRAINEE ---
  Future<void> updateTrainee(String id, Map<String, dynamic> data) async {
    try {
      loading.value = true;
      error.value = '';

      final result = await _apiService.updateTrainee(id, data);
      print('Update Result: $result');

      if (result['success'] == true) {
        success.value = true;

        await fetchTrainees();

        print('Navigating back...');
        Get.back();

        Get.snackbar(
          'Success',
          'Trainee updated successfully',
          backgroundColor: const Color(0xFF00FFA6),
          colorText: Colors.black,
          margin: const EdgeInsets.all(10),
          snackPosition: SnackPosition.TOP,
        );
      } else {
        error.value = result['error'];
        Get.snackbar(
          'Error',
          error.value,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
        );
      }
    } catch (e) {
      print('Controller Update Error: $e');
    } finally {
      loading.value = false;
    }
  }

  // --- DELETE TRAINEE ---
  Future<void> deleteTrainee(String id) async {
    try {
      loading.value = true;
      final result = await _apiService.deleteTrainee(id);

      if (result['success'] == true) {
        success.value = true;
        await fetchTrainees();

        Get.close(2);

        Get.snackbar(
          'Deleted',
          'Trainee removed successfully',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
        );
      } else {
        error.value = result['error'];
        Get.snackbar(
          'Error',
          error.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
        );
      }
    } catch (e) {
      print('Controller Delete Error: $e');
    } finally {
      loading.value = false;
    }
  }

  // Future<void> loadTraineeProgress(String traineeId) async {
  //   try {
  //     final result = await _apiService.getAllProgress(traineeId);
  //     if (result['success'] == true && result['data'] != null) {
  //       List<dynamic> forms = result['data'];
  //       if (forms.isEmpty) {
  //         traineeProgressMap[traineeId] = '0 %';
  //       } else {
  //         double totalPercentage = 0.0;
  //         for (var form in forms) {
  //           totalPercentage += (form['percentage'] ?? 0.0).toDouble();
  //         }
  //         int avg = ((totalPercentage / forms.length) * 100).round();
  //         traineeProgressMap[traineeId] = '$avg %';
  //       }
  //     }
  //   } catch (e) {
  //     print("Error loading progress: $e");
  //   }
  // }

  Future<void> loadTraineeProgress(String traineeId) async {
    try {
      final result = await _apiService.getAllProgress(traineeId);

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];

        // SCENARIO 1: Backend sends Map (Best Case)
        if (data is Map<String, dynamic>) {
          double serverAvg = (data['overallAverage'] ?? 0.0).toDouble();
          int percentageInt = (serverAvg * 100).round();
          traineeProgressMap[traineeId] = '$percentageInt %';
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

          traineeProgressMap[traineeId] = '${(calculatedAvg * 100).round()} %';
        }
      }
    } catch (e) {
      print("Error loading progress: $e");
      traineeProgressMap[traineeId] = '0 %';
    }
  }

  void setTraineeProgressLocally(String id, double value) {
    traineeProgressMap[id] = '${(value * 100).round()} %';
  }

  void resetState() {
    loading.value = false;
    error.value = '';
    success.value = false;
  }
}
