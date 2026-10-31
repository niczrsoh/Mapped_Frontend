import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mapped_frontend/TProgress/belt_progress_ring_controller.dart';
import 'package:mapped_frontend/controller/user_controller';
import 'package:mapped_frontend/services/api_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../forum/forum_controller.dart';

class CreatePostController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  var selectedImages = <XFile>[].obs;
  final ApiService _apiService = ApiService(); // ✅ uses ApiService
  var isPosting = false.obs;
  var showPreview = false.obs;
  var postSuccess = false.obs;
  var userName = 'Loading...'.obs;
  var userAvatar = ''.obs;
  var videoUrl = ''.obs;
  var videoThumbnail = ''.obs;
  var hasContent = false.obs;
  var userBelt = 'White'.obs;

  String? currentUserId;

  YoutubePlayerController? ytPlayerController;
  var sharedTipPostIds = <String>{}.obs;

  final List<String> beltHierarchy = [
    'White',
    'Yellow',
    'Green',
    'Blue',
    'Brown',
    'Black',
  ];

  @override
  void onInit() {
    super.onInit();
    postSuccess.value = false;
    fetchCurrentUser();
    textController.addListener(_updateContentState);
  }

  @override
  void onClose() {
    textController.removeListener(_updateContentState);
    textController.dispose();
    ytPlayerController?.dispose();
    super.onClose();
  }

  void _updateContentState() {
    hasContent.value =
        textController.text.trim().isNotEmpty ||
        selectedImages.isNotEmpty ||
        videoUrl.value.isNotEmpty;
  }

  // ✅ Uses UserController, SharedPreferences, and _apiService.getUserProfile
  Future<void> fetchCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      currentUserId = prefs.getString('user_id');
      String? storedName = prefs.getString('user_name');
      String? storedAvatar = prefs.getString('user_avatar');

      // Also check global UserController if registered
      if (Get.isRegistered<UserController>()) {
        final userCtrl = Get.find<UserController>();
        if ((currentUserId == null || currentUserId!.isEmpty) &&
            userCtrl.userId.value.isNotEmpty) {
          currentUserId = userCtrl.userId.value;
        }
        final ctrlName = userCtrl.userData['name']?.toString().trim();
        final ctrlAvatar = userCtrl.userData['avatar']?.toString().trim();
        if ((storedName == null || storedName.isEmpty) &&
            ctrlName != null &&
            ctrlName.isNotEmpty &&
            ctrlName != 'User') {
          storedName = ctrlName;
        }
        if ((storedAvatar == null || storedAvatar.isEmpty) &&
            ctrlAvatar != null &&
            ctrlAvatar.isNotEmpty) {
          storedAvatar = ctrlAvatar;
        }
      }

      if (storedName != null && storedName.isNotEmpty) {
        userName.value = storedName;
      }
      if (storedAvatar != null && storedAvatar.isNotEmpty) {
        userAvatar.value = storedAvatar;
      }

      if (currentUserId == null || currentUserId!.isEmpty) {
        userName.value = 'user_guest'.tr();
        return;
      }

      // Fetch fresh profile from /api/profile/:userId
      final result = await _apiService.getUserProfile(currentUserId!);
      if (result['success'] == true && result['data'] is Map) {
        final rawData = result['data'] as Map;
        final Map userMap = rawData['user'] is Map
            ? rawData['user'] as Map
            : (rawData['data'] is Map ? rawData['data'] as Map : rawData);

        final fetchedName = userMap['name']?.toString().trim();
        final fetchedAvatar = userMap['avatar']?.toString().trim();

        if (fetchedName != null && fetchedName.isNotEmpty) {
          userName.value = fetchedName;
          await prefs.setString('user_name', fetchedName);
        }
        if (fetchedAvatar != null && fetchedAvatar.isNotEmpty) {
          userAvatar.value = fetchedAvatar;
          await prefs.setString('user_avatar', fetchedAvatar);
        }
      }

      if (userName.value.isEmpty || userName.value == 'Loading...') {
        userName.value =
            (storedName != null && storedName.isNotEmpty)
                ? storedName
                : 'unknown_user'.tr();
      }
    } catch (e) {
      print("Error fetching user: $e");
      if (userName.value.isEmpty || userName.value == 'Loading...') {
        userName.value = 'unknown_user'.tr();
      }
    }
  }

  // --- IMAGES ---
  static const int maxImages = 4;
  static const int maxImageSizeMB = 1;
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;

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
    _updateContentState();
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
    _updateContentState();
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
    _updateContentState();
  }

  // --- PREVIEW ---
  void previewPost() {
    if (textController.text.trim().isEmpty &&
        selectedImages.isEmpty &&
        videoUrl.value.isEmpty) {
      Get.snackbar('error'.tr(), 'create_post_error_no_content_preview'.tr());
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
      _updateContentState();
    } else {
      Get.snackbar('error'.tr(), 'error_invalid_youtube'.tr());
    }
  }

  void removeVideo() {
    videoUrl.value = '';
    videoThumbnail.value = '';
    ytPlayerController?.dispose();
    ytPlayerController = null;
    _updateContentState();
  }

  // --- HASHTAG LOGIC ---
  List<String> _extractHashtags(String text) {
    RegExp regExp = RegExp(r"#[a-zA-Z0-9_]+");
    Iterable<Match> matches = regExp.allMatches(text);
    return matches.map((m) => m.group(0)!).toSet().toList();
  }

  // --- SUBMIT ---
  Future<void> submitPost() async {
    if (textController.text.trim().isEmpty &&
        selectedImages.isEmpty &&
        videoUrl.value.isEmpty) {
      Get.snackbar('error'.tr(), 'create_post_error_no_content_submit'.tr());
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
      // ✅ Use dynamic baseUrl
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${_apiService.baseUrl}/forum'),
      );

      request.fields['userId'] = currentUserId!;
      request.fields['text'] = textController.text.trim();

      List<String> extractedTags = _extractHashtags(textController.text);
      if (extractedTags.isNotEmpty) {
        request.fields['tags'] = extractedTags.join(',');
        print("Sending tags: ${request.fields['tags']}");
      }

      if (videoUrl.value.isNotEmpty)
        request.fields['videoUrl'] = videoUrl.value;
      if (videoThumbnail.value.isNotEmpty)
        request.fields['videoThumbnail'] = videoThumbnail.value;

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
        await _updateShareTipCount();

        try {
          final forumCtrl = Get.find<ForumController>();
          await forumCtrl.loadPosts();
          forumCtrl.scrollToTop();
        } catch (e) {
          print("Forum controller not found");
        }

        textController.clear();
        selectedImages.clear();
        videoUrl.value = '';
        videoThumbnail.value = '';
        ytPlayerController?.dispose();
        ytPlayerController = null;
        showPreview.value = false;
        _updateContentState();
        postSuccess.value = true;

        Get.snackbar('success'.tr(), 'create_post_success_published'.tr());
      } else {
        print("Error: $responseBody");
        Get.snackbar('error'.tr(), 'create_post_error_upload_failed'.tr());
      }
    } catch (e) {
      print("Error sending post: $e");
      Get.snackbar(
        'error'.tr(),
        'error_connection'.tr(namedArgs: {'error': e.toString()}),
      );
    } finally {
      isPosting.value = false;
    }
  }

  // --- BELT PROGRESS & SHARE TIPS (unchanged but uses _apiService) ---
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
      // silent
    }
  }

  Future<void> markShareTipAsSubmitted(String postId) async {
    sharedTipPostIds.add(postId);
    try {
      await _apiService.recordShareTipSubmission(postId, currentUserId!);
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
        final prefs = await SharedPreferences.getInstance();
        currentUserId = prefs.getString('user_id');
      }
      if (currentUserId == null || currentUserId!.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_posted_or_replied_${currentUserId!}', true);
      int prevTipCount = prefs.getInt('shared_tip_count_${currentUserId!}') ?? 0;
      await prefs.setInt(
        'shared_tip_count_${currentUserId!}',
        prevTipCount + 1,
      );

      await _apiService.updateBeltProgress(
        userId: currentUserId!,
        beltColor: 'B',
        actionType: 'shareTip',
      );
      await _apiService.updateBeltProgress(
        userId: currentUserId!,
        beltColor: 'R',
        actionType: 'shareTip',
      );
      await _apiService.updateBeltProgress(
        userId: currentUserId!,
        beltColor: 'B',
        actionType: 'post',
      );
      await _apiService.updateBeltProgress(
        userId: currentUserId!,
        beltColor: 'G',
        actionType: 'post',
      );
      if (Get.isRegistered<BeltProgressRingController>()) {
        final ringCtrl = Get.find<BeltProgressRingController>();
        ringCtrl.incrementProgressCounter(
          beltColor: 'B',
          counter: 'post',
          delta: 1,
        );
        ringCtrl.incrementProgressCounter(
          beltColor: 'B',
          counter: 'shareTip',
          delta: 1,
        );
        ringCtrl.incrementProgressCounter(
          beltColor: 'R',
          counter: 'shareTip',
          delta: 1,
        );
        ringCtrl.incrementProgressCounter(
          beltColor: 'G',
          counter: 'post',
          delta: 1,
        );
        await ringCtrl.fetchBeltProgress();
      }
    } catch (e) {
      print("⚠️ Failed to update post/share tip count: $e");
    }
  }

  Future<void> removePostFromSharedTips(String postId) async {
    if (sharedTipPostIds.isEmpty) {
      await fetchSharedTips();
    }
    if (sharedTipPostIds.contains(postId)) {
      sharedTipPostIds.remove(postId);
    }
    if (Get.isRegistered<BeltProgressRingController>()) {
      await Get.find<BeltProgressRingController>().fetchBeltProgress();
    }
  }
}