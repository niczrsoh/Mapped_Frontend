import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'session_controller.dart';

class SessionReflectionsScreen extends StatefulWidget {
  final Map<String, dynamic> sessionData;

  const SessionReflectionsScreen({Key? key, required this.sessionData})
    : super(key: key);

  @override
  _SessionReflectionsScreenState createState() =>
      _SessionReflectionsScreenState();
}

class _SessionReflectionsScreenState extends State<SessionReflectionsScreen> {
  final Color bgColor = const Color(0xFF141823);
  final Color cardColor = const Color(0xFF1C1C1E);
  final Color inputBg = const Color(0xFF2C2C2E);
  final Color accentGreen = const Color(0xFF00C875);
  final Color accentYellow = const Color(0xFFF2C94C);
  final Color textColor = Colors.white;
  final Color secondaryTextColor = const Color(0xFFB8A0B3);
  final Color hintColor = const Color(0xFF8E8E93);
  final TextEditingController _highlightsCtrl = TextEditingController();
  final TextEditingController _improvementsCtrl = TextEditingController();
  final List<TextEditingController> _actionItemCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];

  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _populateExistingReflection();
  }

  void _populateExistingReflection() {
    if (widget.sessionData.containsKey('reflection') &&
        widget.sessionData['reflection'] != null) {
      final reflection = widget.sessionData['reflection'];
      if (reflection is Map) {
        _rating = int.tryParse(reflection['rating']?.toString() ?? '0') ?? 0;
        _highlightsCtrl.text = reflection['highlights']?.toString() ?? '';
        _improvementsCtrl.text = reflection['improvements']?.toString() ?? '';

        if (reflection['actionItems'] != null &&
            reflection['actionItems'] is List) {
          final List items = reflection['actionItems'];
          for (
            int i = 0;
            i < items.length && i < _actionItemCtrls.length;
            i++
          ) {
            _actionItemCtrls[i].text = items[i].toString();
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _highlightsCtrl.dispose();
    _improvementsCtrl.dispose();
    for (var ctrl in _actionItemCtrls) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: textColor, size: 32),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: Text(
          'Session Reflections',
          style: GoogleFonts.poppins(color: textColor, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reviewing Session:',
                    style: GoogleFonts.poppins(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getSessionTitle(),
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Assessment',
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'How successful was the session?',
                    style: GoogleFonts.poppins(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStarRating(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key Takeaways',
                    style: GoogleFonts.poppins(
                      color: accentYellow,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    label: 'What went well? (Highlights)',
                    hint:
                        'e.g., The participants are seem well and happy during the session. The focus mitt drills really improved reaction speed today; and everyone respected the power control limits....',
                    controller: _highlightsCtrl,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    label: 'Areas for Improvement',
                    hint:
                        'e.g., Warm-up shrimps and rolls took too long to organize; several white belts were forgetting to tap early during the submission drills....',
                    controller: _improvementsCtrl,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Session Action Items',
                    style: GoogleFonts.poppins(
                      color: accentGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'What concrete changes will you make next time?',
                    style: GoogleFonts.poppins(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildActionItemInput(
                    1,
                    _actionItemCtrls[0],
                    'e.g. More Side kicks',
                  ),
                  const SizedBox(height: 12),
                  _buildActionItemInput(
                    2,
                    _actionItemCtrls[1],
                    'e.g. pattern 2 revision',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Center(
              child: GestureDetector(
                onTap: () async {
                  final controller = Get.put(SessionController());
                  final String? id =
                      widget.sessionData['_id'] ?? widget.sessionData['id'];

                  if (id != null) {
                    Map<String, dynamic> reflectionData = {
                      "rating": _rating,
                      "highlights": _highlightsCtrl.text,
                      "improvements": _improvementsCtrl.text,
                      "actionItems": _actionItemCtrls
                          .map((c) => c.text)
                          .where((t) => t.isNotEmpty)
                          .toList(),
                    };

                    Map<String, dynamic> updatePayload = Map.from(
                      widget.sessionData,
                    );
                    updatePayload['reflection'] = reflectionData;

                    if (!updatePayload.containsKey('totalTrainees') &&
                        updatePayload.containsKey('pax')) {
                      updatePayload['totalTrainees'] = updatePayload['pax'];
                    }
                    if (updatePayload['duration'] != null) {
                      updatePayload['duration'] = updatePayload['duration']
                          .toString();
                    }

                    await controller.updateSessionGeneric(id, updatePayload);

                    if (controller.success.value) {
                      // Mark reflection as submitted for belt progress tracking
                      controller.markReflectionAsSubmitted(id);

                      Get.snackbar(
                        "Success",
                        "Reflection Saved Successfully",
                        backgroundColor: accentGreen,
                        colorText: Colors.black,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(10),
                        borderRadius: 10,
                      );
                    } else {
                      Get.snackbar(
                        "Error",
                        controller.error.value.isNotEmpty
                            ? controller.error.value
                            : "Failed to save feedback",
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(10),
                        borderRadius: 10,
                      );
                    }
                  } else {
                    Get.snackbar(
                      "Error",
                      "Session ID missing",
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                    );
                  }

                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Container(
                  width: 129,
                  alignment: Alignment.center,
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
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getSessionTitle() {
    final date = _formatSessionDate(widget.sessionData);
    final level = widget.sessionData['level'] ?? 'Intermediate';
    return '$date - $level Group';
  }

  String _formatSessionDate(Map<String, dynamic> data) {
    final dateStr = data['date']?.toString();
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

    if (dateStr != null) {
      try {
        final dt = DateTime.parse(dateStr);
        return '${dt.day} ${months[dt.month - 1]}';
      } catch (_) {}
      if (dateStr.contains('/')) {
        try {
          final parts = dateStr.split('/');
          if (parts.length == 3) {
            final dt = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
            return '${dt.day} ${months[dt.month - 1]}';
          }
        } catch (_) {}
      }
    }

    final uiDate = data['uiDate']?.toString();
    if (uiDate != null && uiDate.contains(',')) {
      try {
        final parts = uiDate.split(',');
        if (parts.length >= 3) {
          final monthDay = parts[1].trim().split(' ');
          if (monthDay.length >= 2) {
            final mon = monthDay[0];
            final day = monthDay[1];
            final monCap = mon.isNotEmpty
                ? '${mon[0].toUpperCase()}${mon.substring(1).toLowerCase()}'
                : mon;

            return '$day $monCap';
          }
        }
      } catch (_) {}
    }

    return data['uiDate'] ?? data['date'] ?? 'N/A';
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _buildStarRating() {
    return Row(
      children:
          List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                icon: Icon(
                  Icons.star_rounded,
                  color: index < _rating ? accentYellow : Colors.white,
                  size: 36,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            }).expand((widget) => [widget, const SizedBox(width: 8)]).toList()
            ..removeLast(),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: textColor, fontSize: 14)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            maxLength: 2000,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            style: GoogleFonts.poppins(color: textColor, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintMaxLines: 4,
              hintStyle: GoogleFonts.poppins(color: accentYellow, fontSize: 14),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItemInput(
    int index,
    TextEditingController controller,
    String hint,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 8.0),
            child: Text(
              '$index.',
              style: GoogleFonts.poppins(color: accentGreen, fontSize: 14),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.poppins(color: textColor, fontSize: 14),
              maxLines: null,
              maxLength: 2000,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              decoration: InputDecoration(
                isDense: true,
                hintMaxLines: 3,
                hintText: 'Add Action Item. ($hint)',
                hintStyle: GoogleFonts.poppins(
                  color: accentGreen,
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.only(
                  top: 16.0,
                  bottom: 16.0,
                  right: 16.0,
                ),
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
