import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_trainee.dart';

class TraineesScreen extends StatefulWidget {
  const TraineesScreen({Key? key}) : super(key: key);

  @override
  State<TraineesScreen> createState() => _TraineesScreenState();
}

class _TraineesScreenState extends State<TraineesScreen> {
  String selectedFilter = 'All';

  // Gradient border helper constants (match search_result_screen style)
  static const double borderThickness = 1.5;
  final LinearGradient customGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x1AFFFFFF), Color(0xFA00FFA6)],
  );
  // Chip/label background color requested: #72777A8A
  static const Color innerCardBackgroundColor = Color(0x8A72777A);
  static const Color accentColor = Color(0xFF00FFB9);

  final List<Map<String, dynamic>> trainees = [
    {
      'name': 'Rayyan Firas',
      'belt': 'White',
      'color': Colors.white,
      'note': 'Note : Next Green Belt\nin 2 criteria',
      'image': 'assets/rayyan.jpg',
    },
    {
      'name': 'Amirah Aini',
      'belt': 'Red',
      'color': Colors.red,
      'note': 'Note : Next Black Belt\nin 3 criteria',
      'image': 'assets/amirah.jpg',
    },
    {
      'name': 'Badrul Hisham',
      'belt': 'Green',
      'color': Colors.green,
      'note': 'Note : Next Green Belt\nin 2 criteria',
      'image': 'assets/badrul.jpg',
    },
    {
      'name': 'Chan Wei Tian',
      'belt': 'Yellow',
      'color': Colors.yellow,
      'note': 'Note : Next Green Belt\nin 3 criteria',
      'image': 'assets/chan.jpg',
    },
  ];

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
              // Header with back button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
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

              // Trainees header card (gradient border)
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
                        children: const [
                          Text(
                            'Trainees',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '24 active',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                      // Smaller gradient Add button (matches SessionPlanner 'Save' style)
                      GestureDetector(
                        onTap: () async {
                          // Navigate to Add Trainee screen
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

              // Search bar (gradient border)
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

              // Filter chips (responsive: justified on wide, scrollable on small)
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 480) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFilterChip('All'),
                        _buildFilterChip('White'),
                        _buildFilterChip('Yellow'),
                        _buildFilterChip('Green'),
                        _buildFilterChip('Blue'),
                        _buildFilterChip('Red'),
                        _buildFilterChip('Black'),
                      ],
                    );
                  }

                  return SingleChildScrollView(
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
                        _buildFilterChip('Red'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Black'),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Trainees list
              Expanded(
                child: ListView.builder(
                  itemCount: trainees.length,
                  itemBuilder: (context, index) {
                    // Cycle through Trainee1..Trainee6 images for avatars
                    final imagePath =
                        'assets/images/Trainee${(index % 6) + 1}.png';
                    return _buildTraineeCard(
                      trainees[index],
                      imageOverride: imagePath,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to render white text with a 1px black outline (stroke)
  Widget _outlinedText(
    String text,
    TextStyle baseStyle, {
    double strokeWidth = 1.0,
  }) {
    return Stack(
      children: [
        // stroke
        Text(
          text,
          style: baseStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = Colors.black,
          ),
        ),
        // fill
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

  Widget _buildTraineeCard(
    Map<String, dynamic> trainee, {
    String? imageOverride,
  }) {
    final imagePath = imageOverride ?? (trainee['image'] as String?);
    ImageProvider? avatarImage;
    if (imagePath != null) {
      avatarImage = AssetImage(imagePath);
    }

    return Container(
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
            // Profile image (use Trainee images if available)
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[700],
              backgroundImage: avatarImage,
              child: avatarImage == null
                  ? Icon(Icons.person, color: Colors.grey[400], size: 32)
                  : null,
            ),
            const SizedBox(width: 16),

            // Name and belt
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trainee['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Fixed-size belt badge (match visual size of the 'White' filter chip)
                  Container(
                    width: 84,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0x8A72777A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trainee['belt'],
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

            // Note
            Text(
              trainee['note'],
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
