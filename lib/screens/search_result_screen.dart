// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:io';
// import 'dart:async';
// import 'package:flutter/foundation.dart'; // For kIsWeb
// import '../Participants/trainee_controller.dart';
// import '../Participants/trainee_detail_screen.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import '../controller/controller/resource_controller.dart';
// import 'social_feed_screen.dart';

// class SearchResultsScreen extends StatefulWidget {
//   const SearchResultsScreen({super.key});

//   @override
//   State<SearchResultsScreen> createState() => _SearchResultsScreenState();
// }

// class _SearchResultsScreenState extends State<SearchResultsScreen> {
//   final TraineeController _traineeController = Get.put(TraineeController());
//   final ResourceController _resourceController = Get.put(ResourceController());
//   final TextEditingController _searchController = TextEditingController();
//   String _selectedFilter = 'All';
//   String _searchQuery = '';

//   static const Color innerCardBackgroundColor = Color(0xFF2A2D3E);
//   static const Color accentColor = Color(0xFF00FFB9);
//   static const double borderThickness = 1.5;

//   final LinearGradient customGradient = const LinearGradient(
//     begin: Alignment.topCenter,
//     end: Alignment.bottomCenter,
//     colors: [Color(0x1AFFFFFF), Color(0xFA00FFA6)],
//   );

