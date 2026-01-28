import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';

class ResourceController extends GetxController {
  final ApiService _apiService = ApiService();

  var loading = false.obs;
  var resourceList = <dynamic>[].obs;
  var tagList = <String>[].obs;
  var tagsLoading = false.obs;
  var selectedTag = ''.obs;
  var success = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchResources();
    fetchTags();
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
