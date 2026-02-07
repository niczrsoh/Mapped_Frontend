import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/session/session_controller.dart';
import 'session_details.dart';
import 'session_model.dart'; 
import '../screens/main_navigation_screen.dart';

class SessionFlowScreen extends StatefulWidget {
  final Map<String, dynamic> accumulatedData;

  const SessionFlowScreen({super.key, required this.accumulatedData});

  @override
  State<SessionFlowScreen> createState() => _SessionFlowScreenState();
}

class _SessionFlowScreenState extends State<SessionFlowScreen> {
  final SessionController sessionController = Get.put(SessionController());
  final _goalsCtrl = TextEditingController();
  final _warmupDescCtrl = TextEditingController();
  final _warmupTimeCtrl = TextEditingController();
  final _activityDescCtrl = TextEditingController();
  final _activityTimeCtrl = TextEditingController();
  final _cooldownDescCtrl = TextEditingController();
  final _cooldownTimeCtrl = TextEditingController();
  final _contingenciesCtrl = TextEditingController();

  final Color bgColor = const Color(0xFF141823);
  final Color cardColor = const Color(0xFF1C1C1E);
  final Color inputBg = const Color(0xFF2C2C2E);
  final Color primaryGreen = const Color(0xFF00C875);
  final Color accentPurple = const Color(0xFF9FA0B5);

  String? _goalError;
  String? _warmupError;
  String? _activityError;
  String? _cooldownError;
  String? _contingenciesError;
  String? _timeError;
  String? _activityTimeError;
  String? _cooldownTimeError;

  @override
  void initState() {
    super.initState();
    final data = widget.accumulatedData;
    _goalsCtrl.text = data['goals']?.toString() ?? '';

    if (data['warmup'] is Map) {
      _warmupDescCtrl.text = data['warmup']['desc']?.toString() ?? '';
      _warmupTimeCtrl.text = data['warmup']['time']?.toString() ?? '';
    } else if (data['warmup'] != null) {
      _warmupDescCtrl.text = data['warmup'].toString();
    }

    if (data['activity'] is Map) {
      _activityDescCtrl.text = data['activity']['desc']?.toString() ?? '';
      _activityTimeCtrl.text = data['activity']['time']?.toString() ?? '';
    } else if (data['activity'] != null) {
      _activityDescCtrl.text = data['activity'].toString();
    }

    if (data['cooldown'] is Map) {
      _cooldownDescCtrl.text = data['cooldown']['desc']?.toString() ?? '';
      _cooldownTimeCtrl.text = data['cooldown']['time']?.toString() ?? '';
    } else if (data['cooldown'] != null) {
      _cooldownDescCtrl.text = data['cooldown'].toString();
    }

    _contingenciesCtrl.text = data['contingencies']?.toString() ?? '';
  }

  @override
  void dispose() {
    _goalsCtrl.dispose();
    _warmupDescCtrl.dispose();
    _warmupTimeCtrl.dispose();
    _activityDescCtrl.dispose();
    _activityTimeCtrl.dispose();
    _cooldownDescCtrl.dispose();
    _cooldownTimeCtrl.dispose();
    _contingenciesCtrl.dispose();
    super.dispose();
  }

  bool _validateAll() {
    setState(() {
      _goalError = _goalsCtrl.text.isEmpty ? "Required" : null;
      _warmupError = _warmupDescCtrl.text.trim().isEmpty ? "Required" : null;
      _activityError = _activityDescCtrl.text.trim().isEmpty
          ? "Required"
          : null;
      _cooldownError = _cooldownDescCtrl.text.trim().isEmpty
          ? "Required"
          : null;
      _contingenciesError = _contingenciesCtrl.text.trim().isEmpty
          ? "Required"
          : null;
      _timeError = _warmupTimeCtrl.text.trim().isEmpty ? "Required" : null;

      _activityTimeError = _activityTimeCtrl.text.trim().isEmpty
          ? "Required"
          : null;
      _cooldownTimeError = _cooldownTimeCtrl.text.trim().isEmpty
          ? "Required"
          : null;
    });

    return _goalError == null &&
        _warmupError == null &&
        _activityError == null &&
        _cooldownError == null &&
        _contingenciesError == null &&
        _timeError == null &&
        _activityTimeError == null &&
        _cooldownTimeError == null;
  }

  void _handleBack() {
    int parseTime(String value) {
      if (value.trim().isEmpty) return 0;
      return int.tryParse(value) ?? 0;
    }

    final currentData = {
      'goals': _goalsCtrl.text,
      'warmup': {
        'desc': _warmupDescCtrl.text,
        'time': parseTime(_warmupTimeCtrl.text),
      },
      'activity': {
        'desc': _activityDescCtrl.text,
        'time': parseTime(_activityTimeCtrl.text),
      },
      'cooldown': {
        'desc': _cooldownDescCtrl.text,
        'time': parseTime(_cooldownTimeCtrl.text),
      },
      'contingencies': _contingenciesCtrl.text,
    };

    Navigator.pop(context, currentData);
  }

