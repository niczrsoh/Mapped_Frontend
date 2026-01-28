import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'create_resource.dart';
import 'social_feed_screen.dart';
import '../controller/controller/resource_controller.dart';
import 'package:flutter/foundation.dart';

// ... (Existing Imports and Stateful Widget Structure)

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({Key? key}) : super(key: key);

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final ResourceController _resourceController = Get.put(ResourceController());

  String selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearchActive = false;
  bool _showSearchResults = false;

  final LinearGradient customGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x1AFFFFFF), Color(0xFA00FFA6)],
  );

  static const double borderThickness = 1.5;
  static const Color innerCardBackgroundColor =  Color(0xFF141823);
  static const Color filterChipSolidColor = Color(0xFF3d4154);
  static const Color accentColor = Color(0xFF00ff9f);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resourceController.fetchResources(filterType: 'All');
      _resourceController.fetchTags();
    });

    _searchFocusNode.addListener(() {
      setState(() {
        if (_searchFocusNode.hasFocus) {
          _isSearchActive = true;
          _checkSearchState();
        }
      });
    });

    _searchController.addListener(() {
      _checkSearchState();
      _resourceController.fetchResources(
        filterType: 'All',
        searchQuery: _searchController.text,
        filterTag: _resourceController.selectedTag.value,
      );
    });
  }

  void _checkSearchState() {
    setState(() {
      _showSearchResults =
          _searchController.text.isNotEmpty ||
          _resourceController.selectedTag.value.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    _searchFocusNode.unfocus();
    setState(() {
      _isSearchActive = true;
      _showSearchResults = true;
    });
    _resourceController.fetchResources(
      filterType: 'All',
      searchQuery: query,
      filterTag: _resourceController.selectedTag.value,
    );
  }

  void _onTagSelected(String tag) {
    if (_resourceController.selectedTag.value == tag) {
      _resourceController.selectedTag.value = '';
    } else {
      _resourceController.selectedTag.value = tag;
    }
    _searchFocusNode.unfocus();
    setState(() {
      _isSearchActive = true;
      _checkSearchState();
    });
    _resourceController.fetchResources(
      filterType: 'All',
      searchQuery: _searchController.text,
      filterTag: _resourceController.selectedTag.value,
    );
  }

  void _handleBack() {
    if (_isSearchActive) {
      setState(() {
        _isSearchActive = false;
        _showSearchResults = false;
        _searchController.clear();
        _resourceController.selectedTag.value = '';
        _searchFocusNode.unfocus();
      });
      _resourceController.fetchResources(
        filterType: 'All',
        filterTag: '',
        searchQuery: '',
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _handleFilterChange(String label) {
    setState(() {
      selectedFilter = label;
    });
    String backendType = 'All';
    if (label == 'Images') backendType = 'Image';
    if (label == 'Videos') backendType = 'Video';
    if (label == 'Links') backendType = 'Link';
    _resourceController.fetchResources(filterType: backendType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141823),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: _handleBack,
                  ),
                  const Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (!_isSearchActive) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Resources',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              _buildSearchBar(),

              if (_isSearchActive) ...[
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: SingleChildScrollView(child: _buildPopularTags()),
                ),
                const SizedBox(height: 10),
                if (_showSearchResults) Expanded(child: _buildResourceList()),
              ] else ...[
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 10),
                      _buildFilterChip('Images'),
                      const SizedBox(width: 10),
                      _buildFilterChip('Videos'),
                      const SizedBox(width: 10),
                      _buildFilterChip('Links'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(child: _buildResourceList()),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: !_isSearchActive ? _buildFab() : null,
    );
  }

  Widget _buildResourceList() {
    return Obx(() {
      if (_resourceController.loading.value) {
        return const Center(
          child: CircularProgressIndicator(color: accentColor),
        );
      }
      if (_resourceController.resourceList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_open, size: 50, color: Colors.grey[600]),
              const SizedBox(height: 10),
              Text(
                "No resources found",
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        itemCount: _resourceController.resourceList.length,
        itemBuilder: (context, index) {
          return _buildResourceCard(_resourceController.resourceList[index]);
        },
      );
    });
  }

  Widget _buildPopularTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Popular Tags",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            GestureDetector(
              onTap: _resourceController.fetchTags,
              child: const Text(
                "View All",
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Obx(() {
          if (_resourceController.tagsLoading.value) {
            return const SizedBox(
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: accentColor,
              ),
            );
          }
          return Wrap(
            spacing: 8.0,
            runSpacing: 10.0,
            children: _resourceController.tagList.map((tag) {
              final isSelected = _resourceController.selectedTag.value == tag;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onTagSelected(tag),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? accentColor : const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      //tag.replaceAll('#', ''),
                      tag,
                      style: TextStyle(
                        color: isSelected ? Colors.black87 : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildSearchBar() {
    const double searchBarRadius = 30.0;
    return Container(
      decoration: BoxDecoration(
        gradient: customGradient,
        borderRadius: BorderRadius.circular(searchBarRadius),
      ),
      padding: const EdgeInsets.all(borderThickness),
      child: Container(
        decoration: BoxDecoration(
          color: innerCardBackgroundColor,
          borderRadius: BorderRadius.circular(
            searchBarRadius - borderThickness,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: const TextStyle(color: Colors.white),
          onSubmitted: _performSearch,
          decoration: InputDecoration(
            hintText: 'Search images, videos, links...',
            hintStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            suffixIcon:
                (_searchController.text.isNotEmpty ||
                    _resourceController.selectedTag.value.isNotEmpty)
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      if (_searchController.text.isEmpty) {
                        _resourceController.selectedTag.value = '';
                      }
                      _resourceController.fetchResources(
                        filterType: 'All',
                        searchQuery: _searchController.text,
                        filterTag: _resourceController.selectedTag.value,
                      );
                    },
                  )
                : GestureDetector(
                    onTap: () => _performSearch(_searchController.text),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentColor, Color(0xFF00e68d)],
        ),
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        backgroundColor: const Color(0xFF00ff9f),
        shape: const CircleBorder(
          side: BorderSide(color: Colors.black, width: 2),
        ),
        elevation: 0,
        highlightElevation: 0,
        splashColor: Colors.white.withOpacity(0.2),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => _handleFilterChange(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: filterChipSolidColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? accentColor : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCard(dynamic resource) {
    const double cardRadius = 20.0;
    final String title = resource['title'] ?? 'Untitled';
    final String subtitle =
        (resource['description'] != null &&
            resource['description'].toString().isNotEmpty)
        ? resource['description']
        : (resource['date'] ?? '');
    final String type = resource['type'] ?? 'Text';

    // UPDATED LOGIC: Handle multiple URLs, show only index 0
    String? resourceUrl;
    // Check specific fields first
    if (resource['imageUrls'] != null && (resource['imageUrls'] as List).isNotEmpty) {
      resourceUrl = resource['imageUrls'][0];
    } else if (resource['videoUrls'] != null && (resource['videoUrls'] as List).isNotEmpty) {
      resourceUrl = resource['videoUrls'][0];
    } else if (resource['linkUrl'] != null && resource['linkUrl'].toString().isNotEmpty) {
      resourceUrl = resource['linkUrl'];
    } 
    // Fallback to generic 'urls' or 'url' if backend legacy
    else {
      List<dynamic> urls = resource['urls'] ?? [];
      if (urls.isNotEmpty) {
        resourceUrl = urls[0];
      } else {
        resourceUrl = resource['url'];
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SocialFeedScreen(resourceData: resource),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: customGradient,
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        padding: const EdgeInsets.all(borderThickness),
        child: Container(
          padding: const EdgeInsets.all(16.0 - borderThickness),
          decoration: BoxDecoration(
            color: innerCardBackgroundColor,
            borderRadius: BorderRadius.circular(cardRadius - borderThickness),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF3d4154),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildThumbnailContent(type, resourceUrl),
                      if (type == 'Video')
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: accentColor,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailContent(String type, String? url) {
    if (type == 'Text' || url == null || url.isEmpty) {
      return _DefaultPlaceholder(type: type);
    }
    if (type == 'Link') {
      return LinkThumbnail(url: url, fallbackType: type);
    }
    if (kIsWeb) {
      // WEB LOGIC: Never use File() on web. Treat everything as a URL.
      // If the backend sends a local path like "C:/Users/...", this will fail
      // gracefully (show placeholder) instead of crashing the app.
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _DefaultPlaceholder(type: type),
      );
    } else {
      // MOBILE/DESKTOP LOGIC: Check if it is a web URL or local file
      bool isNetwork = url.startsWith('http');

      if (isNetwork) {
        return Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _DefaultPlaceholder(type: type),
        );
      } else {
        return Image.file(
          File(url),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _DefaultPlaceholder(type: type),
        );
      }
    }
  }
}

class LinkThumbnail extends StatefulWidget {
  final String url;
  final String fallbackType;
  const LinkThumbnail({Key? key, required this.url, required this.fallbackType})
    : super(key: key);

  @override
  State<LinkThumbnail> createState() => _LinkThumbnailState();
}

class _LinkThumbnailState extends State<LinkThumbnail> {
  Future<String?>? _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    _thumbnailFuture = _fetchLinkImage(widget.url);
  }

  Future<String?> _fetchLinkImage(String url) async {
    try {
      if (url.contains('youtube.com') || url.contains('youtu.be')) {
        String? videoId;
        if (url.contains('youtu.be/')) {
          videoId = url.split('youtu.be/').last.split('?').first;
        } else if (url.contains('v=')) {
          videoId = url.split('v=').last.split('&').first;
        }
        if (videoId != null && videoId.isNotEmpty) {
          return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
        }
      }
      if (url.endsWith('.jpg') ||
          url.endsWith('.png') ||
          url.endsWith('.jpeg')) {
        return url;
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        RegExp exp = RegExp(r'<meta property="og:image" content="(.*?)"');
        var match = exp.firstMatch(response.body);
        if (match != null) return match.group(1);
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _thumbnailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _DefaultPlaceholder(type: widget.fallbackType);
        }
        if (snapshot.hasData && snapshot.data != null) {
          return Image.network(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                _DefaultPlaceholder(type: widget.fallbackType),
          );
        }
        return _DefaultPlaceholder(type: widget.fallbackType);
      },
    );
  }
}

class _DefaultPlaceholder extends StatelessWidget {
  final String type;
  const _DefaultPlaceholder({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData iconData = Icons.article;
    if (type == 'Image') iconData = Icons.image;
    if (type == 'Video') iconData = Icons.videocam;
    if (type == 'Link') iconData = Icons.link;
    if (type == 'Text') iconData = Icons.article;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF353A4D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          iconData,
          color: const Color(0xFF00ff9f).withOpacity(0.5),
          size: 30,
        ),
      ),
    );
  }
}
