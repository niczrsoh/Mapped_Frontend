import 'package:get/get.dart';
import '../../services/api_service.dart';

class BeltProgressRingController extends GetxController {
  final ApiService _apiService = ApiService();

  // Map to store percentage per belt: {'White': 75, 'Yellow': 30...}
  var beltPercentages = <String, int>{}.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBeltProgress();
  }

  Future<void> fetchBeltProgress() async {
    try {
      isLoading.value = true;
      // You need to add getBeltRings() to your ApiService calling GET /api/belt-progress
      final result = await _apiService.getBeltRings();

      if (result['success'] == true && result['data'] != null) {
        List<dynamic> data = result['data'];
        Map<String, int> newMap = {};

        for (var item in data) {
          String name = item['beltName'];
          int score = item['averagePercentage'] ?? 0;
          newMap[name] = score;
        }
        beltPercentages.assignAll(newMap);
      }
    } catch (e) {
      print("Error fetching belt rings: $e");
    } finally {
      isLoading.value = false;
    }
  }

  int getPercentage(String beltName) {
    // Handle "White Belt" vs "White" mapping if necessary
    String cleanName = beltName.replaceAll(' Belt', '');
    return beltPercentages[cleanName] ?? 0;
  }
}
