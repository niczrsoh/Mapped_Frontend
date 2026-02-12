import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'belt_progress_modelV2.dart';
import '../controller/controller/trainer_controller.dart';

class BeltProgressRingController extends GetxController {
  var isLoading = false.obs;
  var detailedBeltData = <BeltProgressModelV2>[].obs;
  var beltPercentages = <String, int>{}.obs;

  final ApiService _apiService = ApiService();
  final TrainerController _trainerController =
      Get.isRegistered<TrainerController>()
      ? Get.find<TrainerController>()
      : Get.put(TrainerController());

  var backendShareTipCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBeltProgress();
  }

  Future<void> fetchBeltProgress() async {
    try {
      isLoading.value = true;
      String userId = _trainerController.currentUserId.value;
      if (userId.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        userId = prefs.getString('user_id') ?? '';
      }

      if (userId.isEmpty) {
        isLoading.value = false;
        return;
      }

      final result = await _apiService.fetchBeltProgress(userId);

      if (
          result['success'] == true &&
          result['belts'] != null) {
        Map<String, dynamic> beltsData = result['belts'];

        List<BeltProgressModelV2> parsedModels = [];
        Map<String, int> newMap = {};

        ['W', 'Y', 'G', 'B', 'R', 'L'].forEach((code) {
          if (beltsData.containsKey(code)) {
            var data = beltsData[code];

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
            int percentage = _calculatePercentageForBelt(model);
            newMap[uiName] = percentage;
          }
        });

        detailedBeltData.assignAll(parsedModels);
        beltPercentages.assignAll(newMap);
      }
    } catch (e) {
      print("Error fetching belt progress: $e");
    } finally {
      isLoading.value = false;
    }
  }

  int _calculatePercentageForBelt(BeltProgressModelV2 model) {
    if (model.isCompleted) return 100;
    double currentProgress = model.progressPercentage ?? 0.0;

    if (currentProgress > 0) {
      return currentProgress.round();
    }

    return 0;
  }

  Future<void> syncCalculatedProgress({
    required String beltColor,
    int? sessionCount,
    int? activeDayCount,
    int? openResourceCount,
    double? progressPercentage,
  }) async {
    String uiName = _getUiNameFromCode(beltColor);
    if (progressPercentage != null) {
      beltPercentages[uiName] = progressPercentage.round();
    }
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

  int getPercentage(String beltName) {
    String key = beltName.split(' ')[0];
    return beltPercentages[key] ?? 0;
  }

  bool isBeltLocked(String beltId) {
    int index = -1;
    List<String> order = ['W', 'Y', 'G', 'B', 'R', 'L'];

    // Normalize input
    String code = '';
    if (beltId == 'White')
      code = 'W';
    else if (beltId == 'Yellow')
      code = 'Y';
    else if (beltId == 'Green')
      code = 'G';
    else if (beltId == 'Blue')
      code = 'B';
    else if (beltId == 'Brown')
      code = 'R';
    else if (beltId == 'Black')
      code = 'L';
    else
      code = beltId; 

    index = order.indexOf(code);
    if (index <= 0) return false; 


    String prevCode = order[index - 1];
    var prevBelt = detailedBeltData.firstWhereOrNull(
      (b) => b.beltColor == prevCode,
    );

    if (prevBelt == null) return true;
    return !prevBelt.isCompleted;
  }
}
