import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'resource_model.dart';
import 'resource_controller.dart'; // Import to access baseUrl

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

  // Access controller to get the baseUrl
  final ResourceController resourceController = Get.find<ResourceController>();

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
    _initializeVideo();
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
          'Resource Detail',
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
                              : "Unknown User",
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
                  // PIN BUTTON
                  Obx(
                    () => IconButton(
                      icon: Icon(
                        widget.resource.isPinned.value
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        color: widget.resource.isPinned.value
                            ? const Color(0xFF09FACA)
                            : Colors.white54,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      onPressed: () => _showPinConfirmationDialog(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // REPORT BUTTON
                  Obx(
                    () => IconButton(
                      icon: Icon(
                        widget.resource.isReported.value
                            ? Icons.flag
                            : Icons.flag_outlined,
                        color: widget.resource.isReported.value
                            ? Colors.red
                            : Colors.white54,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      onPressed: () => _showReportDialog(),
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
                      fontWeight: FontWeight.w700, // Bold to make it stand out
                      color: Colors.white,
                    ),
                  ),
                ),

              // 3. Content
              Text(
                _getContentWithoutTags(widget.resource.content),
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
    // We check if controller is NOT null to prevent crashes
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
    // 2. IMAGE GALLERY
    else if (widget.resource.images.isNotEmpty) {
      return Container(
        height: 400,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: PageView.builder(
                controller: _imagePageController,
                onPageChanged: (index) => currentImageIndex.value = index,
                itemCount: widget.resource.images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    // Use helper to fix relative URLs
                    _getFixedUrl(widget.resource.images[index]),
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const Center(
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
                            "Image not found",
                            style: TextStyle(color: Colors.white24),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Page Indicator
            if (widget.resource.images.length > 1)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(
                    () => Text(
                      '${currentImageIndex.value + 1}/${widget.resource.images.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    } else if (widget.resource.videoUrl != null && _youtubeController == null) {
      // Fallback if video URL exists but ID extraction failed
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
                "Could not load video: ${widget.resource.videoUrl}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ========== PIN CONFIRMATION DIALOG ==========
  void _showPinConfirmationDialog() {
    bool currentlyPinned = widget.resource.isPinned.value;

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
                ? "Do you want to unpin this resource?"
                : "Do you want to pin this resource?",
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
                    resourceController.togglePin(widget.resource);
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

  // ========== REPORT DIALOG ==========
  void _showReportDialog() {
    if (!resourceController.canReportResource(widget.resource)) {
      Get.snackbar(
        "Info",
        "You have already reported this resource.",
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
      );
      return;
    }

    resourceController.resetReportState();

    // Step 1: Show reason selection
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
                children: resourceController.reportReasons.map((reason) {
                  return Obx(() {
                    final isSelected =
                        resourceController.selectedReason.value == reason;
                    return GestureDetector(
                      onTap: () =>
                          resourceController.selectReportReason(reason),
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
                      backgroundColor:
                          resourceController.selectedReason.value.isEmpty
                          ? Colors.grey
                          : const Color(0xFF00FFA3),
                    ),
                    onPressed: resourceController.selectedReason.value.isEmpty
                        ? null
                        : () {
                            Get.back();
                            _showReportConfirmationDialog();
                          },
                    child: const Text(
                      "NEXT",
                      style: TextStyle(color: Colors.black),
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

  // ========== REPORT CONFIRMATION DIALOG ==========
  void _showReportConfirmationDialog() {
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
                resourceController.selectedReason.value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                resourceController.getReasonDefinition(
                  resourceController.selectedReason.value,
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
                      value: resourceController.isReportConfirmed.value,
                      activeColor: const Color(0xFF007AFF),
                      onChanged: (val) => resourceController
                          .toggleReportConfirmation(val ?? false),
                    ),
                    Expanded(
                      child: Text(
                        "I have confirmed to report this resource as ${resourceController.selectedReason.value.toLowerCase()}",
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
                    onPressed: resourceController.isReportConfirmed.value
                        ? () async {
                            Get.back();
                            final success = await resourceController
                                .submitReport(widget.resource);
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

  // ========== REPORT SUCCESS DIALOG ==========
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
                "You have successfully reported the resource",
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
