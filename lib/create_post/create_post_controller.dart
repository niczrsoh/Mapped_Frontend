import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mapped_frontend/forum/forum_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../forum/forum_controller.dart';
import '../services/api_service.dart';
import '../TProgress/belt_progress_ring_controller.dart';

class CreatePostController extends GetxController {
  final ApiService _apiService = ApiService();
  final String baseUrl = "https://mapped-backend-node-js.onrender.com";

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
  var isVideoLoading = false.obs;

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
  Future<void> addVideoLink(String url) async {
    if (url.isEmpty) return;
    
    isVideoLoading.value = true;
    
    try {
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
        
        // Dispose existing controller if any
        ytPlayerController?.dispose();
        
        // Initialize new controller
        ytPlayerController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            disableDragSeek: true,
            enableCaption: false,
          ),
        );
        
        // Wait for controller to be ready
        await Future.delayed(const Duration(milliseconds: 500));
        
        Get.back();
        Get.snackbar("Success", "Video added successfully");
      } else {
        Get.snackbar("Error", "Please enter a valid YouTube URL");
      }
    } catch (e) {
      print("Error adding video: $e");
      Get.snackbar("Error", "Failed to add video");
    } finally {
      isVideoLoading.value = false;
    }
  }

  void removeVideo() {
    videoUrl.value = '';
    videoThumbnail.value = '';
    isVideoLoading.value = false;
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

        // Reset everything
        textController.clear();
        selectedImages.clear();
        videoUrl.value = '';
        videoThumbnail.value = '';
        isVideoLoading.value = false;
        showPreview.value = false;
        ytPlayerController?.dispose();
        ytPlayerController = null;
        Get.off(() => ForumScreen());
        Get.snackbar("Success", "Post published successfully");
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
      if (currentUserId == null || currentUserId!.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        currentUserId = prefs.getString('user_id');
      }

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

    sharedTipPostIds.add(postId);

    try {
      try {
        await _apiService.recordShareTipSubmission(postId, currentUserId!);
      } catch (e) {
      
        print("⚠️ Individual share tip tracking not available: $e");
      }
      await _updateShareTipCount();

      if (Get.isRegistered<BeltProgressRingController>()) {
        await Get.find<BeltProgressRingController>().fetchBeltProgress();
      }
    } catch (e) {
      sharedTipPostIds.remove(postId);
    }
  }

  Future<void> _updateShareTipCount() async {
    try {
      if (currentUserId == null || currentUserId!.isEmpty) {
        return;
      }
      await _apiService.updateBeltProgress(
        userId: currentUserId!,
        beltColor: 'B',
        actionType: 'shareTip',
      );

      if (Get.isRegistered<BeltProgressRingController>()) {
        await Get.find<BeltProgressRingController>().fetchBeltProgress();
      }

    } catch (e) {
      print("⚠️ Failed to update share tip count: $e");
    }
  }


  Future<void> removePostFromSharedTips(String postId) async {

    if (sharedTipPostIds.isEmpty) {
      await fetchSharedTips();
    }

    if (sharedTipPostIds.contains(postId)) {
      sharedTipPostIds.remove(postId);
      print("✅ Removed from local Set. New size: ${sharedTipPostIds.length}");
    } else {
      print("⚪ Post $postId not found in local shared tips Set");
    }

    if (Get.isRegistered<BeltProgressRingController>()) {
      try {
        final beltCtrl = Get.find<BeltProgressRingController>();
        if (beltCtrl.backendShareTipCount.value > 0) {
          beltCtrl.backendShareTipCount.value =
              beltCtrl.backendShareTipCount.value - 1;
        } else {
          print("➡️ backendShareTipCount already zero; no decrement");
        }
      } catch (e) {
        print("⚠️ Could not adjust backendShareTipCount: $e");
      }
    }

    if (Get.isRegistered<BeltProgressRingController>()) {
      await Get.find<BeltProgressRingController>().fetchBeltProgress();
    }
  }
}