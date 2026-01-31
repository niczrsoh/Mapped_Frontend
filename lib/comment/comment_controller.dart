import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../forum/forum_controller.dart';
import 'comment_model.dart';

class CommentsController extends GetxController {
  final ForumController forumController = Get.find<ForumController>();
  var comments = <Comment>[].obs;
  var isLoading = false.obs;
  var isPosting = false.obs;

  // Store current post ID to avoid reloading unnecessarily
  String? _currentPostId;

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
        comments.value = commentsList.map((json) => Comment.fromJson(json)).toList();
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

  @override
  void onClose() {
    // Clear comments when controller is disposed
    comments.clear();
    _currentPostId = null;
    super.onClose();
  }
}