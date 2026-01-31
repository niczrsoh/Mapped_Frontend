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

  void _showVideoLinkDialog() {
    TextEditingController linkController = TextEditingController();
    bool isDialogOpen = true;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF252836),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          "Add Video Link",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: linkController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Paste YouTube URL here",
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF09FACA)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF09FACA)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF09FACA), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Example: https://youtube.com/watch?v=VIDEO_ID",
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              isDialogOpen = false;
              Navigator.of(Get.context!).pop();
            },
            child: Text(
              "Cancel",
              style: GoogleFonts.roboto(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (linkController.text.isNotEmpty && isDialogOpen) {
                isDialogOpen = false;
                Navigator.of(Get.context!).pop();
                await Future.delayed(const Duration(milliseconds: 300));
                controller.addVideoLink(linkController.text);
              } else {
                isDialogOpen = false;
                Navigator.of(Get.context!).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF09FACA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Add",
              style: GoogleFonts.roboto(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.showPreview.value) {
        return _buildPreviewMode();
      } else {
        return _buildEditMode();
      }
    });
  }

  Widget _buildEditMode() {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D29),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(Get.context!).pop(),
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
                Obx(() => CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: controller.userAvatar.value.isNotEmpty
                      ? NetworkImage(_getAvatarUrl(controller.userAvatar.value))
                      : null,
                  child: controller.userAvatar.value.isEmpty
                      ? const Icon(Icons.person, color: Colors.white, size: 28)
                      : null,
                )),
                const SizedBox(width: 12),
                Obx(() => Text(
                  controller.userName.value, 
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                )),
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
                  counterStyle: GoogleFonts.roboto(color: Colors.white54),
                ),
              ),
            ),

            const SizedBox(height: 24),

            _buildActionRow(
              buttonLabel: 'Next',
              onButtonTap: controller.previewPost,
              isLoading: false,
            ),

            const SizedBox(height: 20),

            Obx(() {
              if (controller.selectedImages.isNotEmpty) {
                return SizedBox(
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
                );
              }
              return const SizedBox.shrink();
            }),

            Obx(() {
              if (controller.videoUrl.value.isNotEmpty) {
                if (controller.ytPlayerController != null) {
                  return _buildVideoPlayer(isEditable: true);
                } else if (controller.isVideoLoading.value) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF09FACA),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Loading video...',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return _buildVideoPreview(isEditable: true);
                }
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

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
                      Obx(() => CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: controller.userAvatar.value.isNotEmpty
                            ? NetworkImage(_getAvatarUrl(controller.userAvatar.value))
                            : null,
                        child: controller.userAvatar.value.isEmpty
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      )),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => Text(
                              controller.userName.value, 
                              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                            )),
                            Text('Just now', style: GoogleFonts.roboto(fontSize: 12, color: Colors.white54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Text(controller.textController.text, style: GoogleFonts.roboto(fontSize: 14, color: Colors.white, height: 1.5)),
                  const SizedBox(height: 12),
                                    
                  if (controller.selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Column(
                      children: controller.selectedImages.map((file) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb 
                                ? Image.network(file.path, width: double.infinity, fit: BoxFit.fitWidth)
                                : Image.file(File(file.path), width: double.infinity, fit: BoxFit.fitWidth),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  Obx(() {
                    if (controller.videoUrl.value.isNotEmpty) {
                      return _buildVideoPreview(isEditable: false);
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => _buildActionRow(
              buttonLabel: 'Post', 
              onButtonTap: controller.submitPost, 
              isLoading: controller.isPosting.value, 
              disableMedia: controller.isPosting.value
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer({required bool isEditable}) {
    if (controller.ytPlayerController == null) {
      return Container(
        height: 200,
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.white, size: 50),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Stack(
        children: [
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

  Widget _buildVideoPreview({required bool isEditable}) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Stack(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: controller.videoThumbnail.value.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      controller.videoThumbnail.value,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(Icons.videocam, color: Colors.white, size: 50),
                          ),
                        );
                      },
                    ),
                  )
                : const Center(
                    child: Icon(Icons.videocam, color: Colors.white, size: 50),
                  ),
          ),
          
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Video',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
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
              onTap: disableMedia ? null : _showVideoLinkDialog,
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
      )
    );
  }
}