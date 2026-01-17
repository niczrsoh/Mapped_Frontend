import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:mapped_frontend/forum/forum_model.dart';
class ForumController extends GetxController {
  var posts = <ForumPost>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
  }

  void loadPosts() {
    posts.value = [
      ForumPost(
        id: '1',
        authorName: 'Ahmad Zafri',
        timeAgo: '3m',
        content:
            '"This week\'s Taekwondo training will focus on the roundhouse kick. Please be on time so we can practice together!"',
        hashtags: [
          '#TaekwondoTraining',
          '#RoundhouseKick',
          '#MartialArts',
          '#UTMDojo'
        ],
        images: [
          'assets/images/taekwondopost1.png',
          'assets/images/taekwondopost2.png',
        ],
        likes: 35,
        comments: 89,
      ),
      ForumPost(
        id: '2',
        authorName: 'Sarah Lee',
        timeAgo: '1h',
        content:
            'Great training session today! Remember to stretch before and after practice to prevent injuries.',
        hashtags: ['#Training', '#MartialArts', '#Fitness'],
        images: [],
        likes: 42,
        comments: 15,
      ),
    ];
  }

  void toggleLike(ForumPost post) {
    if (post.isLiked.value) {
      post.likes.value--;
      post.isLiked.value = false;
    } else {
      post.likes.value++;
      post.isLiked.value = true;
    }
  }

  void openComments(ForumPost post) {
    Get.snackbar(
      'Comments',
      'Opening comments for post by ${post.authorName}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF09FACA),
      colorText: Colors.white,
    );
  }

  void createPost() {
    Get.snackbar(
      'Create Post',
      'Opening post creation screen',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF09FACA),
      colorText: Colors.white,
    );
  }
}