import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:mapped_frontend/admin/admin_controller.dart';
import 'package:mapped_frontend/forum/forum_controller.dart';
import 'package:mapped_frontend/forum/forum_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AdminManageUsersScreen extends StatelessWidget {
  const AdminManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.put(AdminController());
    final ForumController forumController = Get.put(ForumController());

    return Scaffold(
      backgroundColor: const Color(0xFF121421),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "admin_manage_title_dashboard".tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00C7A7),
                      ),
                    );
                  }

                  if (controller.reportedPosts.isEmpty) {
                    return Center(
                      child: Text(
                        "admin_manage_msg_no_reports".tr(),
                        style: const TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.reportedPosts.length,
                    itemBuilder: (context, index) {
                      final post = controller.reportedPosts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildAdminCard(
                          post,
                          controller,
                          forumController,
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== UPDATED: CONFIRMATION DIALOG METHOD ==========
  void _showConfirmDialog({
    required String title,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF252836),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 80,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _actionBtn(
                      "cancel_caps".tr(),
                      const Color(0xFF00C7A7),
                      Colors.black,
                      onTap: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _actionBtn(
                      "ok".tr(),
                      const Color(0xFF00C7A7),
                      Colors.black,
                      onTap: () {
                        Get.back();
                        onConfirm();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    ForumPost post,
    AdminController controller,
    ForumController forumController,
  ) {
    final RxBool isUserBlocked = post.isUserBlocked;

    String displayReason = "admin_manage_reason_default".tr();
    if (post.reports.isNotEmpty) {
      displayReason =
          post.reports[0]['reason'] ?? "admin_manage_reason_unspecified".tr();
    }

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF252836),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: isUserBlocked.value
                    ? const Color(0xFF1F1D2B)
                    : const Color(0xFF4A2B2B),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Text(
                isUserBlocked.value
                    ? "admin_manage_badge_blocked".tr()
                    : "admin_manage_badge_reported".tr(),
                style: TextStyle(
                  color: isUserBlocked.value ? Colors.grey : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage:
                            (post.authorImage != null &&
                                post.authorImage!.isNotEmpty)
                            ? NetworkImage(
                                forumController.getFullImageUrl(
                                  post.authorImage!,
                                ),
                              )
                            : const AssetImage('assets/images/user.png')
                                  as ImageProvider,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.authorName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (isUserBlocked.value)
                            Text(
                              "admin_manage_badge_banned".tr(),
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  if (!isUserBlocked.value) ...[
                    Text(
                      post.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    if (post.videoUrl != null && post.videoUrl!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      PostVideoPlayer(videoUrl: post.videoUrl!),
                    ],
                    if (post.images.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildPostImages(post, forumController),
                    ],
                    const SizedBox(height: 10),
                  ],

                  Text(
                    isUserBlocked.value
                        ? "admin_manage_msg_user_restricted".tr()
                        : "admin_manage_msg_reported_reason".tr(
                            namedArgs: {'reason': displayReason},
                          ),
                    style: TextStyle(
                      color: isUserBlocked.value
                          ? Colors.white54
                          : Colors.redAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (isUserBlocked.value)
                    _actionBtn(
                      "admin_manage_btn_unblock".tr(),
                      const Color(0xFF00C7A7).withOpacity(0.1),
                      const Color(0xFF00C7A7),
                      border: true,
                      onTap: () => _showConfirmDialog(
                        title: "admin_manage_confirm_unblock".tr(),
                        onConfirm: () =>
                            controller.unblockUser(post.authorId ?? ""),
                      ),
                    )
                  else
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _actionBtn(
                                "admin_manage_btn_delete".tr(),
                                Colors.redAccent.withOpacity(0.15),
                                Colors.redAccent,
                                icon: Icons.delete_outline,
                                onTap: () => _showConfirmDialog(
                                  title: "admin_manage_confirm_delete".tr(),
                                  onConfirm: () =>
                                      controller.deletePost(post.id),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _actionBtn(
                                "admin_manage_btn_dismiss".tr(),
                                const Color(0xFF00C7A7).withOpacity(0.15),
                                const Color(0xFF00C7A7),
                                onTap: () => controller.dismissReport(post.id),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Obx(
                          () => _actionBtn(
                            post.isUserBlocked.value
                                ? "admin_manage_btn_unblock".tr()
                                : "admin_manage_btn_block".tr(),
                            post.isUserBlocked.value
                                ? const Color(0xFF00C7A7).withOpacity(0.1)
                                : Colors.transparent,
                            post.isUserBlocked.value
                                ? const Color(0xFF00C7A7)
                                : Colors.redAccent,
                            border: true,
                            onTap: () {
                              final bool isBlocked = post.isUserBlocked.value;
                              _showConfirmDialog(
                                title: isBlocked
                                    ? "admin_manage_confirm_unblock".tr()
                                    : "admin_manage_confirm_block".tr(),
                                onConfirm: () {
                                  if (isBlocked) {
                                    controller.unblockUser(post.authorId ?? "");
                                  } else {
                                    controller.blockUser(post.authorId ?? "");
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostImages(ForumPost post, ForumController controller) {
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
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[800],
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.white54),
              ),
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () => _openImageViewer(
        controller.getFullImageUrl(post.images[0]),
        0,
        post.images.map((img) => controller.getFullImageUrl(img)).toList(),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              controller.getFullImageUrl(post.images[0]),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${post.images.length - 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
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

  Widget _actionBtn(
    String label,
    Color bg,
    Color txt, {
    bool border = false,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(25),
          border: border ? Border.all(color: txt) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: txt, size: 18),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(color: txt, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== VIDEO PLAYER COMPONENT ==========
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
    _initializePlayer();
  }

  void _initializePlayer() {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
      setState(() => _isReady = true);
    } else {
      setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) return const Icon(Icons.error, color: Colors.red);
    if (!_isReady) return const CircularProgressIndicator();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
      ),
    );
  }
}

// ========== FULL SCREEN IMAGE VIEWER ==========
class FullScreenImageViewer extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;
  const FullScreenImageViewer({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            itemCount: imageUrls.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) =>
                InteractiveViewer(child: Image.network(imageUrls[index])),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }
}
