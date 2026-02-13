import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mapped_frontend/forum/forum_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminController extends GetxController {
  // Replace with your actual server URL
  final String baseUrl = "https://mapped-backend-node-js-1.onrender.com/api/admin";
  
  // Observable variables
  var reportedPosts = <ForumPost>[].obs;
  var isLoading = false.obs;
  var adminName = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadAdminProfile();
    fetchReportedContent();
  }

  void _updateUserBlockStatusLocal(String userId, bool status) {
    for (var post in reportedPosts) {
      if (post.authorId == userId) {
        post.isUserBlocked.value = status;
      }
    }
  }

  Future<void> loadAdminProfile() async {
    final prefs = await SharedPreferences.getInstance();
    // Use the same key you used when saving the name during Login (e.g., 'user_name')
    String? storedName = prefs.getString('user_name');
    adminName.value = storedName!;
  }

  // --- 1. Fetch Reported Posts ---
  Future<void> fetchReportedContent() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('user_id') ?? '';

      final response = await http.get(Uri.parse('$baseUrl/reports'));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        List allData = result['data'];
        
        reportedPosts.value = allData
            .map((json) => ForumPost.fromJson(json, currentUserId))
            .toList();
      } else {
        Get.snackbar("Error", "Server returned: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load reports: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- 2. Admin Delete Post ---
  Future<void> deletePost(String postId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/post/$postId'));
      
      if (response.statusCode == 200) {
        reportedPosts.removeWhere((p) => p.id == postId);
        Get.snackbar("Deleted", "Post removed successfully", 
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Error", "Could not delete post");
      }
    } catch (e) {
      Get.snackbar("Error", "Network error: $e");
    }
  }

  // --- 3. Dismiss Report (Clear Reports Array) ---
  Future<void> dismissReport(String postId) async {
    try {
      final response = await http.patch(Uri.parse('$baseUrl/dismiss/$postId'));
      
      if (response.statusCode == 200) {
        reportedPosts.removeWhere((p) => p.id == postId);
        Get.snackbar("Dismissed", "Reports cleared", 
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Error", "Could not dismiss report");
      }
    } catch (e) {
      Get.snackbar("Error", "Network error: $e");
    }
  }

  // --- 4. Block User ---
  Future<void> blockUser(String userId) async {
    try {
      final response = await http.patch(Uri.parse('$baseUrl/user/block/$userId'));
      
      if (response.statusCode == 200) {
        _updateUserBlockStatusLocal(userId, true);
        Get.snackbar("Blocked", "User access restricted", 
            snackPosition: SnackPosition.BOTTOM);
        // Refresh the list to remove other posts by this user if necessary
        fetchReportedContent();
      } else {
        Get.snackbar("Error", "Failed to block user");
      }
    } catch (e) {
      Get.snackbar("Error", "Network error: $e");
    }
  }

  // --- 5. Unblock User ---
  Future<void> unblockUser(String userId) async {
    try {
      final response = await http.patch(Uri.parse('$baseUrl/user/unblock/$userId'));
      
      if (response.statusCode == 200) {
        _updateUserBlockStatusLocal(userId, false);
        Get.snackbar("Unblocked", "User access restored", 
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Error", "Failed to unblock user");
      }
    } catch (e) {
      Get.snackbar("Error", "Network error: $e");
    }
  }

  // Inside your AdminController class
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // This removes the user_id, user_name, and token
      
      Get.offAllNamed('/login'); // Redirect to login and clear navigation stack
      Get.snackbar(
        "Logged Out", 
        "Successfully logged out",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1A1D2D),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Logout failed: $e");
    }
  }
}