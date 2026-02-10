import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/admin/admin_controller.dart';
import 'package:mapped_frontend/forum/forum_model.dart';

class AdminManageUsersScreen extends StatelessWidget {
  const AdminManageUsersScreen({super.key}); // Changed to const and removed redundant vars

  @override
  Widget build(BuildContext context) {
    // Controller is initialized here
    final AdminController controller = Get.put(AdminController());

    return Scaffold(
      backgroundColor: const Color(0xFF121421),
      // Removed the BottomNavigationBar from here as it's now in AdminMainScreen
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Admin Dashboard",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF00C7A7)));
                  }

                  if (controller.reportedPosts.isEmpty) {
                    return const Center(
                      child: Text("No reports found", style: TextStyle(color: Colors.white54)),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.reportedPosts.length,
                    itemBuilder: (context, index) {
                      final post = controller.reportedPosts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildAdminCard(post, controller),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(ForumPost post, AdminController controller) {
    final RxBool isUserBlocked = post.isUserBlocked; 
    
    String displayReason = "Reported content";
    if (post.reports.isNotEmpty) {
      displayReason = post.reports[0]['reason'] ?? "Reason not specified";
    }

    return Obx(() => Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252836),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: isUserBlocked.value ? const Color(0xFF1F1D2B) : const Color(0xFF4A2B2B),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), 
                topRight: Radius.circular(20)
              ),
            ),
            child: Text(
              isUserBlocked.value ? "BLOCKED USER" : "REPORTED POST",
              style: TextStyle(
                color: isUserBlocked.value ? Colors.grey : Colors.redAccent, 
                fontWeight: FontWeight.bold, 
                fontSize: 12
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: (post.authorImage != null && post.authorImage!.isNotEmpty)
                          ? NetworkImage("http://10.0.2.2:5000/api/${post.authorImage}")
                          : const AssetImage('assets/images/user.png') as ImageProvider,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName, 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                        if (isUserBlocked.value)
                          const Text(
                            "Account Banned", 
                            style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)
                          ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 15),
                
                if (!isUserBlocked.value) ...[
                  Text(post.content, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
                  const SizedBox(height: 10),
                ],

                Text(
                  isUserBlocked.value 
                      ? "User is currently restricted from posting."
                      : "Reason: Reported for $displayReason",
                  style: TextStyle(
                    color: isUserBlocked.value ? Colors.white54 : Colors.redAccent, 
                    fontSize: 13, 
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                if (isUserBlocked.value)
                  _actionBtn(
                    "UnBlock User", 
                    const Color(0xFF00C7A7).withOpacity(0.1), 
                    const Color(0xFF00C7A7), 
                    border: true, 
                    onTap: () => controller.unblockUser(post.authorId ?? "")
                  )
                else
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _actionBtn(
                              "Delete Post", 
                              Colors.redAccent.withOpacity(0.15), 
                              Colors.redAccent, 
                              icon: Icons.delete_outline, 
                              onTap: () => controller.deletePost(post.id)
                            )
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _actionBtn(
                              "Dismiss", 
                              const Color(0xFF00C7A7).withOpacity(0.15), 
                              const Color(0xFF00C7A7), 
                              onTap: () => controller.dismissReport(post.id)
                            )
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Obx(() => _actionBtn(
                          post.isUserBlocked.value ? "UnBlock User" : "Block User", 
                          post.isUserBlocked.value 
                              ? const Color(0xFF00C7A7).withOpacity(0.1) 
                              : Colors.transparent, 
                          post.isUserBlocked.value ? const Color(0xFF00C7A7) : Colors.redAccent, 
                          border: true, 
                          onTap: () {
                            if (post.isUserBlocked.value) {
                              controller.unblockUser(post.authorId ?? "");
                            } else {
                              controller.blockUser(post.authorId ?? "");
                            }
                          },
                      )),
                    ],
                  ),
              ],
            ),
          )
        ],
      ),
    ));
  }

  Widget _actionBtn(String label, Color bg, Color txt, {bool border = false, IconData? icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(25),
          border: border ? Border.all(color: txt) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, color: txt, size: 18), const SizedBox(width: 6)],
            Text(label, style: TextStyle(color: txt, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}