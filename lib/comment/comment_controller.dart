import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import '../forum/forum_controller.dart';
import 'comment_model.dart';
import '../services/api_service.dart';
import '../TProgress/belt_progress_ring_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentsController extends GetxController {
  // Lazy initialization - retrieve ForumController only when actually needed
  ForumController get forumController => Get.find<ForumController>();
  final ApiService _apiService = ApiService();
  final BeltProgressRingController beltController = Get.put(
    BeltProgressRingController(),
  );

  var comments = <Comment>[].obs;
  var isLoading = false.obs;
  var isPosting = false.obs;
  var userBelt = 'White'.obs;

  String? _currentPostId;

  var submittedPostIds = <String>{}.obs;

  final List<String> beltHierarchy = [
    'White',
    'Yellow',
    'Green',
    'Blue',
    'Brown',
    'Black',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchSubmittedPosts();
    fetchUserBelt();
    if (beltController.detailedBeltData.isEmpty) {
      beltController.fetchBeltProgress();
    }
  }

  Future<void> fetchUserBelt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userId = forumController.currentUserId;

      if (userId.isEmpty) return;

      final response = await http.get(
        Uri.parse('${_apiService.baseUrl}/auth/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var userData = data['user'] ?? data;
        userBelt.value = userData['currentBelt'] ?? 'White';
      }
    } catch (e) {
      print("Error fetching belt: $e");
    }
  }

  bool get isEligibleToComment {
    if (beltController.detailedBeltData.isNotEmpty) {
      bool isGreenLocked = beltController.isBeltLocked('Green');
      return !isGreenLocked;
    }

    int userBeltIndex = beltHierarchy.indexOf(userBelt.value);
    int requiredBeltIndex = beltHierarchy.indexOf('Green');

    if (userBeltIndex == -1) return false;

    return userBeltIndex >= requiredBeltIndex;
  }

  Future<void> loadComments(String postId, {bool forceReload = false}) async {
    if (_currentPostId == postId && !forceReload && comments.isNotEmpty) {
      return;
    }

    _currentPostId = postId;
    isLoading.value = true;

    try {
      final response = await http.get(
        Uri.parse('${_apiService.baseUrl}/forum/$postId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final commentsList = data['comments'] as List;
        comments.value = commentsList
            .map((json) => Comment.fromJson(json))
            .toList();
      } else {
        Get.snackbar("error".tr(), "comment_snackbar_error_load".tr());
      }
    } catch (e) {
      print("Load Comments Error: $e");
    //  Get.snackbar("error".tr(), "comment_snackbar_error_connect".tr());
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch previously submitted posts/comments from backend
  Future<void> fetchSubmittedPosts() async {
    try {
      final userId = forumController.currentUserId;
      if (userId.isEmpty) return;

      final result = await _apiService.getUserPostProgress(userId);

      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> postIds = result['data'] as List<dynamic>;
        submittedPostIds.value = postIds
            .map((id) => id.toString())
            .where((id) => id.isNotEmpty)
            .toSet();
      }
    } catch (e) {
      // Silent fail - user can still post comments
    }
  }

  Future<void> addComment(String postId, String text) async {
    // if (!isEligibleToComment) {
    //   Get.snackbar(
    //     "comment_snackbar_access_denied_title".tr(),
    //     "comment_snackbar_access_denied_msg".tr(),
    //     backgroundColor: Colors.redAccent,
    //     colorText: Colors.white,
    //     duration: const Duration(seconds: 4),
    //     icon: const Icon(Icons.lock, color: Colors.white),
    //     snackPosition: SnackPosition.BOTTOM,
    //     margin: const EdgeInsets.all(16),
    //     borderRadius: 12,
    //   );
    //   return;
    // }

    if (text.trim().isEmpty) return;

    isPosting.value = true;
    try {
      final response = await http.post(
        Uri.parse('${_apiService.baseUrl}/forum/comment/$postId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': forumController.currentUserId,
          'text': text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        await loadComments(postId, forceReload: true);
        await _updatePostCount();
        Get.snackbar("success".tr(), "comment_snackbar_success_msg_short".tr());
      } else {
        Get.snackbar("error".tr(), "comment_snackbar_error_add".tr());
      }
    } catch (e) {
      print("Add Comment Error: $e");
   //   Get.snackbar("error".tr(), "comment_snackbar_error_connect".tr());
    } finally {
      isPosting.value = false;
    }
  }

  // Mark post/comment
  Future<void> markPostAsSubmitted(String commentId) async {
    final userId = forumController.currentUserId;
    submittedPostIds.add(commentId);

    try {
      try {
        try {
          if (Get.isRegistered<BeltProgressRingController>()) {
            Get.find<BeltProgressRingController>().incrementProgressCounter(
              beltColor: 'G',
              counter: 'post',
              delta: 1,
            );
          }
        } catch (_) {}

        await _apiService.recordPostSubmission(commentId, userId);
      } catch (e) {
        print("⚠️ Individual post tracking not available: $e");
      }

      await _updatePostCount();

      if (Get.isRegistered<BeltProgressRingController>()) {
        await Get.find<BeltProgressRingController>().fetchBeltProgress();
      }
    } catch (e) {
      submittedPostIds.remove(commentId);
    }
  }

  Future<void> _updatePostCount() async {
    try {
      final userId = forumController.currentUserId;
      if (userId.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_posted_or_replied_$userId', true);

      // Update post count for Blue belt ('B') and Green belt ('G')
      await _apiService.updateBeltProgress(
        userId: userId,
        beltColor: 'B',
        actionType: 'post',
      );
      await _apiService.updateBeltProgress(
        userId: userId,
        beltColor: 'G',
        actionType: 'post',
      );

      if (Get.isRegistered<BeltProgressRingController>()) {
        final ringCtrl = Get.find<BeltProgressRingController>();
        ringCtrl.incrementProgressCounter(
          beltColor: 'B',
          counter: 'post',
          delta: 1,
        );
        ringCtrl.incrementProgressCounter(
          beltColor: 'G',
          counter: 'post',
          delta: 1,
        );
        await ringCtrl.fetchBeltProgress();
      }
    } catch (e) {
      print("⚠️ Failed to update post count: $e");
    }
  }

  @override
  void onClose() {
    comments.clear();
    _currentPostId = null;
    super.onClose();
  }
}
