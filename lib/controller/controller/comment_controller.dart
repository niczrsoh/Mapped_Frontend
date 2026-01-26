import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'forum_controller.dart';

// --- MODEL ---
class Comment {
  final String id;
  final String name;
  final String text;
  final String timeAgo;

  Comment({
    required this.id,
    required this.name,
    required this.text,
    required this.timeAgo,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date']);
    final diff = DateTime.now().difference(date);
    String timeAgo = '${diff.inMinutes}m';
    if (diff.inHours > 0) timeAgo = '${diff.inHours}h';
    if (diff.inDays > 0) timeAgo = '${diff.inDays}d';

    return Comment(
      id: json['_id'],
      name: json['name'] ?? 'Unknown',
      text: json['text'],
      timeAgo: timeAgo,
    );
  }
}

// --- CONTROLLER ---
class CommentsController extends GetxController {
  final ForumController forumController = Get.find<ForumController>();
  var comments = <Comment>[].obs;
  var isLoading = false.obs;
  var isPosting = false.obs;

  Future<void> loadComments(String postId) async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('${forumController.baseUrl}/api/forum/$postId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final commentsList = data['comments'] as List;
        comments.value = commentsList.map((json) => Comment.fromJson(json)).toList();
      }
    } catch (e) {
      print("Load Comments Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addComment(String postId, String text) async {
    isPosting.value = true;
    try {
      final response = await http.post(
        Uri.parse('${forumController.baseUrl}/api/forum/comment/$postId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': forumController.currentUserId,
          'text': text,
        }),
      );

      if (response.statusCode == 200) {
        loadComments(postId);
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
}