import 'package:flutter/material.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  // --- Constants ---
  static const Color innerCardBackgroundColor = Color(0xFF2A2D3E);
  static const Color accentColor = Color(0xFF00FFB9);
  static const double borderThickness = 1.5;

  final LinearGradient customGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x1AFFFFFF), Color(0xFA00FFA6)],
  );
  // -----------------

  @override
  void initState() {
    super.initState();
    _searchController.text = 'green belt kicks';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Reusable Gradient Border Container Widget ---
  Widget _buildGradientBorderContainer({
    required Widget child,
    required double borderRadius,
    EdgeInsets? margin,
    List<BoxShadow>? shadows,
  }) {
    return Container(
      margin: margin,
      // 1. Outer Container (The Gradient Border)
      decoration: BoxDecoration(
        gradient: customGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows, // Apply custom shadows if provided
      ),
      padding: const EdgeInsets.all(
        borderThickness,
      ), // This space is the border
      // 2. Inner Container (The Actual Card Body)
      child: Container(
        decoration: BoxDecoration(
          color: innerCardBackgroundColor, // Solid dark background
          borderRadius: BorderRadius.circular(borderRadius - borderThickness),
        ),
        child: child,
      ),
    );
  }
  // ------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Note: Filtering logic needs to be implemented to correctly hide/show sections
    // based on `_selectedFilter`. For now, all sections are displayed.

    return Scaffold(
      backgroundColor: const Color(0xFF1A1D2E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Back Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Search Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Search Bar (Now uses Gradient Border Helper) ---
                  _buildGradientBorderContainer(
                    borderRadius: 30,

                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Results for "green belt kicks"',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 16,
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 20, right: 12),
                          child: Icon(Icons.search, color: accentColor),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),

                  // ----------------------------------------------------
                  const SizedBox(height: 20),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Trainees'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Sessions'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Forum'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Results List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trainees Section
                    if (_selectedFilter == 'All' ||
                        _selectedFilter == 'Trainees') ...[
                      _buildSectionTitle('Trainees'),
                      const SizedBox(height: 12),
                      _buildTraineeCard(
                        name: 'Rayyan Firas',
                        belt: 'Green',
                        note: 'Note : Next Blue Belt in 2 criteria',
                        imageUrl: 'https://i.pravatar.cc/150?img=12',
                      ),
                      const SizedBox(height: 12),
                      _buildTraineeCard(
                        name: 'Chan Wei Tian',
                        belt: 'Green',
                        note: 'Note : Next Blue Belt in 3 criteria',
                        imageUrl: 'https://i.pravatar.cc/150?img=47',
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Sessions Section
                    if (_selectedFilter == 'All' ||
                        _selectedFilter == 'Sessions') ...[
                      _buildSectionTitle('Sessions'),
                      const SizedBox(height: 12),
                      _buildSessionCard(
                        title: 'School Pulai Jaya',
                        time: 'Thu 7pm - Hall B',
                        date: '25 July 2025',
                        beltType: 'Green',
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Forum Section
                    if (_selectedFilter == 'All' ||
                        _selectedFilter == 'Forum') ...[
                      _buildSectionTitle('Forum'),
                      const SizedBox(height: 12),
                      _buildForumCard(
                        title: 'How to achieve green belt faster?',
                        replies: '15 replies',
                        // icon not used when showing forum image asset
                        icon: Icons.sports_martial_arts,
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Resources Section
                    if (_selectedFilter == 'All') ...[
                      // Assuming Resources only shows under 'All'
                      _buildSectionTitle('Resources'),
                      const SizedBox(height: 12),
                      _buildResourceCard(
                        title: 'Green Belt Video Poomsae',
                        subtitle: 'Video Poomsae',
                        thumbnailUrl: 'assets/images/resource1.png',
                      ),
                      const SizedBox(height: 40),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          // No gradient border needed here, maintaining existing chip style
          color: isSelected
              ? accentColor.withOpacity(0.2)
              : innerCardBackgroundColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? accentColor : Colors.white.withOpacity(0.7),
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: accentColor,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

  // --- Trainee Card (Now uses Gradient Border Helper) ---
  Widget _buildTraineeCard({
    required String name,
    required String belt,
    required String note,
    required String imageUrl,
  }) {
    return _buildGradientBorderContainer(
      borderRadius: 16,
      margin: const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: const EdgeInsets.all(16.0 - borderThickness),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // removed accentColor border per design request; keep transparent border
                border: Border.all(color: Colors.transparent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF3A3D4E),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      belt,
                      style: const TextStyle(
                        color: accentColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Note
            Expanded(
              flex: 2,
              child: Text(
                note,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ---------------------------------------------------

  // --- Session Card (Now uses Gradient Border Helper) ---
  Widget _buildSessionCard({
    required String title,
    required String time,
    required String date,
    required String beltType,
  }) {
    return _buildGradientBorderContainer(
      borderRadius: 16,

      child: Padding(
        padding: const EdgeInsets.all(18 - borderThickness),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '$time - ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$date - ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: accentColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    beltType,
                    style: const TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Text(
                  ' Belt Session',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  // ----------------------------------------------------

  // --- Forum Card (Now uses Gradient Border Helper) ---
  Widget _buildForumCard({
    required String title,
    required String replies,
    required IconData icon,
  }) {
    return _buildGradientBorderContainer(
      borderRadius: 16,

      child: Padding(
        padding: const EdgeInsets.all(16.0 - borderThickness),
        child: Row(
          children: [
            // Show forum image (local asset) inside the rectangle. Remove green tint/border.
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.transparent, width: 1.0),
                image: const DecorationImage(
                  image: AssetImage('assets/images/forum1.png'),
                  fit: BoxFit.cover,
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Thread - $replies',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ----------------------------------------------------

  // --- Resource Card (Now uses Gradient Border Helper) ---
  Widget _buildResourceCard({
    required String title,
    required String subtitle,
    required String thumbnailUrl,
  }) {
    return _buildGradientBorderContainer(
      borderRadius: 16,

      child: Padding(
        padding: const EdgeInsets.all(16.0 - borderThickness),
        child: Row(
          children: [
            // Thumbnail container: support both network and asset images
            Builder(
              builder: (context) {
                final ImageProvider imageProvider =
                    thumbnailUrl.startsWith('http')
                    ? NetworkImage(thumbnailUrl)
                    : AssetImage(thumbnailUrl);

                return Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor.withOpacity(0.5),
                      width: 1.5,
                    ),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------
}
