import 'package:get/get.dart';
import '../services/api_service.dart';
import 'trainee_controller.dart';
import '../TProgress/belt_progress_ring_controller.dart';

class ProgressController extends GetxController {
  final ApiService _apiService = ApiService();

  static const int totalFormCount = 8;
  var isLoading = false.obs;
  var currentScore =0.0.obs; 
  var overallAverage = 0.0.obs;
  var loadedTechniques = <String, int>{}.obs;
  var loadedKicks = <String, int>{}.obs;


  Future<void> fetchProgress(
    String traineeId,
    String beltColor, 
    String form,
  ) async {
    try {
      isLoading.value = true;
      final result = await _apiService.getProgress(traineeId, beltColor, form);

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];

        currentScore.value = (data['percentage'] ?? 0.0).toDouble();

        if (data['techniques'] != null) {
          Map<String, dynamic> techMap = data['techniques'];
          loadedTechniques.value = techMap.map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          );
        } else {
          loadedTechniques.clear();
        }

        if (data['kicks'] != null) {
          Map<String, dynamic> kicksMap = data['kicks'];
          loadedKicks.value = kicksMap.map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          );
        } else {
          loadedKicks.clear();
        }
      } else {
        currentScore.value = 0.0;
        loadedTechniques.clear();
        loadedKicks.clear();
      }
    } catch (e) {
      print("Error fetching progress: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProgress({
    required String traineeId,
    required String beltColor,
    required String form,
    required Map<String, int> techniques,
    required Map<String, int> kicks,
  }) async {
    try {

      _calculateLocalScore(techniques, kicks);

      final result = await _apiService.saveProgress({
        'traineeId': traineeId,
        'beltColor': beltColor, 
        'form': form,
        'techniques': techniques,
        'kicks': kicks,
      });

      if (result['success'] == true) {

        currentScore.value = (result['data']['percentage'] ?? 0.0).toDouble();
        await fetchOverallStats(traineeId, beltColor);

        if (Get.isRegistered<TraineeController>()) {
          Get.find<TraineeController>().setTraineeProgressLocally(
            traineeId,
            overallAverage.value,
          );
        }

        if (Get.isRegistered<BeltProgressRingController>()) {
          await Get.find<BeltProgressRingController>().fetchBeltProgress();
        }
      }
    } catch (e) {
      print("Error saving progress: $e");
    }
  }

  Future<void> fetchOverallStats(String traineeId, String beltColor) async {
    try {
      final result = await _apiService.getAllProgress(traineeId, beltColor);

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];


        if (data is Map<String, dynamic>) {
          List? formsList;
          if (data['forms'] is List) {
            formsList = data['forms'];
          } else if (data['progress'] is List) {
            formsList = data['progress'];
          } else {
            for (var val in data.values) {
              if (val is List &&
                  val.isNotEmpty &&
                  val.first is Map &&
                  val.first.containsKey('percentage')) {
                formsList = val;
                break;
              }
            }
          }

          if (formsList != null) {
            double sumOfPercentages = 0.0;
            for (var form in formsList) {
              sumOfPercentages += (form['percentage'] ?? 0.0).toDouble();
            }
            double calculatedAvg = sumOfPercentages / totalFormCount;
            if (calculatedAvg > 1.0) calculatedAvg = 1.0;
            overallAverage.value = calculatedAvg;
          } else {
            double serverAvg = (data['overallAverage'] ?? 0.0).toDouble();
            overallAverage.value = serverAvg;
          }
        }
        else if (data is List) {
          if (data.isEmpty) {
            overallAverage.value = 0.0;
          } else {
            double sumOfPercentages = 0.0;
            for (var form in data) {
              sumOfPercentages += (form['percentage'] ?? 0.0).toDouble();
            }
            double calculatedAvg = sumOfPercentages / totalFormCount;
            if (calculatedAvg > 1.0) calculatedAvg = 1.0;
            overallAverage.value = calculatedAvg;
          }
        }
      } else {
        overallAverage.value = 0.0;
      }
    } catch (e) {
      overallAverage.value = 0.0;
    }
  }

  void _calculateLocalScore(
    Map<String, int> techniques,
    Map<String, int> kicks,
  ) {
    int totalPoints = 0;
    int totalItems = 0;

    techniques.forEach((_, v) {
      totalPoints += v;
      totalItems++;
    });
    kicks.forEach((_, v) {
      totalPoints += v;
      totalItems++;
    });

    if (totalItems > 0) {
      currentScore.value = totalPoints / (totalItems * 2);
    } else {
      currentScore.value = 0.0;
    }
  }
}
