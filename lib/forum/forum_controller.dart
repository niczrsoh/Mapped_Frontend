import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'forum_model.dart';
import '../create_post/create_post_controller.dart';

class ForumController extends GetxController {
  // CONFIGURATION
  final String baseUrl = "http://10.0.2.2:5000";

  String currentUserId = '';

  var posts = <ForumPost>[].obs;
  var isLoading = false.obs;

  // --- REPORTING STATE ---
  var selectedReason = ''.obs;
  var isReportConfirmed = false.obs;

  final List<String> reportReasons = [
    "Harassment",
    "Fraud / Scam",
    "Spam",
    "Misinformation",
    "Self-Harm",
    "Graphic Content",
    "Sexual Content",
    "Fake Account",
    "Hacked Account",
    "Hateful Speech",
  ];

  final Map<String, String> reasonDefinitions = {
    "Harassment":
        "Attacks or intimidation toward others with abusive language or deliberately and repeatedly disrupting conversations, including revealing others' personal or sensitive information. This includes unwanted romantic advances, sexual remarks and or requests for sexual favors.",
    "Fraud / Scam":
        "Illegal activities, malware, or promotion of illegal products or services.",
    "Spam":
        "Irrelevant, repetitive content intended to artificially increase engagement, or other inappropriate promotional content.",
    "Misinformation":
        "False content or information about the post, that present untrue facts or events as though they are true or likely to be true.",
    "Self-Harm":
        "Promotion, encouragement or any portrayal of self-harm or suicide.",
    "Graphic Content": "Excessively gruesome or graphic material.",
    "Sexual Content": "Nudity or other content that's sexual in nature.",
    "Fake Account":
        "Inaccurate or misleading representation of a person or organization.",
    "Hacked Account": "Unauthorized account takeover.",
    "Hateful Speech":
        "Attacks or incitement of violence against individuals or groups based on their actual or perceived traits, or any other speech that promotes hatred.",
  };

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    await _loadCurrentUser();
    loadPosts();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      currentUserId = prefs.getString('user_id') ?? '';

      if (currentUserId.isEmpty) {
        print("Warning: No User ID found. User might be a guest.");
      } else {
        print("Forum initialized for User ID: $currentUserId");
      }
    } catch (e) {
      print("Error fetching user ID: $e");
    }
  }

  // 1. FETCH POSTS
  Future<void> loadPosts() async {
    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/forum'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        posts.value = data
            .map((json) => ForumPost.fromJson(json, currentUserId))
            .toList();
      } else {
        Get.snackbar("Error", "Failed to load posts");
      }
    } catch (e) {
      print("Error loading posts: $e");
      Get.snackbar("Error", "Could not connect to server");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. SEARCH POSTS
  Future<void> searchPosts(String query) async {
    if (query.isEmpty) {
      loadPosts();
      return;
    }

    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/forum/search?q=$query'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        posts.value = data
            .map((json) => ForumPost.fromJson(json, currentUserId))
            .toList();
      }
    } catch (e) {
      print("Search Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 3. PIN POST FUNCTIONALITY
  Future<void> togglePin(ForumPost post) async {
    // Optimistic Update
    post.isPinned.value = !post.isPinned.value;

    // Sort list locally
    posts.sort((a, b) {
      if (b.isPinned.value && !a.isPinned.value) return 1;
      if (!b.isPinned.value && a.isPinned.value) return -1;
      return 0;
    });

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/forum/pin/${post.id}'),
      );
      if (response.statusCode != 200) {
        // Revert on failure
        post.isPinned.value = !post.isPinned.value;
        Get.snackbar("Error", "Failed to update pin status");
        loadPosts();
      }
    } catch (e) {
      post.isPinned.value = !post.isPinned.value;
      Get.snackbar("Error", "Connection error");
      loadPosts();
    }
  }

  // 4. REPORT POST FUNCTIONALITY
  bool canReportPost(ForumPost post) {
    return !post.isReported.value;
  }

  void selectReportReason(String reason) {
    selectedReason.value = reason;
  }

  void toggleReportConfirmation(bool value) {
    isReportConfirmed.value = value;
  }

  String getReasonDefinition(String reason) {
    return reasonDefinitions[reason] ??
        "This content violates our community guidelines regarding $reason.";
  }

  Future<bool> submitReport(ForumPost post) async {
    if (currentUserId.isEmpty) {
      Get.snackbar("Error", "You must be logged in to report.");
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/forum/report/${post.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': currentUserId,
          'reason': selectedReason.value,
        }),
      );

      if (response.statusCode == 200) {
        post.isReported.value = true;
        return true;
      } else {
        Get.snackbar("Error", "Failed to submit report");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Connection error");
      return false;
    }
  }

  void resetReportState() {
    selectedReason.value = '';
    isReportConfirmed.value = false;
  }

  // 5. LIKE POST
  Future<void> toggleLike(ForumPost post) async {
    if (currentUserId.isEmpty) {
      Get.snackbar("Error", "You must be logged in to like posts.");
      return;
    }

    final originalLikes = post.likes.value;
    final originalStatus = post.isLiked.value;

    if (post.isLiked.value) {
      post.likes.value--;
      post.isLiked.value = false;
    } else {
      post.likes.value++;
      post.isLiked.value = true;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/forum/like/${post.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': currentUserId}), // Uses dynamic ID
      );

      if (response.statusCode != 200) {
        post.likes.value = originalLikes;
        post.isLiked.value = originalStatus;
        Get.snackbar("Error", "Could not like post");
      }
    } catch (e) {
      post.likes.value = originalLikes;
      post.isLiked.value = originalStatus;
    }
  }

  // 6. DELETE POST
  Future<bool> deletePost(ForumPost post) async {
    if (currentUserId.isEmpty) return false;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/forum/${post.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': currentUserId}),
      );

      if (response.statusCode == 200) {
        posts.removeWhere((p) => p.id == post.id);
        Get.closeAllSnackbars(); // Close any existing snackbars
        Get.snackbar(
          "Success",
          "Post deleted successfully",
          duration: const Duration(seconds: 2),
        );
        return true;
      } else {
        Get.closeAllSnackbars();
        Get.snackbar(
          "Error",
          "Could not delete post",
          duration: const Duration(seconds: 2),
        );
        return false;
      }
    } catch (e) {
      Get.closeAllSnackbars();
      Get.snackbar(
        "Error",
        "Could not connect to server",
        duration: const Duration(seconds: 2),
      );
      return false;
    }
  }

  // 7. HELPER
  String getFullImageUrl(String relativePath) {
    if (relativePath.startsWith('http')) return relativePath;
    return "$baseUrl/$relativePath";
  }
}
