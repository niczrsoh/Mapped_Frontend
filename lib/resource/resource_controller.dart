import 'dart:convert';
import 'package:get/get.dart' hide Trans;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'resource_model.dart';
import '../controller/controller/trainer_controller.dart';
import '../services/api_service.dart';
import '../TProgress/belt_progress_ring_controller.dart';

class ResourceController extends GetxController {
  // CONFIGURATION
  final String baseUrl = kIsWeb
      ? "http://localhost:5000"
      : "https://mapped-backend-node-js.onrender.com";

  final ApiService _apiService = ApiService();

  TrainerController get trainerController =>
      Get.isRegistered<TrainerController>()
      ? Get.find<TrainerController>()
      : Get.put(TrainerController());

  String currentUserId = '';

  var resources = <ResourcePost>[].obs;
  var isLoading = false.obs;
  var selectedFilter = 'All'.obs;
  var loading = false.obs;
  var resourceList = <dynamic>[].obs;
  var tagList = <String>[].obs;
  var tagsLoading = false.obs;
  var selectedTag = ''.obs;
  var success = false.obs;
  var viewedResourceIds = <String>{}.obs;

  // --- REPORTING STATE ---
  var selectedReason = ''.obs;
  var isReportConfirmed = false.obs;

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
    fetchOpenResourceCount();
  }

  Future<void> _initializeController() async {
    await _loadCurrentUser();
    loadResources();
  }

  Future<void> fetchOpenResourceCount() async {
    try {
      String userId = '';
      try {
        userId = trainerController.currentUserId.value;
      } catch (e) {
        // TrainerController not available, will use local userId
      }

      if (userId.isEmpty) {
        userId = currentUserId;
      }

      if (userId.isEmpty) {
        return;
      }

      final result = await _apiService.getUserResourceProgress(userId);
      if (result['success'] == true) {
        List<String> savedIds = List<String>.from(result['data'] ?? []);
        Set<String> uniqueIds = savedIds.toSet();
        viewedResourceIds.assignAll(uniqueIds);
      }
    } catch (e) {
      // Error fetching resource count
    }
  }

  void markResourceAsViewed(String id) async {
    String userId = '';
    try {
      userId = trainerController.currentUserId.value;
    } catch (e) {
      // TrainerController not available, will use local userId
    }

    if (userId.isEmpty) {
      userId = currentUserId;
    }

    if (userId.isEmpty) {
      return;
    }

    if (viewedResourceIds.contains(id)) {
      return;
    }

    const int resourceTarget = 3;
    if (viewedResourceIds.length >= resourceTarget) {
      return;
    }

    viewedResourceIds.add(id);

    // Optimistically increment local resource counter so UI updates immediately
    try {
      if (Get.isRegistered<BeltProgressRingController>()) {
        // increase both openResourceCount and resourceCount to be safe
        Get.find<BeltProgressRingController>().incrementProgressCounter(
          beltColor: 'G',
          counter: 'openResource',
          delta: 1,
        );
      }
    } catch (_) {}

    try {
      final result = await _apiService.recordResourceView(id, userId);

      if (result['success'] == true) {
        // Refresh belt progress so the home screen chart updates
        if (Get.isRegistered<BeltProgressRingController>()) {
          await Get.find<BeltProgressRingController>().fetchBeltProgress();
        }
      } else {
        // Backend failed to record - rollback by removing from local set
        viewedResourceIds.remove(id);
      }
    } catch (e) {
      // API call failed - rollback by removing from local set
      viewedResourceIds.remove(id);
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      currentUserId = prefs.getString('user_id') ?? '';

      if (currentUserId.isEmpty) {
        print("Warning: No User ID found. User might be a guest.");
      } else {
        print("Resource initialized for User ID: $currentUserId");
      }
    } catch (e) {
      print("Error fetching user ID: $e");
    }
  }

  // 1. FETCH RESOURCES
  Future<void> loadResources() async {
    isLoading.value = true;
    try {
      // Build query parameters for filtering
      // Note: Resources are stored in posts database with category='resource'
      String endpoint = '$baseUrl/api/resources';

      // Add filter parameters
      List<String> queryParams = [];
      if (selectedFilter.value != 'All') {
        queryParams.add('type=${selectedFilter.value}');
      }
      // Ensure we only fetch resources (if backend supports this)
      queryParams.add('category=resource');

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      print('📡 Fetching resources from: $endpoint');
      final response = await http
          .get(Uri.parse(endpoint))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          // Handle empty response
          if (response.body.isEmpty) {
            print('⚠️ Empty response body');
            resources.value = [];
            return;
          }

          final data = jsonDecode(response.body);

          // Handle different response formats
          List<dynamic> resourcesList = [];
          if (data is List) {
            resourcesList = data;
          } else if (data is Map && data['data'] is List) {
            resourcesList = data['data'] as List<dynamic>;
          } else if (data is Map && data['resources'] is List) {
            resourcesList = data['resources'] as List<dynamic>;
          } else {
            print('⚠️ Unexpected response format: ${data.runtimeType}');
            print('⚠️ Response: $data');
            Get.snackbar("error".tr(), "resource_ctrl_error_format".tr());
            return;
          }

          print('✅ Decoded ${resourcesList.length} resources');

          if (resourcesList.isEmpty) {
            print('⚠️ No resources returned');
            resources.value = [];
            return;
          }

          final loadedResources = <ResourcePost>[];
          for (var item in resourcesList) {
            try {
              loadedResources.add(ResourcePost.fromJson(item, currentUserId));
            } catch (e) {
              print('⚠️ Error parsing resource: $e');
              print('⚠️ Resource data: $item');
              // Continue loading other resources even if one fails
            }
          }

          // Sort resources by creation date (newest first)
          loadedResources.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          resources.value = loadedResources;
          print('✅ Resources loaded successfully: ${resources.length}');
        } catch (e) {
          print('❌ Error parsing response: $e');
          Get.snackbar(
            "error".tr(),
            "resource_ctrl_error_parse_fail".tr(args: [e.toString()]),
          );
        }
      } else if (response.statusCode == 404) {
        print('❌ Endpoint not found: ${response.statusCode}');
        Get.snackbar("error".tr(), "resource_ctrl_error_not_found".tr());
        resources.value = [];
      } else {
        print('❌ Server error: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        Get.snackbar(
          "error".tr(),
          "resource_ctrl_error_load_fail".tr(
            args: [response.statusCode.toString()],
          ),
        );
      }
    } catch (e) {
      print("❌ Error loading resources: $e");
      Get.snackbar(
        "error".tr(),
        "resource_ctrl_error_connection".tr(args: [e.toString()]),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 2. SEARCH RESOURCES
  Future<void> searchResources(String query) async {
    if (query.isEmpty) {
      loadResources();
      return;
    }

    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/resources/search?q=$query'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        resources.value = data
            .map((json) => ResourcePost.fromJson(json, currentUserId))
            .toList();
      }
    } catch (e) {
      print("Search Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 3. CREATE RESOURCE (Combined version with both approaches)
  Future<bool> createResource({
    required String title,
    required String content,
    String? videoUrl,
    List<String>? imagePaths,
  }) async {
    if (currentUserId.isEmpty) {
      Get.snackbar("error".tr(), "resource_ctrl_error_login_create".tr());
      return false;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/resources'),
      );

      // Add fields
      request.fields['title'] = title;
      request.fields['content'] = content;
      request.fields['userId'] = currentUserId;

      if (videoUrl != null && videoUrl.isNotEmpty) {
        request.fields['videoUrl'] = videoUrl;
      }

      // Determine resource type
      String resourceType = 'text';
      if (imagePaths != null && imagePaths.isNotEmpty) {
        resourceType = 'image';
      } else if (videoUrl != null && videoUrl.isNotEmpty) {
        resourceType = 'video';
      } else if (content.contains('http://') || content.contains('https://')) {
        resourceType = 'link';
      }
      request.fields['type'] = resourceType;
      request.fields['resourceType'] = resourceType;

      // Mark as resource so it's stored separately from forum posts
      request.fields['category'] = 'resource';
      request.fields['isResource'] = 'true';

      // Add image files
      if (imagePaths != null) {
        for (var imagePath in imagePaths) {
          request.files.add(
            await http.MultipartFile.fromPath('resourceImages', imagePath),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        Get.snackbar(
          'success'.tr(),
          'resource_ctrl_snackbar_create_success'.tr(),
          snackPosition: SnackPosition.BOTTOM,
        );
        loadResources(); // Reload resources
        return true;
      } else {
        Get.snackbar("error".tr(), "resource_ctrl_error_create_fail".tr());
        return false;
      }
    } catch (e) {
      print('Create resource error: $e');
      Get.snackbar(
        "error".tr(),
        "resource_ctrl_error_connection".tr(args: [e.toString()]),
      );
      return false;
    }
  }

  // 4. UPDATE RESOURCE
  Future<bool> updateResource({
    required String resourceId,
    String? title,
    String? content,
    String? videoUrl,
  }) async {
    if (currentUserId.isEmpty) return false;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/resources/$resourceId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': currentUserId,
          if (title != null) 'title': title,
          if (content != null) 'content': content,
          if (videoUrl != null) 'videoUrl': videoUrl,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          "success".tr(),
          "resource_ctrl_snackbar_update_success".tr(),
        );
        loadResources();
        return true;
      } else {
        Get.snackbar("error".tr(), "resource_ctrl_error_update_fail".tr());
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "error".tr(),
        "resource_ctrl_error_connection".tr(args: [e.toString()]),
      );
      return false;
    }
  }

  // 5. DELETE RESOURCE
  Future<bool> deleteResource(ResourcePost resource) async {
    if (currentUserId.isEmpty) return false;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/resources/${resource.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': currentUserId}),
      );

      if (response.statusCode == 200) {
        resources.removeWhere((r) => r.id == resource.id);
        Get.snackbar(
          "success".tr(),
          "resource_ctrl_snackbar_delete_success".tr(),
        );
        return true;
      } else {
        Get.snackbar("error".tr(), "resource_ctrl_error_delete_fail".tr());
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "error".tr(),
        "resource_ctrl_error_connection".tr(args: [e.toString()]),
      );
      return false;
    }
  }

  // 8. FILTERED RESOURCES (Client-side filtering as backup)
  List<ResourcePost> get filteredResources {
    if (selectedFilter.value == 'All') {
      return resources;
    }

    return resources.where((resource) {
      switch (selectedFilter.value) {
        case 'Images':
          return resource.resourceType == 'image';
        case 'Videos':
          return resource.resourceType == 'video';
        case 'Links':
          return resource.resourceType == 'link';
        default:
          return true;
      }
    }).toList();
  }

  // 9. SET FILTER
  void setFilter(String filter) {
    selectedFilter.value = filter;
    print('🔍 Filter changed to: $filter');
    loadResources(); // Reload with filter
  }

  // 10. HELPER
  String getFullImageUrl(String relativePath) {
    if (relativePath.startsWith('http')) return relativePath;
    return "$baseUrl/$relativePath";
  }
}
