import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'create_resource.dart';
//import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../controller/controller/resource_controller.dart';

class SocialFeedScreen extends StatefulWidget {
  final Map<String, dynamic>? resourceData;

  const SocialFeedScreen({Key? key, this.resourceData}) : super(key: key);

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  // Connect to the controller
  final ResourceController _controller = Get.isRegistered<ResourceController>()
      ? Get.find<ResourceController>()
      : Get.put(ResourceController());

  @override
  void initState() {
    super.initState();
    // Only fetch fresh data if we are NOT viewing a specific post
    if (widget.resourceData == null) {
      _controller.fetchResources();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we are in "Detail Mode" (Single Post) or "Feed Mode"
    final bool isDetailMode = widget.resourceData != null;

    return Scaffold(
      backgroundColor: const Color(0xFF141823),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141823),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Resources',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          // Only show "Post" button if we are in the main feed
          if (!isDetailMode)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePostScreen(),
                  ),
                ).then((_) {
                  _controller.fetchResources();
                });
              },
              child: const Text(
                'Post',
                style: TextStyle(
                  color: Color(0xFF00ff9f),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: isDetailMode
          ? _buildDetailView() // Show single passed post immediately
          : _buildFeedView(), // Show reactive feed from controller
    );
  }

  // --- VIEW FOR SINGLE POST (Clicked from Resources Screen or Just Created) ---
  Widget _buildDetailView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PostCard(
          key: ObjectKey(widget.resourceData),
          post: widget.resourceData!,
        ),
      ],
    );
  }

  // --- VIEW FOR FEED (Main List) ---
  Widget _buildFeedView() {
    return Obx(() {
      if (_controller.loading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF00ff9f)),
        );
      }

      if (_controller.resourceList.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () async {
          await _controller.fetchResources();
        },
        color: const Color(0xFF00ff9f),
        backgroundColor: const Color(0xFF1F222E),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _controller.resourceList.length,
          cacheExtent: 1000,
          itemBuilder: (context, index) {
            final post = _controller.resourceList[index];
            return PostCard(key: ObjectKey(post), post: post);
          },
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_clear_outlined, size: 60, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => _controller.fetchResources(),
            child: const Text(
              'Tap to Refresh',
              style: TextStyle(color: Color(0xFF00ff9f)),
            ),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late YoutubePlayerController _controller;
  bool _isYoutube = false;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  // void _initVideoPlayer() {
  //   // API returns 'urls' as List<dynamic>, convert to List<String>
  //   List<dynamic> rawUrls = widget.post['urls'] ?? [];
  //   if (rawUrls.isNotEmpty) {
  //     String url = rawUrls[0].toString();
  //     String? videoId = _convertUrlToId(url);
  //     if (videoId != null) {
  //       _isYoutube = true;
  //       _controller = YoutubePlayerController.fromVideoId(
  //         videoId: videoId,
  //         autoPlay: false,
  //         params: const YoutubePlayerParams(
  //           showControls: true,
  //           showFullscreenButton: true,
  //           mute: false,
  //           strictRelatedVideos: true,
  //           loop: false,
  //         ),
  //       );
  //     }
  //   }
  // }
  void _initVideoPlayer() {
    // API returns 'urls' as List<dynamic>, convert to List<String>
    List<dynamic> rawUrls = widget.post['urls'] ?? [];
    if (rawUrls.isNotEmpty) {
      String url = rawUrls[0].toString();
      // 3. USE NATIVE HELPER TO GET ID
      String? videoId = YoutubePlayer.convertUrlToId(url);

      if (videoId != null) {
        _isYoutube = true;
        // 4. NEW INITIALIZATION SYNTAX
        _controller = YoutubePlayerController(
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

  // String? _convertUrlToId(String url) {
  //   try {
  //     if (url.contains('youtu.be/')) {
  //       return url.split('youtu.be/').last.split('?').first;
  //     } else if (url.contains('v=')) {
  //       return url.split('v=').last.split('&').first;
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  //   return null;
  // }

  // @override
  // void dispose() {
  //   if (_isYoutube) {
  //     _controller.close();
  //   }
  //   _pageController.dispose();
  //   super.dispose();
  // }
  @override
  void dispose() {
    if (_isYoutube) {
      // 5. USE DISPOSE() INSTEAD OF CLOSE()
      _controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MAPPING API DATA TO UI
    // Ensure we handle both 'author' and 'name' keys
    String userName =
        widget.post['author'] ?? widget.post['name'] ?? 'Unknown User';
    String title = widget.post['title'] ?? '';
    String description = widget.post['description'] ?? '';

    String type = widget.post['type'] ?? 'Text';

    // Handle URLs safely
    List<String> urls = [];
    if (widget.post['urls'] != null) {
      urls = List<String>.from(widget.post['urls']);
    } else if (widget.post['url'] != null) {
      urls.add(widget.post['url']);
    }

    bool hasImages = urls.isNotEmpty;

    // Determine if local file logic is needed
    // Logic: If url does NOT start with http, assume local file (from preview screen)
    bool isLocal = false;
    if (urls.isNotEmpty && !urls[0].startsWith('http')) {
      isLocal = true;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            backgroundImage: const AssetImage('assets/images/avatar.png'),
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                const SizedBox(height: 4),
                _buildRichText(description),

                // --- MEDIA BLOCK ---
                if (hasImages && type != 'Text')
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 300,
                        color: Colors.black,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: urls.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return SafeMediaDisplay(
                                  url: urls[index],
                                  isLocal: isLocal,
                                  isYoutube: _isYoutube && index == 0,
                                  youtubeController: (_isYoutube && index == 0)
                                      ? _controller
                                      : null,
                                );
                              },
                            ),
                            if (urls.length > 1)
                              Positioned(
                                bottom: 10,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    urls.length,
                                    (index) => Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      width: _currentImageIndex == index
                                          ? 8
                                          : 6,
                                      height: _currentImageIndex == index
                                          ? 8
                                          : 6,
                                      decoration: BoxDecoration(
                                        color: _currentImageIndex == index
                                            ? const Color(0xFF00ff9f)
                                            : Colors.white.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
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
}

class SafeMediaDisplay extends StatelessWidget {
  final String url;
  final bool isLocal;
  final bool isYoutube;
  final YoutubePlayerController? youtubeController;

  const SafeMediaDisplay({
    Key? key,
    required this.url,
    required this.isLocal,
    required this.isYoutube,
    this.youtubeController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isYoutube && youtubeController != null) {
      return Container(
        color: Colors.black,
        child: YoutubePlayer(
          controller: youtubeController!,
          aspectRatio: 16 / 9,

          onReady: () {
            youtubeController!.unMute(); // Note: we use 'youtubeController' here
            youtubeController!.setVolume(100);
          },
        ),
      );
    }

    if (kIsWeb) {
      return Container(
        width: double.infinity,
        color: Colors.black.withOpacity(0.3),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildErrorContainer(),
        ),
      );
    }

    // Treat as file if explicitly local OR does not start with http
    bool treatAsFile = isLocal || !url.startsWith('http');

    if (treatAsFile) {
      return Container(
        width: double.infinity,
        color: Colors.black.withOpacity(0.3),
        child: Image.file(
          File(url),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildErrorContainer(),
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: Colors.black.withOpacity(0.3),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildErrorContainer(),
      ),
    );
  }

  Widget _buildErrorContainer() {
    return Container(
      width: double.infinity,
      color: Colors.grey[800],
      child: const Center(child: Icon(Icons.broken_image, color: Colors.white)),
    );
  }
}
