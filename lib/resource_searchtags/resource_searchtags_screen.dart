import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:mapped_frontend/resource_searchtags/resource_searchtags_model.dart';
import 'resource_searchtags_controller.dart';

class ResourceSearchtagsScreen extends StatelessWidget {
  ResourceSearchtagsScreen({super.key});
  final ResourceSearchtagsController controller = Get.put(
    ResourceSearchtagsController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildPopularTagsSection(),
            const SizedBox(height: 20),
            _buildResourcesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 8),
          Text(
            'Resources Dashboard',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF252836),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: const Color(0xFF09FACA).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: TextField(
          controller: controller.searchController,
          style: GoogleFonts.roboto(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search by name or tags...',
            hintStyle: GoogleFonts.roboto(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
          ),
          onSubmitted: (value) => controller.searchResources(value),
        ),
      ),
    );
  }

  Widget _buildPopularTagsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Tags',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: controller.toggleTagsExpanded,
                child: Obx(
                  () => Text(
                    controller.isTagsExpanded.value ? 'Show Less' : 'View All',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF09FACA),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Obx(() {
            if (controller.popularTags.isEmpty) {
              return Text(
                "No tags found",
                style: GoogleFonts.roboto(color: Colors.grey),
              );
            }

            final tagsToShow = controller.isTagsExpanded.value
                ? controller.popularTags.toList()
                : controller.popularTags.take(3).toList();

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tagsToShow.map((tag) {
                final isSelected = controller.selectedTag.value == tag;
                return GestureDetector(
                  onTap: () => controller.selectTag(tag),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF09FACA)
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
                      tag,
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF1A1D29)
                            : Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResourcesGrid() {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF09FACA)),
          );
        }

        if (!controller.hasSearched.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: 40,
                  color: Colors.white.withOpacity(0.1),
                ),
                const SizedBox(height: 16),
                Text(
                  'Search tags or keywords to find posts',
                  style: GoogleFonts.roboto(
                    color: Colors.white24,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.resources.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  controller.selectedTag.value.isNotEmpty
                      ? 'No posts found for ${controller.selectedTag.value}'
                      : 'No posts found',
                  style: GoogleFonts.roboto(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
                if (controller.selectedTag.value.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: controller.clearSelection,
                    child: Text(
                      'Clear Filter',
                      style: GoogleFonts.roboto(
                        color: const Color(0xFF09FACA),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadResources,
          color: const Color(0xFF09FACA),
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: controller.resources.length,
            itemBuilder: (context, index) {
              final resource = controller.resources[index];
              return _buildGridCard(resource);
            },
          ),
        );
      }),
    );
  }

  Widget _buildGridCard(Resources resource) {
    // Get the first image if available
    final imageUrl = resource.images.isNotEmpty 
        ? controller.getFullImageUrl(resource.images.first)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF09FACA).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image or Placeholder
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                          size: 40,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(
                          Icons.article,
                          color: Colors.white54,
                          size: 40,
                        ),
                      ),
                    ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title/Content Preview
                Text(
                  _extractTitle(resource.content),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Author Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: resource.authorImage != null &&
                              resource.authorImage!.isNotEmpty
                          ? NetworkImage(
                              controller.getFullImageUrl(resource.authorImage!),
                            )
                          : null,
                      child: resource.authorImage == null ||
                              resource.authorImage!.isEmpty
                          ? const Icon(Icons.person, size: 12, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resource.authorName,
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            resource.timeAgo,
                            style: GoogleFonts.roboto(
                              fontSize: 10,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Extract title from content (first line or first few words)
  String _extractTitle(String content) {
    // Remove hashtags for cleaner title
    final cleanContent = content.replaceAll(RegExp(r'\B#\w+'), '').trim();
    
    // Get first line or first 50 characters
    final firstLine = cleanContent.split('\n').first;
    if (firstLine.length > 50) {
      return '${firstLine.substring(0, 50)}...';
    }
    return firstLine.isEmpty ? 'Untitled' : firstLine;
  }

  List<TextSpan> _parseContent(String text) {
    List<TextSpan> spans = [];

    // Finds words starting with #
    text.splitMapJoin(
      RegExp(r"\B#\w+"),
      onMatch: (m) {
        final tag = m.group(0)!;
        spans.add(
          TextSpan(
            text: tag,
            style: const TextStyle(
              color: Color(0xFF09FACA),
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => controller.selectTag(tag),
          ),
        );
        return "";
      },
      onNonMatch: (n) {
        spans.add(
          TextSpan(
            text: n,
            style: const TextStyle(color: Colors.white),
          ),
        );
        return "";
      },
    );
    return spans;
  }
}