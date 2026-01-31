import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

// --- MODEL ---
class ForumPost {
  final String id;
  final String authorName;
  final String? authorImage;
  final String timeAgo;
  final String content;
  final List<String> hashtags;
  final List<String> images;
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
    required int likes,
    required this.comments,
    bool isLiked = false,
  }) : likes = likes.obs,
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
      images: json['image'] != null && json['image'] != ""
          ? [json['image']]
          : [],
      likes: likes.length,
      comments: (json['comments'] as List).length,
      isLiked: isLiked,
    );
  }
}

// --- CONTROLLER ---
class ForumSearchtagsController extends GetxController {
  final String baseUrl = kIsWeb
      ? "http://localhost:5000"
      : "http://192.168.56.1:5000"; // Update with your IP

  final String currentUserId = "692a8a206881c040ebf00943";

  var hasSearched = false.obs; 
  var posts = <ForumPost>[].obs;
  var popularTags = <String>[].obs;
  var allTags = <String>[].obs;
  var isLoading = false.obs;
  var selectedTag = ''.obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadPopularTags();
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

  Future<void> loadPopularTags() async {
    try {
      // NOTE: Using the same endpoint as all tags. 
      // Ideally, your backend should have '/api/forum/tags/popular' or sort them.
      // Here, we take the first 10 tags as "Popular".
      final response = await http.get(Uri.parse('$baseUrl/api/forum/tags'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        // Process data: Take top 15, ensure they start with '#', and convert to List<String>
        popularTags.value = data.take(15).map((tag) {
          String t = tag.toString();
          return t.startsWith('#') ? t : '#$t';
        }).toList();
        
      } else {
        print("Failed to fetch tags: ${response.statusCode}");
      }
    } catch (e) {
      print("Load Popular Tags Error: $e");
      // Fallback: If backend fails, show these defaults so UI isn't empty
      popularTags.value = [
        '#Taekwondo', '#UTMDojo', '#MartialArts', '#SideKick', 
        '#BeltGrading', '#Discipline', '#Sparring', '#TeamSpirit'
      ];
    }
  }

  // Load all tags for the "See All" dialog
  Future<void> loadAllTags() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/forum/tags'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        // Format them with '#'
        allTags.value = data.map((tag) {
          String t = tag.toString();
          return t.startsWith('#') ? t : '#$t';
        }).toList();
        
        _showTagsDialog();
      }
    } catch (e) {
      print("Load All Tags Error: $e");
    }
  }

  // Used by RefreshIndicator - re-runs the CURRENT search
  Future<void> loadPosts() async {
    if (!hasSearched.value) return; // Don't load if we aren't searching
    
    // Rerun search based on current state
    if (selectedTag.value.isNotEmpty) {
      await searchByTag(selectedTag.value, searchQuery: searchController.text);
    } else if (searchController.text.isNotEmpty) {
      await searchPosts(searchController.text);
    }
  }

  // Search posts by name or text
  Future<void> searchPosts(String query) async {
    String trimmedQuery = query.trim();

    // 1. If empty, clear results
    if (trimmedQuery.isEmpty && selectedTag.value.isEmpty) {
      hasSearched.value = false;
      posts.clear();
      return;
    }

    // --- SMART LOGIC START ---

    // CASE 1: Input starts with '#' (e.g., "#Taekwondo")
    // ACTION: Search ONLY for posts with this tag.
    if (trimmedQuery.startsWith('#')) {
      print("🔹 Detected Hashtag Search: $trimmedQuery");
      
      // We pass the full string (e.g. "#Taekwondo"). 
      // The searchByTag function will handle the API call with ?tag=Taekwondo
      selectedTag.value = trimmedQuery; // Highlight the UI tag if needed
      await searchByTag(trimmedQuery); 
      return; 
    }

    // CASE 2: Input is normal text (e.g., "Kick")
    // ACTION: Search Content AND Tags AND Name
    // This uses the ?q= parameter
    if (selectedTag.value.isNotEmpty) {
      // If a tag button was previously clicked, keep filtering by that tag
      searchByTag(selectedTag.value, searchQuery: trimmedQuery);
      return;
    }

    // STANDARD TEXT SEARCH
    hasSearched.value = true;
    isLoading.value = true;
    posts.clear();

    try {
      // Send as 'q'. The backend will search text, tags, and name.
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

  // Search posts by tag
  Future<void> searchByTag(String tag, {String? searchQuery}) async {
    hasSearched.value = true;
    isLoading.value = true;
    posts.clear();

    try {
      // 1. Handle the Hash symbol
      // CHECK YOUR DATABASE: Does it store ["#Taekwondo"] or ["Taekwondo"]?
      // If DB has #, keep it. If DB has no #, use replaceAll.
      // Let's assume for now the DB stores CLEAN tags (no #).
      String cleanTag = tag.replaceAll('#', ''); 

      // 2. Build Query Parameters separately
      Map<String, String> queryParams = {
        'tag': cleanTag, 
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['q'] = searchQuery;
      }

      // 3. Construct the URI correctly
      final uri = Uri.parse('$baseUrl/api/forum/search').replace(queryParameters: queryParams);
      
      print("📢 Calling API: $uri"); // DEBUG: Check this in your console!

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        posts.value = data
            .map((json) => ForumPost.fromJson(json, currentUserId))
            .toList();
            
        if (posts.isEmpty) {
          print("⚠️ API returned 0 posts for tag: $cleanTag");
        }
      } else {
        print("❌ API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Search by Tag Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Select a tag and filter posts
  void selectTag(String tag) {
    if (selectedTag.value == tag) {
      // If clicking the same tag, deselect it
      clearSelection();
    } else {
      selectedTag.value = tag;
      searchByTag(tag, searchQuery: searchController.text);
    }
  }

  // Clear tag selection and reset state
  void clearSelection() {
    selectedTag.value = '';
    searchController.clear();
    posts.clear();
    hasSearched.value = false; // Returns UI to "Search tags..." state
  }

  // Helper: Get full image URL
  String getFullImageUrl(String relativePath) {
    if (relativePath.startsWith('http')) return relativePath;
    return "$baseUrl/$relativePath";
  }

  // Helper to show the dialog with all tags
  void _showTagsDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF252836),
        title: Text(
          'All Tags',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView( // Added ScrollView for safety
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