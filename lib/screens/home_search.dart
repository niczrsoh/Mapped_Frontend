import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../Participants/trainee_controller.dart';
import '../session/session_controller.dart';
import '../forum/forum_controller.dart';
import '../resource/resource_controller.dart';
import '../resource/resource_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../Participants/trainee_detail_screen.dart';
import '../session/session_details.dart';
import '../resource/resource_detail_screen.dart';
import '../Participants/trainee_screen.dart';
import '../session/session_dashboard_screen.dart';
import '../forum/forum_screen.dart';
import '../resource/resource_screen.dart';


class HomeSearchScreen extends StatefulWidget {
  const HomeSearchScreen({super.key});

  @override
  State<HomeSearchScreen> createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends State<HomeSearchScreen> {
  // Controllers
  final TraineeController _traineeController = Get.put(TraineeController());
  final SessionController _sessionController = Get.put(SessionController());
  final ForumController _forumController = Get.put(ForumController());
  final ResourceController _resourceController = Get.put(ResourceController());
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';
  String _searchQuery = '';

  // --- STYLE CONSTANTS ---
  static const Color innerCardBackgroundColor = Color(0xFF2A2D3E);
  static const Color accentColor = Color(0xFF00FFB9);
  static const double borderThickness = 1.5;

  final LinearGradient customGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x1AFFFFFF), Color(0xFA00FFA6)],
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _traineeController.fetchTrainees();
      _sessionController.fetchDashboardData();
      _forumController.loadPosts();
      _resourceController.loadResources();
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141823),

      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER & SEARCH ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Back Button & Title
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
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
                  const SizedBox(height: 20),

                  // 2. "Search" Title
                  const Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Search Bar
                  _buildGradientBorderContainer(
                    borderRadius: 30,
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        suffixIcon: const Icon(
                          Icons.search,
                          color: accentColor,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Participants'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Sessions'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Forum'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Resource'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- SCROLLABLE CONTENT ---
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _sessionController.fetchDashboardData();
                  await _traineeController.fetchTrainees();
                  await _forumController.loadPosts();
                  await _resourceController.loadResources();
                },
                color: accentColor,
                backgroundColor: const Color(0xFF141823),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. DYNAMIC PARTICIPANTS SECTION
                      if (_selectedFilter == 'All' ||
                          _selectedFilter == 'Participants') ...[
                        Obx(() {
                          if (_traineeController.loading.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(
                                  color: accentColor,
                                ),
                              ),
                            );
                          }

                          // Filter Logic
                          final filteredList = _traineeController.traineeList
                              .where((trainee) {
                                final name = (trainee['name'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                return name.contains(
                                  _searchQuery.toLowerCase(),
                                );
                              })
                              .toList();

                          // Limit Logic
                          List<dynamic> displayList = filteredList;
                          if (_selectedFilter == 'All') {
                            displayList = filteredList.take(2).toList();
                          } else if (_selectedFilter == 'Participants') {
                            displayList = filteredList.take(6).toList();
                          }

                          // If in 'All' mode and there are no items, hide the whole section
                          if (_selectedFilter == 'All' && displayList.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                'Participants',
                                'Participants',
                              ),
                              const SizedBox(height: 14),
                              if (displayList.isEmpty)
                                _buildEmptyState('No participants found')
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: displayList.length,
                                  itemBuilder: (context, index) {
                                    final trainee = displayList[index];
                                    return _buildDynamicParticipantCard(
                                      trainee,
                                    );
                                  },
                                ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }),
                      ],

                      // 2. SESSIONS SECTION
                      if (_selectedFilter == 'All' ||
                          _selectedFilter == 'Sessions') ...[
                        Obx(() {
                          if (_sessionController.isLoading.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(
                                  color: accentColor,
                                ),
                              ),
                            );
                          }

                          // Combine Current + Upcoming sessions
                          List<dynamic> allSessions = [
                            ..._sessionController.currentList,
                            ..._sessionController.upcomingList,
                          ];

                          // Sorting Logic
                          allSessions.sort((a, b) {
                            String? idA = a.id;
                            String? idB = b.id;

                            if (idA != null &&
                                idB != null &&
                                idA.isNotEmpty &&
                                idB.isNotEmpty) {
                              return idB.compareTo(idA);
                            }

                            DateTime da =
                                DateTime.tryParse(a.date.toString()) ??
                                DateTime(2099);
                            DateTime db =
                                DateTime.tryParse(b.date.toString()) ??
                                DateTime(2099);
                            return da.compareTo(db);
                          });

                          // Filter based on search query
                          final filteredSessions = allSessions.where((session) {
                            final venue = (session.venue ?? '').toLowerCase();
                            final level = (session.level ?? '').toLowerCase();
                            final date = (session.date ?? '').toLowerCase();
                            final query = _searchQuery.toLowerCase();
                            return venue.contains(query) ||
                                level.contains(query) ||
                                date.contains(query);
                          }).toList();

                          // Limit display count
                          List<dynamic> displaySessions = filteredSessions;
                          if (_selectedFilter == 'All') {
                            displaySessions = filteredSessions.take(2).toList();
                          } else if (_selectedFilter == 'Sessions') {
                            displaySessions = filteredSessions.take(6).toList();
                          }

                          // Hide entire section in 'All' when empty
                          if (_selectedFilter == 'All' &&
                              displaySessions.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('Sessions', 'Sessions'),
                              const SizedBox(height: 14),
                              if (displaySessions.isEmpty)
                                _buildEmptyState('No upcoming sessions found')
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: displaySessions.length,
                                  itemBuilder: (context, index) {
                                    final session = displaySessions[index];

                                    String duration = session.duration != null
                                        ? '${session.duration} Mins'
                                        : '0 min';
                                    String level = session.level ?? 'N/A';
                                    String venue =
                                        session.venue ?? 'Unknown Venue';
                                    String dateStr = _formatDate(session.date);

                                    // Convert session to Map<String, dynamic> for navigation
                                    Map<String, dynamic> sessionMap = {};
                                    if (session is Map<String, dynamic>) {
                                      sessionMap = session;
                                    } else {
                                      // If session is a model, try toJson or fallback
                                      try {
                                        sessionMap = session.toJson();
                                      } catch (_) {
                                        sessionMap = {
                                          'venue': session.venue,
                                          'level': session.level,
                                          'date': session.date,
                                          'duration': session.duration,
                                          'totalTrainees':
                                              session.totalTrainees ??
                                              session.pax,
                                          'ageRange': session.ageRange,
                                          'sessionNo': session.sessionNo,
                                          'riskAssessment':
                                              session.riskAssessment,
                                          'resources': session.resources,
                                        };
                                      }
                                    }

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                SessionDetailsScreen(
                                                  sessionData: sessionMap,
                                                ),
                                          ),
                                        );
                                      },
                                      child: _buildSessionCard(
                                        title: venue,
                                        details:
                                            '$duration - $level - $dateStr',
                                      ),
                                    );
                                  },
                                ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }),
                      ],

                      // 3. DYNAMIC FORUM SECTION
                      if (_selectedFilter == 'All' ||
                          _selectedFilter == 'Forum') ...[
                        Obx(() {
                          if (_forumController.isLoading.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(
                                  color: accentColor,
                                ),
                              ),
                            );
                          }

                          // Filter Logic
                          final filteredPosts = _forumController.allPosts.where((
                            post,
                          ) {
                            final content = post.content.toLowerCase();
                            final author = post.authorName.toLowerCase();
                            final query = _searchQuery.toLowerCase();
                            return content.contains(query) ||
                                author.contains(query);
                          }).toList();

                          // Limit Logic
                          List<dynamic> displayPosts = filteredPosts;
                          if (_selectedFilter == 'All') {
                            displayPosts = filteredPosts.take(2).toList();
                          } else if (_selectedFilter == 'Forum') {
                            displayPosts = filteredPosts.take(6).toList();
                          }

                          if (_selectedFilter == 'All' &&
                              displayPosts.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('Forum', 'Forum'),
                              const SizedBox(height: 14),
                              if (displayPosts.isEmpty)
                                _buildEmptyState('No forum posts found')
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: displayPosts.length,
                                  itemBuilder: (context, index) {
                                    final post = displayPosts[index];
                                    // Calculate simple text snippet for card
                                    String snippet = post.content;
                                    if (snippet.length > 50) {
                                      snippet =
                                          "${snippet.substring(0, 50)}...";
                                    }

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => ForumScreen(),
                                          ),
                                        );
                                      },
                                      child: _buildDynamicForumCard(
                                        authorName: post.authorName,
                                        authorImage: post.authorImage,
                                        title: snippet,
                                        likes: post.likes,
                                        replies: post.comments,
                                      ),
                                    );
                                  },
                                ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }),
                      ],

                      // 4. DYNAMIC RESOURCES SECTION
                      if (_selectedFilter == 'All' ||
                          _selectedFilter == 'Resource') ...[
                        Obx(() {
                          if (_resourceController.isLoading.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(
                                  color: accentColor,
                                ),
                              ),
                            );
                          }

                          final resources = _resourceController.resources
                              .where(
                                (r) => r.title.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ),
                              )
                              .toList();

                          // Limit display count
                          List<dynamic> displayResources = resources;
                          if (_selectedFilter == 'All') {
                            displayResources = resources.take(2).toList();
                          } else if (_selectedFilter == 'Resource') {
                            displayResources = resources.take(6).toList();
                          }

                          // Hide entire section in 'All' when empty
                          if (_selectedFilter == 'All' &&
                              displayResources.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('Resources', 'Resource'),
                              const SizedBox(height: 14),
                              if (displayResources.isEmpty)
                                _buildEmptyState('No resources found')
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: displayResources.length,
                                  itemBuilder: (context, index) {
                                    final ResourcePost r =
                                        displayResources[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ResourceDetailScreen(
                                                  resource: r,
                                                ),
                                          ),
                                        );
                                      },
                                      child: _buildResourceCardFromPost(r),
                                    );
                                  },
                                ),
                              const SizedBox(height: 40),
                            ],
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildDynamicParticipantCard(Map<String, dynamic> trainee) {
    final String name = trainee['name'] ?? 'Unknown';
    final String belt = trainee['belt'] ?? 'White';

    String noteText = 'None';
    var conditions = trainee['conditions'];
    if (conditions != null) {
      if (conditions is List && conditions.isNotEmpty) {
        noteText = conditions.join(", ");
      } else {
        String text = conditions.toString().trim();
        if (text.isEmpty || text == 'null') {
          noteText = 'None';
        } else if (text.contains('-')) {
          // Remove dashes and join items with comma, like trainee_screen.dart
          final parts = text
              .split('-')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          noteText = parts.isNotEmpty ? parts.join(", ") : 'None';
        } else {
          noteText = text;
        }
      }
    }

    ImageProvider? avatarImage;
    String? imgData = trainee['image'] ?? trainee['imagePath'];
    if (imgData != null && imgData.isNotEmpty) {
      if (imgData.startsWith('http')) {
        avatarImage = NetworkImage(imgData);
      } else if (imgData.startsWith('assets/')) {
        avatarImage = AssetImage(imgData);
      } else {
        try {
          final file = File(imgData);
          if (file.existsSync()) avatarImage = FileImage(file);
        } catch (_) {}
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TraineeDetailScreen(trainee: trainee),
          ),
        );
      },
      child: _buildGradientBorderContainer(
        borderRadius: 16,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[800],
                  border: Border.all(color: Colors.white12),
                  image: avatarImage != null
                      ? DecorationImage(image: avatarImage, fit: BoxFit.cover)
                      : null,
                ),
                child: avatarImage == null
                    ? Icon(Icons.person, color: Colors.white.withOpacity(0.5))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF353A4D),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        belt,
                        style: const TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Note : ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        noteText,
                        textAlign: TextAlign.start,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
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

  Widget _buildSessionCard({required String title, required String details}) {
    return _buildGradientBorderContainer(
      borderRadius: 16,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'JejuGothic',
                ),
                children: [TextSpan(text: details)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DYNAMIC FORUM CARD ---
  Widget _buildDynamicForumCard({
    required String authorName,
    String? authorImage,
    required String title,
    required RxInt likes,
    required int replies,
  }) {
    // Prepare Image URL if it exists
    String? fullImageUrl;
    if (authorImage != null && authorImage.isNotEmpty) {
      // Use controller helper if path is relative
      fullImageUrl = _forumController.getFullImageUrl(authorImage);
    }

    return _buildGradientBorderContainer(
      borderRadius: 16,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // User Avatar (Profile Picture)
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[800],
              backgroundImage: fullImageUrl != null
                  ? NetworkImage(fullImageUrl)
                  : null,
              child: fullImageUrl == null
                  ? const Icon(Icons.person, color: Colors.white54)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Name
                  Text(
                    authorName,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Post Content/Title
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Reply Count
                  Obx(
                    () => Text(
                      '${likes.value} likes - $replies replies',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
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

  // --- DYNAMIC RESOURCE CARD ---
  Widget _buildResourceCardFromPost(ResourcePost resource) {
    Widget thumbnail;

    // 1. Image Check
    if (resource.images.isNotEmpty) {
      thumbnail = Image.network(
        _resourceController.getFullImageUrl(resource.images.first),
        fit: BoxFit.cover,
        width: 60,
        height: 50,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image, color: Colors.white54, size: 24),
      );

      // 2. Video Check
    } else if (resource.videoUrl != null && resource.videoUrl!.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(resource.videoUrl!);
      if (videoId != null && videoId.isNotEmpty) {
        thumbnail = Stack(
          alignment: Alignment.center,
          children: [
            Image.network(
              "https://img.youtube.com/vi/$videoId/0.jpg",
              fit: BoxFit.cover,
              width: 60,
              height: 50,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey[800]),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.play_circle_filled,
                color: Color(0xFF09FACA),
                size: 16,
              ),
            ),
          ],
        );
      } else {
        thumbnail = const Icon(
          Icons.play_circle_outline,
          color: Color(0xFF09FACA),
          size: 24,
        );
      }

      // 3. Link Check -> SHOW PLAY ICON (As requested)
    } else if (resource.resourceType.toLowerCase() == 'link' ||
        resource.content.contains('http://') ||
        resource.content.contains('https://')) {
      thumbnail = Container(
        width: 60,
        height: 50,
        color: const Color(0xFF1A1D29), // Dark background
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(
              Icons.play_circle_filled, // Play icon for links
              color: Color(0xFF09FACA),
              size: 20,
            ),
          ),
        ),
      );

      // 4. Text/Fallback
    } else {
      thumbnail = Container(
        width: 60,
        height: 50,
        color: Colors.grey[800],
        child: const Center(
          child: Icon(Icons.article_outlined, color: Colors.white54, size: 20),
        ),
      );
    }

    return _buildGradientBorderContainer(
      borderRadius: 16,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: thumbnail),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resource.resourceTypeLabel,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF353A4D)
              : innerCardBackgroundColor,
          borderRadius: BorderRadius.circular(25),
          border: isSelected ? null : Border.all(color: Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String filterKey) {
    final bool showSeeMore =
        _selectedFilter == 'All' || _selectedFilter == filterKey;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: accentColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        if (showSeeMore)
          TextButton(
            onPressed: () {
              // Navigate to the appropriate dashboard/list screen
              if (filterKey == 'Participants') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TraineesScreen()),
                );
                return;
              }

              if (filterKey == 'Sessions') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SessionDashboardScreen()),
                );
                return;
              }

              if (filterKey == 'Forum') {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => ForumScreen()));
                return;
              }

              if (filterKey == 'Resource') {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => ResourceScreen()));
                return;
              }

              // Fallback: just switch filter in-place
              setState(() => _selectedFilter = filterKey);
            },
            child: Text(
              'See more',
              style: TextStyle(color: accentColor, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }


  Widget _buildGradientBorderContainer({
    required Widget child,
    required double borderRadius,
    EdgeInsets? margin,
  }) {
    return Container(
      width: double.infinity,
      margin: margin,
      decoration: BoxDecoration(
        gradient: customGradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: const EdgeInsets.all(borderThickness),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141823),
          borderRadius: BorderRadius.circular(borderRadius - borderThickness),
        ),
        child: child,
      ),
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Date TBD';
    try {
      DateTime dt;
      if (dateValue is DateTime) {
        dt = dateValue;
      } else {
        dt =
            DateTime.tryParse(dateValue.toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        if (dt.year == 1970 || dt.millisecondsSinceEpoch == 0) {
          final parts = dateValue.toString().split(RegExp(r'[^0-9]'))
            ..removeWhere((s) => s.isEmpty);
          if (parts.length >= 3) {
            final d = int.tryParse(parts[0]) ?? 0;
            final m = int.tryParse(parts[1]) ?? 1;
            final y = int.tryParse(parts[2]) ?? 0;
            dt = DateTime(y, m, d);
          }
        }
      }
      if (dt.year <= 1) return dateValue.toString();
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      final day = dt.day;
      final monthName = months[dt.month - 1];
      final year = dt.year;
      return '$day $monthName $year';
    } catch (e) {
      return dateValue.toString();
    }
  }
}
