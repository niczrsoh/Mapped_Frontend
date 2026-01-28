import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// --- MODEL ---
class ForumPost {
  final String id;
  final String authorName;
  final String? authorImage;
  final String timeAgo;
  final String content;
  final List<String> hashtags;
  final List<String> images;
  final String? videoUrl;       
  final String? videoThumbnail;
  final RxInt likes;
  final int comments;
  final RxBool isLiked;

  ForumPost({
    required this.id,
    required this.authorName,
    this.authorImage,
    required this.timeAgo,
    required this.content,
    required this.hashtags,
    required this.images,
    required this.videoUrl,
    required this.videoThumbnail,
    required int likes,
    required this.comments,
    bool isLiked = false,
  })  : likes = likes.obs,
        isLiked = isLiked.obs;

  factory ForumPost.fromJson(Map<String, dynamic> json, String currentUserId) {
    final date = DateTime.parse(json['date']);
    final diff = DateTime.now().difference(date);
    String timeAgo = '${diff.inMinutes}m';
    if (diff.inHours > 0) timeAgo = '${diff.inHours}h';
    if (diff.inDays > 0) timeAgo = '${diff.inDays}d';

    final likes = (json['likes'] as List);
    final isLiked = likes.any((like) => like['user'] == currentUserId);

    return ForumPost(
      id: json['_id'],
      authorName: json['name'] ?? 'Unknown',
      authorImage: json['avatar'],
      timeAgo: timeAgo,
      content: json['text'],
      hashtags: List<String>.from(json['tags'] ?? []),
      images: json['image'] != null && json['image'] != "" ? [json['image']] : [],
      videoUrl: json['videoUrl'],             
      videoThumbnail: json['videoThumbnail'],
      likes: likes.length,
      comments: (json['comments'] as List).length,
      isLiked: isLiked,
    );
  }
}

// --- CONTROLLER ---
class ForumController extends GetxController {
  final String baseUrl = kIsWeb ? "http://localhost:5000" : "http://192.168.56.1:5000";
  final String currentUserId = "692a8a206881c040ebf00943";

  var posts = <ForumPost>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
  }

  Future<void> loadPosts() async {
    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/forum'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        posts.value = data.map((json) => ForumPost.fromJson(json, currentUserId)).toList();
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

  Future<void> searchPosts(String query) async {
    if (query.isEmpty) {
      loadPosts();
      return;
    }

    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/forum/search?q=$query'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        posts.value = data.map((json) => ForumPost.fromJson(json, currentUserId)).toList();
      }
    } catch (e) {
      print("Search Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLike(ForumPost post) async {
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
        Get.snackbar("Error", "Could not like post");
      }
    } catch (e) {
      post.likes.value = originalLikes;
      post.isLiked.value = originalStatus;
    }
  }

  Future<void> deletePost(ForumPost post) async {
    Get.defaultDialog(
      title: 'Delete Post',
      middleText: 'Are you sure you want to delete this post?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        try {
          final response = await http.delete(
            Uri.parse('$baseUrl/api/forum/${post.id}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'userId': currentUserId}),
          );

          if (response.statusCode == 200) {
            posts.removeWhere((p) => p.id == post.id);
            Get.snackbar("Success", "Post deleted successfully");
          } else {
            Get.snackbar("Error", "Could not delete post");
          }
        } catch (e) {
          print("Delete Error: $e");
          Get.snackbar("Error", "Could not connect to server");
        }
      },
    );
  }

  String getFullImageUrl(String relativePath) {
    if (relativePath.startsWith('http')) return relativePath;
    return "$baseUrl/$relativePath";
  }
}