// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'create_resource.dart'; // Import CreatePostScreen

// class CustomCameraScreen extends StatefulWidget {
//   const CustomCameraScreen({Key? key}) : super(key: key);

//   @override
//   State<CustomCameraScreen> createState() => _CustomCameraScreenState();
// }

// class _CustomCameraScreenState extends State<CustomCameraScreen> {
//   CameraController? _controller;
//   Future<void>? _initializeControllerFuture;
//   bool _isFlashOn = false;
//   double _currentZoom = 1.0;

//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//     _initCamera();
//   }

//   Future<void> _initCamera() async {
//     final cameras = await availableCameras();
//     if (cameras.isEmpty) return;

//     final firstCamera = cameras.first;

//     _controller = CameraController(
//       firstCamera,
//       ResolutionPreset.high,
//       enableAudio: false,
//     );

//     _initializeControllerFuture = _controller!.initialize();
//     if (mounted) setState(() {});
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   Future<void> _takePicture() async {
//     try {
//       await _initializeControllerFuture;
//       final image = await _controller!.takePicture();
//       if (!mounted) return;

//       // CHANGED LOGIC: Navigate forward to CreatePostScreen
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) =>
//               CreatePostScreen(preSelectedImages: [image.path]),
//         ),
//       );
//     } catch (e) {
//       print(e);
//     }
//   }

//   void _toggleFlash() {
//     if (_controller != null) {
//       setState(() {
//         _isFlashOn = !_isFlashOn;
//         _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done &&
//               _controller != null) {
//             return Stack(
//               children: [
//                 SizedBox(
//                   height: double.infinity,
//                   width: double.infinity,
//                   child: CameraPreview(_controller!),
//                 ),

//                 SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const SizedBox(width: 40),

//                         const Text(
//                           'Camera',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),

//                         IconButton(
//                           icon: const Icon(
//                             Icons.close,
//                             color: Colors.white,
//                             size: 28,
//                           ),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Container(
//                     padding: const EdgeInsets.only(
//                       bottom: 40,
//                       left: 30,
//                       right: 30,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         // REAL 1x / 2x OPTICAL ZOOM BUTTON
//                         GestureDetector(
//                           onTap: () async {
//                             if (_controller == null) return;

//                             try {
//                               final minZoom = await _controller!
//                                   .getMinZoomLevel();
//                               final maxZoom = await _controller!
//                                   .getMaxZoomLevel();

//                               print(
//                                 "DEBUG -> minZoom=$minZoom maxZoom=$maxZoom",
//                               );

//                               double target = 2.0;

//                               if (maxZoom < 2.0) {
//                                 // Device does NOT support 2x → fall back to maxZoom
//                                 target = maxZoom;
//                               }

//                               setState(() {
//                                 _currentZoom = (_currentZoom == 1.0)
//                                     ? target
//                                     : 1.0;
//                               });

//                               await _controller!.setZoomLevel(_currentZoom);
//                             } catch (e) {
//                               print("ZOOM ERROR -> $e");
//                             }
//                           },

//                           child: Container(
//                             width: 45,
//                             height: 45,
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.5),
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: Colors.white,
//                                 width: 1.5,
//                               ),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 "${_currentZoom.toStringAsFixed(1)}x",
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),

//                         GestureDetector(
//                           onTap: _takePicture,
//                           child: Container(
//                             height: 80,
//                             width: 80,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(color: Colors.white, width: 4),
//                               color: Colors.transparent,
//                             ),
//                             child: Container(
//                               margin: const EdgeInsets.all(4),
//                               decoration: const BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),

//                         Container(
//                           width: 45,
//                           height: 45,
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.5),
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white, width: 1.5),
//                           ),
//                           child: IconButton(
//                             padding: EdgeInsets.zero,
//                             icon: Icon(
//                               _isFlashOn ? Icons.flash_on : Icons.flash_off,
//                               color: _isFlashOn ? Colors.yellow : Colors.white,
//                               size: 24,
//                             ),
//                             onPressed: _toggleFlash,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           } else {
//             return const Center(
//               child: CircularProgressIndicator(color: Color(0xFF00ff9f)),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
