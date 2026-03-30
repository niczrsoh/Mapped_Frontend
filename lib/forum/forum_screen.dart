import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/controller/user_controller';
import 'dart:async';
import 'package:mapped_frontend/helper/colorConstant.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/gestures.dart';
import '../forum/forum_controller.dart';
import '../forum/forum_model.dart';
import '../forum_searchtags/forum_searchtags_screen.dart';
import '../comment/comment_screen.dart';
import '../create_post/create_post_screen.dart';
import 'package:mapped_frontend/TProgress/belt_progress_ring_controller.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  late final ForumController controller;
  late final UserController userController;

  @override
  void initState() {
    super.initState();
    Get.put(ForumController());
    controller = Get.find<ForumController>();
    userController = Get.find<UserController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadPosts();
    });
  }

  final BeltProgressRingController beltController = Get.put(
    BeltProgressRingController(),
  );

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
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildCreatePostSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              _buildPostsListSliver(),
              // 🔁 Pagination at the bottom
              SliverToBoxAdapter(child: _buildPagination()),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- SLIVER APP BAR ----------
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF1A1D29),
      pinned: true,
      floating: false,
      elevation: 0,
      automaticallyImplyLeading: false,
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

  // ---------- SEARCH BAR ----------
  Widget _buildSearchBar() {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ForumSearchtagsScreen()),
          ),
          child: Container(
            decoration: AppStyles.searchBarDeco,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'hint_search'.tr(),
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
      ),
    );
  }

  // ---------- CREATE POST SECTION ----------
  Widget _buildCreatePostSection() {
    void handlePostCreation() async {
      // Check if Blue Belt is LOCKED (meaning Green is not finished)
      if (beltController.detailedBeltData.isEmpty) {
        // Show loading indicator
        Get.dialog(
          const Center(
            child: CircularProgressIndicator(color: Color(0xFF09FACA)),
          ),
          barrierDismissible: false,
        );

        // Force a refresh
        await beltController.fetchBeltProgress();

        // Close loading indicator
        if (Get.isDialogOpen ?? false) Get.back();
      }

      // 2. Perform the check
      // We check if it IS locked (True = Blocked)
      if (beltController.isBeltLocked('Blue')) {
        Get.snackbar(
          "forum_snackbar_access_denied_title".tr(),
          "forum_snackbar_access_denied_blue_belt".tr(),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const Icon(Icons.lock, color: Colors.white),
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        // Unlocked -> Go to Create Screen
        Get.to(() => CreatePostScreen());
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Obx(() {
            final avatar = userController.userAvatar;
            return CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[300],
              backgroundImage: avatar.isNotEmpty
                  ? NetworkImage(
                      avatar.startsWith('http')
                          ? avatar
                          : 'https://mapped-backend-node-js-ce6r.onrender.com/$avatar',
                    )
                  : null,
              child: avatar.isEmpty
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            );
          }),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: handlePostCreation,
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
                  'create_post_hint_input'.tr(),
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
            onTap: handlePostCreation,
            //onTap: () => Get.to(() => CreatePostScreen()),
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

  // ---------- POSTS LIST (USING displayedPosts) ----------
  Widget _buildPostsListSliver() {
    return Obx(() {
      if (controller.isLoading.value && controller.allPosts.isEmpty) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF09FACA)),
          ),
        );
      }

      if (controller.allPosts.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              'forum_empty_state_posts'.tr(),
              style: GoogleFonts.roboto(color: Colors.white54, fontSize: 16),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final post = controller.displayedPosts[index];
            return _buildPostCard(post);
          }, childCount: controller.displayedPosts.length),
        ),
      );
    });
  }

  // ---------- POST CARD (unchanged) ----------
  Widget _buildPostCard(ForumPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.postCardDeco(post.isPinned.value),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(post),
          const SizedBox(height: 12),
          _buildPostContent(post),
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

  // ---------- POST CONTENT (unchanged) ----------
  Widget _buildPostContent(ForumPost post) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.roboto(
          fontSize: 14,
          color: Colors.white,
          height: 1.5,
        ),
        children: _parseContent(post.content),
      ),
    );
  }

  List<TextSpan> _parseContent(String text) {
    List<TextSpan> spans = [];
    text.splitMapJoin(
      RegExp(r"\B#\w+"),
      onMatch: (m) {
        final tag = m.group(0)!;
        spans.add(
          TextSpan(
            text: tag,
            style: const TextStyle(
              color: Color(0xFF09FACA),
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () =>
                  Get.to(() => ForumSearchtagsScreen(), arguments: tag),
          ),
        );
        return "";
      },
      onNonMatch: (n) {
        spans.add(
          TextSpan(
            text: n,
            style: const TextStyle(color: Colors.white),
          ),
        );
        return "";
      },
    );
    return spans;
  }

  // ---------- POST HEADER (updated: no .value on currentUserId) ----------
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
                    if (post.isPinned.value) ...[
                      const SizedBox(width: 8),
                      _buildPinnedBadge(),
                    ],
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
        isAuthor(post) ? _buildPostMenu(post) : const SizedBox.shrink(),
      ],
    );
  }

  // Helper to keep code clean
  bool isAuthor(ForumPost post) {
    return post.authorId.toString() == controller.currentUserId;
  }

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
            "forum_badge_pinned".tr(),
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
        "forum_badge_reported".tr(),
        style: GoogleFonts.roboto(
          fontSize: 10,
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

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
            'forum_menu_delete_post'.tr(),
            style: GoogleFonts.roboto(color: Colors.red),
          ),
        ),
      ],
    );
  }

  // ---------- POST IMAGES (unchanged) ----------
  Widget _buildPostImages(ForumPost post) {
    if (post.images.length == 1) {
      return GestureDetector(
        onTap: () => _openImageViewer(
          controller.getFullImageUrl(post.images[0]),
          0,
          post.images.map((img) => controller.getFullImageUrl(img)).toList(),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            controller.getFullImageUrl(post.images[0]),
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[800],
                child: Center(
                  child: Text(
                    'forum_image_error'.tr(),
                    style: const TextStyle(color: Colors.red),
                  ),
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
    }

    return PostImageGallery(
      images: post.images,
      controller: controller,
      onImageTap: (index) => _openImageViewer(
        controller.getFullImageUrl(post.images[index]),
        index,
        post.images.map((img) => controller.getFullImageUrl(img)).toList(),
      ),
    );
  }

  void _openImageViewer(
    String imageUrl,
    int initialIndex,
    List<String> allImages,
  ) {
    Get.to(
      () => FullScreenImageViewer(
        imageUrls: allImages,
        initialIndex: initialIndex,
      ),
      transition: Transition.fade,
    );
  }

  // ---------- INTERACTION BUTTONS (unchanged) ----------
  Widget _buildInteractionButtons(ForumPost post) {
    return Builder(
      builder: (context) => Row(
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
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CommentsScreen(post: post),
              ),
            ),
          ),
          const Spacer(),
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

  // ---------- PIN CONFIRMATION DIALOG (unchanged) ----------
  void _showPinConfirmationDialog(ForumPost post) {
    bool currentlyPinned = post.isPinned.value;

    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF252836),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                        child: Container(
                          height: 2,
                          width: 40,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  currentlyPinned
                      ? "forum_dialog_pin_title_pin".tr()
                      : "forum_dialog_pin_title_unpin".tr(),
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
                        onPressed: () => Navigator.of(context).pop(),
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
                          Navigator.of(context).pop();
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
          ),
        );
      },
    );
  }

  // ---------- DELETE CONFIRMATION DIALOG (unchanged) ----------
  void _showDeleteConfirmationDialog(ForumPost post) {
    Get.defaultDialog(
      title: 'forum_dialog_delete_title'.tr(),
      middleText: 'forum_dialog_delete_msg'.tr(),
      textConfirm: 'delete'.tr(),
      textCancel: 'cancel'.tr(),
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      barrierDismissible: false,
      onConfirm: () async {
        Get.back();
        await Future.delayed(const Duration(milliseconds: 100));
        await controller.deletePost(post);
      },
      onCancel: () {
        Get.back();
      },
    );
  }

  // ---------- REPORT DIALOGS (unchanged) ----------
  void _showReportDialog(ForumPost post) {
    if (!controller.canReportPost(post)) {
      Get.snackbar(
        "forum_snackbar_report_info_title".tr(),
        "forum_snackbar_report_info_msg".tr(),
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
      );
      return;
    }

    controller.resetReportState();

    showDialog(
      context: Get.context!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                              Navigator.of(context).pop();
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
        );
      },
    );
  }

  void _showReportConfirmationDialog(ForumPost post) {
    controller.toggleReportConfirmation(false);

    showDialog(
      context: Get.context!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                  controller.getReasonDefinition(
                    controller.selectedReason.value,
                  ),
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
                              Navigator.of(context).pop();
                              final success = await controller.submitReport(
                                post,
                              );
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
        );
      },
    );
  }

  void _showReportSuccessDialog() {
    showDialog(
      context: Get.context!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- 🆕 PAGINATION WIDGET ----------
  Widget _buildPagination() {
    return Obx(() {
      final total = controller.totalPages.value;
      final current = controller.currentPage.value;

      if (total <= 1) return const SizedBox.shrink(); // Hide if only one page

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous button
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white54),
              onPressed: current > 1
                  ? () => controller.goToPage(current - 1)
                  : null,
            ),
            const SizedBox(width: 8),

            // Page numbers
            ...List.generate(total, (index) {
              final page = index + 1;
              final isCurrent = page == current;
              return GestureDetector(
                onTap: () => controller.goToPage(page),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFF09FACA).withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCurrent
                          ? const Color(0xFF09FACA)
                          : Colors.white24,
                    ),
                  ),
                  child: Text(
                    '$page',
                    style: GoogleFonts.roboto(
                      color: isCurrent
                          ? const Color(0xFF09FACA)
                          : Colors.white70,
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(width: 8),
            // Next button
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white54),
              onPressed: current < total
                  ? () => controller.goToPage(current + 1)
                  : null,
            ),
          ],
        ),
      );
    });
  }
}

