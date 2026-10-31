import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'belt_progress_modelV2.dart';
import '../controller/controller/trainer_controller.dart';
import '../forum/forum_controller.dart';

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

      if (result['success'] == true && result['belts'] != null) {
        Map<String, dynamic> beltsData = result['belts'];

        final prefs = await SharedPreferences.getInstance();
        bool hasPostedOrReplied =
            prefs.getBool('has_posted_or_replied_$userId') ?? false;
        int sharedTipCount = prefs.getInt('shared_tip_count_$userId') ?? 0;

        // Also check actual forum posts authored by this user
        int forumUserPostCount = 0;
        bool userCommentedInForum = false;
        try {
          if (Get.isRegistered<ForumController>()) {
            final forumCtrl = Get.find<ForumController>();
            if (forumCtrl.allPosts.isNotEmpty) {
              forumUserPostCount = forumCtrl.allPosts
                  .where((p) => p.authorId == userId)
                  .length;
            }
          }
          if (forumUserPostCount == 0) {
            final forumRes = await http
                .get(Uri.parse('${_apiService.baseUrl}/forum'))
                .timeout(const Duration(seconds: 5));
            if (forumRes.statusCode == 200) {
              final List<dynamic> postsList = jsonDecode(forumRes.body);
              for (final p in postsList) {
                if (p is Map) {
                  final u = p['user'];
                  final authorId =
                      u is Map ? u['_id']?.toString() : u?.toString();
                  if (authorId == userId) {
                    forumUserPostCount++;
                  }
                  final comments = p['comments'];
                  if (!userCommentedInForum && comments is List) {
                    for (final c in comments) {
                      if (c is Map) {
                        final cu = c['user'];
                        final commentUserId =
                            cu is Map ? cu['_id']?.toString() : cu?.toString();
                        if (commentUserId == userId) {
                          userCommentedInForum = true;
                          break;
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        } catch (_) {}

        int backendTipsB = (beltsData['B']?['shareTipCount'] is num)
            ? (beltsData['B']['shareTipCount'] as num).toInt()
            : 0;
        int backendTipsR = (beltsData['R']?['shareTipCount'] is num)
            ? (beltsData['R']['shareTipCount'] as num).toInt()
            : 0;

        sharedTipCount = [
          sharedTipCount,
          forumUserPostCount,
          backendTipsB,
          backendTipsR,
        ].reduce(max);

        if (sharedTipCount > 0) {
          await prefs.setInt('shared_tip_count_$userId', sharedTipCount);
          hasPostedOrReplied = true;
          await prefs.setBool('has_posted_or_replied_$userId', true);
        }

        // If either B or G has postCount > 0 from backend or user commented, sync local flag
        if (!hasPostedOrReplied) {
          if ((beltsData['B']?['postCount'] ?? 0) > 0 ||
              (beltsData['G']?['postCount'] ?? 0) > 0 ||
              userCommentedInForum) {
            hasPostedOrReplied = true;
            await prefs.setBool('has_posted_or_replied_$userId', true);
          }
        }

        List<BeltProgressModelV2> parsedModels = [];
        Map<String, int> newMap = {};

        ['W', 'Y', 'G', 'B', 'R', 'L'].forEach((code) {
          if (beltsData.containsKey(code)) {
            var data = Map<String, dynamic>.from(beltsData[code]);

            // If user already posted or replied in forum, ensure Blue and Green requirement is 1/1
            if ((code == 'B' || code == 'G') && hasPostedOrReplied) {
              int currentPosts = data['postCount'] ?? 0;
              if (currentPosts < 1) {
                data['postCount'] = 1;
              }
            }

            // If user shared forum posts (tips/resources), update Blue and Brown shareTipCount
            if ((code == 'B' || code == 'R') && sharedTipCount > 0) {
              int currentTips = data['shareTipCount'] ?? 0;
              if (currentTips < sharedTipCount) {
                data['shareTipCount'] = sharedTipCount;
              }
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

  // Optimistically increment a progress counter locally so UI updates immediately
  void incrementProgressCounter({
    required String beltColor,
    required String counter,
    int delta = 1,
  }) {
    int idx = detailedBeltData.indexWhere((b) => b.beltColor == beltColor);
    if (idx == -1) return;

    final old = detailedBeltData[idx];
    final oldP = old.progress;

    // Build new ProgressCounters copying existing values and applying delta
    final newP = ProgressCounters(
      recommendationCount:
          oldP.recommendationCount + (counter == 'recommendation' ? delta : 0),
      sessionPhotoCount:
          oldP.sessionPhotoCount + (counter == 'sessionPhoto' ? delta : 0),
      activeDayCount:
          oldP.activeDayCount + (counter == 'activeDay' ? delta : 0),
      postCount: oldP.postCount + (counter == 'post' ? delta : 0),
      shareTipCount: oldP.shareTipCount + (counter == 'shareTip' ? delta : 0),
      resourceCount: oldP.resourceCount + (counter == 'resource' ? delta : 0),
      openResourceCount:
          oldP.openResourceCount + (counter == 'openResource' ? delta : 0),
      reflectionCount:
          oldP.reflectionCount + (counter == 'reflection' ? delta : 0),
    );

    final newModel = BeltProgressModelV2(
      beltColor: old.beltColor,
      planSessionCount: old.planSessionCount,
      reqSessionCount: old.reqSessionCount,
      progress: newP,
      isCompleted: old.isCompleted,
      assignedTrainerId: old.assignedTrainerId,
      progressPercentage: old.progressPercentage,
    );

    detailedBeltData[idx] = newModel;
    detailedBeltData.refresh();
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
