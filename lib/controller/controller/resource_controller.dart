import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import 'trainee_controller.dart';


class ResourceController extends GetxController {
  final ApiService _apiService = ApiService();

  final TraineeController traineeController = Get.find<TraineeController>();

  var loading = false.obs;
  var resourceList = <dynamic>[].obs;
  var tagList = <String>[].obs;
  var tagsLoading = false.obs;
  var selectedTag = ''.obs;
  var success = false.obs;
  var viewedResourceIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchResources();
    fetchOpenResourceCount();
  }

Future<void> fetchOpenResourceCount() async {
    try {
      // Get the ID from the TraineeController
      String userId = traineeController.currentUserId.value;
      if (userId.isEmpty) return;

      final result = await _apiService.getUserResourceProgress(userId);
      if (result['success'] == true) {
        List<String> savedIds = List<String>.from(result['data'] ?? []);
        viewedResourceIds.assignAll(savedIds);
      }
    } catch (e) {
      debugPrint("Error fetching resource count: $e");
    }
  }

 // Update this in ResourceController
void markResourceAsViewed(String id) async {
    String userId = traineeController.currentUserId.value;
    
    if (!viewedResourceIds.contains(id)) {
      viewedResourceIds.add(id); // Update UI immediately
      try {
        // Record to DB so it persists after logout
        await _apiService.recordResourceView(id, userId); 
      } catch (e) {
        debugPrint("Failed to record view: $e");
      }
    }
  }

  Future<void> fetchResources({
    String filterType = 'All',
    String? searchQuery,
    String? filterTag,
  }) async {
    try {
      loading.value = true;

      String? actualTag =
          filterTag ??
          (selectedTag.value.isNotEmpty ? selectedTag.value : null);
      if (filterTag == '') actualTag = null;

      String? encodedTag;
      if (actualTag != null && actualTag.isNotEmpty) {
        encodedTag = Uri.encodeComponent(actualTag);
      }

      final result = await _apiService.getAllResources(
        type: filterType,
        search: searchQuery,
        tag: encodedTag,
      );

      if (result['success'] == true) {
        resourceList.assignAll(result['data']);
      }
    } catch (e) {
      print("Error fetching: $e");
    } finally {
      loading.value = false;
    }
  }

  Future<void> fetchTags() async {
    try {
      tagsLoading.value = true;
      final result = await _apiService.getTags();
      if (result['success'] == true) {
        List<String> tags = List<String>.from(result['data']);
        tagList.assignAll(tags);
      }
    } catch (e) {
      print("Error fetching tags: $e");
    } finally {
      tagsLoading.value = false;
    }
  }

  // UPDATED: Now accepts List<String> urls
  Future<void> addResource({
    required String title,
    required String description,
    required String type,
   List<String>? imageUrls,
    List<String>? videoUrls,
    String? linkUrl,
    String author = 'Lieyza Wahab',
  }) async {
    try {
      loading.value = true;
      success.value = false;

      final result = await _apiService.addResource(
        title: title,
        description: description,
        type: type,
        imageUrls: imageUrls,
        videoUrls: videoUrls,
        linkUrl: linkUrl,
        author: author,
      );

      if (result['success'] == true) {
        success.value = true;
        await fetchResources();
        await fetchTags();
        Get.snackbar(
          'Success',
          'Post published',
          backgroundColor: const Color(0xFF00ff9f),
          colorText: const Color(0xFF1a1d2e),
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar('Error', result['msg'] ?? 'Failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Network Error');
    } finally {
      loading.value = false;
    }
  }
}
