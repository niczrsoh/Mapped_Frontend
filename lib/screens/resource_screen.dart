import 'package:flutter/material.dart';
import 'package:mapped_frontend/screens/create_resource_post_scren.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({Key? key}) : super(key: key);

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> resources = [
    {
      'title': 'White Belt Poomsae',
      'subtitle': 'White Belt Poomsae',
      'thumbnail': 'assets/white_belt.jpg',
      'type': 'video',
    },
    {
      'title': 'Training Sekolah Parit Raja',
      'subtitle': 'Training video',
      'thumbnail': 'assets/training.jpg',
      'type': 'video',
    },
    {
      'title': 'Poomsae for Black Belt',
      'subtitle': 'Pooamsae Belt',
      'thumbnail': 'assets/black_belt.jpg',
      'type': 'image',
    },
    {
      'title': 'Side Kick upper',
      'subtitle': 'Video Side Kick',
      'thumbnail': 'assets/side_kick.jpg',
      'type': 'video',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF252836),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF00ff9f).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search images, videos, links...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    suffixIcon: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
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
                  itemCount: resources.length,
                  itemBuilder: (context, index) {
                    return _buildResourceCard(resources[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePostScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF00ff9f),
        child: const Icon(
          Icons.add,
          color: Color(0xFF1a1d2e),
          size: 32,
        ),
      ),
    );
  }

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
          color: const Color(0xFF3d4154),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCard(Map<String, dynamic> resource) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00ff9f),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00ff9f).withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
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
              child: Icon(
                resource['type'] == 'video' 
                    ? Icons.play_circle_filled
                    : Icons.image,
                color: const Color(0xFF00ff9f),
                size: 30,
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
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}