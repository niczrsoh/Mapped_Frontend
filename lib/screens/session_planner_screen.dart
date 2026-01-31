import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import '../screens/main_navigation_screen.dart';
import '../controller/controller/session_controller.dart';

class SessionPlannerScreen extends StatefulWidget {
  const SessionPlannerScreen({super.key});

  @override
  State<SessionPlannerScreen> createState() => _SessionPlannerScreenState();
}

class _SessionPlannerScreenState extends State<SessionPlannerScreen> {
  // 3. INJECT THE CONTROLLER
  final SessionController sessionController = Get.find<SessionController>();

  final _trainerCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();

  // Focus Nodes (For Validation Logic)
  final FocusNode _trainerFocus = FocusNode();
  final FocusNode _venueFocus = FocusNode();
  final FocusNode _numberFocus = FocusNode();

  // Error Messages
  String? _trainerError;
  String? _dateError;
  String? _timeError;
  String? _venueError;
  String? _numberError;

  // --- NEW: Private variables to hold actual Date/Time objects ---
  DateTime? _selectedDate;
  TimeOfDay? _startTx;
  TimeOfDay? _endTx;

  @override
  void initState() {
    super.initState();

    // Validation Listeners (Same logic as Add Trainee, but applied to these fields)
    _trainerFocus.addListener(() {
      if (!_trainerFocus.hasFocus) {
        setState(() {
          _trainerError = _trainerCtrl.text.trim().isEmpty
              ? "Trainer name is required"
              : null;
        });
      }
    });

    _venueFocus.addListener(() {
      if (!_venueFocus.hasFocus) {
        setState(() {
          _venueError = _venueCtrl.text.trim().isEmpty
              ? "Venue is required"
              : null;
        });
      }
    });

    _numberFocus.addListener(() {
      if (!_numberFocus.hasFocus) {
        setState(() {
          if (_numberCtrl.text.trim().isEmpty) {
            _numberError = "Number is required";
          } else if (int.tryParse(_numberCtrl.text.trim()) == null) {
            _numberError = "Invalid number";
          } else {
            _numberError = null;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _trainerCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _venueCtrl.dispose();
    _numberCtrl.dispose();
    _trainerFocus.dispose();
    _venueFocus.dispose();
    _numberFocus.dispose();
    super.dispose();
  }

  // --- VALIDATE ALL ---
  bool _validateAll() {
    setState(() {
      _trainerError = _trainerCtrl.text.trim().isEmpty
          ? "Trainer name is required"
          : null;
      _venueError = _venueCtrl.text.trim().isEmpty ? "Venue is required" : null;

      if (_numberCtrl.text.trim().isEmpty) {
        _numberError = "Number is required";
      } else if (int.tryParse(_numberCtrl.text.trim()) == null) {
        _numberError = "Invalid number";
      } else {
        _numberError = null;
      }

      _dateError = _dateCtrl.text.isEmpty ? "Date is required" : null;
      _timeError = _timeCtrl.text.isEmpty ? "Time is required" : null;
    });

    return _trainerError == null &&
        _dateError == null &&
        _timeError == null &&
        _venueError == null &&
        _numberError == null;
  }

  // --- DATE PICKER LOGIC ---
  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00FFA6),
              onPrimary: Colors.black,
              surface: Color(0xFF141823),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF141823),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _selectedDate = picked;
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sept',
        'Oct',
        'Nov',
        'Dec',
      ];
      final weekday = days[picked.weekday - 1];
      final month = months[picked.month - 1];
      setState(() {
        _dateCtrl.text = "$weekday, $month ${picked.day}, ${picked.year}";
        _dateError = null; // Clear error
      });
    }
  }

  // --- TIME PICKER LOGIC ---
  Future<void> _pickTime() async {
    FocusScope.of(context).unfocus();
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: "SELECT START TIME",
      builder: (context, child) => _timePickerTheme(child!),
    );

    if (startTime == null) return;

    // ignore: use_build_context_synchronously
    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: (startTime.hour + 1) % 24,
        minute: startTime.minute,
      ),
      helpText: "SELECT END TIME",
      builder: (context, child) => _timePickerTheme(child!),
    );

    if (endTime == null) return;

    _startTx = startTime;
    _endTx = endTime;

    // ignore: use_build_context_synchronously
    setState(() {
      _timeCtrl.text =
          "${startTime.format(context)} - ${endTime.format(context)}";
      _timeError = null; // Clear error
    });
  }

  Widget _timePickerTheme(Widget child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FFA6),
          onPrimary: Colors.black,
          surface: Color(0xFF141823),
          onSurface: Colors.white,
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: const Color(0xFF141823),
          dialHandColor: const Color(0xFF00FFA6),
          dialBackgroundColor: Colors.grey.shade800,
          hourMinuteTextColor: Colors.white,
          dayPeriodTextColor: Colors.white,
          entryModeIconColor: const Color(0xFF00FFA6),
        ),
      ),
      child: child,
    );
  }

  Widget _gradientTextField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    FocusNode? focusNode, // Added to original layout
    String? errorText, // Added to original layout
  }) {
    final outerRadius = 50.0;
    final innerRadius = 47.0;

    // Wrapped in Column to show error text below, keeping original style above
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
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
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFF141823),
                borderRadius: BorderRadius.circular(innerRadius),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: keyboardType,
                readOnly: readOnly,
                onTap: onTap,
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
        ),
        // Error Message (Added logic, maintains style)
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              errorText,
              style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  void _showConfirmation(BuildContext context) {
    // 1. Run Validation Logic
    final bool isValid = _validateAll();

    // 2. Logic: Change Message/Icon based on validity
    final String dialogMessage = isValid
        ? 'Are you sure want to create a session?'
        : 'Please complete all required fields.';

    final IconData dialogIcon = isValid
        ? Icons.warning_amber_rounded
        : Icons.error_outline_rounded;

    final Color dialogIconColor = isValid
        ? Colors.red
        : Colors.redAccent.shade700;

    // Original Style Color
    final dialogBtnColor = const Color(0xFF09FACA);

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
                // Icon (Visuals kept from original, just dynamic data)
                Container(
                  width: 96,
                  height: 72,
                  alignment: Alignment.center,
                  child: Icon(dialogIcon, color: dialogIconColor, size: 56),
                ),
                const SizedBox(height: 8),
                Text(
                  dialogMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // Original Button Layout
                Row(
                  children: [
                    // CANCEL BUTTON
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

                    // OK BUTTON
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
                        onPressed: () async {
                          // 1. Close Dialog
                          Navigator.of(dialogContext).pop();

                          if (isValid) {
                            // 🛑 SAFETY CHECK: Did the user actually pick a Date and Time?
                            if (_selectedDate == null ||
                                _startTx == null ||
                                _endTx == null) {
                              Get.snackbar(
                                'Missing Info',
                                'Please select a Date and Time first!',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return; // STOP HERE so it doesn't crash
                            }

                            // 2. Only submit if Valid
                            // --- CONSTRUCT ACTUAL DATE OBJECTS ---
                            // Merge Date + Start Time
                            final startDateTime = DateTime(
                              _selectedDate!.year,
                              _selectedDate!.month,
                              _selectedDate!.day,
                              _startTx!.hour,
                              _startTx!.minute,
                            );

                            // Merge Date + End Time
                            // Handle logic if end time is technically the next day?
                            // For now, assuming same day.
                            final endDateTime = DateTime(
                              _selectedDate!.year,
                              _selectedDate!.month,
                              _selectedDate!.day,
                              _endTx!.hour,
                              _endTx!.minute,
                            );

                            await sessionController.createSession(
                              trainer: _trainerCtrl.text,
                              // Send ISO Strings to backend
                              date: _dateCtrl.text,
                              startTime: startDateTime.toIso8601String(),
                              endTime: endDateTime.toIso8601String(),
                              venue: _venueCtrl.text,
                              totalTrainees: _numberCtrl.text,
                            );

                            if (sessionController.success.value) {
                              Get.snackbar(
                                'Success',
                                'Session Created Successfully',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFF141823),
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(10),
                              );

                              Get.offAll(
                                () =>
                                    const MainNavigationScreen(initialIndex: 1),
                              );
                            } else {
                              Get.snackbar(
                                'Error',
                                sessionController.error.value,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(10),
                              );
                            }
                          }
                          // If invalid, dialog closes, showing errors on screen
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
    final themeBg = const Color(0xFF141823);
    final innerFill = const Color(0xFF00FFA6);

    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 8,
        leadingWidth: 40,
        leading: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Session Planner',
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
              _gradientTextField(
                _trainerCtrl,
                'Name',
                focusNode: _trainerFocus,
                errorText: _trainerError,
              ),
              const SizedBox(height: 18),
              Text(
                'Date',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _gradientTextField(
                _dateCtrl,
                'Date',
                readOnly: true,
                onTap: _pickDate,
                errorText: _dateError,
              ),
              const SizedBox(height: 18),
              Text(
                'Time',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _gradientTextField(
                _timeCtrl,
                'Time',
                readOnly: true,
                onTap: _pickTime,
                errorText: _timeError,
              ),
              const SizedBox(height: 18),
              Text(
                'Venue',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _gradientTextField(
                _venueCtrl,
                'Venue',
                focusNode: _venueFocus,
                errorText: _venueError,
              ),
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
                focusNode: _numberFocus,
                errorText: _numberError,
              ),
              const SizedBox(height: 28),
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
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: innerFill,
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
