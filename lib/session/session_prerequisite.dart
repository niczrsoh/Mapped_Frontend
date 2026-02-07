import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mapped_frontend/session/session_flow.dart';

class SessionPrerequisitesScreen extends StatefulWidget {
  final Map<String, dynamic> previousData;
  const SessionPrerequisitesScreen({super.key, required this.previousData});

  @override
  State<SessionPrerequisitesScreen> createState() =>
      _SessionPrerequisitesScreenState();
}

class _SessionPrerequisitesScreenState
    extends State<SessionPrerequisitesScreen> {

  final _riskCtrl = TextEditingController();
  final _resourcesCtrl = TextEditingController();
  final _othersCtrl = TextEditingController();

  Map<String, dynamic> _futureData = {};

  final Color bgColor = const Color(0xFF141823);
  final Color cardColor = const Color(0xFF1C1C1E);
  final Color inputBg = const Color(
    0xFF2C2C2E,
  ); 
  final Color primaryGreen = const Color(0xFF00C875);
  final Color greyButton = const Color(0xFF8E8E93);

  String? _riskError;
  String? _resourcesError;
  String? _othersError;

  @override
  void initState() {
    super.initState();
    final data = widget.previousData;
    _riskCtrl.text = data['riskAssessment']?.toString() ?? '';
    _resourcesCtrl.text = data['resources']?.toString() ?? '';
    _othersCtrl.text = data['othersInvolved']?.toString() ?? '';
  }

  @override
  void dispose() {
    _riskCtrl.dispose();
    _resourcesCtrl.dispose();
    _othersCtrl.dispose();
    super.dispose();
  }

  bool _validateAll() {
    setState(() {
      _riskError = _riskCtrl.text.isEmpty ? "Required" : null;
      _resourcesError = _resourcesCtrl.text.trim().isEmpty ? "Required" : null;
      _othersError = _othersCtrl.text.trim().isEmpty ? "Required" : null;
    });

    return _riskError == null &&
        _resourcesError == null &&
        _othersError == null;
  }

  void _handleNext() async {
    if (!_validateAll()) {
      Get.snackbar(
        'Error',
        'Please fill in all required fields',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final currentStepData = {
      'riskAssessment': _riskCtrl.text,
      'resources': _resourcesCtrl.text,
      'othersInvolved': _othersCtrl.text,
    };

    final Map<String, dynamic> accumulatedData = {
      ...widget.previousData,
      ..._futureData, 
      ...currentStepData,
    };

    final result = await Get.to(
      () => SessionFlowScreen(accumulatedData: accumulatedData),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _futureData = result;
      });
    }
  }

  Map<String, dynamic> _collectCurrentData() {
    return {
      'riskAssessment': _riskCtrl.text,
      'resources': _resourcesCtrl.text,
      'othersInvolved': _othersCtrl.text,
    };
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
                          colors: [Color(0xFF00E676), Color(0xFF008042)],
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
                            'Pre-requisites',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 20),

                          _buildTextArea(
                            label: 'Risk Assessment',
                            hint:
                                'Enter safety details... (e.g. Verified all students have trimmed fingernails...)',
                            controller: _riskCtrl,
                            error: _riskError,
                          ),
                          const SizedBox(height: 15),

                          _buildTextArea(
                            label: 'Resources Required',
                            hint:
                                'List equipment... (e.g. 12 Double Kicking Paddles...)',
                            controller: _resourcesCtrl,
                            error: _resourcesError,
                          ),
                          const SizedBox(height: 15),

                          _buildTextArea(
                            label: 'Others involved & Role',
                            hint:
                                'List all involvements (e.g. Assistant Instructor Sarah...)',
                            controller: _othersCtrl,
                            error: _othersError,
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
                    onTap: () {
                      final current = _collectCurrentData();
                      final allData = {
                        ...widget.previousData,
                        ..._futureData,
                        ...current,
                      };
                      Navigator.pop(context, allData);
                    },
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
                    onTap: _handleNext,
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
                            'Next',
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
                            'Next',
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

  Widget _buildTextArea({
    required String label,
    required String hint,
    required TextEditingController controller,
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
          height: 100, 
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: error != null ? Colors.red : Colors.white10,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: 5,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFFB7CDAC),
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.all(12),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
