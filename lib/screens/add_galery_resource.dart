// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter/foundation.dart';

// class AddGalleryResourceScreen extends StatefulWidget {
//   final List<String>? initialSelected;

//   const AddGalleryResourceScreen({Key? key, this.initialSelected})
//     : super(key: key);

//   @override
//   State<AddGalleryResourceScreen> createState() =>
//       _AddGalleryResourceScreenState();
// }

// class _AddGalleryResourceScreenState extends State<AddGalleryResourceScreen> {
//   final ImagePicker _picker = ImagePicker();
//   List<XFile> _picked = [];

//   @override
//   void initState() {
//     super.initState();
//     if (widget.initialSelected != null && widget.initialSelected!.isNotEmpty) {
//       _picked = widget.initialSelected!.map((p) => XFile(p)).toList();
//     }
//   }

//   Future<void> _openSystemGallery() async {
//     try {
//       final images = await _picker.pickMultiImage(imageQuality: 85);
//       if (images.isNotEmpty) {
//         final existingPaths = _picked.map((e) => e.path).toSet();
//         final toAdd = images
//             .where((x) => !existingPaths.contains(x.path))
//             .toList();

//         if (toAdd.isNotEmpty) {
//           setState(() {
//             _picked.addAll(toAdd);
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('pickMultiImage error: $e');
//     }
//   }

//   void _removeImage(int index) {
//     setState(() {
//       _picked.removeAt(index);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     const backgroundColor = Color(0xFF141823);
//     const tealColor = Color(0xFF00C8B3);
//     const cameraIconColor = Color(0xFFFF4560);

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: backgroundColor,
//         elevation: 0,
//         centerTitle: false,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'Resources',
//           style: GoogleFonts.inter(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               final paths = _picked.map((x) => x.path).toList();
//               // RETURN DATA TO PREVIOUS SCREEN
//               Navigator.pop(context, paths);
//             },
//             child: Text(
//               'Done',
//               style: GoogleFonts.poppins(
//                 color: tealColor,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: GridView.builder(
//         padding: const EdgeInsets.all(12),
//         itemCount: _picked.length + 1,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           crossAxisSpacing: 8,
//           mainAxisSpacing: 8,
//           childAspectRatio: 1,
//         ),
//         itemBuilder: (context, index) {
//           if (index == 0) {
//             return GestureDetector(
//               onTap: _openSystemGallery,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(0),
//                 ),
//                 child: Center(
//                   child: Icon(
//                     Icons.camera_alt_outlined,
//                     color: cameraIconColor,
//                     size: 32,
//                   ),
//                 ),
//               ),
//             );
//           }

//           final imageIndex = index - 1;
//           final file = _picked[imageIndex].path;

//           final imageWidget = kIsWeb
//               ? Image.network(file, fit: BoxFit.cover)
//               : Image.file(File(file), fit: BoxFit.cover);
//           return Stack(
//             children: [
//               Positioned.fill(child: imageWidget),
//               Positioned(
//                 top: 4,
//                 right: 4,
//                 child: GestureDetector(
//                   onTap: () => _removeImage(imageIndex),
//                   child: Container(
//                     padding: const EdgeInsets.all(2),
//                     decoration: const BoxDecoration(
//                       color: Colors.black54,
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.close,
//                       size: 16,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
