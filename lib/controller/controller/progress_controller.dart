import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../Participants/trainee_controller.dart';
import '../../TProgress/belt_progress_ring_controller.dart';

class ProgressController extends GetxController {
  final ApiService _apiService = ApiService();

  static const int totalFormCount = 8;

  var isLoading = false.obs;
  var currentScore =
      0.0.obs; // Observable percentage for current form (0.0 to 1.0)

  // --- NEW: For the Dashboard Average (Global Progress) ---
  var overallAverage = 0.0.obs;

  // Variables to hold data fetched from backend for specific form
  var loadedTechniques = <String, int>{}.obs;
  var loadedKicks = <String, int>{}.obs;

  // --- FETCH DATA (Load previous ratings for specific form) ---
  Future<void> fetchProgress(
    String traineeId,
    String beltColor, // Add beltColor
    String form,
  ) async {
    try {
      isLoading.value = true;

      // Call Backend
      final result = await _apiService.getProgress(traineeId, beltColor, form);

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];

        // 1. Update Score for this specific form
        currentScore.value = (data['percentage'] ?? 0.0).toDouble();

        // 2. Load Techniques Map
        if (data['techniques'] != null) {
          Map<String, dynamic> techMap = data['techniques'];
          loadedTechniques.value = techMap.map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          );
          print(
            "ProgressController: Loaded ${loadedTechniques.length} techniques.",
          );
        } else {
          print("ProgressController: No techniques data found for this form.");
          loadedTechniques.clear();
        }

        // 3. Load Kicks Map
        if (data['kicks'] != null) {
          Map<String, dynamic> kicksMap = data['kicks'];
          loadedKicks.value = kicksMap.map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          );
        } else {
          loadedKicks.clear();
        }
      } else {
        // New Form or No Data: Reset everything
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

  // --- SAVE DATA (Auto-save on tap) ---
  Future<void> saveProgress({
    required String traineeId,
    required String beltColor, // Add beltColor
    required String form,
    required Map<String, int> techniques,
    required Map<String, int> kicks,
  }) async {
    try {
      // 1. Calculate score locally immediately for smooth UI (Optimistic Update)
      _calculateLocalScore(techniques, kicks);

      // 2. Send to Backend silently
      print("Sending Progress Update for Belt: $beltColor");
      final result = await _apiService.saveProgress({
        'traineeId': traineeId,
        'beltColor': beltColor, // Include beltColor
        'form': form,
        'techniques': techniques,
        'kicks': kicks,
      });

      // 3. Sync with exact backend calculation if successful
      if (result['success'] == true) {
        print(
          "ProgressController: Save Success. New Form Score: ${result['data']['percentage']}",
        );
        // Update current form score from backend
        currentScore.value = (result['data']['percentage'] ?? 0.0).toDouble();

        // --- KEY LOGIC: Recalculate Overall Average for Dashboard ---
        await fetchOverallStats(traineeId, beltColor);

        // Sync the result to TraineeController immediately
        if (Get.isRegistered<TraineeController>()) {
          Get.find<TraineeController>().setTraineeProgressLocally(
            traineeId,
            overallAverage.value,
          );
        }

        // Force Belt Ring Recalculation (triggers GET /api/belt-progress)
        if (Get.isRegistered<BeltProgressRingController>()) {
          await Get.find<BeltProgressRingController>().fetchBeltProgress();
        }
      }
    } catch (e) {
      print("Error saving progress: $e");
    }
  }

  // --- 1. FETCH OVERALL STATS (The Fix is Here) ---
  Future<void> fetchOverallStats(String traineeId, String beltColor) async {
    try {
      final result = await _apiService.getAllProgress(traineeId, beltColor);

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];

        // FIX: Check if data is a Map (New Backend format)
        if (data is Map<String, dynamic>) {
          // Robust parsing for overallAverage
          var avgVal = data['overallAverage'];
          double serverAvg = 0.0;
          if (avgVal is num) {
            serverAvg = avgVal.toDouble();
          } else if (avgVal is String) {
            serverAvg = double.tryParse(avgVal) ?? 0.0;
          }
          overallAverage.value = serverAvg;
        }
        // Fallback: Check if data is a List (Old Backend format)
        else if (data is List) {
          if (data.isEmpty) {
            overallAverage.value = 0.0;
          } else {
            double sumOfPercentages = 0.0;
            for (var form in data) {
              sumOfPercentages += (form['percentage'] ?? 0.0).toDouble();
            }
            // Divide by total forms (8), not list length
            double calculatedAvg = sumOfPercentages / totalFormCount;
            if (calculatedAvg > 1.0) calculatedAvg = 1.0;
            overallAverage.value = calculatedAvg;
          }
        }
      } else {
        overallAverage.value = 0.0;
      }
    } catch (e) {
      // This is where your error was printing from
      print("Error calculating average: $e");
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
      // Max points per item is 2 (Poor=0, Med=1, Good=2)
      currentScore.value = totalPoints / (totalItems * 2);
    } else {
      currentScore.value = 0.0;
    }
  }
}