//   String _getNextBelt(String currentBelt) {
//     switch (currentBelt) {
//       case 'White':
//         return 'Yellow';
//       case 'Yellow':
//         return 'Green';
//       case 'Green':
//         return 'Blue';
//       case 'Blue':
//         return 'Brown';
//       case 'Brown':
//         return 'Black';
//       default:
//         return 'White';
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       setState(() {
//         _searchQuery = _searchController.text.toLowerCase();
//       });
//     });

//     // --- ADD THIS NEW CODE ---
//     // Fetch resources once the screen is built
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _resourceController.fetchResources(filterType: 'All');
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Widget _buildGradientBorderContainer({
//     required Widget child,
//     required double borderRadius,
//     EdgeInsets? margin,
//     List<BoxShadow>? shadows,
//     double? minHeight,
//   }) {
//     return Container(
//       width: double.infinity,
//       margin: margin,
//       decoration: BoxDecoration(
//         gradient: customGradient,
//         borderRadius: BorderRadius.circular(borderRadius),
//         boxShadow: shadows,
//       ),
//       padding: const EdgeInsets.all(borderThickness),
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: const Color(0xFF141823),
//           borderRadius: BorderRadius.circular(borderRadius - borderThickness),
//         ),
//         child: minHeight != null
//             ? ConstrainedBox(
//                 constraints: BoxConstraints(minHeight: minHeight),
//                 child: child,
//               )
//             : child,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF141823),
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Home',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Search Section
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Search',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // Search Bar
//                   _buildGradientBorderContainer(
//                     borderRadius: 30,
//                     child: TextField(
//                       controller: _searchController,
//                       style: const TextStyle(color: Colors.white, fontSize: 16),
//                       decoration: InputDecoration(
//                         hintText: 'Search by name or belt...',
//                         hintStyle: TextStyle(
//                           color: Colors.white.withOpacity(0.5),
//                           fontSize: 16,
//                         ),
//                         suffixIcon: const Padding(
//                           padding: EdgeInsets.only(right: 20, left: 12),
//                           child: Icon(Icons.search, color: accentColor),
//                         ),
//                         border: InputBorder.none,
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 16,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // Filter Chips
//                   LayoutBuilder(
//                     builder: (context, constraints) {
//                       return SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(
//                           children: [
//                             _buildFilterChip('All'),
//                             const SizedBox(width: 12),
//                             _buildFilterChip('Trainees'),
//                             const SizedBox(width: 12),
//                             _buildFilterChip('Sessions'),
//                             const SizedBox(width: 12),
//                             _buildFilterChip('Forum'),
//                             const SizedBox(width: 12),
//                             _buildFilterChip('Belt'),
//                             const SizedBox(width: 12),
//                             _buildFilterChip('Resource'),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Results List
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // --- 1. DYNAMIC TRAINEES SECTION ---
//                     if (_selectedFilter == 'All' ||
//                         _selectedFilter == 'Trainees') ...[
//                       _buildSectionTitle('Trainees'),
//                       const SizedBox(height: 14),

//                       Obx(() {
//                         final results = _traineeController.traineeList.where((
//                           t,
//                         ) {
//                           final name = (t['name'] ?? '')
//                               .toString()
//                               .toLowerCase();
//                           final belt = (t['belt'] ?? '')
//                               .toString()
//                               .toLowerCase();

//                           if (_searchQuery.isEmpty) return true;
//                           return name.contains(_searchQuery) ||
//                               belt.contains(_searchQuery);
//                         }).toList();

//                         if (results.isEmpty) {
//                           return const Padding(
//                             padding: EdgeInsets.only(bottom: 20),
//                             child: Text(
//                               "No trainees found.",
//                               style: TextStyle(color: Colors.grey),
//                             ),
//                           );
//                         }

//                         return Column(
//                           children: results.map((trainee) {
//                             final String currentBelt = trainee['belt'] ?? 'White';
//                             final String nextBelt = _getNextBelt(currentBelt);
                            
//                             // Construct the dynamic note based on the next belt
//                             final String defaultNote = 'Note : Next $nextBelt belt in 3 criteria';
                            
//                             final String traineeNote = trainee['note'] ?? defaultNote;

//                             return _buildTraineeCard(
//                               traineeData: trainee,
//                               name: trainee['name'] ?? 'Unknown',
//                               belt: currentBelt, // Pass the current belt
//                               note: traineeNote, // Pass the dynamic note
//                               imageUrl: trainee['image'],
//                             );
//                           }).toList(),
//                         );
//                       }),
//                       const SizedBox(height: 20),
//                     ],

//                     // --- 2. SESSIONS (Static) ---
//                     if (_selectedFilter == 'All' ||
//                         _selectedFilter == 'Sessions' ||
//                         _selectedFilter == 'Belt') ...[
//                       _buildSectionTitle('Sessions'),
//                       const SizedBox(height: 14),
//                       _buildSessionCard(
//                         title: 'School Pulai Jaya',
//                         time: 'Thu 7pm - Hall B',
//                         date: '25 July 2025',
//                         beltType: 'Green',
//                       ),
//                       const SizedBox(height: 32),
//                     ],

//                     // --- 3. FORUM (Static) ---
//                     if (_selectedFilter == 'All' ||
//                         _selectedFilter == 'Forum') ...[
//                       _buildSectionTitle('Forum'),
//                       const SizedBox(height: 14),
//                       _buildForumCard(
//                         title: 'How to achieve green belt faster?',
//                         replies: '15 replies',
//                         icon: Icons.sports_martial_arts,
//                       ),
//                       const SizedBox(height: 32),
//                     ],

//                     if (_selectedFilter == 'All' ||
//                         _selectedFilter == 'Resource') ...[
//                       _buildSectionTitle('Resources'),
//                       const SizedBox(height: 14),

//                       // START OF NEW LOGIC
//                       Obx(() {
//                         if (_resourceController.loading.value) {
//                           return const Center(
//                             child: Padding(
//                               padding: EdgeInsets.all(20.0),
//                               child: CircularProgressIndicator(
//                                 color: Color(0xFF00ff9f),
//                               ),
//                             ),
//                           );
//                         }

//                         if (_resourceController.resourceList.isEmpty) {
//                           return Center(
//                             child: Padding(
//                               padding: const EdgeInsets.all(20.0),
//                               child: Text(
//                                 "No resources found",
//                                 style: TextStyle(color: Colors.grey[400]),
//                               ),
//                             ),
//                           );
//                         }

//                         // Render the list of resources
//                         return ListView.builder(
//                           physics:
//                               const NeverScrollableScrollPhysics(), // Disables scrolling so it fits in your outer scroll
//                           shrinkWrap: true, // Takes only needed space
//                           itemCount: _resourceController.resourceList.length,
//                           itemBuilder: (context, index) {
//                             return _buildBackendResourceCard(
//                               _resourceController.resourceList[index],
//                             );
//                           },
//                         );
//                       }),

//                       // END OF NEW LOGIC
//                       const SizedBox(height: 40),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBackendResourceCard(dynamic resource) {
//     // Styles matched to your UI
//     const double cardRadius = 20.0;
//     const double borderThickness = 1.5;
//     const Color innerBg = Color(0xFF252836);
//     final LinearGradient gradient = const LinearGradient(
//       begin: Alignment.topCenter,
//       end: Alignment.bottomCenter,
//       colors: [Color(0x1AFFFFFF), Color(0xFA00FFA6)],
//     );

//     final String title = resource['title'] ?? 'Untitled';
//     final String subtitle =
//         (resource['description'] != null &&
//             resource['description'].toString().isNotEmpty)
//         ? resource['description']
//         : (resource['date'] ?? '');
//     final String type = resource['type'] ?? 'Text';

//     // Logic to extract the correct URL
//     String? resourceUrl;
//     if (resource['imageUrls'] != null &&
//         (resource['imageUrls'] as List).isNotEmpty) {
//       resourceUrl = resource['imageUrls'][0];
//     } else if (resource['videoUrls'] != null &&
//         (resource['videoUrls'] as List).isNotEmpty) {
//       resourceUrl = resource['videoUrls'][0];
//     } else if (resource['linkUrl'] != null &&
//         resource['linkUrl'].toString().isNotEmpty) {
//       resourceUrl = resource['linkUrl'];
//     } else {
//       // Legacy fallback
//       List<dynamic> urls = resource['urls'] ?? [];
//       if (urls.isNotEmpty)
//         resourceUrl = urls[0];
//       else
//         resourceUrl = resource['url'];
//     }

//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => SocialFeedScreen(resourceData: resource),
//           ),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         decoration: BoxDecoration(
//           gradient: gradient,
//           borderRadius: BorderRadius.circular(cardRadius),
//         ),
//         padding: const EdgeInsets.all(borderThickness),
//         child: Container(
//           padding: const EdgeInsets.all(16.0 - borderThickness),
//           decoration: BoxDecoration(
//             color: const Color(0xFF141823),
//             borderRadius: BorderRadius.circular(cardRadius - borderThickness),
//           ),
//           child: Row(
//             children: [
//               // Thumbnail
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF3d4154),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       _buildBackendThumbnail(type, resourceUrl),
//                       if (type == 'Video')
//                         Align(
//                           alignment: Alignment.center,
//                           child: Container(
//                             width: 28,
//                             height: 28,
//                             decoration: const BoxDecoration(
//                               color: Colors.black45,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.play_arrow,
//                               color: Color(0xFF00ff9f),
//                               size: 18,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               // Text Info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       subtitle,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(color: Colors.grey[400], fontSize: 13),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBackendThumbnail(String type, String? url) {
//     // 1. Handle missing URL or Text type
//     if (type == 'Text' || url == null || url.isEmpty) {
//       return _DefaultPlaceholder(type: type);
//     }

//     // 2. Handle Links (This is what you were missing)
//     if (type == 'Link') {
//       return LinkThumbnail(url: url, fallbackType: type);
//     }

//     // 3. Handle Web Platform (Everything must be network image)
//     if (kIsWeb) {
//       return Image.network(
//         url,
//         fit: BoxFit.cover,
//         errorBuilder: (_, __, ___) => _DefaultPlaceholder(type: type),
//       );
//     }
//     // 4. Handle Mobile/Desktop (Network vs Local File)
//     else {
//       bool isNetwork = url.startsWith('http');
//       if (isNetwork) {
//         return Image.network(
//           url,
//           fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) => _DefaultPlaceholder(type: type),
//         );
//       } else {
//         return Image.file(
//           File(url),
//           fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) => _DefaultPlaceholder(type: type),
//         );
//       }
//     }
//   }

//   Widget _buildFilterChip(String label) {
//     final isSelected = _selectedFilter == label;
//     return GestureDetector(
//       onTap: () => setState(() => _selectedFilter = label),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? accentColor.withOpacity(0.2)
//               : innerCardBackgroundColor,
//           borderRadius: BorderRadius.circular(25),
//           border: Border.all(
//             color: isSelected ? accentColor : Colors.transparent,
//             width: 1.5,
//           ),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: isSelected ? accentColor : Colors.white,
//             fontFamily: 'Roboto',
//             fontWeight: FontWeight.w600,
//             fontSize: 16,
//             height: 1.0,
//             letterSpacing: 0.0,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: const TextStyle(
//         color: accentColor,
//         fontFamily: 'Roboto',
//         fontWeight: FontWeight.w600,
//         fontSize: 16,
//         height: 1.0,
//         letterSpacing: 0.0,
//       ),
//     );
//   }

//   Widget _buildTraineeCard({
//     required Map<String, dynamic> traineeData,
//     required String name,
//     required String belt,
//     required String note,
//     String? imageUrl,
//   }) {
//     ImageProvider imageProvider;
//     if (imageUrl != null && imageUrl.isNotEmpty) {
//       if (imageUrl.startsWith('http')) {
//         imageProvider = NetworkImage(imageUrl);
//       } else if (imageUrl.startsWith('assets/')) {
//         imageProvider = AssetImage(imageUrl);
//       } else {
//         try {
//           imageProvider = FileImage(File(imageUrl));
//         } catch (e) {
//           imageProvider = const AssetImage('assets/images/accountLogo.png');
//         }
//       }
//     } else {
//       imageProvider = const AssetImage('assets/images/accountLogo.png');
//     }

//     return GestureDetector(
//       onTap: () {
//         Get.to(() => TraineeDetailScreen(trainee: traineeData));
//       },
//       child: _buildGradientBorderContainer(
//         borderRadius: 16,
//         minHeight: 100,
//         margin: const EdgeInsets.only(bottom: 12),

//         child: Padding(
//           padding: const EdgeInsets.all(16.0 - borderThickness),
//           child: Row(
//             children: [
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.15),
//                       blurRadius: 6,
//                       spreadRadius: 0.5,
//                     ),
//                   ],
//                 ),
//                 child: ClipOval(
//                   child: Image(
//                     image: imageProvider,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Image.asset(
//                         'assets/images/accountLogo.png',
//                         fit: BoxFit.cover,
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),

//               Expanded(
//                 flex: 2,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       name,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontFamily: 'Roboto',
//                         fontWeight: FontWeight.w700,
//                         fontSize: 14,
//                         height: 1.0,
//                         letterSpacing: 0.0,
//                       ),
//                     ),
//                     const SizedBox(height: 14),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: const Color(0x8A72777A),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: const Color(0x8A72777A),
//                           width: 1,
//                         ),
//                       ),
//                       child: Text(
//                         belt,
//                         style: const TextStyle(
//                           color: accentColor,
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 12),
//               // Note
//               Expanded(
//                 flex: 3,
//                 child: Text(
//                   note,
//                   textAlign: TextAlign.right,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontFamily: 'Roboto',
//                     fontWeight: FontWeight.w700,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSessionCard({
//     required String title,
//     required String time,
//     required String date,
//     required String beltType,
//   }) {
//     return _buildGradientBorderContainer(
//       borderRadius: 16,
//       minHeight: 100,

