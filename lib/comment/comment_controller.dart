import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../forum/forum_controller.dart';
import 'comment_model.dart';
import '../services/api_service.dart';
import '../TProgress/belt_progress_ring_controller.dart';

class CommentsController extends GetxController {
  // Lazy initialization - retrieve ForumController only when actually needed
  ForumController get forumController => Get.find<ForumController>();
  final ApiService _apiService = ApiService();

  var comments = <Comment>[].obs;
  var isLoading = false.obs;
  var isPosting = false.obs;

  String? _currentPostId;

  var submittedPostIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSubmittedPosts();
  }

  Future<void> loadComments(String postId, {bool forceReload = false}) async {
    // Avoid reloading if already loaded for this post (unless forced)
    if (_currentPostId == postId && !forceReload && comments.isNotEmpty) {
      return;
    }

    _currentPostId = postId;
    isLoading.value = true;
    
    try {
      final response = await http.get(
        Uri.parse('${forumController.baseUrl}/api/forum/$postId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final commentsList = data['comments'] as List;
        comments.value = commentsList
            .map((json) => Comment.fromJson(json))
            .toList();
      } else {
        Get.snackbar("Error", "Failed to load comments");
      }
    } catch (e) {
      print("Load Comments Error: $e");
      Get.snackbar("Error", "Could not connect to server");
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
    if (text.trim().isEmpty) return;

    isPosting.value = true;
    try {
      final response = await http.post(
        Uri.parse('${forumController.baseUrl}/api/forum/comment/$postId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': forumController.currentUserId,
          'text': text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        // Force reload comments to get the new comment
        await loadComments(postId, forceReload: true);
        Get.snackbar("Success", "Comment added");
      } else {
        Get.snackbar("Error", "Could not add comment");
      }
    } catch (e) {
      print("Add Comment Error: $e");
      Get.snackbar("Error", "Could not connect to server");
    } finally {
      isPosting.value = false;
    }
  }

  // Mark post/comment as submitted with duplicate prevention and target capping
  Future<void> markPostAsSubmitted(String commentId) async {
    print("🔵 markPostAsSubmitted called with commentId: $commentId");
    print("   Current Set size: ${submittedPostIds.length}");
    
    final userId = forumController.currentUserId;
    if (userId.isEmpty || commentId.isEmpty) {
      print("❌ Missing userId or commentId");
      return;
    }

    // CRITICAL CHECK: Prevent duplicate counting of the same comment
    if (submittedPostIds.contains(commentId)) {
      print("🚫 DUPLICATE DETECTED - Comment already in Set");
      return; // Exit early - do NOT increment count for same comment
    }

    submittedPostIds.add(commentId);
    print("✅ Added to Set. New size: ${submittedPostIds.length}");

    try {
      // Try to record individual comment ID (optional - for future backend support)
      try {
        await _apiService.recordPostSubmission(commentId, userId);
        print("📡 Individual tracking API called successfully");
      } catch (e) {
        // If individual tracking fails, that's okay - we'll still update cumulative count
        print("⚠️ Individual post tracking not available: $e");
      }

      // ALWAYS update the cumulative count using existing backend API
      print("🔄 Calling _updatePostCount...");
      await _updatePostCount();
      print("✅ Post count updated successfully");

      // Refresh belt progress so the home screen chart updates
      if (Get.isRegistered<BeltProgressRingController>()) {
        print("🔄 Refreshing belt progress...");
        await Get.find<BeltProgressRingController>().fetchBeltProgress();
      }
    } catch (e) {
      // Only rollback if the main cumulative count update fails
      print("❌ Failed to update post count: $e");
      submittedPostIds.remove(commentId);
      print("↩️ Rolled back - removed from Set");
    }
  }

  Future<void> _updatePostCount() async {
    try {
      final userId = forumController.currentUserId;
      if (userId.isEmpty) {
        print("⚠️ _updatePostCount: No userId available");
        return;
      }

      print("📤 Calling updateBeltProgress API (userId: $userId, belt: G, action: post)");

      await _apiService.updateBeltProgress(
        userId: userId,
        beltColor: 'G',
        actionType: 'post',
      );

      print("✅ updateBeltProgress API call succeeded!");

      // Refresh belt progress display
      if (Get.isRegistered<BeltProgressRingController>()) {
        print("🔄 Refreshing belt progress display...");
        await Get.find<BeltProgressRingController>().fetchBeltProgress();
        print("✅ Belt progress refreshed");
      }

      print("✅ Post/reply count updated (cumulative)");
    } catch (e) {
      print("⚠️ Failed to update post count: $e");
    }
  }

  @override
  void onClose() {
    // Clear comments when controller is disposed
    comments.clear();
    _currentPostId = null;
    super.onClose();
  }
}