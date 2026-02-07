import 'package:get/get_rx/src/rx_types/rx_types.dart';

class Resources {
  final String id;
  final String authorName;
  final String? authorImage;
  final String timeAgo;
  final String content;
  final List<String> hashtags;
  final List<String> images;
  final String? videoUrl;
  final RxInt likes;
  final int comments;
  final RxBool isLiked;

  Resources({
    required this.id,
    required this.authorName,
    this.authorImage,
    required this.timeAgo,
    required this.content,
    required this.hashtags,
    required this.images,
    this.videoUrl,
    required int likes,
    required this.comments,
    bool isLiked = false,
  }) : likes = likes.obs,
       isLiked = isLiked.obs;

  factory Resources.fromJson(Map<String, dynamic> json, String currentUserId) {
    // Handle date safely
    String timeAgo = 'now';
    try {
      final dateStr =
          json['createdAt'] ?? json['date'] ?? DateTime.now().toIso8601String();
      final date = DateTime.parse(dateStr.toString());
      final diff = DateTime.now().difference(date);
      timeAgo = '${diff.inMinutes}m';
      if (diff.inHours > 0) timeAgo = '${diff.inHours}h';
      if (diff.inDays > 0) timeAgo = '${diff.inDays}d';
    } catch (e) {
      print("Date parsing error: $e");
    }

    // Handle likes safely
    int likeCount = 0;
    bool isLiked = false;
    try {
      final likes = json['likes'] as List? ?? [];
      likeCount = likes.length;
      isLiked = likes.any((like) {
        if (like is Map) {
          return like['user'] == currentUserId ||
              like['userId'] == currentUserId;
        }
        return like.toString() == currentUserId;
      });
    } catch (e) {
      print("Likes parsing error: $e");
    }

    // Handle comments safely
    int commentCount = 0;
    try {
      final comments = json['comments'] as List? ?? [];
      commentCount = comments.length;
    } catch (e) {
      print("Comments parsing error: $e");
    }

    // Handle hashtags safely
    List<String> hashtags = [];
    try {
      final tagsData = json['tags'];
      if (tagsData is List) {
        hashtags = tagsData
            .map((tag) => tag.toString().trim())
            .where((tag) => tag.isNotEmpty)
            .toSet()
            .toList();
      } else if (tagsData is String && tagsData.isNotEmpty) {
        hashtags = tagsData
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toSet()
            .toList();
      }
    } catch (e) {
      print("Tags parsing error: $e");
    }

    // Handle images safely
    List<String> images = [];
    try {
      final imageData =
          json['images'] ??
          json['image'] ??
          json['postImages'] ??
          json['imageUrls'];
      if (imageData is List && imageData.isNotEmpty) {
        images = imageData
            .map((img) => img.toString())
            .where((img) => img.isNotEmpty)
            .toList();
      } else if (imageData is String && imageData.isNotEmpty) {
        images = [imageData];
      }
    } catch (e) {
      print("Images parsing error: $e");
    }

    // Handle video URL safely
    String? videoUrl;
    try {
      videoUrl = json['videoUrl'] ?? json['video'] ?? json['youtubeUrl'];
      if (videoUrl is String && videoUrl.isEmpty) {
        videoUrl = null;
      }
      if (videoUrl != null) {
        print("✅ Found video URL: $videoUrl");
      }
    } catch (e) {
      print("Video URL parsing error: $e");
    }

    return Resources(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      authorName:
          json['authorName'] ?? json['name'] ?? json['author'] ?? 'Unknown',
      authorImage: json['authorImage'] ?? json['avatar'],
      timeAgo: timeAgo,
      content: json['content'] ?? json['text'] ?? json['description'] ?? '',
      hashtags: hashtags,
      images: images,
      videoUrl: videoUrl,
      likes: likeCount,
      comments: commentCount,
      isLiked: isLiked,
    );
  }
}
