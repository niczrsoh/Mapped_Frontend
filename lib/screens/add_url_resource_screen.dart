import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../controller/controller/resource_controller.dart';
import '../controller/controller/hashtag_controller.dart';
import 'preview_resource.dart';

class AddUrlResourceScreen extends StatefulWidget {
  const AddUrlResourceScreen({Key? key}) : super(key: key);

  @override
  State<AddUrlResourceScreen> createState() => _AddUrlResourceScreenState();
}

class _AddUrlResourceScreenState extends State<AddUrlResourceScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  late final HashtagEditingController _descriptionController;

  final ResourceController _resourceController = Get.put(ResourceController());

  bool _isLoading = false;
  bool _showPreview = false;
  // bool _isVideo = false; // Logic removed to restore 'Link' behavior

  String? _fetchedTitle;
  String? _fetchedDescription;
  String? _fetchedImage;
  String? _fetchedUrl;

  @override
  void initState() {
    super.initState();
    _descriptionController = HashtagEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  final LinearGradient borderGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x1AFFFFFF),
      Color(0xFA00FFA6),
    ], // Transparent White -> Neon Green
  );

  Future<void> _fetchUrlPreview(String url) async {
    if (url.isEmpty) return;
    if (!url.startsWith('http')) url = 'https://$url';
    setState(() {
      _isLoading = true;
      _showPreview = false;
    });
    try {
      if (url.contains('youtube.com') || url.contains('youtu.be')) {
        await _fetchYoutubeData(url);
      } else {
        setState(() {
          _fetchedTitle = "Web Link";
          _fetchedDescription = url;
          _fetchedImage = null;
          _fetchedUrl = url;
          _isLoading = false;
          _showPreview = true;
        });
      }
    } catch (e) {
      _handleError();
    }
  }

  Future<void> _fetchYoutubeData(String videoUrl) async {
    final oEmbedUrl = Uri.parse(
      'https://www.youtube.com/oembed?url=$videoUrl&format=json',
    );
    try {
      final response = await http.get(oEmbedUrl);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _fetchedTitle = data['title'];
            _fetchedDescription = data['author_name'];
            _fetchedImage = data['thumbnail_url'];
            _fetchedUrl = videoUrl;
            _isLoading = false;
            _showPreview = true;
          });
          // Auto-fill title if empty
          if (_titleController.text.isEmpty) {
            _titleController.text = data['title'] ?? "";
          }
        }
      } else {
        throw Exception('Invalid YouTube URL');
      }
    } catch (e) {
      throw Exception('Network error');
    }
  }

  void _handleError() {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _showPreview = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not fetch link details. Is this a valid URL?'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearUrl() {
    setState(() {
      _urlController.clear();
      _showPreview = false;
      _fetchedTitle = null;
      _fetchedImage = null;
      _fetchedDescription = null;
    });
  }

  void _onNextPressed() {
    // 1. Validation
    if (_fetchedUrl == null && _urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid URL'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String postUrl = _fetchedUrl ?? _urlController.text;
    String finalTitle = _titleController.text.isNotEmpty
        ? _titleController.text
        : (_fetchedTitle ?? 'New Resource');

    // 2. Navigate to Preview
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewResourceScreen(
              title: finalTitle,
              description: _descriptionController.text,
              images: [postUrl],
              // ALWAYS pass 'Link' so ResourceScreen uses LinkThumbnail to display it correctly
              resourceType: 'Link',
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141823),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Resources Search',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // --- URL INPUT ---
                Stack(
                  children: [
                    Container(
                      // 1. Outer Container: Holds the Gradient
                      decoration: BoxDecoration(
                        gradient: borderGradient,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(1.5), // Border Width
                      // 2. Inner Container: Holds the Content
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F222E),
                          borderRadius: BorderRadius.circular(28.5), // 30 - 1.5
                        ),
                        child: TextField(
                          controller: _urlController,
                          style: const TextStyle(color: Colors.white),
                          textInputAction: TextInputAction.go,
                          onSubmitted: (value) => _fetchUrlPreview(value),
                          decoration: InputDecoration(
                            hintText: 'Paste a YouTube URL...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            suffixIcon: _urlController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      color: Color(0xFF00ff9f),
                                    ),
                                    onPressed: () =>
                                        _fetchUrlPreview(_urlController.text),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    if (!_showPreview && _urlController.text.isNotEmpty)
                      Positioned(
                        right: 0,
                        top: -40,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: _clearUrl,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // --- LOADING INDICATOR ---
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFF00ff9f),
                      ),
                    ),
                  ),

                // --- PREVIEW CARD ---
                if (_showPreview) ...[
                  Container(
                    decoration: BoxDecoration(
                      gradient: borderGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(1.5), // Border Width
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F222E),
                        borderRadius: BorderRadius.circular(14.5),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child:
                                _fetchedImage != null &&
                                    _fetchedImage!.isNotEmpty
                                ? Image.network(
                                    _fetchedImage!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      height: 200,
                                      color: Colors.grey[800],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 200,
                                    width: double.infinity,
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.link,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              _fetchedTitle ?? 'Link Content',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // --- TITLE CONTAINER ---
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: borderGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(1.5), // Border Width
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F222E),
                      borderRadius: BorderRadius.circular(18.5),
                    ),
                    child: TextField(
                      controller: _titleController,
                      maxLines: 1,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Title",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- DESCRIPTION CONTAINER ---
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 120),
                  decoration: BoxDecoration(
                    gradient: borderGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(1.5), // Border Width
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F222E),
                      borderRadius: BorderRadius.circular(18.5),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Description ... #hashtag",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- NEXT BUTTON ---
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: _onNextPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB0B3C7),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
