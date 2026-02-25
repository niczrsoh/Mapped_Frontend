import 'dart:convert';
import 'package:get/get.dart' hide Trans;
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forum_model.dart';
import '../create_post/create_post_controller.dart';

class ForumController extends GetxController {
  // CONFIGURATION
  final String baseUrl = "https://mapped-backend-node-js.onrender.com";

  String currentUserId = '';

  // 🔁 Full list of all posts (cached)
  var allPosts = <ForumPost>[].obs;

  // 📄 Posts visible on the current page
  var displayedPosts = <ForumPost>[].obs;

  var isLoading = false.obs;

  // --- REPORTING STATE ---
  var selectedReason = ''.obs;
  var isReportConfirmed = false.obs;

  // 🔢 Pagination state
  var currentPage = 1.obs;
  final int pageSize = 5;
  var totalPages = 1.obs;

  List<String> get reportReasons => [
    "forum_report_reason_harassment".tr(),
    "forum_report_reason_fraud".tr(),
    "forum_report_reason_spam".tr(),
    "forum_report_reason_misinfo".tr(),
    "forum_report_reason_self_harm".tr(),
    "forum_report_reason_graphic".tr(),
    "forum_report_reason_sexual".tr(),
    "forum_report_reason_fake".tr(),
    "forum_report_reason_hacked".tr(),
    "forum_report_reason_hateful".tr(),
  ];

