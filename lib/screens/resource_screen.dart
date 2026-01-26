import 'package:flutter/material.dart';
// Assuming 'create_resource_post_scren.dart' exists and is correct
import 'package:mapped_frontend/screens/create_resource_post_screen.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({Key? key}) : super(key: key);

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  String selectedFilter = 'All';

  // --- Common Styles and Constants ---
  final LinearGradient customGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x1AFFFFFF), Color(0xFA00FFA6)],
  );

  static const double borderThickness = 1.5;
  static const Color innerCardBackgroundColor = Color(0xFF252836);
  static const Color filterChipSolidColor = Color(0xFF3d4154);
  static const Color accentColor = Color(0xFF00ff9f); // Green/Cyan accent color

  final List<Map<String, dynamic>> resources = [
    {
      'title': 'White Belt Poomsae',
      'subtitle': 'White Belt Poomsae',
      'thumbnail': 'assets/images/resource1.png',
      'type': 'image',
    },
    {
      'title': 'Training Sekolah Parit ',
      'subtitle': 'Training video',
      'thumbnail': 'assets/images/resource2.png',
      'type': 'video',
    },
    {
      'title': 'Poomsae for Black Belt',
      'subtitle': 'Pooamsae Belt',
      'thumbnail': 'assets/images/resource3.png',
      'type': 'image',
    },
    {
      'title': 'Side Kick upper',
      'subtitle': 'Video Side Kick',
      'thumbnail': 'assets/images/resource4.png',
      'type': 'image',
    },
  ];

  // Helper function to filter resources based on selectedFilter
  List<Map<String, dynamic>> get _filteredResources {
    if (selectedFilter == 'All') {
      return resources;
    }
    // Convert chip label ("Images") to resource type key ("image")
    String expectedType = selectedFilter.toLowerCase().replaceAll('s', '');

    return resources.where((resource) {
      return resource['type'] == expectedType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayedResources = _filteredResources;

    return Scaffold(
      backgroundColor: const Color(0xFF1a1d2e),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
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

              // Resources Title
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

              // Search bar with Gradient Border
              _buildSearchBar(),
              const SizedBox(height: 20),

              // Filter chips
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

              // Resources list
              Expanded(
                child: ListView.builder(
                  itemCount: displayedResources.length,
                  itemBuilder: (context, index) {
                    return _buildResourceCard(displayedResources[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // --- Floating Action Button with Circular Gradient Style ---
      floatingActionButton: Container(
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
      ),
    );
  }

  // --- Helper Widgets ---

  // Search Bar with Gradient Border
  Widget _buildSearchBar() {
    const double searchBarRadius = 30.0;

    return Container(
      // 1. Outer Container (Gradient Border)
      decoration: BoxDecoration(
        gradient: customGradient,
        borderRadius: BorderRadius.circular(searchBarRadius),
      ),
      padding: const EdgeInsets.all(borderThickness),

      // 2. Inner Container (Search Bar Body)
      child: Container(
        decoration: BoxDecoration(
          color: innerCardBackgroundColor,
          borderRadius: BorderRadius.circular(
            searchBarRadius - borderThickness,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),

        child: const TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search images, videos, links...',
            hintStyle: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            suffixIcon: Icon(Icons.search, color: Colors.white),
            contentPadding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  // Filter Chip (Maintains background, changes text color on select)
  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          // Background color is ALWAYS the solid default color
          color: filterChipSolidColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            // Text color is green/cyan when selected
            color: isSelected ? accentColor : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Resource Card (Gradient Border)
  Widget _buildResourceCard(Map<String, dynamic> resource) {
    const double cardRadius = 20.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      // 1. Outer Container (Gradient Border)
      decoration: BoxDecoration(
        gradient: customGradient,
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      padding: const EdgeInsets.all(borderThickness),

      // 2. Inner Container (Card Body)
      child: Container(
        padding: const EdgeInsets.all(16.0 - borderThickness),
        decoration: BoxDecoration(
          color: innerCardBackgroundColor,
          borderRadius: BorderRadius.circular(cardRadius - borderThickness),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (resource['thumbnail'] != null)
                      Image.asset(
                        resource['thumbnail'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[800],
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.white,
                          ),
                        ),
                      )
                    else
                      const Center(
                        child: Icon(Icons.image, color: Colors.white, size: 28),
                      ),

                    // Video Play Icon Overlay
                    if (resource['type'] == 'video')
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

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resource['subtitle'],
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
