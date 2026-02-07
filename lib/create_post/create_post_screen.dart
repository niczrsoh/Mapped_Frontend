import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'create_post_controller.dart';

class CreatePostScreen extends StatelessWidget {
  CreatePostScreen({super.key});
  final CreatePostController controller = Get.put(CreatePostController());

  String _getAvatarUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return "${controller.baseUrl}/$path";
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show preview mode or edit mode
      if (controller.showPreview.value) {
        return _buildPreviewMode();
      } else {
        return _buildEditMode();
      }
    });
  }

  // EDIT MODE - Where user creates the post
  Widget _buildEditMode() {
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
          'Forum Dashboard',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Obx(
                  () => CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: controller.userAvatar.value.isNotEmpty
                        ? NetworkImage(
                            _getAvatarUrl(controller.userAvatar.value),
                          )
                        : null,
                    child: controller.userAvatar.value.isEmpty
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Obx(
                  () => Text(
                    controller.userName.value,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF252836),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF09FACA).withOpacity(0.3),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: controller.textController,
                maxLines: 8,
                maxLength: 2000,
                style: GoogleFonts.roboto(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'What\'s on your mind?',
                  hintStyle: GoogleFonts.roboto(color: Colors.white54),
                  border: InputBorder.none,
                  counterStyle: GoogleFonts.roboto(
                    color: Colors.white54,
                  ), // Style the 0/2000 text
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Combined Row: Media Icons (Left) + Next Button (Right)
            _buildActionRow(
              buttonLabel: 'Next',
              onButtonTap: controller.previewPost,
              isLoading: false,
            ),

            const SizedBox(height: 20),

            // Image Counter and Preview
            Obx(() {
              if (controller.selectedImages.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Counter
                    Text(
                      'Images: ${controller.selectedImages.length}/${CreatePostController.maxImages}',
                      style: GoogleFonts.roboto(
                        color:
                            controller.selectedImages.length >=
                                CreatePostController.maxImages
                            ? Colors.orange
                            : Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Image Preview
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.selectedImages.length,
                        itemBuilder: (context, index) {
                          final file = controller.selectedImages[index];
                          return Stack(
                            children: [
                              Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white12,
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: kIsWeb
                                      ? Image.network(
                                          file.path,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(file.path),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              // Remove Button (X)
                              Positioned(
                                top: 4,
                                right: 16,
                                child: GestureDetector(
                                  onTap: () => controller.removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            Obx(() {
              if (controller.videoUrl.value.isNotEmpty &&
                  controller.ytPlayerController != null) {
                return _buildVideoPlayer(isEditable: true);
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  // PREVIEW MODE - Where user sees preview before posting
  Widget _buildPreviewMode() {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D29),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: controller.backToEdit,
        ),
        title: Text(
          'Forum Dashboard',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                  Row(
                    children: [
                      Obx(
                        () => CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey[800],
                          backgroundImage:
                              controller.userAvatar.value.isNotEmpty
                              ? NetworkImage(
                                  _getAvatarUrl(controller.userAvatar.value),
                                )
                              : null,
                          child: controller.userAvatar.value.isEmpty
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => Text(
                                controller.userName.value,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              'Just now',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Content
                  Text(
                    controller.textController.text,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Images Stack
                  if (controller.selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Column(
                      children: controller.selectedImages.map((file) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb
                                ? Image.network(
                                    file.path,
                                    width: double.infinity,
                                    fit: BoxFit.fitWidth,
                                  )
                                : Image.file(
                                    File(file.path),
                                    width: double.infinity,
                                    fit: BoxFit.fitWidth,
                                  ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  Obx(() {
                    if (controller.videoUrl.value.isNotEmpty &&
                        controller.ytPlayerController != null) {
                      return _buildVideoPlayer(isEditable: false);
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => _buildActionRow(
                buttonLabel: 'Post',
                onButtonTap: controller.submitPost,
                isLoading: controller.isPosting.value,
                disableMedia: controller.isPosting.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE ROW ---
  Widget _buildVideoPlayer({required bool isEditable}) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Stack(
        children: [
          // The Player
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: YoutubePlayer(
              controller: controller.ytPlayerController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: const Color(0xFF09FACA),
              progressColors: const ProgressBarColors(
                playedColor: Color(0xFF09FACA),
                handleColor: Color(0xFF09FACA),
              ),
            ),
          ),

          // Close Button (Only in Edit Mode)
          if (isEditable)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: controller.removeVideo,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 18, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required String buttonLabel,
    required VoidCallback onButtonTap,
    required bool isLoading,
    bool disableMedia = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSmallIcon(
              icon: Icons.camera_alt,
              label: 'Camera',
              onTap: disableMedia ? null : controller.pickImageFromCamera,
            ),
            const SizedBox(width: 30),
            _buildSmallIcon(
              icon: Icons.image,
              label: 'Gallery',
              onTap: disableMedia ? null : controller.pickImageFromGallery,
            ),
            const SizedBox(width: 30),
            _buildSmallIcon(
              icon: Icons.link,
              label: 'URL Link',
              onTap: disableMedia
                  ? null
                  : () {
                      // Show Input Dialog
                      TextEditingController linkController =
                          TextEditingController();
                      Get.defaultDialog(
                        title: "Add Video Link",
                        titleStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                        ),
                        content: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: linkController,
                            decoration: const InputDecoration(
                              hintText: "Paste YouTube URL here",
                            ),
                          ),
                        ),
                        textConfirm: "Add",
                        textCancel: "Cancel",
                        confirmTextColor: Colors.white,
                        buttonColor: const Color(0xFF09FACA),
                        onConfirm: () {
                          controller.addVideoLink(linkController.text);
                        },
                      );
                    },
            ),
          ],
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: isLoading ? null : onButtonTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF09FACA),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 2,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  buttonLabel,
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSmallIcon({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: onTap == null ? Colors.white24 : const Color(0xFF09FACA),
            size: 24,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 11,
              color: onTap == null ? Colors.white24 : Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
