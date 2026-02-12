import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../forum/forum_model.dart';

class ForumSearchtagsController extends GetxController {
  final String baseUrl = "https://mapped-backend-node-js.onrender.com";

  // 1. Dynamic User ID
  String currentUserId = '';

  var hasSearched = false.obs;
  var posts = <ForumPost>[].obs;
  var popularTags = <String>[].obs;
  var allTags = <String>[].obs;
  var isLoading = false.obs;
  var selectedTag = ''.obs;
  var isTagsExpanded = false.obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    await _loadCurrentUser();
    loadPopularTags();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      currentUserId = prefs.getString('user_id') ?? '';
    } catch (e) {
      print("Error fetching user ID: $e");
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (Get.arguments != null && Get.arguments is String) {
      String passedArg = Get.arguments;
      if (passedArg.startsWith('#')) {
        selectTag(passedArg);
      } else {
        searchController.text = passedArg;
        searchPosts(passedArg);
      }
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void toggleTagsExpanded() {
    isTagsExpanded.value = !isTagsExpanded.value;
  }

  // 2. Fix Popular Tags Parsing
  Future<void> loadPopularTags() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/forum/tags'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        List<String> cleanedTags = data.expand<String>((item) {
          String t = "";

          if (item is Map) {
            t = item['name'] ?? item['_id'] ?? item.toString();
          } else {
            t = item.toString();
          }

          if (t.contains(' ')) {
            return t
                .split(' ')
                .where(
                  (subTag) => subTag.trim().isNotEmpty,
                ) // Remove empty spaces
                .map((subTag) => subTag.startsWith('#') ? subTag : '#$subTag');
          }

          return [t.startsWith('#') ? t : '#$t'];
        }).toList();

        popularTags.value = cleanedTags.toSet().toList().take(15).toList();
      } else {
        print("Failed to fetch tags: ${response.statusCode}");
      }
    } catch (e) {
      print("Load Popular Tags Error: $e");
      popularTags.value = [
        '#Taekwondo',
        '#UTMDojo',
        '#MartialArts',
        '#SideKick',
        '#BeltGrading',
        '#Discipline',
        '#Sparring',
        '#TeamSpirit',
      ];
    }
  }

  Future<void> loadAllTags() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/forum/tags'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        allTags.value = data.map((item) {
          String t = "";
          if (item is Map) {
            t = item['name'] ?? item['_id'] ?? item.toString();
          } else {
            t = item.toString();
          }
          return t.startsWith('#') ? t : '#$t';
        }).toList();

        _showTagsDialog();
      }
    } catch (e) {
      print("Load All Tags Error: $e");
    }
  }

  Future<void> loadPosts() async {
    if (!hasSearched.value) return;

    if (selectedTag.value.isNotEmpty) {
      await searchByTag(selectedTag.value, searchQuery: searchController.text);
    } else if (searchController.text.isNotEmpty) {
      await searchPosts(searchController.text);
    }
  }

  // 3. Fix Search Logic for Hashtags
  Future<void> searchPosts(String query) async {
    String trimmedQuery = query.trim();

    // Reset if empty
    if (trimmedQuery.isEmpty && selectedTag.value.isEmpty) {
      hasSearched.value = false;
      posts.clear();
      return;
    }

    // CASE 1: User typed a Hashtag (starts with #)
    if (trimmedQuery.startsWith('#')) {
      print("🔹 Hashtag Search detected: $trimmedQuery");

      // Update the UI to show this tag is selected
      selectedTag.value = trimmedQuery;

      // Call the Tag Search function
      await searchByTag(trimmedQuery);
      return;
    }

    // CASE 2: User typed normal text (No #)
    if (selectedTag.value.isNotEmpty) {
      selectedTag.value = '';
    }

    hasSearched.value = true;
    isLoading.value = true;
    posts.clear();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/forum/search?q=$trimmedQuery'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        posts.value = data
            .map((json) => ForumPost.fromJson(json, currentUserId))
            .toList();
      }
    } catch (e) {
      print("Search Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchByTag(String tag, {String? searchQuery}) async {
    hasSearched.value = true;
    isLoading.value = true;
    posts.clear();

    try {
      String cleanTag = tag.replaceAll('#', '');

      Map<String, String> queryParams = {'tag': cleanTag};

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['q'] = searchQuery;
      }

      final uri = Uri.parse(
        '$baseUrl/api/forum/search',
      ).replace(queryParameters: queryParams);

      print("📢 Calling API: $uri");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        posts.value = data
            .map((json) => ForumPost.fromJson(json, currentUserId))
            .toList();
      } else {
        print("❌ API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Search by Tag Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void selectTag(String tag) {
    if (selectedTag.value == tag) {
      clearSelection();
    } else {
      selectedTag.value = tag;
      searchController.clear();
      searchByTag(tag);
    }
  }

  void clearSelection() {
    selectedTag.value = '';
    searchController.clear();
    posts.clear();
    hasSearched.value = false;
  }

  String getFullImageUrl(String relativePath) {
    if (relativePath.isEmpty) return '';
    if (relativePath.startsWith('http')) return relativePath;
    return "$baseUrl/$relativePath";
  }

  void _showTagsDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF252836),
        title: Text('All Tags', style: GoogleFonts.inter(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allTags.map((tag) {
                return GestureDetector(
                  onTap: () {
                    Get.back();
                    selectTag(tag);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D29),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF09FACA).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Close',
              style: GoogleFonts.roboto(color: const Color(0xFF09FACA)),
            ),
          ),
        ],
      ),
    );
  }
}
