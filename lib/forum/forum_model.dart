import 'package:get/get_rx/src/rx_types/rx_types.dart';

class ForumPost {
  final String id;
  final String authorName;
  final String? authorImage;
  final String timeAgo;
  final String content;
  final List<String> hashtags;
  final List<String> images;
  final String? videoUrl;
  final String? videoThumbnail;
  final RxInt likes;
  final int comments;
  final RxBool isLiked;
  final RxBool isPinned;
  final RxBool isReported;

  ForumPost({
    required this.id,
    required this.authorName,
    this.authorImage,
    required this.timeAgo,
    required this.content,
    required this.hashtags,
    required this.images,
    required this.videoUrl,
    required this.videoThumbnail,
    required int likes,
    required this.comments,
    bool isLiked = false,
    bool isPinned = false,
    bool isReported = false,
  }) : likes = likes.obs,
       isLiked = isLiked.obs,
       isPinned = isPinned.obs,
       isReported = isReported.obs;

  factory ForumPost.fromJson(Map<String, dynamic> json, String currentUserId) {
    final date = DateTime.parse(json['date']);
    final diff = DateTime.now().difference(date);
    String timeAgo = '${diff.inMinutes}m';
    if (diff.inHours > 0) timeAgo = '${diff.inHours}h';
    if (diff.inDays > 0) timeAgo = '${diff.inDays}d';

    final likesList = (json['likes'] as List? ?? []);
    final isLiked = likesList.any((like) => like['user'] == currentUserId);

    final reportsList = (json['reports'] as List? ?? []);
    final isReported = reportsList.any(
      (report) => report['user'] == currentUserId,
    );

    // Logic: Check 'images' array first (new backend), fallback to single 'image' (legacy)
    List<String> parsedImages = [];
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      parsedImages = List<String>.from(json['images']);
    } else if (json['image'] != null && json['image'] != "") {
      parsedImages = [json['image']];
    }

    return ForumPost(
      id: json['_id'],
      authorName: json['name'] ?? 'Unknown',
      authorImage: json['avatar'],
      timeAgo: timeAgo,
      content: json['text'],
      hashtags: List<String>.from(json['tags'] ?? []),
      images: parsedImages,
      videoUrl: json['videoUrl'],
      videoThumbnail: json['videoThumbnail'],
      likes: likesList.length,
      comments: (json['comments'] as List? ?? []).length,
      isLiked: isLiked,
      isPinned: json['isPinned'] ?? false,
      isReported: isReported,
    );
  }
}