  Map<String, String> get reasonDefinitions => {
    "forum_report_reason_harassment".tr(): "forum_report_def_harassment".tr(),
    "forum_report_reason_fraud".tr(): "forum_report_def_fraud".tr(),
    "forum_report_reason_spam".tr(): "forum_report_def_spam".tr(),
    "forum_report_reason_misinfo".tr(): "forum_report_def_misinfo".tr(),
    "forum_report_reason_self_harm".tr(): "forum_report_def_self_harm".tr(),
    "forum_report_reason_graphic".tr(): "forum_report_def_graphic".tr(),
    "forum_report_reason_sexual".tr(): "forum_report_def_sexual".tr(),
    "forum_report_reason_fake".tr(): "forum_report_def_fake".tr(),
    "forum_report_reason_hacked".tr(): "forum_report_def_hacked".tr(),
    "forum_report_reason_hateful".tr(): "forum_report_def_hateful".tr(),
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

  // ----------------------------------------------
  // 1. FETCH POSTS – store all, then paginate
  // ----------------------------------------------
  Future<void> loadPosts() async {
    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/forum'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        allPosts.value = data
            .map((json) => ForumPost.fromJson(json, currentUserId))
            .toList();

        // Sort pinned posts first
        _sortAllPostsByPinned();

        // Calculate total pages
        totalPages.value = (allPosts.length / pageSize).ceil();
        if (totalPages.value == 0) totalPages.value = 1;

        // Reset to first page
        currentPage.value = 1;
        _updateDisplayedPosts();
      } else {
        Get.snackbar("error".tr(), "forum_error_load_posts".tr());
      }
    } catch (e) {
      print("Error loading posts: $e");
      Get.snackbar("error".tr(), "forum_error_connection".tr());
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------------------------
  // 2. SEARCH – update allPosts and paginate
  // ----------------------------------------------
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
        allPosts.value = data
            .map((json) => ForumPost.fromJson(json, currentUserId))
            .toList();

        _sortAllPostsByPinned();

        totalPages.value = (allPosts.length / pageSize).ceil();
        if (totalPages.value == 0) totalPages.value = 1;

        currentPage.value = 1;
        _updateDisplayedPosts();
      }
    } catch (e) {
      print("Search Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------------------------
  // 3. PAGINATION CORE
  // ----------------------------------------------
  void _updateDisplayedPosts() {
    final start = (currentPage.value - 1) * pageSize;
    final end = start + pageSize;
    if (start < allPosts.length) {
      displayedPosts.value = allPosts.sublist(
        start,
        end > allPosts.length ? allPosts.length : end,
      );
    } else {
      displayedPosts.value = [];
    }
  }

  void goToPage(int page) {
    if (page < 1 || page > totalPages.value) return;
    currentPage.value = page;
    _updateDisplayedPosts();
  }

  // ----------------------------------------------
  // 4. TOGGLE PIN – update allPosts, re‑sort, refresh page
  // ----------------------------------------------
  Future<void> togglePin(ForumPost post) async {
    // Optimistic update
    post.isPinned.value = !post.isPinned.value;

    // Re‑sort the full list
    _sortAllPostsByPinned();

    // Refresh current page
    _updateDisplayedPosts();

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/forum/pin/${post.id}'),
      );
      if (response.statusCode != 200) {
        // Revert on failure
        post.isPinned.value = !post.isPinned.value;
        _sortAllPostsByPinned();
        _updateDisplayedPosts();
        Get.snackbar("error".tr(), "forum_error_pin_status".tr());
      }
    } catch (e) {
      post.isPinned.value = !post.isPinned.value;
      _sortAllPostsByPinned();
      _updateDisplayedPosts();
      Get.snackbar("error".tr(), "forum_error_network".tr());
    }
  }

  // Helper to sort allPosts: pinned first
  void _sortAllPostsByPinned() {
    allPosts.sort((a, b) {
      if (b.isPinned.value && !a.isPinned.value) return 1;
      if (!b.isPinned.value && a.isPinned.value) return -1;
      return 0;
    });
  }

  // ----------------------------------------------
  // 5. DELETE POST – remove from allPosts, refresh page
  // ----------------------------------------------
  Future<bool> deletePost(ForumPost post) async {
    if (currentUserId.isEmpty) return false;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/forum/${post.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': currentUserId}),
      );

      if (response.statusCode == 200) {
        allPosts.removeWhere((p) => p.id == post.id);
        totalPages.value = (allPosts.length / pageSize).ceil();
        if (totalPages.value == 0) totalPages.value = 1;

        // Adjust current page if it becomes out of range
        if (currentPage.value > totalPages.value) {
          currentPage.value = totalPages.value;
        }
        _updateDisplayedPosts();

        Get.closeAllSnackbars();
        Get.snackbar(
          "success".tr(),
          "forum_success_post_deleted".tr(),
          duration: const Duration(seconds: 2),
        );
        return true;
      } else {
        Get.closeAllSnackbars();
        Get.snackbar("error".tr(), "forum_error_delete_post".tr());
        return false;
      }
    } catch (e) {
      Get.closeAllSnackbars();
      Get.snackbar("error".tr(), "forum_error_connection".tr());
      return false;
    }
  }

  // ----------------------------------------------
  // 6. REPORT POST
  // ----------------------------------------------
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
        "forum_report_def_default".tr(namedArgs: {'reason': reason});
  }

  Future<bool> submitReport(ForumPost post) async {
    if (currentUserId.isEmpty) {
      Get.snackbar("error".tr(), "forum_error_login_report".tr());
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
        _updateDisplayedPosts(); // Refresh current page
        return true;
      } else {
        Get.snackbar("error".tr(), "forum_error_submit_report".tr());
        return false;
      }
    } catch (e) {
      Get.snackbar("error".tr(), "forum_error_network".tr());
      return false;
    }
  }

  void resetReportState() {
    selectedReason.value = '';
    isReportConfirmed.value = false;
  }

  // ----------------------------------------------
  // 7. LIKE POST
  // ----------------------------------------------
  Future<void> toggleLike(ForumPost post) async {
    if (currentUserId.isEmpty) {
      Get.snackbar("error".tr(), "forum_error_login_like".tr());
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
        body: jsonEncode({'userId': currentUserId}),
      );

      if (response.statusCode != 200) {
        post.likes.value = originalLikes;
        post.isLiked.value = originalStatus;
        Get.snackbar("error".tr(), "forum_error_like_post".tr());
      }
    } catch (e) {
      post.likes.value = originalLikes;
      post.isLiked.value = originalStatus;
    } finally {
      _updateDisplayedPosts(); // Refresh current page
    }
  }

  // ----------------------------------------------
  // 8. HELPER
  // ----------------------------------------------
  String getFullImageUrl(String relativePath) {
    if (relativePath.startsWith('http')) return relativePath;
    return "$baseUrl/$relativePath";
  }
}
