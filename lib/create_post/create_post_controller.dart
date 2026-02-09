import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../forum/forum_controller.dart';
import '../services/api_service.dart';
import '../TProgress/belt_progress_ring_controller.dart';

class CreatePostController extends GetxController {
  final ApiService _apiService = ApiService();
  final String baseUrl = kIsWeb
      ? "http://localhost:5000"
      : "http://10.0.2.2:5000";

  final TextEditingController textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  var selectedImages = <XFile>[].obs;
  var isPosting = false.obs;
  var showPreview = false.obs;
  var postSuccess = false.obs;
  var userName = 'Loading...'.obs;
  var userAvatar = ''.obs;
  var videoUrl = ''.obs;
  var videoThumbnail = ''.obs;

  // Share tip tracking - stores unique post IDs that have been shared
  // Using Set to automatically prevent duplicate counting
  var sharedTipPostIds = <String>{}.obs;

  String? currentUserId;

  YoutubePlayerController? ytPlayerController;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser();
    fetchSharedTips();
  }

  @override
  void onClose() {
    textController.dispose();
    ytPlayerController?.dispose();
    super.onClose();
  }

  Future<void> fetchCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      currentUserId = prefs.getString('user_id');
      String? storedName = prefs.getString('user_name');
      String? storedAvatar = prefs.getString('user_avatar');

      if (storedName != null && storedName.isNotEmpty)
        userName.value = storedName;
      if (storedAvatar != null && storedAvatar.isNotEmpty)
        userAvatar.value = storedAvatar;

      if (currentUserId == null) {
        userName.value = "Guest";
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/$currentUserId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userName.value =
            data['name'] ?? data['user']?['name'] ?? 'Unknown User';
        userAvatar.value = data['avatar'] ?? data['user']?['avatar'] ?? '';
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  // --- IMAGES ---
  Future<void> pickImageFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) selectedImages.addAll(images);
    } catch (e) {
      Get.snackbar("Error", "Failed to pick images");
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) selectedImages.add(image);
    } catch (e) {
      Get.snackbar("Error", "Failed to take photo");
    }
  }

  void removeImage(int index) => selectedImages.removeAt(index);

  // --- PREVIEW ---
  void previewPost() {
    if (textController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please write something");
      return;
    }
    showPreview.value = true;
    postSuccess.value = false;
  }

  void backToEdit() {
    showPreview.value = false;
    postSuccess.value = false;
  }

  // --- VIDEO ---
  void addVideoLink(String url) {
    if (url.isEmpty) return;
    String? videoId = YoutubePlayer.convertUrlToId(url);

    if (videoId == null) {
      if (url.contains("youtube.com/watch?v=")) {
        videoId = url.split("v=")[1].split("&")[0];
      } else if (url.contains("youtu.be/")) {
        videoId = url.split("youtu.be/")[1].split("?")[0];
      }
    }

    if (videoId != null && videoId.isNotEmpty) {
      videoUrl.value = url;
      videoThumbnail.value = "https://img.youtube.com/vi/$videoId/0.jpg";
      ytPlayerController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          disableDragSeek: true,
        ),
      );
      Get.back();
    } else {
      Get.snackbar("Error", "Please enter a valid YouTube URL");
    }
  }

  void removeVideo() {
    videoUrl.value = '';
    videoThumbnail.value = '';
    ytPlayerController?.dispose();
    ytPlayerController = null;
  }

  // --- HASHTAG LOGIC ---
  List<String> _extractHashtags(String text) {
    RegExp regExp = RegExp(r"#[a-zA-Z0-9_]+");

    Iterable<Match> matches = regExp.allMatches(text);

    return matches.map((m) => m.group(0)!).toSet().toList();
  }

  // --- SUBMIT ---
  Future<void> submitPost() async {
    if (textController.text.trim().isEmpty) {
      Get.snackbar("Error", "Post content cannot be empty");
      return;
    }

    if (currentUserId == null) {
      final prefs = await SharedPreferences.getInstance();
      currentUserId = prefs.getString('user_id');
      if (currentUserId == null) {
        Get.snackbar("Error", "User session expired. Please login again.");
        return;
      }
    }

    isPosting.value = true;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/forum'),
      );

      request.fields['userId'] = currentUserId!;
      request.fields['text'] = textController.text.trim();

      // 1. EXTRACT TAGS AUTOMATICALLY
      List<String> extractedTags = _extractHashtags(textController.text);

      // 2. SEND AS COMMA-SEPARATED STRING
      if (extractedTags.isNotEmpty) {
        request.fields['tags'] = extractedTags.join(','); // e.g. "#tag1,#tag2"
        print("Sending tags: ${request.fields['tags']}");
      }

      if (videoUrl.value.isNotEmpty)
        request.fields['videoUrl'] = videoUrl.value;
      if (videoThumbnail.value.isNotEmpty)
        request.fields['videoThumbnail'] = videoThumbnail.value;

      // Add Images
      for (var image in selectedImages) {
        if (kIsWeb) {
          var bytes = await image.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'postImages',
              bytes,
              filename: image.name,
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'postImages',
              image.path,
              filename: image.name,
            ),
          );
        }
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(responseBody);
        String postId =
            responseData['postId'] ??
            DateTime.now().millisecondsSinceEpoch.toString();

        print("🎉 Post submitted successfully! PostId: $postId");
        postSuccess.value = true;

        // Mark this post as a shared tip for belt progress tracking
        print("📝 About to mark post as shared tip...");
        await markShareTipAsSubmitted(postId);
        print("✅ Marking complete");

        await Future.delayed(const Duration(seconds: 1));

        // Reset
        textController.clear();
        selectedImages.clear();
        videoUrl.value = '';
        videoThumbnail.value = '';
        ytPlayerController?.dispose();
        ytPlayerController = null;

        Get.back();
        Get.snackbar("Success", "Post published successfully");

        // Refresh Feed
        try {
          Get.find<ForumController>().loadPosts();
        } catch (e) {
          print("Forum controller not found");
        }
      } else {
        print("Error: $responseBody");
        Get.snackbar("Error", "Failed to upload post");
      }
    } catch (e) {
      print("Error sending post: $e");
      Get.snackbar("Error", "Connection error: $e");
    } finally {
      isPosting.value = false;
    }
  }

  // Fetch previously shared tips from backend
  Future<void> fetchSharedTips() async {
    try {
      if (currentUserId == null || currentUserId!.isEmpty) return;

      final result = await _apiService.getUserShareTipProgress(currentUserId!);

      if (result['success'] == true && result['data'] != null) {
        final List<dynamic> postIds = result['data'] as List<dynamic>;
        sharedTipPostIds.value = postIds
            .map((id) => id.toString())
            .where((id) => id.isNotEmpty)
            .toSet();
      }
    } catch (e) {
      // Silent fail - user can still share tips
    }
  }

  // Mark tip/resource share as submitted with duplicate prevention
  Future<void> markShareTipAsSubmitted(String postId) async {
    print("🔵 markShareTipAsSubmitted called with postId: $postId");
    print("   Current Set size: ${sharedTipPostIds.length}");

    if (currentUserId == null || currentUserId!.isEmpty || postId.isEmpty) {
      print("❌ Missing userId or postId");
      return;
    }

    // CRITICAL CHECK: Prevent duplicate counting of the same post
    if (sharedTipPostIds.contains(postId)) {
      print("🚫 DUPLICATE DETECTED - Post already in Set");
      return; // Exit early - do NOT increment count for same post
    }

    // First time sharing this tip - add to Set and count it
    sharedTipPostIds.add(postId);
    print("✅ Added to Set. New size: ${sharedTipPostIds.length}");

    try {
      // Try to record individual post ID (optional - for future backend support)
      try {
        await _apiService.recordShareTipSubmission(postId, currentUserId!);
        print("📡 Individual tracking API called successfully");
      } catch (e) {
        // If individual tracking fails, that's okay - we'll still update cumulative count
        print("⚠️ Individual share tip tracking not available: $e");
      }

      // ALWAYS update the cumulative count using existing backend API
      print("🔄 Calling _updateShareTipCount...");
      await _updateShareTipCount();
      print("✅ Share tip count updated successfully");

      // Refresh belt progress so the home screen chart updates
      if (Get.isRegistered<BeltProgressRingController>()) {
        print("🔄 Refreshing belt progress...");
        await Get.find<BeltProgressRingController>().fetchBeltProgress();
      }
    } catch (e) {
      // Only rollback if the main cumulative count update fails
      print("❌ Failed to update share tip count: $e");
      sharedTipPostIds.remove(postId);
      print("↩️ Rolled back - removed from Set");
    }
  }

  Future<void> _updateShareTipCount() async {
    try {
      if (currentUserId == null || currentUserId!.isEmpty) {
        print("⚠️ _updateShareTipCount: No userId available");
        return;
      }

      print(
        "📤 Calling updateBeltProgress API (userId: $currentUserId, belt: B, action: shareTip)",
      );

      // Update shareTip count for Blue belt (cumulative counting)
      // Similar to post/reply, this is cumulative across belts
      await _apiService.updateBeltProgress(
        userId: currentUserId!,
        beltColor: 'B',
        actionType: 'shareTip',
      );

      print("✅ updateBeltProgress API call succeeded!");

      // Refresh belt progress display
      if (Get.isRegistered<BeltProgressRingController>()) {
        print("🔄 Refreshing belt progress display...");
        await Get.find<BeltProgressRingController>().fetchBeltProgress();
        print("✅ Belt progress refreshed");
      }

      print("✅ Share tip count updated (cumulative)");
    } catch (e) {
      print("⚠️ Failed to update share tip count: $e");
    }
  }
}
