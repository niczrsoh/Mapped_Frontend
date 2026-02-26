import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'resource_model.dart';
import 'resource_controller.dart';
import 'package:easy_localization/easy_localization.dart';

class ResourceDetailScreen extends StatefulWidget {
  final ResourcePost resource;

  const ResourceDetailScreen({Key? key, required this.resource})
    : super(key: key);

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  YoutubePlayerController? _youtubeController;
  PageController? _imagePageController;
  RxInt currentImageIndex = 0.obs;
  bool? _allImagesSameRatio;

  // Access controller to get the baseUrl
  final ResourceController resourceController = Get.find<ResourceController>();

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
    _initializeVideo();
    _checkImageRatios();
  }

  Future<void> _checkImageRatios() async {
    if (widget.resource.images.isEmpty) return;
    if (widget.resource.images.length == 1) {
      setState(() {
        _allImagesSameRatio = true;
      });
      return;
    }

    try {
      List<double> aspectRatios = [];

      for (var imagePath in widget.resource.images) {
        final String fullUrl = _getFixedUrl(imagePath);
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
        _allImagesSameRatio = false; // Default to fixed ratio if error occurs
      });
    }
  }

  void _initializeVideo() {
    if (widget.resource.videoUrl != null &&
        widget.resource.videoUrl!.isNotEmpty) {
      // Clean the URL (remove extra spaces)
      final url = widget.resource.videoUrl!.trim();
      final videoId = YoutubePlayer.convertUrlToId(url);

      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: false,
          ),
        );
      } else {
        print("⚠️ Error: Could not extract YouTube ID from: $url");
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _imagePageController?.dispose();
    super.dispose();
  }

  // Helper to fix image URLs (Relative -> Absolute)
  String _getFixedUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http') || path.startsWith('https')) return path;

    // Remove leading slash if present to avoid double slashes
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return "${resourceController.baseUrl}/$cleanPath";
  }

  // Helper to remove hashtags from the content string for display
  String _getContentWithoutTags(String content) {
    // This Regex finds words starting with '#' and replaces them with empty string
    return content.replaceAll(RegExp(r'#\w+'), '').trim();
  }

  // Open fullscreen image viewer
  void _openImageViewer(int initialIndex) {
    final imageUrls = widget.resource.images
        .map((img) => _getFixedUrl(img))
        .toList();
    Get.to(
      () => FullScreenImageViewer(
        imageUrls: imageUrls,
        initialIndex: initialIndex,
      ),
      transition: Transition.fade,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D29),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.back();
            }
          },
        ),
        title: Text(
          'resource_detail_title'.tr(),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Author Row (Avatar + Name + Pin/Report Buttons)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.resource.authorName.isNotEmpty
                              ? widget.resource.authorName
                              : "unknown_user".tr(),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.resource.timeAgo,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 2. Title
              if (widget.resource.title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    widget.resource.title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),

              // 3. Content
              Text(
                _getContentWithoutTags(widget.resource.content),
                textAlign: TextAlign.justify,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 12),

              // 4. Hashtags
              if (widget.resource.tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: widget.resource.tags.map((tag) {
                    final displayTag = tag.startsWith('#') ? tag : '#$tag';
                    return Text(
                      displayTag,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF09FACA),
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 20),

              // 5. Media Section
              _buildMediaSection(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    // Check if we have an image path
    if (widget.resource.authorImage != null &&
        widget.resource.authorImage!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[800],
        // Use the helper to get the full URL
        backgroundImage: NetworkImage(
          _getFixedUrl(widget.resource.authorImage!),
        ),
        onBackgroundImageError: (_, __) {
          // Fallback if image fails to load
          print("Error loading avatar image");
        },
      );
    } else {
      // Fallback Initials Avatar
      return CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFF09FACA),
        child: Text(
          widget.resource.authorName.isNotEmpty
              ? widget.resource.authorName[0].toUpperCase()
              : '?',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );
    }
  }

  Widget _buildMediaSection() {
    // 1. VIDEO PLAYER
    if (_youtubeController != null) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: YoutubePlayer(
            controller: _youtubeController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: const Color(0xFF09FACA),
            bottomActions: [
              CurrentPosition(),
              ProgressBar(
                isExpanded: true,
                colors: const ProgressBarColors(
                  playedColor: Color(0xFF09FACA),
                  handleColor: Color(0xFF09FACA),
                ),
              ),
              RemainingDuration(),
              FullScreenButton(),
            ],
          ),
        ),
      );
    }
    // 2. IMAGE GALLERY - Single Image
    else if (widget.resource.images.length == 1) {
      return GestureDetector(
        onTap: () => _openImageViewer(0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            _getFixedUrl(widget.resource.images[0]),
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => Container(
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, color: Colors.white24, size: 50),
                    SizedBox(height: 8),
                    Text(
                      "resource_detail_img_not_found".tr(),
                      style: TextStyle(color: Colors.white24),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    // 3. IMAGE GALLERY - Multiple Images (Instagram-style)
    else if (widget.resource.images.length > 1) {
      final bool useSameRatio = _allImagesSameRatio ?? false;
      final BoxFit fitMode = useSameRatio ? BoxFit.contain : BoxFit.cover;

      return Container(
        height: useSameRatio ? null : 400,
        constraints: useSameRatio
            ? BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              )
            : null,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black,
        ),
        child: Stack(
          children: [
            // Image PageView
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: PageView.builder(
                controller: _imagePageController,
                onPageChanged: (index) => currentImageIndex.value = index,
                itemCount: widget.resource.images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _openImageViewer(index),
                    child: Image.network(
                      _getFixedUrl(widget.resource.images[index]),
                      fit: fitMode,
                      errorBuilder: (ctx, err, stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.white24,
                              size: 50,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "resource_detail_img_not_found".tr(),
                              style: TextStyle(color: Colors.white24),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Page Counter Badge (Top Right)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(
                  () => Text(
                    'resource_detail_img_count'.tr(args: [
                      '${currentImageIndex.value + 1}',
                      '${widget.resource.images.length}'
                    ]) ,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Dot Indicators (Bottom Center) - Instagram Style
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.resource.images.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentImageIndex.value == index
                            ? const Color(0xFF09FACA)
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    // 4. Fallback if video URL exists but ID extraction failed
    else if (widget.resource.videoUrl != null && _youtubeController == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "resource_detail_video_error".tr(args: [widget.resource.videoUrl ?? ""]),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ========== FULL SCREEN IMAGE VIEWER ==========
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
          // Image PageView with Zoom
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
                      return Center(
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
                              'resource_detail_viewer_error'.tr(),
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

          // Close Button - LEFT
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

          // Page Counter (if multiple images) - RIGHT
          if (widget.imageUrls.length > 1)
            Positioned(
              top: 20,
              right: 16,
              child: SafeArea(
                child: Container(
                  height: 48, // Match the IconButton height
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
                      'resource_detail_img_count'.tr(args: [
                        '${_currentIndex + 1}',
                        '${widget.imageUrls.length}'
                      ]),
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

          // Dot Indicators (if multiple images)
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
