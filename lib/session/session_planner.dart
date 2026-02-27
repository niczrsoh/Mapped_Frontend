import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:mapped_frontend/session/session_controller.dart';
import 'session_prerequisite.dart';

class SessionPlannerScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const SessionPlannerScreen({super.key, this.initialData});

  @override
  State<SessionPlannerScreen> createState() => _SessionPlannerScreenState();
}

class _SessionPlannerScreenState extends State<SessionPlannerScreen> {
  final SessionController sessionController = Get.put(SessionController());
  final _dateCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _paxCtrl = TextEditingController();
  final _sessionNoCtrl = TextEditingController();
  final _ageRangeCtrl = TextEditingController();
  String _selectedLevel = 'session_planner_level_beginner'.tr();
  DateTime? _selectedDate;
  String? _dateError;
  String? _venueError;
  String? _paxError;
  String? _timeError;
  String? _ageError;
  String? _sessionError;

  Map<String, dynamic> _draftData = {};

  final Color bgColor = const Color(0xFF141823);
  final Color cardColor = const Color(0xFF1C1C1E);
  final Color inputBg = const Color(0xFF2C2C2E);
  final Color primaryGreen = const Color(0xFF00C875);
  final Color accentCyan = const Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _draftData = Map.from(widget.initialData!);
      final data = widget.initialData!;
      _selectedLevel = data['level'] ?? 'Beginner';

      if (data['date'] != null) {
        try {
          final dt = DateTime.parse(data['date'].toString());
          _dateCtrl.text = "${dt.day}/${dt.month}/${dt.year}";
        } catch (_) {
          _dateCtrl.text = data['uiDate'] ?? data['date'].toString();
        }
      } else {
        _dateCtrl.text = data['uiDate'] ?? '';
      }

      _venueCtrl.text = data['venue'] ?? '';
      _durationCtrl.text = data['duration']?.toString() ?? '60 min';
      _paxCtrl.text = (data['totalTrainees'] ?? data['pax'] ?? '').toString();
      _sessionNoCtrl.text = (data['sessionNo'] ?? '1 / 3').toString();
      _ageRangeCtrl.text = (data['ageRange'] ?? '').toString();
    }
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _venueCtrl.dispose();
    _durationCtrl.dispose();
    _paxCtrl.dispose();
    _sessionNoCtrl.dispose();
    _ageRangeCtrl.dispose();
    super.dispose();
  }

  bool _validateAll() {
    setState(() {
      _dateError = _dateCtrl.text.isEmpty
          ? 'session_planner_error_required'.tr()
          : null;
      _venueError = _venueCtrl.text.trim().isEmpty
          ? 'session_planner_error_required'.tr()
          : null;
      _paxError = _paxCtrl.text.trim().isEmpty
          ? 'session_planner_error_required'.tr()
          : null;
      _timeError = _durationCtrl.text.trim().isEmpty
          ? 'session_planner_error_required'.tr()
          : null;
      _ageError = _ageRangeCtrl.text.trim().isEmpty
          ? 'session_planner_error_required'.tr()
          : null;
      _sessionError = _sessionNoCtrl.text.trim().isEmpty
          ? 'session_planner_error_required'.tr()
          : null;
    });

    return _dateError == null &&
        _venueError == null &&
        _paxError == null &&
        _timeError == null &&
        _ageError == null &&
        _sessionError == null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: primaryGreen,
            surface: cardColor,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      _selectedDate = picked;
      setState(() {
        _dateCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
        _dateError = null;
      });
    }
  }

  Future<void> _handleSubmission() async {
    if (!_validateAll()) {
      Get.snackbar(
        'error'.tr(),
        'add_trainee_error_fill_all'.tr(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Capture current screen data
    final Map<String, dynamic> currentScreenData = {
      'level': _selectedLevel,
      'date': _dateCtrl.text,
      'venue': _venueCtrl.text,
      'duration': _durationCtrl.text,
      'pax': _paxCtrl.text,
      'totalTrainees': _paxCtrl.text,
      'sessionNo': _sessionNoCtrl.text,
      'ageRange': _ageRangeCtrl.text,
    };

    _draftData.addAll(currentScreenData);
    final result = await Get.to(
      () => SessionPrerequisitesScreen(previousData: _draftData),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _draftData.addAll(result);
      });
    }
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
          'session_planner_title'.tr(),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              _buildBadge('session_planner_badge'.tr()),
              const SizedBox(height: 12),
              Text(
                'session_planner_subtitle'.tr(),
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 25),
              _buildLevelSelector(),
              const SizedBox(height: 25),
              _buildMainCard(),
              const SizedBox(height: 35),
              _buildNextButton(),
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

  Widget _buildLevelSelector() {
    final List<String> levels = [
      'session_planner_level_beginner'.tr(),
      'session_planner_level_intermediate'.tr(),
      'session_planner_level_advanced'.tr(),
    ];
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: levels.map((l) {
          bool isSelected = _selectedLevel == l;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedLevel = l),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF00E676), Color(0xFF008042)],
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l.tr(),
                  style: GoogleFonts.poppins(
                    color: isSelected ? const Color(0xFF141823) : Colors.grey,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
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
                colors: [Color(0xFF00E5FF), Color(0xFF008999)],
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
                Text(
                  'session_planner_sec_general'.tr(),
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 2.2,
                  children: [
                    _buildInput(
                      'session_planner_lbl_date'.tr(),
                      'session_planner_hint_date'.tr(),
                      _dateCtrl,
                      readOnly: true,
                      onTap: _pickDate,
                      error: _dateError,
                    ),
                    _buildInput(
                      'session_planner_lbl_venue'.tr(),
                      'session_planner_hint_venue'.tr(),
                      _venueCtrl,
                      error: _venueError,
                    ),
                    _buildInput(
                      'session_planner_lbl_duration'.tr(),
                      'session_planner_hint_duration'.tr(),
                      _durationCtrl,
                      isNumber: true,
                      error: _timeError,
                    ),
                    _buildInput(
                      'session_planner_lbl_participants'.tr(),
                      'session_planner_hint_participants'.tr(),
                      _paxCtrl,
                      keyboard: TextInputType.number,
                      error: _paxError,
                      isNumber: true,
                    ),
                    _buildInput(
                      'session_planner_lbl_session_no'.tr(),
                      'session_planner_hint_session_no'.tr(),
                      _sessionNoCtrl,
                      isNumber: true,
                      error: _sessionError,
                    ),
                    _buildInput(
                      'session_planner_lbl_age'.tr(),
                      'session_planner_hint_age'.tr(),
                      _ageRangeCtrl,
                      error: _ageError,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    String label,
    String hint,
    TextEditingController ctrl, {
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboard,
    String? error,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: error != null ? Colors.red : Colors.white10,
              ),
            ),
            child: TextField(
              controller: ctrl,
              readOnly: readOnly,
              onTap: onTap,
              keyboardType: keyboard,
              inputFormatters: (isNumber)
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : [],
              style: GoogleFonts.poppins(color: accentCyan, fontSize: 13),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.poppins(color: accentCyan, fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return Center(
      child: GestureDetector(
        onTap: _handleSubmission,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
                'session_planner_btn_next'.tr(),
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
                'session_planner_btn_next'.tr(),
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
    );
  }
}
