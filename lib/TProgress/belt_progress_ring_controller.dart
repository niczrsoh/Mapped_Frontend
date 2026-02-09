import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:mapped_frontend/TProgress/belt_progress_modelV2.dart';
import 'package:mapped_frontend/TProgress/data/belt_requirements.dart';
import 'dart:convert';
import '../controller/controller/trainer_controller.dart';
import '../services/api_service.dart';
import '../session/session_controller.dart';
import '../comment/comment_controller.dart';
import '../create_post/create_post_controller.dart';

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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          fetchBeltProgress();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchBeltProgress();
    });
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

        int backendTotalPosts = 0;
        int backendTotalShareTips = 0;
        ['W', 'Y', 'G', 'B', 'R', 'L'].forEach((code) {
          if (beltsData.containsKey(code)) {
            var data = beltsData[code];
            backendTotalPosts += (data['postCount'] ?? 0) as int;
            backendTotalShareTips += (data['shareTipCount'] ?? 0) as int;
          }
        });

        if (Get.isRegistered<CommentsController>()) {
          final commentsCtrl = Get.find<CommentsController>();
          print(
            "📊 CommentsController found. Current Set size: ${commentsCtrl.submittedPostIds.length}, Backend count: $backendTotalPosts",
          );
          if (commentsCtrl.submittedPostIds.length < backendTotalPosts) {
            for (
              int i = commentsCtrl.submittedPostIds.length;
              i < backendTotalPosts;
              i++
            ) {
              commentsCtrl.submittedPostIds.add('backend_post_$i');
            }
          }
        } else {
          print("⚠️ CommentsController not registered!");
        }
        
       if (Get.isRegistered<CreatePostController>()) {
          final postCtrl = Get.find<CreatePostController>();
          int localShareCount = postCtrl.sharedTipPostIds.length;
          
          if (localShareCount < backendTotalShareTips) {
            for (int i = localShareCount; i < backendTotalShareTips; i++) {
              postCtrl.sharedTipPostIds.add('backend_share_$i');
            }
          } else if (localShareCount > backendTotalShareTips) {
             postCtrl.sharedTipPostIds.removeWhere((id) => id.startsWith('backend_share_'));
          }
        }

        int totalPosts = 0;
        int totalShareTips = 0;
        if (Get.isRegistered<CommentsController>()) {
          totalPosts = Get.find<CommentsController>().submittedPostIds.length;
        }
        if (Get.isRegistered<CreatePostController>()) {
          totalShareTips =
              Get.find<CreatePostController>().sharedTipPostIds.length;
        }

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
            int percentage = _calculatePercentageForBelt(
              model,
              uiName,
              totalPosts,
              totalShareTips,
            );
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

  int _calculatePercentageForBelt(
    BeltProgressModelV2 belt,
    String beltName,
    int totalPosts,
    int totalShareTips,
  ) {
    if (belt.progressPercentage != null) {
      return belt.progressPercentage!.round();
    }

    double current = 0;
    double target = 0;

    var p = belt.progress;
    int sessions = belt.planSessionCount;
    int activeDays = p.activeDayCount;
    int openResources = p.openResourceCount;
    int recommendations = p.recommendationCount;
    int reflections = 0;

    if (Get.isRegistered<SessionController>()) {
      final sessionController = Get.find<SessionController>();
      reflections = sessionController.submittedReflectionSessionIds.length;
    }

    final req = BeltRequirementsData.getFor(belt.beltColor);
    int currentPosts = (totalPosts - req.cumulativePostOffset).clamp(0, 999);

    int cumulativeShareTipOffset = 0;
    if (beltName == 'Brown') {
      cumulativeShareTipOffset = 1;
    }
    int currentShareTips = (totalShareTips - cumulativeShareTipOffset).clamp(
      0,
      999,
    );

    for (var task in req.tasks) {
      switch (task.type) {
        case RequirementType.session:
          current += sessions.toDouble();
          target += task.target.toDouble();
          break;
        case RequirementType.activeDay:
          current += activeDays.toDouble();
          target += task.target.toDouble();
          break;
        case RequirementType.resource:
          current += openResources.clamp(0, task.target).toDouble();
          target += task.target.toDouble();
          break;
        case RequirementType.recommendation:
          current += recommendations.clamp(0, task.target).toDouble();
          target += task.target.toDouble();
          break;
        case RequirementType.reflection:
          current += reflections.clamp(0, task.target).toDouble();
          target += task.target.toDouble();
          break;
        case RequirementType.forumPost:
          current += currentPosts.clamp(0, task.target).toDouble();
          target += task.target.toDouble();
          break;
        case RequirementType.shareTip:
          current += currentShareTips.clamp(0, task.target).toDouble();
          target += task.target.toDouble();
          break;
      }
    }

    if (target == 0) return 0;

    double fraction = (current / target).clamp(0.0, 1.0);
    return (fraction * 100).round();
  }
}
