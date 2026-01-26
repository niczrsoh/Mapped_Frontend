import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../controller/controller/forum_controller.dart';
import '../screens/forum_searchtags_screen.dart';
import '../screens/comment_screen.dart';
import '../screens/create_post_screen.dart';

class ForumScreen extends StatelessWidget {
  ForumScreen({super.key});
  final ForumController controller = Get.put(ForumController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.themeBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadPosts,
          color: const Color(0xFF09FACA),
          child: CustomScrollView(
            slivers: [
              // 1. Sticky Header AND Search Bar
              SliverAppBar(
                backgroundColor: const Color(0xFF1A1D29),
                pinned: true,
                floating: false,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Text(
                  'Home',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Obx(() => controller.isLoading.value
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF09FACA),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            onPressed: controller.loadPosts,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          )),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(70.0),
                  child: Container(
                    color: const Color(0xFF1A1D29),
                    padding: const EdgeInsets.only(bottom: 16, top: 0),
                    child: _buildSearchBar(),
                  ),
                ),
              ),

              // 2. Create Post Section
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildCreatePostSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // 3. The Post List
              _buildPostsListSliver(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Get.to(() => ForumSearchtagsScreen()),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF252836),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: const Color(0xFF09FACA).withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Search by name or tags...',
                  style: GoogleFonts.roboto(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const Icon(Icons.search, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatePostSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => Get.to(() => CreatePostScreen()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          GestureDetector(
            onTap: () => Get.to(() => CreatePostScreen()),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF09FACA), Color(0xFF0D7C7C)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.collections, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsListSliver() {
    return Obx(() {
      if (controller.isLoading.value && controller.posts.isEmpty) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF09FACA)),
          ),
        );
      }

      if (controller.posts.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              'No posts yet. Be the first to post!',
              style: GoogleFonts.roboto(color: Colors.white54, fontSize: 16),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final post = controller.posts[index];
              return _buildPostCard(post);
            },
            childCount: controller.posts.length,
          ),
        ),
      );
    });
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
          _buildPostHeader(post),
          const SizedBox(height: 12),
          _buildPostContent(post),
          if (post.hashtags.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildHashtags(post),
          ],
          if (post.videoUrl != null && post.videoUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            PostVideoPlayer(videoUrl: post.videoUrl!),
          ],
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            // UPDATED: Now supports full size vertical stacking
            _buildPostImages(post),
          ],
          const SizedBox(height: 12),
          _buildInteractionButtons(post),
        ],
      ),
    );
  }

  Widget _buildPostHeader(ForumPost post) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey[300],
          backgroundImage: post.authorImage != null && post.authorImage!.isNotEmpty
              ? NetworkImage(controller.getFullImageUrl(post.authorImage!))
              : null,
          child: post.authorImage == null || post.authorImage!.isEmpty
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
                style: GoogleFonts.roboto(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz, color: Colors.white54),
          color: const Color(0xFF252836),
          onSelected: (value) {
            if (value == 'delete') {
              controller.deletePost(post);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: Text(
                'Delete Post',
                style: GoogleFonts.roboto(color: Colors.red),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPostContent(ForumPost post) {
    return Text(
      post.content,
      style: GoogleFonts.roboto(
        fontSize: 14,
        color: Colors.white,
        height: 1.5,
      ),
    );
  }

  Widget _buildHashtags(ForumPost post) {
    return Wrap(
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
    );
  }

  // --- FIXED: Vertical Column for "Own Size" ---
  Widget _buildPostImages(ForumPost post) {
    return Column(
      children: post.images.map((imgUrl) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0), // Spacing between images
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              controller.getFullImageUrl(imgUrl),
              width: double.infinity, // Fill the card width
              fit: BoxFit.fitWidth,   // Scale height automatically (maintain aspect ratio)
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200, // Fallback height if image fails
                  width: double.infinity,
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.white54),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200, // Placeholder height while loading
                  width: double.infinity,
                  color: Colors.grey[900],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: const Color(0xFF09FACA),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInteractionButtons(ForumPost post) {
    return Row(
      children: [
        Obx(() => _buildInteractionButton(
              icon: post.isLiked.value ? Icons.favorite : Icons.favorite_border,
              count: post.likes.value,
              color: post.isLiked.value ? Colors.red : Colors.white54,
              onTap: () => controller.toggleLike(post),
            )),
        const SizedBox(width: 20),
        _buildInteractionButton(
          icon: Icons.chat_bubble_outline,
          count: post.comments,
          color: Colors.white54,
          onTap: () => Get.to(() => CommentsScreen(post: post)),
        ),
      ],
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

class PostVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const PostVideoPlayer({super.key, required this.videoUrl});

  @override
  State<PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer> {
  late YoutubePlayerController _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    // 1. Extract Video ID
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    // 2. Initialize Controller
    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false, // Don't play automatically in feed!
          mute: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: false,
        ),
      )..addListener(() {
          if (mounted && _controller.value.isReady && !_isReady) {
            setState(() {
              _isReady = true;
            });
          }
        });
    }
  }

  @override
  void dispose() {
    // 3. Dispose Controller to free memory (CRITICAL)
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFF09FACA),
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFF09FACA),
          handleColor: Color(0xFF09FACA),
        ),
        // Optional: Custom Thumbnail if player isn't ready
        thumbnail: Container(
          color: Colors.black,
          child: Center(child: CircularProgressIndicator(color: Color(0xFF09FACA))),
        ),
      ),
    );
  }
}