//       child: Padding(
//         padding: const EdgeInsets.all(16.0 - borderThickness),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontFamily: 'Roboto',
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//                 height: 1.0,
//                 letterSpacing: 0.0,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               runSpacing: 6,
//               children: [
//                 Text(
//                   '$time -',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontFamily: 'JejuGothic',
//                     fontWeight: FontWeight.w400,
//                     fontSize: 12,
//                     height: 1.0,
//                     letterSpacing: 0.0,
//                   ),
//                 ),
//                 Text(
//                   '$date -',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontFamily: 'JejuGothic',
//                     fontWeight: FontWeight.w400,
//                     fontSize: 12,
//                     height: 1.0,
//                     letterSpacing: 0.0,
//                   ),
//                 ),
//                 Text(
//                   beltType,
//                   style: const TextStyle(
//                     color: accentColor,
//                     fontFamily: 'JejuGothic',
//                     fontWeight: FontWeight.w400,
//                     fontSize: 12,
//                     height: 1.0,
//                     letterSpacing: 0.0,
//                   ),
//                 ),
//                 const Text(
//                   'Belt Session',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontFamily: 'JejuGothic',
//                     fontWeight: FontWeight.w400,
//                     fontSize: 12,
//                     height: 1.0,
//                     letterSpacing: 0.0,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildForumCard({
//     required String title,
//     required String replies,
//     required IconData icon,
//   }) {
//     return _buildGradientBorderContainer(
//       borderRadius: 16,
//       minHeight: 100,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0 - borderThickness),
//         child: Row(
//           children: [
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 image: const DecorationImage(
//                   image: AssetImage('assets/images/forum1.png'),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontFamily: 'Roboto',
//                       fontWeight: FontWeight.w600,
//                       fontSize: 16,
//                       height: 1.0,
//                       letterSpacing: 0.0,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     'Thread - $replies',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontFamily: 'JejuGothic',
//                       fontWeight: FontWeight.w400,
//                       fontSize: 12,
//                       height: 1.0,
//                       letterSpacing: 0.0,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildResourceCard({
//     required String title,
//     required String subtitle,
//     required String thumbnailUrl,
//   }) {
//     return _buildGradientBorderContainer(
//       borderRadius: 16,
//       minHeight: 100,

//       child: Padding(
//         padding: const EdgeInsets.all(16.0 - borderThickness),
//         child: Row(
//           children: [
//             Container(
//               width: 70,
//               height: 70,
//               decoration: BoxDecoration(
//                 color: const Color(0xFF1A1D2E),
//                 borderRadius: BorderRadius.circular(12),
//                 image: DecorationImage(
//                   image: thumbnailUrl.startsWith('http')
//                       ? NetworkImage(thumbnailUrl)
//                       : AssetImage(thumbnailUrl) as ImageProvider,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontFamily: 'Roboto',
//                       fontWeight: FontWeight.w600,
//                       fontSize: 16,
//                       height: 1.0,
//                       letterSpacing: 0.0,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     subtitle,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontFamily: 'JejuGothic',
//                       fontWeight: FontWeight.w400,
//                       fontSize: 12,
//                       height: 1.0,
//                       letterSpacing: 0.0,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// // ADD THESE CLASSES AT THE BOTTOM OF search_result_screen.dart
// // ---------------------------------------------------------------------------

// class LinkThumbnail extends StatefulWidget {
//   final String url;
//   final String fallbackType;
//   const LinkThumbnail({Key? key, required this.url, required this.fallbackType})
//     : super(key: key);

//   @override
//   State<LinkThumbnail> createState() => _LinkThumbnailState();
// }

// class _LinkThumbnailState extends State<LinkThumbnail> {
//   Future<String?>? _thumbnailFuture;

//   @override
//   void initState() {
//     super.initState();
//     _thumbnailFuture = _fetchLinkImage(widget.url);
//   }

//   Future<String?> _fetchLinkImage(String url) async {
//     try {
//       // 1. YouTube Logic
//       if (url.contains('youtube.com') || url.contains('youtu.be')) {
//         String? videoId;
//         if (url.contains('youtu.be/')) {
//           videoId = url.split('youtu.be/').last.split('?').first;
//         } else if (url.contains('v=')) {
//           videoId = url.split('v=').last.split('&').first;
//         }
//         if (videoId != null && videoId.isNotEmpty) {
//           return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
//         }
//       }
//       // 2. Direct Image Logic
//       if (url.endsWith('.jpg') ||
//           url.endsWith('.png') ||
//           url.endsWith('.jpeg')) {
//         return url;
//       }
//       // 3. Open Graph (Website) Logic
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         RegExp exp = RegExp(r'<meta property="og:image" content="(.*?)"');
//         var match = exp.firstMatch(response.body);
//         if (match != null) return match.group(1);
//       }
//     } catch (_) {}
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<String?>(
//       future: _thumbnailFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return _DefaultPlaceholder(type: widget.fallbackType);
//         }
//         if (snapshot.hasData && snapshot.data != null) {
//           return Image.network(
//             snapshot.data!,
//             fit: BoxFit.cover,
//             errorBuilder: (_, __, ___) =>
//                 _DefaultPlaceholder(type: widget.fallbackType),
//           );
//         }
//         return _DefaultPlaceholder(type: widget.fallbackType);
//       },
//     );
//   }
// }

// class _DefaultPlaceholder extends StatelessWidget {
//   final String type;
//   const _DefaultPlaceholder({Key? key, required this.type}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     IconData iconData = Icons.article;
//     if (type == 'Image') iconData = Icons.image;
//     if (type == 'Video') iconData = Icons.videocam;
//     if (type == 'Link') iconData = Icons.link;
//     if (type == 'Text') iconData = Icons.article;

//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF353A4D),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Center(
//         child: Icon(
//           iconData,
//           color: const Color(0xFF00ff9f).withOpacity(0.5),
//           size: 30,
//         ),
//       ),
//     );
//   }
// }