  void _submitFinalData() async {
    int parseTime(String value) {
      if (value.trim().isEmpty) return 0;
      return int.tryParse(value) ?? 0;
    }

    final finalData = {
      ...widget.accumulatedData,
      'goals': _goalsCtrl.text,
      'warmup': {
        'desc': _warmupDescCtrl.text,
        'time': parseTime(_warmupTimeCtrl.text),
      },
      'activity': {
        'desc': _activityDescCtrl.text,
        'time': parseTime(_activityTimeCtrl.text),
      },
      'cooldown': {
        'desc': _cooldownDescCtrl.text,
        'time': parseTime(_cooldownTimeCtrl.text),
      },
      'contingencies': _contingenciesCtrl.text,
    };

    Map<String, dynamic> dataToPass = finalData;

    if (finalData.containsKey('_id') && finalData['_id'] != null) {
      await sessionController.updateSessionGeneric(finalData['_id'], finalData);
    } else if (finalData.containsKey('id') && finalData['id'] != null) {
      await sessionController.updateSessionGeneric(finalData['id'], finalData);
    } else {
      final newSession = SessionModel.fromJson(finalData);
      final createdModel = await sessionController.createSession(newSession);
      if (createdModel != null) {
        dataToPass = createdModel.toJson();
      }
    }

    if (sessionController.success.value) {
      Get.snackbar(
        "Success",
        (finalData.containsKey('_id') || finalData.containsKey('id'))
            ? "Session Updated Successfully"
            : "Session Created Successfully",
        backgroundColor: primaryGreen,
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAll(() => const MainNavigationScreen(initialIndex: 1));
      Get.to(() => SessionDetailsScreen(sessionData: dataToPass));
    } else {
      Get.snackbar(
        "Error",
        sessionController.error.value,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showConfirmation(BuildContext context) {
    final bool isValid = _validateAll();
    final bool isUpdate =
        widget.accumulatedData.containsKey('_id') ||
        widget.accumulatedData.containsKey('id');
    final String dialogMessage = isValid
        ? (isUpdate
              ? 'Are you sure want to update this session?'
              : 'Are you sure want to create a session?')
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
                // Icon
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

                // Button Row
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
                          // 1. Close Dialog
                          Navigator.of(dialogContext).pop();

                          // 2. Execute Save if Valid
                          if (isValid) {
                            _submitFinalData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Session Dashboard',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              _buildBadge('Coaching Session Plan'),
              const SizedBox(height: 12),
              Text(
                'Fill in the details for your upcoming session.',
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 25),

              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFB8A0B3), Color(0xFF524750)],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputSection(
                            'Session Goal',
                            'Enter the main goal for this session...',
                            _goalsCtrl,
                            error: _goalError,
                          ),

                          _buildSplitInputSection(
                            'Warm-up / Preparation',
                            'Activity details (e.g. Joint rotations...)',
                            _warmupDescCtrl,
                            _warmupTimeCtrl,
                            descError: _warmupError,
                            timeError: _timeError,
                          ),

                          _buildSplitInputSection(
                            'Activity',
                            'Activity details (e.g. Paddle Drills...)',
                            _activityDescCtrl,
                            _activityTimeCtrl,
                            descError: _activityError,
                            timeError: _activityTimeError,
                          ),

                          _buildSplitInputSection(
                            'Cool-down',
                            'Activity details (e.g. slow walk)',
                            _cooldownDescCtrl,
                            _cooldownTimeCtrl,
                            descError: _cooldownError,
                            timeError: _cooldownTimeError,
                          ),

                          _buildInputSection(
                            'Planned Contingencies',
                            'Backup plans... (e.g. If we have an odd number...)',
                            _contingenciesCtrl,
                            isLast: true,
                            error: _contingenciesError,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _handleBack,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const RadialGradient(
                          center: Alignment(0.0, -1.0),
                          radius: 1.0,
                          colors: [Color(0xFFCBD5D2), Color(0xFF7E8783)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Text(
                            'Back',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 1.0
                                ..color = const Color(0xFF141823),
                            ),
                          ),
                          Text(
                            'Back',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => _showConfirmation(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const RadialGradient(
                          center: Alignment(0.0, -1.0),
                          radius: 1.0,
                          colors: [Color(0xFF88D0B7), Color(0xFF00FFA6)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.22),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Text(
                            'Save',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 1.0
                                ..color = const Color(0xFF141823),
                            ),
                          ),
                          Text(
                            'Save',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF26282B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
      ),
    );
  }

  Widget _buildInputSection(
    String label,
    String hint,
    TextEditingController ctrl, {
    bool isLast = false,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          height: isLast ? 120 : 80,
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: error != null ? Colors.red : Colors.white10,
            ),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: 5,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFFB8A0B3),
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.all(12),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildSplitInputSection(
    String label,
    String hint,
    TextEditingController descCtrl,
    TextEditingController timeCtrl, {
    String? descError,
    String? timeError,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: descError != null ? Colors.red : Colors.white10,
                  ),
                ),
                child: TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.poppins(
                      color: const Color(0xFFB8A0B3),
                      fontSize: 12,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: timeError != null ? Colors.red : Colors.white10,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => timeCtrl.clear(),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: TextField(
                        controller: timeCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Min',
                          hintStyle: GoogleFonts.poppins(
                            color: const Color(0xFFB8A0B3),
                            fontSize: 12,
                          ),
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
