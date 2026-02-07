import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mapped_frontend/TProgress/belt_progress_modelV2.dart';
import 'dart:convert';
import '../controller/controller/trainer_controller.dart';
import '../services/api_service.dart';

class BeltProgressRingController extends GetxController {
  final TrainerController _trainerController =
      Get.isRegistered<TrainerController>()
      ? Get.find<TrainerController>()
      : Get.put(TrainerController());
  final ApiService _apiService = ApiService();

  var beltPercentages = <String, int>{}.obs;
  var detailedBeltData = <BeltProgressModelV2>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();

    ever(_trainerController.currentUserId, (String uid) {
      if (uid.isNotEmpty) {
        fetchBeltProgress();
      }
    });

    fetchBeltProgress();
  }

  Future<void> syncCalculatedProgress({
    required String beltColor,
    required int sessionCount,
    required int activeDayCount,
    double? progressPercentage,
    int? openResourceCount,
  }) async {
    try {
      String userId = _trainerController.currentUserId.value;
      if (userId.isEmpty) {
        isLoading.value = false;
        return;
      }

      var url = Uri.parse('${_apiService.baseUrl}/belt-progress/sync-belt');

      Map<String, dynamic> requestBody = {
        "userId": userId,
        "beltColor": beltColor,
        "planSessionCount": sessionCount,
        "activeDayCount": activeDayCount,
      };

      if (progressPercentage != null) {
        requestBody["progressPercentage"] = progressPercentage;
      }

      if (openResourceCount != null) {
        requestBody["openResourceCount"] = openResourceCount;
      }

      var body = jsonEncode(requestBody);

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        print(
          "Synced $beltColor: Sessions=$sessionCount, Days=$activeDayCount, Progress=$progressPercentage",
        );
      } else {
        print("Failed to sync: ${response.body}");
      }
    } catch (e) {
      print("Error syncing belt progress: $e");
    }
  }

  Future<void> fetchBeltProgress() async {
    try {
      isLoading.value = true;
      String userId = _trainerController.currentUserId.value;
      if (userId.isEmpty) {
        isLoading.value = false;
        return;
      }

      final result = await _apiService.fetchBeltProgress(userId);

      //update data

      if (result['success'] == true && result['belts'] != null) {
        Map<String, dynamic> beltsData = result['belts'];

        List<BeltProgressModelV2> parsedModels = [];
        Map<String, int> newMap = {};

        ['W', 'Y', 'G', 'B', 'R', 'L'].forEach((code) {
          if (beltsData.containsKey(code)) {
            var data = beltsData[code];

            // Debug the specific field parsing
            if (code == 'W') {
              int rawOpen = data['openResourceCount'] ?? -1;
            }

            var model = BeltProgressModelV2(
              beltColor: code,
              planSessionCount: data['planSessionCount'] ?? 0,
              reqSessionCount: data['reqSessionCount'] ?? 0,
              progress: ProgressCounters.fromJson(data),
              assignedTrainerId: data['assignedTrainerId'],
              isCompleted: data['isCompleted'] ?? false,
              progressPercentage: (data['progressPercentage'] is num)
                  ? (data['progressPercentage'] as num).toDouble()
                  : 0.0,
            );

            parsedModels.add(model);

            String uiName = _getUiNameFromCode(code);
            int percentage = _calculatePercentageForBelt(model, uiName);
            newMap[uiName] = percentage;
          }
        });

        detailedBeltData.assignAll(parsedModels);
        beltPercentages.assignAll(newMap);
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBeltProgress(String beltCode, String actionType) async {
    try {
      String userId = _trainerController.currentUserId.value;
      if (userId.isEmpty) {
        isLoading.value = false;
        return;
      }

      // Use the service method
      final result = await _apiService.updateBeltProgress(
        userId: userId,
        beltColor: beltCode,
        actionType: actionType,
      );

      if (result['success'] == true) {
        await fetchBeltProgress();
      } else {
        Get.snackbar("Error", result['msg'] ?? "Failed to update progress");
      }
    } catch (e) {
      print("Network Error: $e");
    }
  }

  int getPercentage(String beltName) {
    String cleanName = beltName.replaceAll(' Belt', '');
    return beltPercentages[cleanName] ?? 0;
  }

  String _getUiNameFromCode(String code) {
    switch (code) {
      case 'W':
        return 'White';
      case 'Y':
        return 'Yellow';
      case 'G':
        return 'Green';
      case 'B':
        return 'Blue';
      case 'R':
        return 'Brown';
      case 'L':
        return 'Black';
      default:
        return 'White';
    }
  }

  int _calculatePercentageForBelt(BeltProgressModelV2 belt, String beltName) {
    if (belt.progressPercentage != null) {
      return belt.progressPercentage!.round();
    }

    double current = 0;
    double target = 1;

    var p = belt.progress;
    int sessions = belt.planSessionCount;
    int activeDays = p.activeDayCount;
    int openResources = p.openResourceCount;

    const int hcRecs = 3;
    const int hcPhotos = 5;
    const int hcReflections = 1;
    const int hcForumPosts = 1;

    if (beltName == 'White') {
      current =
          sessions.toDouble() +
          openResources.clamp(0, 3) +
          activeDays.toDouble();
      target = belt.reqSessionCount.toDouble() + 3 + 3;
    } else if (beltName == 'Yellow') {
      current = sessions.toDouble() + hcRecs + hcPhotos + activeDays.toDouble();
      target = belt.reqSessionCount.toDouble() + 3 + 5 + 5;
    } else if (beltName == 'Green') {
      current =
          sessions.toDouble() +
          5 +
          hcReflections +
          hcForumPosts +
          activeDays.toDouble();
      target = belt.reqSessionCount.toDouble() + 5 + 1 + 1 + 14;
    } else if (beltName == 'Blue') {
      current = sessions.toDouble() + 1 + 1 + activeDays.toDouble();
      target = belt.reqSessionCount.toDouble() + 1 + 1 + 30;
    } else if (beltName == 'Brown') {
      current = sessions.toDouble() + 10 + 3 + activeDays.toDouble();
      target = belt.reqSessionCount.toDouble() + 10 + 3 + 60;
    }

    if (target == 0) return 0;

    double fraction = (current / target).clamp(0.0, 1.0);
    return (fraction * 100).round();
  }
}
