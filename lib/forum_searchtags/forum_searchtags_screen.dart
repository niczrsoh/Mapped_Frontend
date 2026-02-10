import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:mapped_frontend/forum/forum_model.dart';
import 'forum_searchtags_controller.dart';

class ForumSearchtagsScreen extends StatelessWidget {
  ForumSearchtagsScreen({super.key});
  final ForumSearchtagsController controller = Get.put(
    ForumSearchtagsController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildPopularTagsSection(),
            const SizedBox(height: 20),
            _buildPostsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Forum Dashboard',
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
          onSubmitted: (value) => controller.searchPosts(value),
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
                onTap: controller
                    .toggleTagsExpanded,
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

  Widget _buildPostsList() {
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

        if (controller.posts.isEmpty) {
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
          onRefresh: controller.loadPosts,
          color: const Color(0xFF09FACA),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.posts.length,
            itemBuilder: (context, index) {
              final post = controller.posts[index];
              return _buildPostCard(post);
            },
          ),
        );
      }),
    );
  }

  Widget _buildPostCard(ForumPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          // Author Info
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    post.authorImage != null && post.authorImage!.isNotEmpty
                    ? NetworkImage(
                        controller.getFullImageUrl(post.authorImage!),
                      )
                    : null,
                child: post.authorImage == null || post.authorImage!.isEmpty
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      post.timeAgo,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          RichText(
            text: TextSpan(
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.white,
                height: 1.5,
              ),
              children: _parseContent(post.content),
            ),
          ),

          const SizedBox(height: 12),

          // Post Images
          if (post.images.isNotEmpty)
            Column(
              children: post.images.map((imgUrl) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      controller.getFullImageUrl(imgUrl),
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[800],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
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
