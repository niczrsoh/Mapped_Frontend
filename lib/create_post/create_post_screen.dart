import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped_frontend/services/api_service.dart';
import 'dart:io';
import 'dart:async';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'create_post_controller.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final CreatePostController controller = Get.put(CreatePostController());
  Worker? _postSuccessWorker;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Listen for post success
    _postSuccessWorker = ever(controller.postSuccess, (success) {
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _postSuccessWorker?.dispose();
    super.dispose();
  }

  String _getAvatarUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return "${_apiService.baseUrl}/$path";
  }

  void _showVideoLinkDialog() {
    TextEditingController linkController = TextEditingController();
    bool isDialogOpen = true;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF252836),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'dialog_video_title'.tr(),
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
                hintText: 'dialog_video_hint'.tr(),
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
                  borderSide: const BorderSide(
                    color: Color(0xFF09FACA),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'dialog_video_example'.tr(),
              style: GoogleFonts.roboto(fontSize: 12, color: Colors.white54),
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
              'cancel'.tr(),
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
              'add'.tr(),
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
        return _buildPreviewMode(context);
      } else {
        return _buildEditMode(context);
      }
    });
  }

  // EDIT MODE - Where user creates the post
  Widget _buildEditMode(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D29),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'create_post_title_dashboard'.tr(),
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
                  hintText: 'create_post_hint_input'.tr(),
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
            Obx(
              () => _buildActionRow(
                buttonLabel: 'next'.tr(),
                onButtonTap: controller.previewPost,
                isLoading: false,
                disableNext: !controller.hasContent.value,
              ),
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
                      'lbl_images_count'.tr(
                        namedArgs: {
                          'current': controller.selectedImages.length
                              .toString(),
                          'max': CreatePostController.maxImages.toString(),
                        },
                      ),
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
  Widget _buildPreviewMode(BuildContext context) {
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
          'create_post_title_dashboard'.tr(),
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
                  if (controller.textController.text.trim().isNotEmpty)
                    Text(
                      controller.textController.text,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),

                  if (controller.textController.text.trim().isEmpty &&
                      (controller.selectedImages.isNotEmpty ||
                          controller.videoUrl.value.isNotEmpty))
                    Text(
                      'create_post_lbl_shared_media'.tr(),
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Images Slider (Preview Mode)
                  if (controller.selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildImageSlider(),
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
                buttonLabel: 'create_post_btn_post'.tr(),
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
    bool disableNext = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSmallIcon(
              icon: Icons.camera_alt,
              label: 'camera'.tr(),
              onTap: disableMedia ? null : controller.pickImageFromCamera,
            ),
            const SizedBox(width: 30),
            _buildSmallIcon(
              icon: Icons.image,
              label: 'gallery'.tr(),
              onTap: disableMedia ? null : controller.pickImageFromGallery,
            ),
            const SizedBox(width: 30),
            _buildSmallIcon(
              icon: Icons.link,
              label: 'lbl_url'.tr(),
              onTap: disableMedia
                  ? null
                  : () {
                      // Show Input Dialog
                      TextEditingController linkController =
                          TextEditingController();
                      Get.defaultDialog(
                        title: 'dialog_video_title'.tr(),
                        titleStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                        ),
                        content: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: linkController,
                            decoration: InputDecoration(
                              hintText: 'dialog_video_hint'.tr(),
                            ),
                          ),
                        ),
                        textConfirm: 'add'.tr(),
                        textCancel: 'cancel'.tr(),
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
          onPressed: (isLoading || disableNext) ? null : onButtonTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF09FACA),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[700],
            disabledForegroundColor: Colors.grey[500],
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

  // Image Slider Widget for Preview Mode
  Widget _buildImageSlider() {
    return FutureBuilder<bool>(
      future: _checkIfAllImagesSameRatio(),
      builder: (context, snapshot) {
        final bool useSameRatio = snapshot.data ?? false;
        final BoxFit fitMode = useSameRatio ? BoxFit.contain : BoxFit.cover;

        return StatefulBuilder(
          builder: (context, setState) {
            int currentPage = 0;
            final PageController pageController = PageController();

            return Container(
              height: useSameRatio ? null : 400,
              constraints: useSameRatio
                  ? BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    )
                  : null,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black,
              ),
              child: Stack(
                children: [
                  // Image PageView
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: PageView.builder(
                      controller: pageController,
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      itemCount: controller.selectedImages.length,
                      itemBuilder: (context, index) {
                        final file = controller.selectedImages[index];
                        return kIsWeb
                            ? Image.network(
                                file.path,
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
                              )
                            : Image.file(
                                File(file.path),
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
                              );
                      },
                    ),
                  ),

                  // Page Counter (if multiple images)
                  if (controller.selectedImages.length > 1)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'forum_image_counter'.tr(
                            namedArgs: {
                              'current': (currentPage + 1).toString(),
                              'total': controller.selectedImages.length
                                  .toString(),
                            },
                          ),
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                  // Dot Indicators (if multiple images)
                  if (controller.selectedImages.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          controller.selectedImages.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentPage == index
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
          },
        );
      },
    );
  }

  // Helper method to check if all images have the same aspect ratio
  Future<bool> _checkIfAllImagesSameRatio() async {
    if (controller.selectedImages.isEmpty) return false;
    if (controller.selectedImages.length == 1) return true;

    try {
      List<double> aspectRatios = [];

      for (var file in controller.selectedImages) {
        final Image image = kIsWeb
            ? Image.network(file.path)
            : Image.file(File(file.path));

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
      if (aspectRatios.isEmpty) return false;

      final double firstRatio = aspectRatios[0];
      const double tolerance = 0.05; // 5% tolerance

      return aspectRatios.every((ratio) {
        return (ratio - firstRatio).abs() / firstRatio <= tolerance;
      });
    } catch (e) {
      print('Error checking aspect ratios: $e');
      return false; // Default to fixed ratio if error occurs
    }
  }
}
