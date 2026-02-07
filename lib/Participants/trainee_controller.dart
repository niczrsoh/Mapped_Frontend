import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'trainee_model.dart';

class TraineeController extends GetxController {
  static const double totalFormCount = 8.0;
  var loading = false.obs;
  var error = ''.obs;
  var success = false.obs;
  var currentUserId = ''.obs;

  var currentUserName = ''.obs;
  var traineeList = <dynamic>[].obs;
  var traineeProgressMap = <String, String>{}.obs;

  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    _loadAuthData().then((_) {
      fetchTrainees();
    });
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
  }

  Future<void> fetchTrainees() async {
    try {
      loading.value = true;

      if (currentUserId.value.isEmpty) {
        await _loadAuthData();
      }

      final result = await _apiService.getAllTrainees();

      if (result['success'] == true) {
        List<dynamic> allData = result['data'];
        if (currentUserId.value.isNotEmpty) {
          List<dynamic> myTrainees = allData
              .where((t) => t['trainerId'] == currentUserId.value)
              .toList();
          traineeList.assignAll(myTrainees);
        } else {
          traineeList.assignAll([]);
        }

        for (var trainee in traineeList) {
          loadTraineeProgress(trainee['id'], trainee['belt'] ?? 'White');
        }
      }
    } catch (e) {
      print('Fetch Error: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> addTrainee(TraineeModel trainee) async {
    try {
      loading.value = true;
      error.value = '';

      final result = await _apiService.addTrainee(trainee);

      if (result['success'] == true) {
        success.value = true;
        await fetchTrainees();
      } else {
        error.value = result['error'] ?? 'Failed to add trainee';
        success.value = false;
      }
    } catch (e) {
      error.value = 'Error: $e';
      success.value = false;
    } finally {
      loading.value = false;
    }
  }

  Future<void> updateTrainee(String id, Map<String, dynamic> data) async {
    try {
      loading.value = true;
      error.value = '';

      final result = await _apiService.updateTrainee(id, data);

      if (result['success'] == true) {
        success.value = true;

        if (result['data'] != null) {
          int index = traineeList.indexWhere((t) => t['id'] == id);

          if (index != -1) {
            final Map<String, dynamic> oldData = traineeList[index];
            final Map<String, dynamic> newData = Map<String, dynamic>.from(
              result['data'],
            );

            traineeList[index] = {...oldData, ...newData};
            traineeList.refresh();
            print(
              "✅ TraineeController: Local state updated for ${result['data']['name']}",
            );
          } else {
            await fetchTrainees();
          }
        } else {
          await fetchTrainees();
        }

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

  Future<void> deleteTrainee(String id) async {
    try {
      loading.value = true;

      final progressRes = await _apiService.deleteProgress(id);
      if (progressRes['success'] != true) {
        print(
          "⚠️ Warning: Failed to delete progress. proceeding to delete trainee. Reason: ${progressRes['msg']}",
        );
      } else {
        print("✅ Progress deleted successfully");
      }

      // 2. Then Delete Trainee
      final result = await _apiService.deleteTrainee(id);

      if (result['success'] == true) {
        success.value = true;
        // Remove from local list immediately
        traineeList.removeWhere((t) => t['id'] == id);
        update(); // Force UI update

        await fetchTrainees();

        Get.close(2); 

        Get.snackbar(
          'Deleted',
          'Trainee and progress removed successfully',
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

  Future<void> loadTraineeProgress(String traineeId, String beltColor) async {
    try {
      final result = await _apiService.getAllProgress(traineeId, beltColor);

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];

        if (data is Map<String, dynamic>) {
          double serverAvg = (data['overallAverage'] ?? 0.0).toDouble();
          int percentageInt = (serverAvg * 100).round();
          traineeProgressMap[traineeId] = '$percentageInt %';
        } else if (data is List) {
          double totalPercentage = 0.0;
          for (var form in data) {
            totalPercentage += (form['percentage'] ?? 0.0).toDouble();
          }

          double calculatedAvg = totalPercentage / totalFormCount;

          if (calculatedAvg > 1.0) calculatedAvg = 1.0;

          traineeProgressMap[traineeId] = '${(calculatedAvg * 100).round()} %';
        }
      }
    } catch (e) {
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
