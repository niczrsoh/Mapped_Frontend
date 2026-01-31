import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import Get
import 'package:google_fonts/google_fonts.dart';
import 'dart:io'; // Needed for FileImage
import '../controller/controller/trainee_controller.dart'; // Import your controller
import 'add_trainee.dart';
import 'trainee_detail_screen.dart';

class TraineesScreen extends StatefulWidget {
  const TraineesScreen({Key? key}) : super(key: key);

  @override
  State<TraineesScreen> createState() => _TraineesScreenState();
}

class _TraineesScreenState extends State<TraineesScreen> {
  String selectedFilter = 'All';

  // Inject Controller
  final TraineeController traineeController = Get.put(TraineeController());

  static const double borderThickness = 1.5;
  final LinearGradient customGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x1AFFFFFF), Color(0xFA00FFA6)],
  );
  static const Color innerCardBackgroundColor = Color(0x8A72777A);
  static const Color accentColor = Color(0xFF00FFB9);

String _getNextBelt(String currentBelt) {
    switch (currentBelt) {
      case 'White':
        return 'Yellow';
      case 'Yellow':
        return 'Green';
      case 'Green':
        return 'Blue';
      case 'Blue':
        return 'Brown';
      case 'Brown':
        return 'Black';
      default:
        return 'White';
    }
  }

  @override
  void initState() {
    super.initState();
    // Ensure data is fresh when screen loads
    traineeController.fetchTrainees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1d2e),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Trainees Header Card ---
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: customGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(borderThickness),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF141823),
                    borderRadius: BorderRadius.circular(20 - borderThickness),
                  ),
                  padding: EdgeInsets.all(20 - borderThickness),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Trainees',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Reactive count
                          Obx(
                            () => Text(
                              '${traineeController.traineeList.length} active',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddTraineeScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const RadialGradient(
                              center: Alignment(0.0, -1.0),
                              radius: 1.0,
                              colors: [Color(0xFF88D0B7), Color(0xFF00FFA6)],
                              stops: [0.0, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.22),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _outlinedText(
                                '+',
                                GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                strokeWidth: 1.0,
                              ),
                              const SizedBox(width: 6),
                              _outlinedText(
                                'Add',
                                GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                strokeWidth: 1.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Search Bar ---
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: customGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(borderThickness),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF141823),
                    borderRadius: BorderRadius.circular(30 - borderThickness),
                  ),
                  padding: EdgeInsets.all(16 - borderThickness),
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Search by name ...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(right: 20, left: 12),
                        child: Icon(Icons.search, color: accentColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Filter Chips ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 12),
                    _buildFilterChip('White'),
                    const SizedBox(width: 12),
                    _buildFilterChip('Yellow'),
                    const SizedBox(width: 12),
                    _buildFilterChip('Green'),
                    const SizedBox(width: 12),
                    _buildFilterChip('Blue'),
                    const SizedBox(width: 12),
                    _buildFilterChip('Brown'),
                    const SizedBox(width: 12),
                    _buildFilterChip('Black'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Reactive Trainees List ---
              Expanded(
                child: Obx(() {
                  if (traineeController.loading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: accentColor),
                    );
                  }

                  // Filter logic (optional, basic client-side filtering)
                  final displayList = selectedFilter == 'All'
                      ? traineeController.traineeList
                      : traineeController.traineeList
                            .where(
                              (t) =>
                                  t['belt'].toString().toLowerCase() ==
                                  selectedFilter.toLowerCase(),
                            )
                            .toList();

                  if (displayList.isEmpty) {
                    return const Center(
                      child: Text(
                        'No trainees found',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final trainee = displayList[index];
                      return _buildTraineeCard(trainee);
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

  Widget _outlinedText(
    String text,
    TextStyle baseStyle, {
    double strokeWidth = 1.0,
  }) {
    return Stack(
      children: [
        Text(
          text,
          style: baseStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = Colors.black,
          ),
        ),
        Text(text, style: baseStyle.copyWith(color: Colors.white)),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withOpacity(0.2)
              : innerCardBackgroundColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: borderThickness,
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

  Widget _buildTraineeCard(Map<String, dynamic> trainee) {
    final String belt = trainee['belt'] ?? 'White';
    // final Color beltColor = _getBeltColor(belt);
    final String nextBelt = _getNextBelt(belt);

    // Handle Image: Check if it's a network URL, local file path, or asset
    // Since backend might return full object, we usually store image path/url
    // For this example, if 'image' is null, show default icon
    final String? imgData = trainee['image'];
    ImageProvider? avatarImage;

    if (imgData != null && imgData.isNotEmpty) {
      if (imgData.startsWith('http')) {
        avatarImage = NetworkImage(imgData);
      } else if (imgData.startsWith('assets/')) {
        //else if (imgData.contains('/')) {
        // Assuming it's a local file path captured from camera
        //avatarImage = FileImage(File(imgData));
        avatarImage = AssetImage(imgData);
      } else {
        // Fallback for your hardcoded assets if mixed data
        // avatarImage = AssetImage(imgData);
        try {
          final file = File(imgData);
          // Check if file actually exists to prevent crash/error loop
          if (file.existsSync()) {
            avatarImage = FileImage(file);
          } else {
            // File path exists in DB but file is gone from phone cache
            avatarImage = null;
          }
        } catch (e) {
          avatarImage = null;
        }
      }
    }

    return GestureDetector(
      // --- UPDATE THIS ONTAP SECTION ---
      onTap: () {
        // Use Get.to() so the Controller knows this screen exists
        Get.to(() => TraineeDetailScreen(trainee: trainee));
      },
      // return GestureDetector(
      //   onTap: () {
      //     // Pass ID or Trainee Object to detail screen
      //     Navigator.of(
      //       context,
      //     ).push(MaterialPageRoute(builder: (_) => const TraineeRayyanScreen()));
      //   },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: customGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(borderThickness),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141823),
            borderRadius: BorderRadius.circular(20 - borderThickness),
          ),
          padding: EdgeInsets.all(16 - borderThickness),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[700],
                backgroundImage: avatarImage,
                child: avatarImage == null
                    ? Icon(Icons.person, color: Colors.grey[400], size: 32)
                    : null,
              ),
              const SizedBox(width: 16),
              // --- UPDATED ROW STRUCTURE TO FIX DISPLAY ---
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trainee['name'] ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis, // Prevents overflow
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 84,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0x8A72777A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              belt,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // --- DISPLAY NEXT BELT HERE ---
                    Expanded(
                      child: Text(
                        'Note : Next $nextBelt\nBelt in 3 criteria',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.4,
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
  }