// ============================================================================
// EXTERNAL WIDGETS (PostVideoPlayer, PostImageGallery, FullScreenImageViewer)
// ============================================================================
// These widgets are already perfect and remain unchanged from the original code.

// ---------- VIDEO PLAYER ----------
class PostVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const PostVideoPlayer({super.key, required this.videoUrl});

  @override
  State<PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer> {
  YoutubePlayerController? _controller;
  bool _isReady = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlayer();
    });
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.videoUrl.isEmpty) {
        throw Exception('Video URL is empty');
      }

      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

      if (videoId == null) {
        throw Exception('Invalid YouTube URL');
      }

      _controller = YoutubePlayerController(
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
      );

      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    } catch (e) {
      print("Error initializing YouTube player: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(
            'forum_video_error'.tr(),
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF09FACA)),
            const SizedBox(height: 10),
            Text(
              'forum_video_loading'.tr(),
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (!_isReady || _controller == null) {
      return _buildLoadingWidget();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFF09FACA),
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFF09FACA),
          handleColor: Color(0xFF09FACA),
        ),
        onReady: () {
          if (mounted) {
            setState(() {
              _isReady = true;
            });
          }
        },
      ),
    );
  }
}

// ---------- INSTAGRAM-STYLE IMAGE GALLERY ----------
class PostImageGallery extends StatefulWidget {
  final List<String> images;
  final ForumController controller;
  final Function(int)? onImageTap;

