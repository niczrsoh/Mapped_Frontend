import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import '../controller/controller/session_controller.dart';

class EditSessionScreen extends StatefulWidget {
  final Map<String, dynamic> sessionData;

  const EditSessionScreen({super.key, required this.sessionData});

  @override
  State<EditSessionScreen> createState() => _EditSessionScreenState();
}

class _EditSessionScreenState extends State<EditSessionScreen> {
  // Inject Controller
  final SessionController sessionController = Get.find<SessionController>();

  late TextEditingController _trainerCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _timeCtrl;
  late TextEditingController _venueCtrl;
  late TextEditingController _numberCtrl;

  // Focus Nodes
  final FocusNode _trainerFocus = FocusNode();
  final FocusNode _venueFocus = FocusNode();
  final FocusNode _numberFocus = FocusNode();

  // Error Messages
  String? _trainerError;
  String? _dateError;
  String? _timeError;
  String? _venueError;
  String? _numberError;

  // --- LOGIC FROM SESSION PLANNER: Private variables for Objects ---
  DateTime? _selectedDate;
  TimeOfDay? _startTx;
  TimeOfDay? _endTx;

  @override
  void initState() {
    super.initState();
    // Prefill data from the passed sessionData
    _trainerCtrl = TextEditingController(
      text: widget.sessionData['trainer'] ?? '',
    );
    _dateCtrl = TextEditingController(text: widget.sessionData['date'] ?? '');
    _timeCtrl = TextEditingController(text: widget.sessionData['time'] ?? '');
    _venueCtrl = TextEditingController(text: widget.sessionData['venue'] ?? '');
    _numberCtrl = TextEditingController(
      text: widget.sessionData['number'] != null
          ? widget.sessionData['number'].toString()
          : '',
    );

    // ✅ IMPORTANT: Try to parse existing strings back into Objects
    _parseInitialData();

    // Add Validation Listeners
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

  // --- HELPER: RECONSTRUCT OBJECTS FROM STRINGS ---
  void _parseInitialData() {
    try {
      // 1. Initialize with Now as fallback
      _selectedDate = DateTime.now();

      // 2. ✅ FIX: Parse the Date String "Wed, Dec 11, 2025"
      String dStr = _dateCtrl.text; // e.g. "Wed, Dec 11, 2025"
      if (dStr.isNotEmpty) {
        // Remove commas to make splitting easier: "Wed Dec 11 2025"
        String cleanStr = dStr.replaceAll(',', '');
        // Split by space and remove empty entries (handles double spaces)
        List<String> parts = cleanStr
            .split(' ')
            .where((s) => s.isNotEmpty)
            .toList();

        // Expected parts: [Weekday, Month, Day, Year] -> ["Wed", "Dec", "11", "2025"]
        if (parts.length >= 4) {
          String monthStr = parts[1];
          String dayStr = parts[2];
          String yearStr = parts[3];

          int year = int.parse(yearStr);
          int day = int.parse(dayStr);
          int month = _monthStringToInt(monthStr);

          // Update _selectedDate to the ACTUAL session date
          _selectedDate = DateTime(year, month, day);
        }
      }

      // 3. Parse Time String "6:00 PM - 7:00 PM"
      String tStr = _timeCtrl.text;
      if (tStr.isNotEmpty && tStr.contains(' - ')) {
        List<String> times = tStr.split(' - ');
        _startTx = _parseTimeOfDay(times[0]);
        _endTx = _parseTimeOfDay(times[1]);
      }
    } catch (e) {
      print("Error parsing initial data: $e");
    }
  }

  // Helper to convert Month name to int
  int _monthStringToInt(String m) {
    // Handle both "Sept" (Flutter default) and "Sep" (Backend default)
    if (m.startsWith('Sep')) return 9;

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    int index = months.indexOf(m);
    if (index != -1) return index + 1;
    return 1; // Default to Jan if fail
  }

  TimeOfDay? _parseTimeOfDay(String timeString) {
    try {
      // Format ex: "6:00 PM"
      final parts = timeString.trim().split(' '); // ["6:00", "PM"]
      final timeParts = parts[0].split(':'); // ["6", "00"]
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      if (parts.length > 1) {
        if (parts[1] == 'PM' && hour != 12) hour += 12;
        if (parts[1] == 'AM' && hour == 12) hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
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

  // --- CONFIRMATION DIALOG ---
  void _showConfirmation(BuildContext context) {
    final bool isValid = _validateAll();

    final String dialogMessage = isValid
        ? 'Are you sure want to update this session?'
        : 'Please complete all required fields.';

    final IconData dialogIcon = isValid
        ? Icons.warning_amber_rounded
        : Icons.error_outline_rounded;

    final Color dialogIconColor = isValid
        ? Colors.red
        : Colors.redAccent.shade700;

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

                // Button Layout
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
                          Navigator.of(dialogContext).pop();

                          if (isValid) {
                            // If _selectedDate is null (parsing failed), we use Now as fallback
                            DateTime finalDate =
                                _selectedDate ?? DateTime.now();
                            TimeOfDay startT =
                                _startTx ?? const TimeOfDay(hour: 0, minute: 0);
                            TimeOfDay endT =
                                _endTx ?? const TimeOfDay(hour: 0, minute: 0);

                            final startDateTime = DateTime(
                              finalDate.year,
                              finalDate.month,
                              finalDate.day,
                              startT.hour,
                              startT.minute,
                            );

                            final endDateTime = DateTime(
                              finalDate.year,
                              finalDate.month,
                              finalDate.day,
                              endT.hour,
                              endT.minute,
                            );

                            await sessionController.updateSession(
                              id: widget.sessionData['id'] ?? '',
                              trainer: _trainerCtrl.text,
                              date: _dateCtrl.text,
                              startTime: startDateTime.toIso8601String(),
                              endTime: endDateTime.toIso8601String(),
                              venue: _venueCtrl.text,
                              totalTrainees: _numberCtrl.text,
                            );

                            if (sessionController.success.value) {
                              Get.back(result: true);
                              Get.snackbar(
                                'Success',
                                'Session updated successfully',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFF141823),
                                colorText: Colors.white,
                              );
                            } else {
                              Get.snackbar(
                                'Error',
                                sessionController.error.value,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                            }
                          }
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

  // --- DATE PICKER LOGIC (Matches Session Planner) ---
  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    // Allow picking past dates for editing
    final initialDate = _selectedDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
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
      final year = picked.year;

      setState(() {
        _dateCtrl.text = "$weekday, $month ${picked.day}, $year";
        _dateError = null;
      });
    }
  }

  // --- TIME PICKER LOGIC (Matches Session Planner) ---
  Future<void> _pickTime() async {
    FocusScope.of(context).unfocus();
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: _startTx ?? TimeOfDay.now(),
      helpText: "SELECT START TIME",
      builder: (context, child) => _timePickerTheme(child!),
    );

    if (startTime == null) return;

    // ignore: use_build_context_synchronously
    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime:
          _endTx ??
          TimeOfDay(hour: (startTime.hour + 1) % 24, minute: startTime.minute),
      helpText: "SELECT END TIME",
      builder: (context, child) => _timePickerTheme(child!),
    );

    if (endTime == null) return;

    // Save objects
    _startTx = startTime;
    _endTx = endTime;

    // ignore: use_build_context_synchronously
    setState(() {
      _timeCtrl.text =
          "${startTime.format(context)} - ${endTime.format(context)}";
      _timeError = null;
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
    FocusNode? focusNode,
    String? errorText,
  }) {
    final outerRadius = 50.0;
    final innerRadius = 47.0;

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

  @override
  Widget build(BuildContext context) {
    final themeBg = const Color(0xFF141823);

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
          'Edit Session',
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

              // Trainer
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

              // Date
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

              // Time
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

              // Venue
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

              // Number
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
              const SizedBox(height: 40),

              // Save/Cancel Buttons
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // CANCEL BUTTON
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
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

                    // SAVE BUTTON
                    GestureDetector(
                      onTap: () {
                        _showConfirmation(context);
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
