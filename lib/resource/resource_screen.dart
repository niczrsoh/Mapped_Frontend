import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:mapped_frontend/helper/colorConstant.dart';
import 'resource_controller.dart';
import 'resource_model.dart';
import 'resource_detail_screen.dart';
import '../resource_searchtags/resource_searchtags_screen.dart';
import '../create_resource/create_resource_screen.dart';

class ResourceScreen extends StatelessWidget {
  ResourceScreen({super.key});
  final ResourceController controller = Get.put(ResourceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.themeBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadResources,
          color: const Color(0xFF09FACA),
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildFilterButtons(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              _buildResourcesListSliver(),
            ],
          ),
        ),
      ),
     floatingActionButton: Obx(() {
        return controller.isAdmin.value 
            ? _buildFloatingActionButton() 
            : const SizedBox.shrink(); 
      }),
    );
  }

  // ========== SLIVER APP BAR ==========
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color(0xFF1A1D29),
      pinned: true,
      floating: false,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              // Use Navigator.pop() with proper context
              Navigator.pop(context);
            },
          ),
          Text(
            'Resources',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: Container(
          color: const Color(0xFF1A1D29),
          padding: const EdgeInsets.only(bottom: 16, top: 0),
          child: _buildSearchBar(),
        ),
      ),
    );
  }

  // ========== SEARCH BAR ==========
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Get.to(() => ResourceSearchtagsScreen()),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF252836),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: const Color(0xFF09FACA).withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Search images, videos, links...',
                  style: GoogleFonts.roboto(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const Icon(Icons.search, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  // ========== FILTER BUTTONS ==========
  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All', controller.selectedFilter.value == 'All'),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Images',
                controller.selectedFilter.value == 'Images',
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Videos',
                controller.selectedFilter.value == 'Videos',
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Links',
                controller.selectedFilter.value == 'Links',
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.setFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF09FACA).withOpacity(0.2)
              : const Color(0xFF252836),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF09FACA)
                : const Color(0xFF09FACA).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? const Color(0xFF09FACA) : Colors.white,
          ),
        ),
      ),
    );
  }

  // ========== RESOURCES LIST SLIVER ==========
  Widget _buildResourcesListSliver() {
    return Obx(() {
      if (controller.isLoading.value && controller.resources.isEmpty) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF09FACA)),
          ),
        );
      }

      if (controller.filteredResources.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 60,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No resources found',
                  style: GoogleFonts.roboto(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to add a resource!',
                  style: GoogleFonts.roboto(
                    color: Colors.white38,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final resource = controller.filteredResources[index];
            return _buildResourceCard(resource);
          }, childCount: controller.filteredResources.length),
        ),
      );
    });
  }

  // ========== RESOURCE CARD ==========
  Widget _buildResourceCard(ResourcePost resource) {
    return GestureDetector(
      onTap: () {
        // Mark resource as viewed to increment count
        controller.markResourceAsViewed(resource.id);
        Get.to(() => ResourceDetailScreen(resource: resource));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF252836),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resource Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[800],
                      child: _buildThumbnail(resource),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title and Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                resource.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getResourceTypeLabel(resource),
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: const Color(0xFF09FACA),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.grey[300],
                              backgroundImage:
                                  resource.authorImage != null &&
                                      resource.authorImage!.isNotEmpty
                                  ? NetworkImage(
                                      controller.getFullImageUrl(
                                        resource.authorImage!,
                                      ),
                                    )
                                  : null,
                              child:
                                  resource.authorImage == null ||
                                      resource.authorImage!.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 10,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${resource.authorName} • ${resource.timeAgo}',
                                style: GoogleFonts.roboto(
                                  fontSize: 11,
                                  color: Colors.white54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Delete button for owner
                  if (resource.authorId == controller.currentUserId)
                    _buildResourceMenu(resource),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== THUMBNAIL BUILDER ==========
  Widget _buildThumbnail(ResourcePost resource) {
    // If it has images, show first image
    if (resource.images.isNotEmpty) {
      return Image.network(
        controller.getFullImageUrl(resource.images.first),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image, color: Colors.white54, size: 32),
      );
    }

    // If it has video, show YouTube thumbnail
    if (resource.videoUrl != null && resource.videoUrl!.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(resource.videoUrl!);
      if (videoId != null && videoId.isNotEmpty) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // YouTube thumbnail
            Image.network(
              "https://img.youtube.com/vi/$videoId/0.jpg",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[800],
                child: const Icon(
                  Icons.play_circle_outline,
                  color: Color(0xFF09FACA),
                  size: 32,
                ),
              ),
            ),
            // Play button overlay
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.play_circle_filled,
                  color: Color(0xFF09FACA),
                  size: 28,
                ),
              ),
            ),
          ],
        );
      }
      // Fallback if videoId can't be extracted
      return const Icon(
        Icons.play_circle_outline,
        color: Color(0xFF09FACA),
        size: 32,
      );
    }

    // If it has links, show link preview or icon
    if (resource.content.contains('http://') ||
        resource.content.contains('https://')) {
      return Container(
        color: const Color(0xFF1A1D29),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.link, color: Color(0xFF09FACA), size: 28),
            const SizedBox(height: 4),
            Text(
              'Link',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.white54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Default to document icon for text resources
    return Container(
      color: const Color(0xFF1A1D29),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.article_outlined, color: Colors.white54, size: 28),
          const SizedBox(height: 4),
          Text(
            'Text',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.white54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ========== RESOURCE MENU ==========
  Widget _buildResourceMenu(ResourcePost resource) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz, color: Colors.white54),
      color: const Color(0xFF252836),
      onSelected: (value) {
        if (value == 'delete') {
          _showDeleteConfirmationDialog(resource);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'Delete Resource',
            style: GoogleFonts.roboto(color: Colors.red),
          ),
        ),
      ],
    );
  }

  // ========== RESOURCE TYPE LABEL ==========
  String _getResourceTypeLabel(ResourcePost resource) {
    return resource.resourceTypeLabel;
  }

  // ========== FLOATING ACTION BUTTON ==========
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => Get.to(() => CreateResourceScreen()),
      backgroundColor: const Color(0xFF09FACA),
      child: const Icon(Icons.add, color: Colors.white, size: 32),
    );
  }

  // ========== DIALOGS ==========
  // --- DELETE CONFIRMATION DIALOG ---
  void _showDeleteConfirmationDialog(ResourcePost resource) {
    Get.defaultDialog(
      title: 'Delete Resource',
      middleText: 'Are you sure you want to delete this resource?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        await controller.deleteResource(resource);
      },
    );
  }
}
