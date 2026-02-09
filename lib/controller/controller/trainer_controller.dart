import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../TProgress/belt_progress_ring_controller.dart';

class TrainerController extends GetxController {
  static const double totalFormCount = 8.0;
  var loading = false.obs;
  var error = ''.obs;
  var success = false.obs;
  var currentUserId = ''.obs;

  var currentUserName = ''.obs;
  var activeDaysCount = 0.obs;
  var cumulativePostCount = 0.obs;
  var cumulativeShareTipCount = 0.obs;
  var trainerList = <dynamic>[].obs;
  var recommendationCount = 0.obs;

  var trainerProgressMap = <String, String>{}.obs;

  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    _loadAuthData().then((_) {
      _loadLocalCounts();
      updateActiveDays();
      _loadRecommendationCount();
    });

    ever(currentUserId, (String uid) {
      _onUserChanged(uid);
    });
  }

  @override
  void onReady() {
    super.onReady();
    updateActiveDays();
  }

  Future<void> _loadLocalCounts() async {
    final prefs = await SharedPreferences.getInstance();
    int savedDays = prefs.getInt(_prefKey('active_days_count')) ?? 0;
    activeDaysCount.value = savedDays;
    print("🏠 TrainerController: Loaded local days: $savedDays");
  }

  Future<void> _loadRecommendationCount() async {
    final prefs = await SharedPreferences.getInstance();
    int localCount = prefs.getInt(_prefKey('recommendation_count')) ?? 0;
    recommendationCount.value = localCount;
  }

  Future<void> incrementRecommendationCount() async {
    final prefs = await SharedPreferences.getInstance();

    String userId = currentUserId.value;
    if (userId.isEmpty) {
      userId = prefs.getString('user_id') ?? '';
    }

    if (userId.isNotEmpty) {
      int newCount = recommendationCount.value + 1;
      recommendationCount.value = newCount;
      await prefs.setInt(_prefKey('recommendation_count', userId), newCount);

      print("📈 Incrementing Recommendation Count to: $newCount");

      try {
        var url = Uri.parse('${_apiService.baseUrl}/belt-progress/update');
        var body = jsonEncode({
          "userId": userId,
          "actionType": "recommendation",
          "beltColor": "White", 
        });

        var response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: body,
        );

        if (response.statusCode == 200) {
          print("✅ Success: Database updated");

          // 3. FORCE REFRESH THE BELT UI
          if (Get.isRegistered<BeltProgressRingController>()) {
            print("🔄 Refreshing Belt Progress Ring...");
            await Get.find<BeltProgressRingController>().fetchBeltProgress();
          }
        } else {
          print("❌ Failed: ${response.statusCode} - ${response.body}");
        }
      } catch (e) {
        print("❌ Network Error: $e");
      }
    }
  }

  Future<void> updateActiveDays() async {
    final prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toString().split(' ')[0];
    String? lastDate = prefs.getString(_prefKey('last_active_date'));
    int currentCount = activeDaysCount.value;
    String userId = currentUserId.value;

    if (userId.isEmpty) {
      userId = prefs.getString('user_id') ?? '';
      if (userId.isNotEmpty) currentUserId.value = userId;
    }

    if (userId.isEmpty) return;

    try {
      var profile = await _apiService.getTrainerById(userId);
      if (profile['success'] != true) {
        profile = await _apiService.getUserProfile(userId);
      }

      if (profile['success'] == true && profile['data'] != null) {
        var userData = profile['data'];
        int backendCount =
            int.tryParse(userData['activeCount']?.toString() ?? '0') ?? 0;

        if (backendCount > currentCount) {
          currentCount = backendCount;
          await prefs.setInt(
            _prefKey('active_days_count', userId),
            currentCount,
          );
        }
      }
    } catch (e) {
      currentCount = prefs.getInt('active_days_count') ?? currentCount;
    }

    if (lastDate != today) {
      currentCount++;
      await prefs.setInt(_prefKey('active_days_count', userId), currentCount);
      await prefs.setString(_prefKey('last_active_date', userId), today);

      _apiService.updateTrainer(userId, {'activeCount': currentCount});
    }


    activeDaysCount.value = currentCount;
  }

  Future<void> forceUpdateActiveCount(int newCount) async {
    if (newCount > activeDaysCount.value) {
      print(
        "🚀 Found higher count in Belt Data ($newCount). Updating Local State.",
      );
      activeDaysCount.value = newCount;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKey('active_days_count'), newCount);
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
        _onUserChanged(storedId);
      } else {
        print("⚠️ TrainerController: No stored auth data found");
      }
    } catch (e) {
      print("❌ TrainerController: Error loading auth data: $e");
    }
  }

  String _prefKey(String base, [String? uid]) {
    final id = uid ?? currentUserId.value;
    return id.isNotEmpty ? '${base}_$id' : base;
  }

  void _onUserChanged(String uid) async {
    if (uid.isEmpty) {
      activeDaysCount.value = 0;
      recommendationCount.value = 0;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    activeDaysCount.value =
        prefs.getInt(_prefKey('active_days_count', uid)) ?? 0;
    recommendationCount.value =
        prefs.getInt(_prefKey('recommendation_count', uid)) ?? 0;
  }

  void setUserInfo(String id, String name) {
    currentUserId.value = id;
    currentUserName.value = name;
    print("👤 Trainer Profile Set: $name ($id)");
  }

  Future<void> fetchTrainers() async {
    try {
      loading.value = true;
      final result = await _apiService.getAllTrainers();

      if (result['success'] == true) {
        trainerList.assignAll(result['data']);

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
}
