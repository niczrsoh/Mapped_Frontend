import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SessionReflectionsPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> sessionData;

  const SessionReflectionsPreviewScreen({Key? key, required this.sessionData})
      : super(key: key);

  @override
  _SessionReflectionsPreviewScreenState createState() =>
      _SessionReflectionsPreviewScreenState();
}

class _SessionReflectionsPreviewScreenState
    extends State<SessionReflectionsPreviewScreen> {
  // --- Style Constants ---
  final Color bgColor = const Color(0xFF141823);
  final Color cardColor = const Color(0xFF1C1C1E);
  final Color inputBg = const Color(0xFF2C2C2E);
  final Color accentGreen = const Color(0xFF00C875);
  final Color accentYellow = const Color(0xFFF2C94C);
  final Color textColor = Colors.white;
  final Color secondaryTextColor = const Color(0xFFB8A0B3);
  final Color hintColor = const Color(0xFF8E8E93);

  // --- Data Variables ---
  int _rating = 0;
  String _highlights = '';
  String _improvements = '';
  List<String> _actionItems = [];

  @override
  void initState() {
    super.initState();
    _parseReflectionData();
  }

  void _parseReflectionData() {
    if (widget.sessionData.containsKey('reflection') &&
        widget.sessionData['reflection'] != null) {
      final reflection = widget.sessionData['reflection'];
      if (reflection is Map) {
        setState(() {
          _rating = int.tryParse(reflection['rating']?.toString() ?? '0') ?? 0;
          _highlights = reflection['highlights']?.toString() ?? '';
          _improvements = reflection['improvements']?.toString() ?? '';

          if (reflection['actionItems'] != null &&
              reflection['actionItems'] is List) {
            _actionItems =
                (reflection['actionItems'] as List)
                    .map((e) => e.toString())
                    .toList();
          }
        });
      }
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
          icon: Icon(Icons.chevron_left, color: textColor, size: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Reflection Preview',
          style: GoogleFonts.poppins(color: textColor, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Header Card ---
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Date:',
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
                    'Session Success Rating',
                    style: GoogleFonts.poppins(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStaticStarRating(),
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
                  _buildReadOnlyField(
                    label: 'What went well? (Highlights)',
                    content: _highlights,
                    placeholder: 'No highlights recorded.',
                  ),
                  const SizedBox(height: 20),
                  _buildReadOnlyField(
                    label: 'Areas for Improvement',
                    content: _improvements,
                    placeholder: 'No improvements recorded.',
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
                  const SizedBox(height: 20),
                  if (_actionItems.isEmpty)
                    Text(
                      'No action items set.',
                      style: GoogleFonts.poppins(
                        color: hintColor,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    ..._actionItems.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildActionItemDisplay(
                          entry.key + 1,
                          entry.value,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),

          ],
        ),
      ),
    );
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

  Widget _buildStaticStarRating() {
    return Row(
      children:
          List.generate(5, (index) {
            return Icon(
              Icons.star_rounded,
              color: index < _rating ? accentYellow : Colors.white12,
              size: 36,
            );
          }).expand((widget) => [widget, const SizedBox(width: 8)]).toList()
            ..removeLast(),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String content,
    required String placeholder,
  }) {
    final bool hasContent = content.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: textColor, fontSize: 14)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            hasContent ? content : placeholder,
            style: GoogleFonts.poppins(
              color: hasContent ? textColor : hintColor,
              fontSize: 14,
              fontStyle: hasContent ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItemDisplay(int index, String text) {
    return Container(
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index.',
            style: GoogleFonts.poppins(
              color: accentGreen,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(color: textColor, fontSize: 14),
            ),
          ),
        ],
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
            final monCap =
                mon.isNotEmpty
                    ? '${mon[0].toUpperCase()}${mon.substring(1).toLowerCase()}'
                    : mon;

            return '$day $monCap';
          }
        }
      } catch (_) {}
    }

    return data['uiDate'] ?? data['date'] ?? 'N/A';
  }
}
