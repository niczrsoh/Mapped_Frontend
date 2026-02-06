import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
              _buildSliverAppBar(),
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
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // ========== SLIVER APP BAR ==========
  Widget _buildSliverAppBar() {
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
            onPressed: () => Get.back(),
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
        Get.to(() => ResourceDetailScreen(resource: resource));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF252836),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: resource.isPinned.value
                ? const Color(0xFF09FACA).withOpacity(0.5)
                : const Color(0xFF09FACA).withOpacity(0.2),
            width: 1,
          ),
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
                            if (resource.isPinned.value)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _buildPinnedBadge(),
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

            // Interaction Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  const Spacer(),

                  // PIN BUTTON
                  Obx(
                    () => IconButton(
                      icon: Icon(
                        resource.isPinned.value
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        color: resource.isPinned.value
                            ? const Color(0xFF09FACA)
                            : Colors.white54,
                        size: 20,
                      ),
                      onPressed: () => _showPinConfirmationDialog(resource),
                    ),
                  ),

                  // REPORT BUTTON
                  Obx(
                    () => IconButton(
                      icon: Icon(
                        resource.isReported.value
                            ? Icons.flag
                            : Icons.flag_outlined,
                        color: resource.isReported.value
                            ? Colors.red
                            : Colors.white54,
                        size: 20,
                      ),
                      onPressed: () => _showReportDialog(resource),
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

    // If it has video, show video icon
    if (resource.videoUrl != null && resource.videoUrl!.isNotEmpty) {
      return const Icon(
        Icons.play_circle_outline,
        color: Color(0xFF09FACA),
        size: 32,
      );
    }

    // If it has links, show link icon
    if (resource.content.contains('http://') ||
        resource.content.contains('https://')) {
      return const Icon(Icons.link, color: Color(0xFF09FACA), size: 32);
    }

    // Default to document icon
    return const Icon(Icons.article_outlined, color: Colors.white54, size: 32);
  }

  // ========== BADGES ==========
  Widget _buildPinnedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF09FACA).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.push_pin, size: 10, color: Color(0xFF09FACA)),
          const SizedBox(width: 4),
          Text(
            "Pinned",
            style: GoogleFonts.roboto(
              fontSize: 10,
              color: const Color(0xFF09FACA),
              fontWeight: FontWeight.bold,
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
  // --- PIN CONFIRMATION DIALOG ---
  void _showPinConfirmationDialog(ResourcePost resource) {
    bool currentlyPinned = resource.isPinned.value;

    Get.defaultDialog(
      title: "",
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(20),
      backgroundColor: const Color(0xFF252836),
      radius: 20,
      content: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.push_pin_outlined,
                size: 40,
                color: Colors.white,
              ),
              if (currentlyPinned)
                Transform.rotate(
                  angle: -0.8,
                  child: Container(height: 2, width: 40, color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currentlyPinned
                ? "Do you want to unpin this resource?"
                : "Do you want to pin this resource?",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF09FACA),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text(
                    "CANCEL",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF09FACA),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    controller.togglePin(resource);
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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

  // --- REPORT DIALOG - STEP 1: POLICY SELECTION ---
  void _showReportDialog(ResourcePost resource) {
    if (!controller.canReportResource(resource)) {
      Get.snackbar(
        "Info",
        "You have already reported this resource.",
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
      );
      return;
    }

    controller.resetReportState();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select our policy that applies",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: controller.reportReasons.map((reason) {
                  return Obx(() {
                    final isSelected =
                        controller.selectedReason.value == reason;
                    return GestureDetector(
                      onTap: () => controller.selectReportReason(reason),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00FFA3)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00FFA3)
                                : Colors.black54,
                          ),
                        ),
                        child: Text(
                          reason,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: controller.selectedReason.value.isEmpty
                        ? null
                        : () {
                            Get.back();
                            _showReportConfirmationDialog(resource);
                          },
                    child: const Text(
                      "Next",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- REPORT DIALOG - STEP 2: CONFIRMATION ---
  void _showReportConfirmationDialog(ResourcePost resource) {
    controller.toggleReportConfirmation(false);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "You've selected the following reason",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                controller.selectedReason.value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.getReasonDefinition(controller.selectedReason.value),
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              const Text(
                "Confirmation",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Row(
                  children: [
                    Checkbox(
                      value: controller.isReportConfirmed.value,
                      activeColor: const Color(0xFF007AFF),
                      onChanged: (val) =>
                          controller.toggleReportConfirmation(val ?? false),
                    ),
                    Expanded(
                      child: Text(
                        "I have confirmed to report this resource as ${controller.selectedReason.value.toLowerCase()}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: controller.isReportConfirmed.value
                        ? () async {
                            Get.back();
                            final success = await controller.submitReport(
                              resource,
                            );
                            if (success) {
                              _showReportSuccessDialog();
                            }
                          }
                        : null,
                    child: const Text(
                      "Submit Report",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- REPORT DIALOG - STEP 3: SUCCESS ---
  void _showReportSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 50,
              ),
              const SizedBox(height: 16),
              const Text(
                "You have successfully reported the resource",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
