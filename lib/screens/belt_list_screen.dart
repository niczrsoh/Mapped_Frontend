import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controller/controller/trainee_controller.dart';

class BeltListScreen extends StatefulWidget {
  final String beltName;
  final Color themeColor;

  const BeltListScreen({
    Key? key,
    required this.beltName,
    required this.themeColor,
  }) : super(key: key);

  @override
  State<BeltListScreen> createState() => _BeltListScreenState();
}

class _BeltListScreenState extends State<BeltListScreen> {
  final TraineeController traineeController = Get.find<TraineeController>();
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // Local state for search text to trigger UI updates
  final RxString _searchText = ''.obs;

  @override
  void initState() {
    super.initState();
    // Ensure data is fresh when entering the screen
    traineeController.fetchTrainees();

    _searchCtrl.addListener(() {
      _searchText.value = _searchCtrl.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // --- UI HELPERS ---

  // 1. ADDED: Helper to calculate Next Belt
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

  Widget _gradientBox({required Widget child, double radius = 20}) {
    // Dynamic gradient based on the belt theme color
    final LinearGradient customGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        widget.themeColor.withOpacity(0.1), // Tint with belt color
        widget.themeColor.withOpacity(0.4),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: customGradient,
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141823),
          borderRadius: BorderRadius.circular(radius - 1.5),
        ),
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }

  Widget _beltBadge(String belt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3136),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.themeColor.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Text(
        belt,
        style: GoogleFonts.roboto(
          color: widget.themeColor, // Use theme color for text
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  ImageProvider _getDisplayImage(String? imgPath) {
    if (imgPath != null && imgPath.isNotEmpty) {
      if (imgPath.startsWith('http')) return NetworkImage(imgPath);
      if (imgPath.startsWith('assets/')) return AssetImage(imgPath);
      try {
        final f = File(imgPath);
        if (f.existsSync()) return FileImage(f);
      } catch (e) {
        // ignore error
      }
    }
    return const AssetImage('assets/images/placeholder_avatar.png');
  }

  Widget _traineeCard(Map<String, dynamic> t) {
    final String currentBelt = t['belt'] ?? widget.beltName;
  // Calculate the next belt
  final String nextBelt = _getNextBelt(currentBelt);
  
  // This is the new dynamic default text
  final String defaultNote = 'Next $nextBelt Belt in 3 criteria.';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: _gradientBox(
        radius: 14,
        child: Container(
          color: const Color(0xFF0F1419),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: _getDisplayImage(t['image']),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t['name'] ?? 'Unknown',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          _beltBadge(t['belt'] ?? widget.beltName),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Note : ${t['note'] ?? defaultNote}',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.roboto(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141823),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${widget.beltName} Belt',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Pill (Counts active trainees dynamically)
              Obx(() {
                final count = traineeController.traineeList
                    .where(
                      (t) =>
                          t['belt'].toString().toLowerCase() ==
                          widget.beltName.toLowerCase(),
                    )
                    .length;

                return SizedBox(
                  width: double.infinity,
                  child: _gradientBox(
                    radius: 20,
                    child: SizedBox(
                      height: 48,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.beltName} Belt',
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$count active',
                                style: GoogleFonts.roboto(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 18),

              // 2. Search Box
              SizedBox(
                width: double.infinity,
                child: _gradientBox(
                  radius: 20,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          focusNode: _searchFocus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'JejuGothic',
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search by name ...',
                            hintStyle: TextStyle(
                              color: Colors.white54,
                              fontFamily: 'JejuGothic',
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _searchFocus.requestFocus(),
                        child: const Icon(
                          Icons.search,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 3. Trainee List (Filtered via Obx)
              Expanded(
                child: Obx(() {
                  if (traineeController.loading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: widget.themeColor,
                      ),
                    );
                  }

                  // Filter Logic: Match Belt Name AND Search Text
                  final filteredList = traineeController.traineeList.where((t) {
                    final beltMatch =
                        (t['belt'] ?? '').toString().toLowerCase() ==
                        widget.beltName.toLowerCase();
                    final nameMatch = (t['name'] ?? '')
                        .toString()
                        .toLowerCase()
                        .contains(_searchText.value);
                    return beltMatch && nameMatch;
                  }).toList();

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Text(
                        'No trainees found.',
                        style: GoogleFonts.poppins(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredList.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      // Cast to Map<String, dynamic> safely
                      final trainee = Map<String, dynamic>.from(
                        filteredList[index],
                      );
                      return _traineeCard(trainee);
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
}
