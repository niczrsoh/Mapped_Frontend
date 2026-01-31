import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/helper/colorConstant.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../forum/forum_controller.dart';
import '../forum/forum_model.dart';
import '../forum_searchtags/forum_searchtags_screen.dart';
import '../comment/comment_screen.dart';
import '../create_post/create_post_screen.dart';

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
              // 1. Sticky Header
              _buildSliverAppBar(),

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

              // 3. Posts List
              _buildPostsListSliver(),
            ],
          ),
        ),
      ),
    );
  }

  // ========== SLIVER APP BAR ==========
  Widget _buildSliverAppBar() {
    return SliverAppBar(
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
          child: Obx(
            () => controller.isLoading.value
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
                  ),
          ),
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
    );
  }

  // ========== SEARCH BAR ==========
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

  // ========== CREATE POST SECTION ==========
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
              child: const Icon(
                Icons.collections,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== POSTS LIST SLIVER ==========
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
          delegate: SliverChildBuilderDelegate((context, index) {
            final post = controller.posts[index];
            return _buildPostCard(post);
          }, childCount: controller.posts.length),
        ),
      );
    });
  }

  // ========== POST CARD ==========
  Widget _buildPostCard(ForumPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: post.isPinned.value
              ? const Color(0xFF09FACA).withOpacity(0.6)
              : const Color(0xFF09FACA).withOpacity(0.2),
          width: post.isPinned.value ? 1.5 : 1,
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
            _buildPostImages(post),
          ],
          const SizedBox(height: 12),
          _buildInteractionButtons(post),
        ],
      ),
    );
  }

  // ========== POST HEADER ==========
  Widget _buildPostHeader(ForumPost post) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey[300],
          backgroundImage:
              post.authorImage != null && post.authorImage!.isNotEmpty
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
              Obx(
                () => Row(
                  children: [
                    Flexible(
                      child: Text(
                        post.authorName,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Pinned Badge
                    if (post.isPinned.value) ...[
                      const SizedBox(width: 8),
                      _buildPinnedBadge(),
                    ],

                    // Reported Badge
                    if (post.isReported.value) ...[
                      const SizedBox(width: 8),
                      _buildReportedBadge(),
                    ],
                  ],
                ),
              ),
              Text(
                post.timeAgo,
                style: GoogleFonts.roboto(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
        ),

        _buildPostMenu(post),
      ],
    );
  }

  // ========== BADGES ==========
  Widget _buildPinnedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF09FACA).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.push_pin, size: 10, color: Color(0xFF09FACA)),
          const SizedBox(width: 4),
          Text(
            "Pinned",
            style: GoogleFonts.roboto(
              fontSize: 10,
              color: const Color(0xFF09FACA),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red, width: 1),
      ),
      child: Text(
        "Reported post",
        style: GoogleFonts.roboto(
          fontSize: 10,
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ========== POST MENU ==========
  Widget _buildPostMenu(ForumPost post) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz, color: Colors.white54),
      color: const Color(0xFF252836),
      onSelected: (value) {
        if (value == 'delete') {
          _showDeleteConfirmationDialog(post);
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
    );
  }

  // ========== POST CONTENT ==========
  Widget _buildPostContent(ForumPost post) {
    return Text(
      post.content,
      style: GoogleFonts.roboto(fontSize: 14, color: Colors.white, height: 1.5),
    );
  }

  // ========== HASHTAGS ==========
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

  // ========== POST IMAGES ==========
  Widget _buildPostImages(ForumPost post) {
    return Column(
      children: post.images.map((imgUrl) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              controller.getFullImageUrl(imgUrl),
              width: double.infinity,
              fit: BoxFit.fitWidth,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
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
                  height: 200,
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

  // ========== INTERACTION BUTTONS ==========
  Widget _buildInteractionButtons(ForumPost post) {
    return Row(
      children: [
        Obx(
          () => _buildInteractionButton(
            icon: post.isLiked.value ? Icons.favorite : Icons.favorite_border,
            count: post.likes.value,
            color: post.isLiked.value ? Colors.red : Colors.white54,
            onTap: () => controller.toggleLike(post),
          ),
        ),
        const SizedBox(width: 20),
        _buildInteractionButton(
          icon: Icons.chat_bubble_outline,
          count: post.comments,
          color: Colors.white54,
          onTap: () => Get.to(() => CommentsScreen(post: post)),
        ),

        const Spacer(),

        // PIN BUTTON
        Obx(
          () => IconButton(
            icon: Icon(
              post.isPinned.value ? Icons.push_pin : Icons.push_pin_outlined,
              color: post.isPinned.value
                  ? const Color(0xFF09FACA)
                  : Colors.white54,
              size: 20,
            ),
            onPressed: () => _showPinConfirmationDialog(post),
          ),
        ),

        // REPORT BUTTON
        Obx(
          () => IconButton(
            icon: Icon(
              post.isReported.value ? Icons.flag : Icons.flag_outlined,
              color: post.isReported.value ? Colors.red : Colors.white54,
              size: 20,
            ),
            onPressed: () => _showReportDialog(post),
          ),
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

  // ========== DIALOGS ==========

  // --- PIN CONFIRMATION DIALOG ---
  void _showPinConfirmationDialog(ForumPost post) {
    bool currentlyPinned = post.isPinned.value;

    Get.defaultDialog(
      title: "",
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(20),
      backgroundColor: const Color(0xFF252836),
      radius: 20,
      content: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.push_pin_outlined,
                size: 40,
                color: Colors.white,
              ),
              if (currentlyPinned)
                Transform.rotate(
                  angle: -0.8,
                  child: Container(height: 2, width: 40, color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currentlyPinned
                ? "Do you want to unpin this post?"
                : "Do you want to pin this post?",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF09FACA),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text(
                    "CANCEL",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF09FACA),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    controller.togglePin(post);
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- DELETE CONFIRMATION DIALOG ---
  void _showDeleteConfirmationDialog(ForumPost post) {
    Get.defaultDialog(
      title: 'Delete Post',
      middleText: 'Are you sure you want to delete this post?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        await controller.deletePost(post);
      },
    );
  }

  // --- REPORT DIALOG - STEP 1: POLICY SELECTION ---
  void _showReportDialog(ForumPost post) {
    if (!controller.canReportPost(post)) {
      Get.snackbar(
        "Info",
        "You have already reported this post.",
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
      );
      return;
    }

    controller.resetReportState();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select our policy that applies",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: controller.reportReasons.map((reason) {
                  return Obx(() {
                    final isSelected =
                        controller.selectedReason.value == reason;
                    return GestureDetector(
                      onTap: () => controller.selectReportReason(reason),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00FFA3)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00FFA3)
                                : Colors.black54,
                          ),
                        ),
                        child: Text(
                          reason,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: controller.selectedReason.value.isEmpty
                        ? null
                        : () {
                            Get.back();
                            _showReportConfirmationDialog(post);
                          },
                    child: const Text(
                      "Next",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- REPORT DIALOG - STEP 2: CONFIRMATION ---
  void _showReportConfirmationDialog(ForumPost post) {
    controller.toggleReportConfirmation(false);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "You've selected the following reason",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                controller.selectedReason.value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.getReasonDefinition(controller.selectedReason.value),
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              const Text(
                "Confirmation",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Row(
                  children: [
                    Checkbox(
                      value: controller.isReportConfirmed.value,
                      activeColor: const Color(0xFF007AFF),
                      onChanged: (val) =>
                          controller.toggleReportConfirmation(val ?? false),
                    ),
                    Expanded(
                      child: Text(
                        "I have confirmed to report this post as ${controller.selectedReason.value.toLowerCase()}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: controller.isReportConfirmed.value
                        ? () async {
                            Get.back();
                            final success = await controller.submitReport(post);
                            if (success) {
                              _showReportSuccessDialog();
                            }
                          }
                        : null,
                    child: const Text(
                      "Submit Report",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- REPORT DIALOG - STEP 3: SUCCESS ---
  void _showReportSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 50,
              ),
              const SizedBox(height: 16),
              const Text(
                "You have successfully reported the post",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== VIDEO PLAYER WIDGET ==========
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
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    if (videoId != null) {
      _controller =
          YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        thumbnail: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF09FACA)),
          ),
        ),
      ),
    );
  }
}