  const PostImageGallery({
    super.key,
    required this.images,
    required this.controller,
    this.onImageTap,
  });

  @override
  State<PostImageGallery> createState() => _PostImageGalleryState();
}

class _PostImageGalleryState extends State<PostImageGallery> {
  late PageController _pageController;
  int _currentPage = 0;
  bool? _allImagesSameRatio;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _checkImageRatios();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkImageRatios() async {
    if (widget.images.isEmpty) return;
    if (widget.images.length == 1) {
      setState(() {
        _allImagesSameRatio = true;
      });
      return;
    }

    try {
      List<double> aspectRatios = [];

      for (var imageUrl in widget.images) {
        final String fullUrl = widget.controller.getFullImageUrl(imageUrl);
        final Image image = Image.network(fullUrl);

        final Completer<double> completer = Completer<double>();

        image.image
            .resolve(const ImageConfiguration())
            .addListener(
              ImageStreamListener((ImageInfo info, bool _) {
                if (!completer.isCompleted) {
                  final double ratio = info.image.width / info.image.height;
                  completer.complete(ratio);
                }
              }),
            );

        aspectRatios.add(await completer.future);
      }

      // Check if all aspect ratios are similar (within 5% tolerance)
      if (aspectRatios.isEmpty) {
        setState(() {
          _allImagesSameRatio = false;
        });
        return;
      }

      final double firstRatio = aspectRatios[0];
      const double tolerance = 0.05; // 5% tolerance

      final bool allSame = aspectRatios.every((ratio) {
        return (ratio - firstRatio).abs() / firstRatio <= tolerance;
      });

      setState(() {
        _allImagesSameRatio = allSame;
      });
    } catch (e) {
      print('Error checking aspect ratios: $e');
      setState(() {
        _allImagesSameRatio = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool useSameRatio = _allImagesSameRatio ?? false;
    final BoxFit fitMode = useSameRatio ? BoxFit.contain : BoxFit.cover;

    return Container(
      height: useSameRatio ? null : 400,
      constraints: useSameRatio
          ? BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6)
          : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => widget.onImageTap?.call(index),
                  child: Image.network(
                    widget.controller.getFullImageUrl(widget.images[index]),
                    fit: fitMode,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                            size: 50,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
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
                );
              },
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentPage + 1}/${widget.images.length}',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? const Color(0xFF09FACA)
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- FULL SCREEN IMAGE VIEWER ----------
class FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: const Color(0xFF09FACA),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                              size: 80,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 15,
            left: 16,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ),
          if (widget.imageUrls.length > 1)
            Positioned(
              top: 20,
              right: 16,
              child: SafeArea(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      '${_currentIndex + 1} / ${widget.imageUrls.length}',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? const Color(0xFF09FACA)
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
