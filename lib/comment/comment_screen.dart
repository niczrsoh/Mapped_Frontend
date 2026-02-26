import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/forum/forum_controller.dart';
import 'comment_controller.dart';
import '../forum/forum_model.dart';
import 'comment_model.dart';

class CommentsScreen extends StatefulWidget {
  final ForumPost post;

  const CommentsScreen({super.key, required this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  late final CommentsController controller;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure ForumController is registered before creating CommentsController
    if (!Get.isRegistered<ForumController>()) {
      Get.put(ForumController());
    }

    controller = Get.put(CommentsController());

    // Load comments only once when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadComments(widget.post.id);
    });
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildCommentsList()),
          _buildCommentInput(),
        ],
      ),
    );
  }

  // ========== APP BAR ==========
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1D29),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          try {
            Get.find<ForumController>().loadPosts();
          } catch (e) {
            print("Forum controller not found: $e");
          }
          Navigator.pop(context);
        },
      ),
      title: Text(
        'comment_title_main'.tr(),
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // ========== COMMENTS LIST ==========
  Widget _buildCommentsList() {
    return Obx(() {
      if (controller.isLoading.value && controller.comments.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF09FACA)),
        );
      }

      if (controller.comments.isEmpty) {
        return Center(
          child: Text(
            'comment_empty_state'.tr(),
            style: GoogleFonts.roboto(color: Colors.white54, fontSize: 16),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () =>
            controller.loadComments(widget.post.id, forceReload: true),
        color: const Color(0xFF09FACA),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.comments.length,
          itemBuilder: (context, index) {
            final comment = controller.comments[index];
            return _buildCommentCard(comment);
          },
        ),
      );
    });
  }

  // ========== COMMENT CARD ==========
  Widget _buildCommentCard(Comment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF09FACA).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.grey, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: GoogleFonts.roboto(fontSize: 13, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.timeAgo,
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== COMMENT INPUT ==========
  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF09FACA).withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                style: GoogleFonts.roboto(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'comment_hint_input'.tr(),
                  hintStyle: GoogleFonts.roboto(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1A1D29),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: const Color(0xFF09FACA).withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: const Color(0xFF09FACA).withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Color(0xFF09FACA),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSendComment(),
              ),
            ),
            const SizedBox(width: 12),
            Obx(() => _buildSendButton()),
          ],
        ),
      ),
    );
  }

  // ========== SEND BUTTON ==========
  Widget _buildSendButton() {
    return GestureDetector(
      onTap: controller.isPosting.value ? null : _handleSendComment,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: controller.isPosting.value
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF09FACA), Color(0xFF0D7C7C)],
                ),
          color: controller.isPosting.value ? Colors.grey : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: controller.isPosting.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send, color: Colors.white, size: 20),
      ),
    );
  }

  // ========== HANDLE SEND COMMENT ==========
  void _handleSendComment() async {
    if (!controller.isEligibleToComment) {
      Get.snackbar(
        "comment_snackbar_access_denied_title".tr(),
        "comment_snackbar_access_denied_msg".tr(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.lock, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return; // ⛔ STOP HERE
    }

    if (commentController.text.trim().isNotEmpty &&
        !controller.isPosting.value) {
      final commentText = commentController.text.trim();
      commentController.clear();
      // Unfocus keyboard
      FocusScope.of(context).unfocus();

      // Add comment
      await controller.addComment(widget.post.id, commentText);

      // Show styled success message
      if (controller.comments.isNotEmpty) {
        Get.snackbar(
          "success".tr(),
          "comment_snackbar_success_msg_long".tr(),
          backgroundColor: const Color(0xFF09FACA),
          colorText: Colors.black,
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    }
  }
}
