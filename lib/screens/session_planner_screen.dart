import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:get/get.dart';

class SessionPlannerScreen extends StatefulWidget {
  // optional initialSession: used when opening the screen to edit an existing session
  final Map<String, String>? initialSession;
  final bool isEditing;

  const SessionPlannerScreen({
    super.key,
    this.initialSession,
    this.isEditing = false,
  });

  @override
  State<SessionPlannerScreen> createState() => _SessionPlannerScreenState();
}

class _SessionPlannerScreenState extends State<SessionPlannerScreen> {
  final _trainerCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  bool _sessionCreated = false;
  Map<String, String>? _createdSession;

  @override
  void dispose() {
    _trainerCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _venueCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // if opened for editing, prefill fields and show the Save/Cancel buttons
    if (widget.initialSession != null) {
      final s = widget.initialSession!;
      _trainerCtrl.text = s['trainer'] ?? '';
      _dateCtrl.text = s['date'] ?? '';
      _timeCtrl.text = s['time'] ?? '';
      _venueCtrl.text = s['venue'] ?? '';
      _numberCtrl.text = s['number'] ?? '';
      _sessionCreated = true;
      _createdSession = Map<String, String>.from(s);
    }
  }

  // Gradient bordered text field: 304x50, 3px gradient border, 50px radius
  Widget _gradientTextField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
  }) {
    final outerRadius = 50.0;
    final innerRadius = 47.0; // outer minus border
    // Stretch to the available width so fields align with labels.
    return SizedBox(
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [Color(0xFF7FF4D3), Color(0xFF09FACA)],
            transform: GradientRotation(95.92 * math.pi / 180),
          ),
          borderRadius: BorderRadius.circular(outerRadius),
        ),
        child: Container(
          margin: const EdgeInsets.all(3), // border width 3
          decoration: BoxDecoration(
            color: const Color(0xFF141823),
            borderRadius: BorderRadius.circular(innerRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.white),
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 14,
              ),
            ),
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

  void _showConfirmation(BuildContext context) {
    final dialogBtnColor = const Color(0xFF09FACA);
    final data = {
      'trainer': _trainerCtrl.text,
      'date': _dateCtrl.text,
      'time': _timeCtrl.text,
      'venue': _venueCtrl.text,
      'number': _numberCtrl.text,
    };

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning icon (can be replaced with a custom triangular asset later)
                Container(
                  width: 96,
                  height: 72,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure want to create a session?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dialogBtnColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 6,
                          shadowColor: dialogBtnColor.withOpacity(0.4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: Text(
                          'CANCEL',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dialogBtnColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 6,
                          shadowColor: dialogBtnColor.withOpacity(0.4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          // close dialog and show the Cancel/Save buttons below
                          Navigator.of(dialogContext).pop();
                          setState(() {
                            _sessionCreated = true;
                            _createdSession = data.map(
                              (k, v) => MapEntry(k, v.toString()),
                            );
                          });
                        },
                        child: Text(
                          'OK',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeBg = const Color(0xFF0F1114);
    final innerFill = const Color(0xFF00FFA6);

    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // make the gap between leading icon and title smaller
        titleSpacing: 8,
        leadingWidth: 40,
        leading: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.isEditing ? 'Edit Session' : 'Session Planner',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF26282B),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Session Planner',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Trainer',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _gradientTextField(_trainerCtrl, 'Name'),
              const SizedBox(height: 18),

              Text(
                'Date',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _gradientTextField(_dateCtrl, 'Date'),
              const SizedBox(height: 18),

              Text(
                'Time',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _gradientTextField(_timeCtrl, 'Time'),
              const SizedBox(height: 18),

              Text(
                'Venue',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _gradientTextField(_venueCtrl, 'Venue'),
              const SizedBox(height: 18),

              Text(
                'Total Number of Trainee',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _gradientTextField(
                _numberCtrl,
                'Number',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 28),

              // Centered create session button with 2px gradient border simulation
              if (!_sessionCreated)
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 35,
                    child: GestureDetector(
                      onTap: () => _showConfirmation(context),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment(-1.0, -0.2),
                            end: Alignment(1.0, 0.2),
                            colors: [Color(0xFFFFFFFF), Color(0xFF666E6D)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(2), // border width 2px
                          decoration: BoxDecoration(
                            color: innerFill, // inner fill
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Text(
                            'CREATE SESSION',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 18),
              // show Cancel / Save buttons after session is created
              if (_sessionCreated && _createdSession != null)
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Cancel pill
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _sessionCreated = false;
                            _createdSession = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const RadialGradient(
                              // approximate: center at top-center, elongated vertical radius
                              center: Alignment(0.0, -1.0),
                              radius: 1.0,
                              colors: [Color(0xFFCBD5D2), Color(0xFF7E8783)],
                              stops: [0.0, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _outlinedText(
                            'Cancel',
                            GoogleFonts.poppins(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Save pill
                      GestureDetector(
                        onTap: () {
                          // return created session to previous screen
                          Get.back(result: _createdSession);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const RadialGradient(
                              center: Alignment(0.0, -1.0),
                              radius: 1.0,
                              colors: [Color(0xFF88D0B7), Color(0xFF00FFA6)],
                              stops: [0.0, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: _outlinedText(
                            'Save',
                            GoogleFonts.poppins(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
