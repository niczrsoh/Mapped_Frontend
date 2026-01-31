import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/controller/comment_controller.dart';
import '../controller/controller/forum_controller.dart' ;

class CommentsScreen extends StatelessWidget {
  final ForumPost post;
  CommentsScreen({super.key, required this.post});

  final CommentsController controller = Get.put(CommentsController());
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    controller.loadComments(post.id);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D29),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Comments',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF09FACA)),
                );
              }

              if (controller.comments.isEmpty) {
                return Center(
                  child: Text(
                    'No comments yet. Be the first!',
                    style: GoogleFonts.roboto(color: Colors.white54, fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.comments.length,
                itemBuilder: (context, index) {
                  final comment = controller.comments[index];
                  return _buildCommentCard(comment);
                },
              );
            }),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

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
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: Colors.white,
                  ),
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: commentController,
              style: GoogleFonts.roboto(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                hintStyle: GoogleFonts.roboto(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: const Color(0xFF09FACA).withOpacity(0.3),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(() => GestureDetector(
                onTap: controller.isPosting.value
                    ? null
                    : () {
                        if (commentController.text.isNotEmpty) {
                          controller.addComment(post.id, commentController.text);
                          commentController.clear();
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF09FACA), Color(0xFF0D7C7C)],
                    ),
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
              )),
        ],
      ),
    );
  }
}