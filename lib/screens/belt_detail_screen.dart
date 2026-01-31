import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../controller/controller/trainee_controller.dart';
import 'trainee_detail_screen.dart';

class BeltDetailListScreen extends StatefulWidget {
  final String beltName;

  const BeltDetailListScreen({Key? key, required this.beltName})
    : super(key: key);

  @override
  State<BeltDetailListScreen> createState() => _BeltDetailListScreenState();
}

class _BeltDetailListScreenState extends State<BeltDetailListScreen> {
  // Inject Controller
  final TraineeController controller = Get.put(TraineeController());

  late TextEditingController _searchCtrl;
  final FocusNode _searchFocus = FocusNode();

  // Search query state
  String _searchQuery = "";

  // Styles from your original code
  final LinearGradient _customGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x1AFFFFFF), Color(0xFA00FFA6)],
  );

  static const Color _innerBg = Color(0xFF141823);

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // --- NEW: Helper to calculate Next Belt ---
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1114),
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
        child: Obx(() {
          final beltTrainees = controller.traineeList.where((t) {
            final b = t['belt'].toString().toLowerCase();
            return b == widget.beltName.toLowerCase();
          }).toList();

          final displayList = _searchQuery.isEmpty
              ? beltTrainees
              : beltTrainees.where((t) {
                  final name = (t['name'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _pill(
                  '${widget.beltName} Belt',
                  subtitle: '${displayList.length} active',
                ),

                const SizedBox(height: 18),

                _searchBox(),

                const SizedBox(height: 18),

                if (displayList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'No trainees found.',
                        style: GoogleFonts.roboto(color: Colors.white54),
                      ),
                    ),
                  )
                else
                  Column(
                    children: displayList.map((t) => _traineeCard(t)).toList(),
                  ),

                const SizedBox(height: 60),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _gradientBox({required Widget child, double radius = 20}) {
    return Container(
      decoration: BoxDecoration(
        gradient: _customGradient,
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          color: _innerBg,
          borderRadius: BorderRadius.circular(radius - 1.5),
        ),
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }

  Widget _pill(String title, {String? subtitle}) {
    return SizedBox(
      width: double.infinity,
      child: _gradientBox(
        radius: 20,
        child: SizedBox(
          height: 48,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
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

  Widget _searchBox() {
    return SizedBox(
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
                    color: Colors.white,
                    fontFamily: 'JejuGothic',
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.search,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _searchFocus.requestFocus(),
              child: const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Icon(Icons.search, color: Colors.white70, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _beltBadge(String belt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3136),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        belt,
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _traineeCard(Map<String, dynamic> t) {
    // Logic to display image (Network, Asset, or File)
    final String? imgData = t['image'];
    ImageProvider imageProvider;

    final String currentBelt = t['belt'] ?? widget.beltName;
    final String nextBelt = _getNextBelt(currentBelt);

    final String defaultNote = 'Next $nextBelt Belt in 3 criteria.';

    if (imgData != null && imgData.isNotEmpty) {
      if (imgData.startsWith('http')) {
        imageProvider = NetworkImage(imgData);
      } else if (imgData.startsWith('assets/')) {
        imageProvider = AssetImage(imgData);
      } else {
        // Try file
        try {
          imageProvider = FileImage(File(imgData));
        } catch (e) {
          imageProvider = const AssetImage('assets/images/accountLogo.png');
        }
      }
    } else {
      imageProvider = const AssetImage('assets/images/accountLogo.png');
    }

    return GestureDetector(
      onTap: () {
        Get.to(() => TraineeDetailScreen(trainee: t));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: _gradientBox(
          radius: 14,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade800,
                  backgroundImage: imageProvider,
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
                            ),
                            const SizedBox(height: 6),
                            _beltBadge(t['belt'] ?? ''),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Note : ${t['note'] ?? defaultNote}',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
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
      ),
    );
  }
}
