import 'package:get/get_rx/src/rx_types/rx_types.dart';

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
  })  : likes = likes.obs,
        isLiked = isLiked.obs;
}