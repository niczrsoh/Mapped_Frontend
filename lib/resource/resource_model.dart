import 'package:get/get.dart';

class ResourcePost {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorImage;
  final String timeAgo;
  final List<String> images;
  final String? videoUrl;
  final List<String> tags;
  final String resourceType;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Reactive properties
  var isPinned = false.obs;
  var isReported = false.obs;

  ResourcePost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorImage,
    required this.timeAgo,
    this.images = const [],
    this.videoUrl,
    this.tags = const [],
    required this.resourceType,
    bool isPinned = false,
    bool isReported = false,
    this.viewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  }) {
    this.isPinned.value = isPinned;
    this.isReported.value = isReported;
  }

  // Factory constructor to create ResourcePost from JSON
  factory ResourcePost.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    // Debug: Print the raw JSON
    print('📦 Raw JSON for: ${json['title']}');
    print('   Type field: ${json['type']}');
    print('   ResourceType field: ${json['resourceType']}');
    print('   ImageUrls: ${json['imageUrls']}');
    print('   Images: ${json['images']}');

    // Determine resource type from JSON
    String determineResourceType() {
      // Check multiple possible field names (with different cases)
      String? resourceType =
          json['type'] ?? json['resourceType'] ?? json['resource_type'];

      if (resourceType != null && resourceType.isNotEmpty) {
        // Convert to lowercase for consistency
        final normalizedType = resourceType.toLowerCase();
        print('✅ ResourceType from backend: $normalizedType');
        return normalizedType;
      }

      // Fallback: Auto-detect based on content
      final imageUrls = json['imageUrls'] ?? json['images'];
      final videoUrls =
          json['videoUrls'] ?? json['videoUrl'] ?? json['video_url'];

      if (imageUrls is List && imageUrls.isNotEmpty) {
        print('🖼️ Auto-detected as IMAGE');
        return 'image';
      }

      // Note: videoUrl (YouTube links) are classified as 'link'
      if (videoUrls != null) {
        if (videoUrls is List && videoUrls.isNotEmpty) {
          print('🔗 Auto-detected as LINK (from video URL array)');
          return 'link';
        } else if (videoUrls is String && videoUrls.isNotEmpty) {
          print('🔗 Auto-detected as LINK (from video URL string)');
          return 'link';
        }
      }

      final content = json['description'] ?? json['content'] ?? '';
      if (content.contains('http://') || content.contains('https://')) {
        print('🔗 Auto-detected as LINK');
        return 'link';
      }

      print('📄 Defaulting to TEXT');
      return 'text';
    }

    // Extract images from either imageUrls or images field
    List<String> extractImages() {
      final imageUrls = json['imageUrls'];
      final images = json['images'];

      if (imageUrls is List && imageUrls.isNotEmpty) {
        return List<String>.from(imageUrls);
      }

      if (images is List && images.isNotEmpty) {
        return List<String>.from(images);
      }

      return [];
    }

    // Extract video URL from either videoUrls array or videoUrl string
    String? extractVideoUrl() {
      final videoUrls = json['videoUrls'];
      final videoUrl = json['videoUrl'] ?? json['video_url'];

      if (videoUrls is List && videoUrls.isNotEmpty) {
        return videoUrls[0].toString();
      }

      if (videoUrl != null && videoUrl.toString().isNotEmpty) {
        return videoUrl.toString();
      }

      return null;
    }

    // Extract content from description or content field
    String extractContent() {
      return json['description'] ?? json['content'] ?? '';
    }

    // Extract tags from comma-separated string or array
    List<String> _extractTags(dynamic tagsData) {
      if (tagsData == null) return [];

      // If it's already a list, use it directly and remove duplicates
      if (tagsData is List) {
        return tagsData
            .map((tag) => tag.toString().trim())
            .where((tag) => tag.isNotEmpty)
            .toSet()
            .toList();
      }

      // If it's a string (comma-separated), split it
      if (tagsData is String && tagsData.isNotEmpty) {
        return tagsData
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toSet()
            .toList();
      }

      return [];
    }

    return ResourcePost(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: extractContent(),
      authorId:
          json['authorId']?.toString() ??
          json['author_id']?.toString() ??
          json['author']?.toString() ??
          '',
      authorName:
          json['authorName'] ??
          json['author_name'] ??
          json['author'] ??
          'Unknown',
      authorImage: json['authorImage'] ?? json['author_image'],
      timeAgo:
          json['timeAgo'] ??
          json['time_ago'] ??
          _calculateTimeAgo(json['createdAt']),
      images: extractImages(),
      videoUrl: extractVideoUrl(),
      tags: _extractTags(json['tags']),
      resourceType: determineResourceType(),
      isPinned: json['isPinned'] ?? json['is_pinned'] ?? false,
      isReported: _checkIfReported(json, currentUserId),
      viewCount: json['viewCount'] ?? json['view_count'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // Check if current user has reported this resource
  static bool _checkIfReported(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    if (currentUserId.isEmpty) return false;

    final reports = json['reports'] as List<dynamic>?;
    if (reports == null) return false;

    return reports.any(
      (report) =>
          report['userId']?.toString() == currentUserId ||
          report['user_id']?.toString() == currentUserId,
    );
  }

  // Helper method to calculate time ago
  static String _calculateTimeAgo(dynamic dateString) {
    if (dateString == null) return 'Just now';

    try {
      final date = DateTime.parse(dateString.toString());
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}y ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else if (difference.inDays > 7) {
        return '${(difference.inDays / 7).floor()}w ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Just now';
    }
  }

  // Convert ResourcePost to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorImage': authorImage,
      'timeAgo': timeAgo,
      'images': images,
      'videoUrl': videoUrl,
      'tags': tags,
      'resourceType': resourceType,
      'isPinned': isPinned.value,
      'isReported': isReported.value,
      'viewCount': viewCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper method to get resource type label
  String get resourceTypeLabel {
    switch (resourceType.toLowerCase()) {
      case 'image':
        return 'Image';
      case 'video':
        return 'Video';
      case 'link':
        return 'Link';
      case 'text':
        return 'Text';
      default:
        return 'Resource';
    }
  }
}
