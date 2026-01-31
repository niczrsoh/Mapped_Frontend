import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
import '../controller/controller/hashtag_controller.dart';
import 'camera_ui_resorce.dart';
import 'add_galery_resource.dart';
import 'add_url_resource_screen.dart';
import 'preview_resource.dart';

class CreatePostScreen extends StatefulWidget {
  final List<String>? preSelectedImages;

  const CreatePostScreen({Key? key, this.preSelectedImages}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final HashtagEditingController _titleController = HashtagEditingController();
  final HashtagEditingController _descriptionController =
      HashtagEditingController();

  List<String> _selectedGalleryImages = [];
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedImages != null &&
        widget.preSelectedImages!.isNotEmpty) {
      _selectedGalleryImages.addAll(widget.preSelectedImages!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CustomCameraScreen()),
    );

    if (result != null && result is String) {
      setState(() {
        _selectedGalleryImages.add(result);
      });
    }
  }

  void _onNextPressed() {
    if (_titleController.text.trim().isEmpty &&
        _descriptionController.text.trim().isEmpty &&
        _selectedGalleryImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add content before continuing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewResourceScreen(
              title: _titleController.text,
              description: _descriptionController.text,
              images: _selectedGalleryImages,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final LinearGradient borderGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x1AFFFFFF), Color(0xFA00FFA6)],
    );
    const double borderThickness = 1.5;

    return Scaffold(
      backgroundColor: const Color(0xFF141823),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- HEADER ----------------
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
                    'Resource Dashboard',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ---------------- USER INFO ----------------
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.black54),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Lieyza Wahab',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ---------------- SCROLLABLE AREA ----------------
              // We use Expanded to fill the remaining screen space
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 1. TITLE INPUT
                      Container(
                        width: double.infinity,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: borderGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(borderThickness),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F222E),
                            borderRadius: BorderRadius.circular(
                              20 - borderThickness,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _titleController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Title",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2. DESCRIPTION INPUT
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 180),
                        decoration: BoxDecoration(
                          gradient: borderGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(borderThickness),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F222E),
                            borderRadius: BorderRadius.circular(
                              20 - borderThickness,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _descriptionController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Description ...",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),

                      // 3. IMAGE PREVIEW (Conditionally Visible)
                      // When this renders, it naturally pushes the buttons down
                      if (_selectedGalleryImages.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildGalleryPreview(),
                      ],

                      const SizedBox(
                        height: 30,
                      ), // Spacing between content and buttons
                      // ---------------- BOTTOM ACTIONS (MOVED INSIDE) ----------------
                      // Now these are part of the scrollable list
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Camera
                          _buildActionIcon(
                            Icons.camera_alt_outlined,
                            'Camera',
                            _openCamera,
                          ),

                          // Gallery
                          _buildActionIcon(
                            Icons.image_outlined,
                            'Gallery',
                            () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddGalleryResourceScreen(
                                        initialSelected: _selectedGalleryImages,
                                      ),
                                ),
                              );
                              if (result != null && result is List<String>) {
                                setState(() {
                                  _selectedGalleryImages = result;
                                  _currentImageIndex = 0;
                                });
                              }
                            },
                          ),

                          // Url Link
                          _buildActionIcon(Icons.link, 'Url Link', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AddUrlResourceScreen(),
                              ),
                            );
                          }),

                          // Next Button
                          GestureDetector(
                            onTap: _onNextPressed,
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB0B3C7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Next',
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

                      // Extra padding at the very bottom for better scrolling experience
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- RESTORED ORIGINAL PREVIEW STYLE ---
  Widget _buildGalleryPreview() {
    double screenWidth = MediaQuery.of(context).size.width - 40;

    return Column(
      children: [
        Container(
          height: screenWidth, // Fixed Square Size
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _selectedGalleryImages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? Image.network(
                            _selectedGalleryImages[index],
                            fit: BoxFit.contain, // Maintain Aspect Ratio
                            width: double.infinity,
                          )
                        : Image.file(
                            File(_selectedGalleryImages[index]),
                            fit: BoxFit.contain, // Maintain Aspect Ratio
                            width: double.infinity,
                          ),
                  );
                },
              ),
              // Close Button (Top Right)
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGalleryImages.removeAt(_currentImageIndex);
                      if (_currentImageIndex >= _selectedGalleryImages.length &&
                          _currentImageIndex > 0) {
                        _currentImageIndex = _selectedGalleryImages.length - 1;
                        if (_selectedGalleryImages.isNotEmpty) {
                          _pageController.jumpToPage(_currentImageIndex);
                        }
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Dots Indicator
        if (_selectedGalleryImages.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _selectedGalleryImages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentImageIndex == index ? 8 : 6,
                height: _currentImageIndex == index ? 8 : 6,
                decoration: BoxDecoration(
                  color: _currentImageIndex == index
                      ? const Color(0xFF00ff9f)
                      : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF00ff9f), size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
