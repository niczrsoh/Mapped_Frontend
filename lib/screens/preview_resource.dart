import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
//import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../controller/controller/resource_controller.dart';
import 'social_feed_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PreviewResourceScreen extends StatefulWidget {
  final String title;
  final String description;
  final List<String> images;
  final String? resourceType; // 'Image', 'Video', 'Link'

  const PreviewResourceScreen({
    Key? key,
    required this.title,
    required this.description,
    required this.images,
    this.resourceType,
  }) : super(key: key);

  @override
  State<PreviewResourceScreen> createState() => _PreviewResourceScreenState();
}

class _PreviewResourceScreenState extends State<PreviewResourceScreen> {
  late final ResourceController _resourceController;

  bool _isPosting = false;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  YoutubePlayerController? _youtubeController;
  bool _isYoutube = false;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ResourceController>()) {
      _resourceController = Get.find<ResourceController>();
    } else {
      _resourceController = Get.put(ResourceController());
    }
    _initVideoPlayer();
  }

  // void _initVideoPlayer() {
  //   // Check if it's a YouTube link, regardless of whether type is Video or Link
  //   if (widget.images.isNotEmpty) {
  //     String url = widget.images[0];
  //     String? videoId = _convertUrlToId(url);
  //     if (videoId != null) {
  //       _isYoutube = true;
  //       _youtubeController = YoutubePlayerController.fromVideoId(
  //         videoId: videoId,
  //         autoPlay: false,
  //         params: const YoutubePlayerParams(
  //           showControls: true,
  //           showFullscreenButton: true,
  //           mute: false,
  //         ),
  //       );
  //     }
  //   }
  // }
  void _initVideoPlayer() {
    if (widget.images.isNotEmpty) {
      String url = widget.images[0];
      // 3. USE NATIVE HELPER TO GET ID
      String? videoId = YoutubePlayer.convertUrlToId(url);

      if (videoId != null) {
        _isYoutube = true;
        // 4. NEW INITIALIZATION
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            disableDragSeek: false,
            loop: false,
            isLive: false,
            forceHD: false,
            enableCaption: true,
          ),
        );
      }
    }
  }

  String? _convertUrlToId(String url) {
    try {
      if (url.contains('youtu.be/')) {
        return url.split('youtu.be/').last.split('?').first;
      } else if (url.contains('v=')) {
        return url.split('v=').last.split('&').first;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // @override
  // void dispose() {
  //   if (_youtubeController != null) _youtubeController!.close();
  //   super.dispose();
  // }
  @override
  void dispose() {
    // 5. DISPOSE CORRECTLY
    if (_youtubeController != null) {
      _youtubeController!.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handlePost() async {
    if (_isPosting) return;
    await Future.delayed(Duration.zero);
    setState(() => _isPosting = true);

    try {
      String type =
          widget.resourceType ?? (widget.images.isNotEmpty ? 'Image' : 'Text');

      // Sort data into correct fields for backend
      List<String> imageUrls = [];
      List<String> videoUrls = [];
      String linkUrl = "";

      if (type == 'Image')
        imageUrls = widget.images;
      else if (type == 'Video')
        videoUrls = widget.images;
      else if (type == 'Link')
        linkUrl = widget.images.isNotEmpty ? widget.images[0] : "";

      await _resourceController.addResource(
        title: widget.title.isEmpty ? 'New Post' : widget.title,
        description: widget.description,
        type: type,
        imageUrls: imageUrls,
        videoUrls: videoUrls,
        linkUrl: linkUrl,
        author: 'Lieyza Wahab',
      );

      if (_resourceController.success.value) {
        final Map<String, dynamic> localPostData = {
          'title': widget.title.isEmpty ? 'New Post' : widget.title,
          'description': widget.description,
          'type': type,
          'author': 'Lieyza Wahab',
          'date': 'Just now',
          'imageUrls': imageUrls,
          'videoUrls': videoUrls,
          'linkUrl': linkUrl,
          'urls': widget.images,
        };

        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SocialFeedScreen(resourceData: localPostData),
              ),
              (route) => route.isFirst,
            );
          }
        });
      } else {
        if (mounted) {
          setState(() => _isPosting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to post.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141823),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Preview Post',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // PREVIEW
              Expanded(
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, color: Colors.black54),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lieyza Wahab',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (widget.title.isNotEmpty)
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            const SizedBox(height: 4),
                            if (widget.description.isNotEmpty)
                              _buildRichText(widget.description),
                            if (widget.images.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildMediaPreview(),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // POST BUTTON
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _handlePost,
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: _isPosting
                            ? const Color(0xFFB0B3C7).withOpacity(0.5)
                            : const Color(0xFFB0B3C7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: _isPosting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Post',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
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

  Widget _buildRichText(String text) {
    List<TextSpan> spans = [];
    text.split(' ').forEach((word) {
      if (word.startsWith('#')) {
        spans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(
              color: Color(0xFF00ff9f),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(color: Colors.white, height: 1.4),
          ),
        );
      }
    });
    return RichText(
      text: TextSpan(style: const TextStyle(fontSize: 14), children: spans),
    );
  }

  Widget _buildMediaPreview() {
    // 1. YouTube Video (Updated to use Native Player + Fix Sound)
    if (_isYoutube && _youtubeController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        // USE YoutubePlayer DIRECTLY HERE
        child: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: const Color(0xFF00ff9f),
          progressColors: const ProgressBarColors(
            playedColor: Color(0xFF00ff9f),
            handleColor: Color(0xFF00ff9f),
          ),
          // 👇 THIS FIXES THE "NO SOUND" ISSUE
          onReady: () {
            _youtubeController!.unMute();
            _youtubeController!.setVolume(100);
          },
        ),
      );
    }

    // 2. Generic Link Preview (Green Card) - Only if not YouTube and type is Link
    if (widget.resourceType == 'Link' && !_isYoutube) {
      return Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.link, color: Colors.white70, size: 40),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.images[0],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    // 3. Image Gallery (Fallback)
    double screenWidth = MediaQuery.of(context).size.width - 40 - 40 - 12;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: screenWidth,
            width: double.infinity,
            color: Colors.black26,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) =>
                  setState(() => _currentImageIndex = index),
              itemBuilder: (context, index) {
                return SafeMediaDisplay(
                  url: widget.images[index],
                  isLocal: !widget.images[index].startsWith('http'),
                  isYoutube: false,
                );
              },
            ),
          ),
        ),
        if (widget.images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentImageIndex == index ? 8 : 6,
                  height: _currentImageIndex == index ? 8 : 6,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index
                        ? const Color(0xFF00ff9f)
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
