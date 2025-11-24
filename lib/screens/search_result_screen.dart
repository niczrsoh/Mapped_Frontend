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
    double? minHeight,
  }) {
    return Container(
      width: double.infinity, // 🔧 FIX: Ensure full width for all cards
      margin: margin,
      decoration: BoxDecoration(
        gradient: customGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows,
      ),
      padding: const EdgeInsets.all(borderThickness),

      // INNER CARD
      child: Container(
        width: double.infinity, // 🔧 FIX: Ensures uniform width
        decoration: BoxDecoration(
          color: const Color(0xFF141823),
          borderRadius: BorderRadius.circular(borderRadius - borderThickness),
        ),
        child: minHeight != null
            ? ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: child,
              )
            : child,
      ),
    );
  }
  // ------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1114),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
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
                        suffixIcon: const Padding(
                          padding: EdgeInsets.only(right: 20, left: 12),
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

                  const SizedBox(height: 20),

                  // Filter Chips
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 480) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFilterChip('All'),
                            _buildFilterChip('Trainees'),
                            _buildFilterChip('Sessions'),
                            _buildFilterChip('Forum'),
                            _buildFilterChip('Belt'),
                            _buildFilterChip('Resource'),
                          ],
                        );
                      }

                      return SingleChildScrollView(
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
                            const SizedBox(width: 12),
                            _buildFilterChip('Belt'),
                            const SizedBox(width: 12),
                            _buildFilterChip('Resource'),
                          ],
                        ),
                      );
                    },
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
                      const SizedBox(height: 14),
                      _buildTraineeCard(
                        name: 'Rayyan Firas',
                        belt: 'Green',
                        note: 'Note : Next Blue Belt in 2 criteria',
                        imageUrl: 'assets/images/searchperson1.png',
                      ),
                      const SizedBox(height: 14),
                      _buildTraineeCard(
                        name: 'Chan Wei Tian',
                        belt: 'Green',
                        note: 'Note : Next Blue Belt in 3 criteria',
                        imageUrl: 'assets/images/searchperson2.png',
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Sessions
                    if (_selectedFilter == 'All' ||
                        _selectedFilter == 'Sessions' ||
                        _selectedFilter == 'Belt') ...[
                      _buildSectionTitle('Sessions'),
                      const SizedBox(height: 14),
                      _buildSessionCard(
                        title: 'School Pulai Jaya',
                        time: 'Thu 7pm - Hall B',
                        date: '25 July 2025',
                        beltType: 'Green',
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Forum
                    if (_selectedFilter == 'All' ||
                        _selectedFilter == 'Forum') ...[
                      _buildSectionTitle('Forum'),
                      const SizedBox(height: 14),
                      _buildForumCard(
                        title: 'How to achieve green belt faster?',
                        replies: '15 replies',
                        icon: Icons.sports_martial_arts,
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Resources
                    if (_selectedFilter == 'All' ||
                        _selectedFilter == 'Resource') ...[
                      _buildSectionTitle('Resources'),
                      const SizedBox(height: 14),
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
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
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
            color: isSelected ? accentColor : Colors.white,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            height: 1.0,
            letterSpacing: 0.0,
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
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w600, // SemiBold
        fontSize: 16,
        height: 1.0, // line-height 100%
        letterSpacing: 0.0,
      ),
    );
  }

  // --- Trainee Card ---
  Widget _buildTraineeCard({
    required String name,
    required String belt,
    required String note,
    required String imageUrl,
  }) {
    return _buildGradientBorderContainer(
      borderRadius: 16,
      minHeight: 100,
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image(
                  image: imageUrl.startsWith('http')
                      ? NetworkImage(imageUrl)
                      : AssetImage(imageUrl) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.0,
                      letterSpacing: 0.0,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0x8A72777A,
                      ), // #72777A8A interpreted as RRGGBBAA -> 0x8A72777A
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0x8A72777A),
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

            // Note (prevents overflow)
            Expanded(
              flex: 3,
              child: Text(
                note,
                softWrap: true,
                overflow: TextOverflow.visible,
                maxLines: 3, // prevent overflow
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.0,
                  letterSpacing: 0.0,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Session Card ---
  Widget _buildSessionCard({
    required String title,
    required String time,
    required String date,
    required String beltType,
  }) {
    return _buildGradientBorderContainer(
      borderRadius: 16,
      minHeight: 100,

      child: Padding(
        padding: const EdgeInsets.all(16.0 - borderThickness),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 1.0,
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Text(
                  '$time -',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'JejuGothic',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.0,
                    letterSpacing: 0.0,
                  ),
                ),
                Text(
                  '$date -',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'JejuGothic',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.0,
                    letterSpacing: 0.0,
                  ),
                ),
                Text(
                  beltType,
                  style: const TextStyle(
                    color: accentColor,
                    fontFamily: 'JejuGothic',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.0,
                    letterSpacing: 0.0,
                  ),
                ),
                const Text(
                  'Belt Session',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'JejuGothic',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.0,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Forum Card ---
  Widget _buildForumCard({
    required String title,
    required String replies,
    required IconData icon,
  }) {
    return _buildGradientBorderContainer(
      borderRadius: 16,
      minHeight: 100,
      child: Padding(
        padding: const EdgeInsets.all(16.0 - borderThickness),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.0,
                      letterSpacing: 0.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Thread - $replies',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'JejuGothic',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 1.0,
                      letterSpacing: 0.0,
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

  // --- Resource Card ---
  Widget _buildResourceCard({
    required String title,
    required String subtitle,
    required String thumbnailUrl,
  }) {
    return _buildGradientBorderContainer(
      borderRadius: 16,
      minHeight: 100,

      child: Padding(
        padding: const EdgeInsets.all(16.0 - borderThickness),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D2E),
                borderRadius: BorderRadius.circular(12),
                //border: Border.all(
                //  color: accentColor.withOpacity(0.5),
                //  width: 1.5,
                // ),
                image: DecorationImage(
                  image: thumbnailUrl.startsWith('http')
                      ? NetworkImage(thumbnailUrl)
                      : AssetImage(thumbnailUrl) as ImageProvider,
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
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.0,
                      letterSpacing: 0.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'JejuGothic',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 1.0,
                      letterSpacing: 0.0,
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
}
