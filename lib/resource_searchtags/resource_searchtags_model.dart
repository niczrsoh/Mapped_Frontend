import 'package:get/get_rx/src/rx_types/rx_types.dart';

class Resources {
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

  Resources({
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

  factory Resources.fromJson(Map<String, dynamic> json, String currentUserId) {
    final date = DateTime.parse(json['date']);
    final diff = DateTime.now().difference(date);
    String timeAgo = '${diff.inMinutes}m';
    if (diff.inHours > 0) timeAgo = '${diff.inHours}h';
    if (diff.inDays > 0) timeAgo = '${diff.inDays}d';

    final likes = (json['likes'] as List);
    final isLiked = likes.any((like) => like['user'] == currentUserId);

    return Resources(
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
