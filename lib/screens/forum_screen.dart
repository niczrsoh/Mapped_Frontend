import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ForumScreen extends StatelessWidget {
  ForumScreen({super.key});
  final ForumController controller = Get.put(ForumController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Home',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF252836),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFF09FACA).withValues(alpha: .3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  style: GoogleFonts.roboto(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by name ...',
                    hintStyle: GoogleFonts.roboto(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w400
                    ),
                    suffixIcon: const Icon(
                      Icons.search,
                      color: Colors.white54,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Create Post Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: controller.createPost,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252836),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF09FACA).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'What\'s on your mind?',
                          style: GoogleFonts.roboto(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF09FACA), Color(0xFF0D7C7C)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.collections,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Posts List
            Expanded(
              child: Obx(() => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.posts.length,
                itemBuilder: (context, index) {
                  final post = controller.posts[index];
                  return _buildPostCard(post);
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(ForumPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF09FACA).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Info
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey[300],
                backgroundImage: post.authorImage != null
                    ? AssetImage(post.authorImage!)
                    : null,
                child: post.authorImage == null
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      post.timeAgo,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.white54),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Post Content
          Text(
            post.content,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.white,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 12),

          // Hashtags
          if (post.hashtags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: post.hashtags.map((tag) {
                return Text(
                  tag,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: const Color(0xFF09FACA),
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 12),

          // Post Images
          if (post.images.isNotEmpty)
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: post.images.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: post.images.length > 1 ? 160 : double.infinity,
                    margin: EdgeInsets.only(
                      right: index < post.images.length - 1 ? 8 : 0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[800],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        post.images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.white54,
                                size: 50,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 12),

          // Interaction Buttons
          Row(
            children: [
              Obx(() => _buildInteractionButton(
                icon: post.isLiked.value
                    ? Icons.favorite
                    : Icons.favorite_border,
                count: post.likes.value,
                color: post.isLiked.value
                    ? Colors.red
                    : Colors.white54,
                onTap: () => controller.toggleLike(post),
              )),
              const SizedBox(width: 20),
              _buildInteractionButton(
                icon: Icons.chat_bubble_outline,
                count: post.comments,
                color: Colors.white54,
                onTap: () => controller.openComments(post),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            count.toString(),
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

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