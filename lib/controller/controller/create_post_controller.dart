import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'forum_controller.dart';

class CreatePostController extends GetxController {
  // Configuration
  final String baseUrl = kIsWeb 
      ? "http://localhost:5000" 
      : "http://10.0.2.2:5000";
  final String currentUserId = "692a8a206881c040ebf00943";

  // Text Controllers (for input fields)
  final TextEditingController textController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Observable State Variables
  var selectedImages = <XFile>[].obs;      // Stores selected image
  var isPosting = false.obs;                  // Shows loading during post
  var showPreview = false.obs;                // Toggles preview mode
  var postSuccess = false.obs;                // Shows success indicator
  var userName = 'Loading...'.obs;
  var userAvatar = ''.obs;
  var videoUrl = ''.obs;
  var videoThumbnail = ''.obs;

  YoutubePlayerController? ytPlayerController;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser(); // Fetch user details when controller loads
  }

  @override
  void onClose() {
    // Dispose the player when leaving the screen to prevent memory leaks
    ytPlayerController?.dispose();
    super.onClose();
  }

  // Fetch User Data from Backend
  Future<void> fetchCurrentUser() async {
    try {
      // NOTE: Ensure your backend has a route like: router.get('/users/:id')
      // If you don't have a user route yet, you can use the hardcoded values for now.
      final response = await http.get(Uri.parse('$baseUrl/api/auth/$currentUserId')); 
      // OR if your route is different, e.g., '$baseUrl/api/users/$currentUserId'

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userName.value = data['name'] ?? 'Unknown User';
        userAvatar.value = data['avatar'] ?? '';
      } else {
        // Fallback if API fails
        userName.value = "User"; 
        print("Failed to fetch user: ${response.statusCode}");
      }
    } catch (e) {
      userName.value = "User";
      print("Error fetching user: $e");
    }
  }

  // 1. PICK MULTIPLE IMAGES (Gallery)
  Future<void> pickImageFromGallery() async {
    // pickMultiImage returns a List<XFile>
    final List<XFile> images = await _picker.pickMultiImage();
    
    if (images.isNotEmpty) {
      // Add new images to the existing list
      selectedImages.addAll(images);
    }
  }

  // 2. PICK SINGLE IMAGE (Camera)
  Future<void> pickImageFromCamera() async {
    // Camera only picks one at a time
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      // Add the single camera photo to our list
      selectedImages.add(image);
    }
  }

  // Helper to remove an image if user changes their mind
  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  void previewPost() {
    if (textController.text.isEmpty) {
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

  // Function to process the pasted link
  void addVideoLink(String url) {
    if (url.isEmpty) return;

    // Simple regex to extract YouTube ID
    String? videoId = YoutubePlayer.convertUrlToId(url);
    
    // Check for youtube.com/watch?v=
    if (url.contains("youtube.com/watch?v=")) {
      videoId = url.split("v=")[1].split("&")[0];
    } 
    // Check for youtu.be/
    else if (url.contains("youtu.be/")) {
      videoId = url.split("youtu.be/")[1].split("?")[0];
    }

    if (videoId != null) {
      videoUrl.value = url;
      // YouTube generates predictable thumbnail URLs
      videoThumbnail.value = "https://img.youtube.com/vi/$videoId/0.jpg";

      // Initialize the Player
      ytPlayerController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          disableDragSeek: true,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: false,
        ),
      );

      Get.back(); // Close the dialog
    } else {
      Get.snackbar("Error", "Please enter a valid YouTube URL");
    }
  }

  // Remove Video
  void removeVideo() {
    videoUrl.value = '';
    videoThumbnail.value = '';

    ytPlayerController?.dispose();
    ytPlayerController = null;
  }

  // 3. SUBMIT MULTIPLE IMAGES
  Future<void> submitPost() async {
    isPosting.value = true;

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/forum'));

      // Add Text Fields
      request.fields['userId'] = currentUserId;
      request.fields['text'] = textController.text;
      request.fields['tags'] = tagsController.text;
      request.fields['videoUrl'] = videoUrl.value;
      request.fields['videoThumbnail'] = videoThumbnail.value;

      // --- LOOP THROUGH IMAGES ---
      // We iterate through the selectedImages list and add every file
      // IMPORTANT: Field name must be 'postImages' (Plural) to match Backend upload.array()
      for (var image in selectedImages) {
        if (kIsWeb) {
          // ON WEB: Read bytes, do not use path
          var bytes = await image.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'postImages', // Must match backend upload.array('postImages')
              bytes,
              filename: image.name,
            ),
          );
        } else {
          // ON MOBILE: Path is safe to use
          request.files.add(
            await http.MultipartFile.fromPath(
              'postImages',
              image.path,
            ),
          );
        }
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        postSuccess.value = true;
        await Future.delayed(const Duration(seconds: 2));
        videoUrl.value = '';
          videoThumbnail.value = '';

        // Reset form
        textController.clear();
        tagsController.clear();
        selectedImages.clear(); // Clear the list

        Get.back();
        Get.snackbar("Success", "Post published successfully");

        // Refresh forum feed
        Get.find<ForumController>().loadPosts();
      } else {
        print("Upload Failed: ${response.statusCode}");
        Get.snackbar("Error", "Failed to upload post");
      }
    } catch (e) {
      print("Error sending post: $e");
      Get.snackbar("Error", "Connection error");
    } finally {
      isPosting.value = false;
    }
  }
}

