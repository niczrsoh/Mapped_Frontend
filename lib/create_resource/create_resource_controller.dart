import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mapped_frontend/services/api_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../forum/forum_controller.dart';
import '../resource/resource_controller.dart';

class CreateResourceController extends GetxController {
  final ApiService _apiService = ApiService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  var showTitleError = false.obs;
  var selectedImages = <XFile>[].obs;
  var isPosting = false.obs;
  var showPreview = false.obs;
  var postSuccess = false.obs;
  var userName = 'Loading...'.obs;
  var userAvatar = ''.obs;
  var videoUrl = ''.obs;
  var videoThumbnail = ''.obs;

  String? currentUserId;

  YoutubePlayerController? ytPlayerController;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser();
  }

  @override
  void onClose() {
    titleController.dispose();
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
        userName.value = 'user_guest'.tr();
        return;
      }

      final response = await http.get(
        Uri.parse('${_apiService.baseUrl}/profile/$currentUserId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userName.value =
            data['name'] ??
            data['data']?['name'] ??
            data['user']?['name'] ??
            'unknown_user'.tr();
        userAvatar.value =
            data['avatar'] ??
            data['data']?['avatar'] ??
            data['user']?['avatar'] ??
            '';
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  // --- IMAGES ---
  // Constants for image validation
  static const int maxImages = 4;
  static const int maxImageSizeMB = 1;
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024; // 1MB

  Future<void> pickImageFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        for (var image in images) {
          if (selectedImages.length >= maxImages) {
            Get.snackbar(
              'snackbar_limit_title'.tr(),
              'snackbar_limit_msg'.tr(namedArgs: {'max': maxImages.toString()}),
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            break;
          }

          // Check file size
          final fileSize = await image.length();
          if (fileSize > maxImageSizeBytes) {
            Get.snackbar(
              'snackbar_size_title'.tr(),
              'snackbar_size_msg'.tr(
                namedArgs: {
                  'max': maxImageSizeMB.toString(),
                  'size': (fileSize / 1024 / 1024).toStringAsFixed(2),
                },
              ),
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
            continue;
          }

          selectedImages.add(image);
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick images");
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      if (selectedImages.length >= maxImages) {
        Get.snackbar(
          'snackbar_limit_title'.tr(),
          'snackbar_limit_msg'.tr(namedArgs: {'max': maxImages.toString()}),
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        // Check file size
        final fileSize = await image.length();
        if (fileSize > maxImageSizeBytes) {
          Get.snackbar(
            'snackbar_size_title'.tr(),
            'snackbar_size_msg'.tr(
              namedArgs: {
                'max': maxImageSizeMB.toString(),
                'size': (fileSize / 1024 / 1024).toStringAsFixed(2),
              },
            ),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          return;
        }

        selectedImages.add(image);
      }
    } catch (e) {
      Get.snackbar('error'.tr(), 'error_pick_images'.tr());
    }
  }

  void removeImage(int index) => selectedImages.removeAt(index);

  // --- PREVIEW ---
  void previewPost() {
    if (titleController.text.trim().isEmpty) {
      showTitleError.value = true;
      return;
    }

    showTitleError.value = false;
    showPreview.value = true;
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
      Get.snackbar('error'.tr(), 'error_invalid_youtube'.tr());
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
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('error'.tr(), 'create_resource_error_empty_title'.tr());
      return;
    }

    if (textController.text.trim().isEmpty) {
      Get.snackbar('error'.tr(), 'create_resource_error_empty_content'.tr());
      return;
    }

    if (currentUserId == null) {
      final prefs = await SharedPreferences.getInstance();
      currentUserId = prefs.getString('user_id');
      if (currentUserId == null) {
        Get.snackbar('error'.tr(), 'error_session_expired'.tr());
        return;
      }
    }

    isPosting.value = true;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${_apiService.baseUrl}/resources'),
      );

      // Required fields
      request.fields['userId'] = currentUserId!;
      request.fields['title'] = titleController.text.trim();
      request.fields['content'] = textController.text.trim();
      request.fields['description'] = textController.text.trim();

      // Mark as resource
      request.fields['category'] = 'resource';
      request.fields['isResource'] = 'true';

      // Initialize linkUrl (required by server)
      request.fields['linkUrl'] = '';

      // 1. EXTRACT TAGS AUTOMATICALLY
      List<String> extractedTags = _extractHashtags(textController.text);

      // 2. SEND AS COMMA-SEPARATED STRING
      if (extractedTags.isNotEmpty) {
        request.fields['tags'] = extractedTags.join(',');
        print("Sending tags: ${request.fields['tags']}");
      }

      // Determine resource type
      // Note: videoUrl refers to YouTube links, which should be classified as 'link'
      String resourceType = 'text';
      if (selectedImages.isNotEmpty) {
        resourceType = 'image';
      } else if (videoUrl.value.isNotEmpty) {
        // YouTube links are classified as 'link', not 'video'
        resourceType = 'link';
      } else if (textController.text.contains('http://') ||
          textController.text.contains('https://')) {
        resourceType = 'link';
      }
      request.fields['type'] = resourceType;
      request.fields['resourceType'] = resourceType;

      if (videoUrl.value.isNotEmpty) {
        request.fields['videoUrl'] = videoUrl.value;
        request.fields['linkUrl'] =
            videoUrl.value; // Update with actual video URL
      }
      if (videoThumbnail.value.isNotEmpty) {
        request.fields['videoThumbnail'] = videoThumbnail.value;
      }

      // Add Images with correct field name
      for (var image in selectedImages) {
        if (kIsWeb) {
          var bytes = await image.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes('images', bytes, filename: image.name),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'images',
              image.path,
              filename: image.name,
            ),
          );
        }
      }

      print('📤 Sending resource POST to: ${request.url}');
      print('📝 Fields: ${request.fields}');

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        postSuccess.value = true;
        await Future.delayed(const Duration(seconds: 1));

        // Reset
        titleController.clear();
        textController.clear();
        selectedImages.clear();
        videoUrl.value = '';
        videoThumbnail.value = '';
        ytPlayerController?.dispose();
        ytPlayerController = null;

        Get.back();
        Get.snackbar('success'.tr(), 'create_resource_success_published'.tr());

        // Refresh both resource and forum pages
        try {
          // Refresh resource page
          Get.find<ResourceController>().loadResources();
        } catch (e) {
          print("ResourceController not found, that's okay");
        }

        try {
          // Also refresh forum if it's open
          Get.find<ForumController>().loadPosts();
        } catch (e) {
          print("ForumController not found, that's okay");
        }
      } else {
        print("❌ Error: $responseBody");
        Get.snackbar(
          'error'.tr(),
          'create_resource_error_upload_failed'.tr(
            namedArgs: {'statusCode': response.statusCode.toString()},
          ),
        );
      }
    } catch (e) {
      print("❌ Error sending resource: $e");
      Get.snackbar(
        'error'.tr(),
        'error_connection'.tr(namedArgs: {'error': e.toString()}),
      );
    } finally {
      isPosting.value = false;
    }
  }
}
