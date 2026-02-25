import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'progress_controller.dart';

const double _borderThickness = 1.5;
const LinearGradient _customGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0x1AFFFFFF), Color(0xFA00FFA6)],
);

class TraineeProgressScreen extends StatefulWidget {
  final String traineeId;
  final String traineeName;
  final String currentBelt;
  final Map<String, Map<String, dynamic>>? initialPendingUpdates;

  const TraineeProgressScreen({
    Key? key,
    required this.traineeId,
    required this.traineeName,
    required this.currentBelt,
    this.initialPendingUpdates,
  }) : super(key: key);

  @override
  State<TraineeProgressScreen> createState() => _TraineeProgressScreenState();
}

class _TraineeProgressScreenState extends State<TraineeProgressScreen> {
  final ProgressController _controller = Get.find<ProgressController>();
  late String _activeBelt;
  late Map<String, Map<String, dynamic>> _pendingChanges;

  String _selectedFormText = 'Form: Pattern 1 ';
  String _highlightedForm = 'Pattern 1 ';
  bool _isFormDropdownOpen = false;

  final List<String> _formOptions = [
    'Pattern 1 ',
    'Pattern 2 ',
    'Pattern 3 ',
    'Pattern 4 ',
    'Pattern 5 ',
    'Pattern 6 ',
    'Pattern 7 ',
    'Pattern 8 ',
  ];

  // Local state maps
  final Map<String, int> _blocksAndStrikes = {
    'Low block': 0,
    'High block': 0,
    'Middle punch': 0,
  };

  final Map<String, int> _kicks = {
    'Front (L/R)': 0,
    'Side (L/R)': 0,
    'Roundhouse': 0,
  };

  String _getNextBelt(String currentBelt) {
    // Normalize input to Title Case for switch matching
    String belt = currentBelt.trim();
    if (belt.isEmpty) return 'Yellow';
    belt = belt[0].toUpperCase() + belt.substring(1).toLowerCase();

    switch (belt) {
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
      case 'Black':
        return 'Black';
      default:
        return 'White';
    }
  }

  @override
  void initState() {
    super.initState();
    _pendingChanges = widget.initialPendingUpdates != null
        ? Map<String, Map<String, dynamic>>.from(widget.initialPendingUpdates!)
        : {};

    String rawBelt = widget.currentBelt.trim();
    if (rawBelt.isNotEmpty) {
      _activeBelt =
          rawBelt[0].toUpperCase() + rawBelt.substring(1).toLowerCase();
    } else {
      _activeBelt = 'White';
    }

    _fetchData();
  }

  void _fetchData() async {
    await _controller.fetchProgress(
      widget.traineeId,
      _activeBelt,
      _highlightedForm,
    );

    setState(() {
      _blocksAndStrikes.updateAll((key, val) => 0);
      _kicks.updateAll((key, val) => 0);

      if (_controller.loadedTechniques.isNotEmpty) {
        _controller.loadedTechniques.forEach((key, value) {
          if (_blocksAndStrikes.containsKey(key)) {
            _blocksAndStrikes[key] = value;
          }
        });
      }

      if (_controller.loadedKicks.isNotEmpty) {
        _controller.loadedKicks.forEach((key, value) {
          if (_kicks.containsKey(key)) {
            _kicks[key] = value;
          }
        });
      }

      if (_pendingChanges.containsKey(_highlightedForm)) {
        final pending = _pendingChanges[_highlightedForm]!;
        if (pending['techniques'] != null) {
          final Map<String, int> pendingTech =
              pending['techniques'] as Map<String, int>;
          pendingTech.forEach((key, value) {
            if (_blocksAndStrikes.containsKey(key)) {
              _blocksAndStrikes[key] = value;
            }
          });
        }
        if (pending['kicks'] != null) {
          final Map<String, int> pendingKicks =
              pending['kicks'] as Map<String, int>;
          pendingKicks.forEach((key, value) {
            if (_kicks.containsKey(key)) {
              _kicks[key] = value;
            }
          });
        }
      }

      // 4. RECALCULATE SCORE based on updated maps (Backend + Pending)
      int totalPoints = 0;
      int totalItems = 0;

      _blocksAndStrikes.forEach((_, v) {
        totalPoints += v;
        totalItems++;
      });
      _kicks.forEach((_, v) {
        totalPoints += v;
        totalItems++;
      });

      if (totalItems > 0) {
        _controller.currentScore.value = totalPoints / (totalItems * 2);
      } else {
        _controller.currentScore.value = 0.0;
      }
    });
  }

  void _setSelectedForm(String form) {
    setState(() {
      _selectedFormText = 'Form: $form';
      _highlightedForm = form;
      _isFormDropdownOpen = false;
    });
    _fetchData();
  }

  void _setRating(Map<String, int> map, String key, int value) async {
    setState(() {
      map[key] = value;
    });

    _pendingChanges[_highlightedForm] = {
      'techniques': Map<String, int>.from(_blocksAndStrikes),
      'kicks': Map<String, int>.from(_kicks),
    };

    int totalPoints = 0;
    int totalItems = 0;

    _blocksAndStrikes.forEach((_, v) {
      totalPoints += v;
      totalItems++;
    });
    _kicks.forEach((_, v) {
      totalPoints += v;
      totalItems++;
    });

    if (totalItems > 0) {
      _controller.currentScore.value = totalPoints / (totalItems * 2);
    } else {
      _controller.currentScore.value = 0.0;
    }
  }

  Widget _formFormItem(String label) {
    final bool isHighlighted = label == _highlightedForm;
    const Color whiteBackground = Colors.white;
    const Color darkTextColor = Colors.black;
    const Color lightTextColor = Colors.white;

    Color backgroundColor = isHighlighted
        ? whiteBackground
        : Colors.transparent;
    Color textColor = isHighlighted ? darkTextColor : lightTextColor;
    Color iconColor = isHighlighted
        ? darkTextColor.withOpacity(0.5)
        : lightTextColor.withOpacity(0.7);
    IconData iconData = isHighlighted
        ? Icons.check_circle_outline
        : Icons.circle_outlined;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: () => _setSelectedForm(label),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: isHighlighted
                ? Border.all(color: Colors.white, width: 1.0)
                : null,
            boxShadow: isHighlighted
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(iconData, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.roboto(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: isHighlighted
                        ? FontWeight.w500
                        : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ..._formOptions.map((label) => _formFormItem(label)).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF141823);
    const accent = Color(0xFF00FFA6);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _pendingChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context, _pendingChanges),
          ),
          title: Text(
            'trainee_progress_title'.tr(),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF181C26), Color(0xFF161C2C)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Text(
                        widget.traineeName,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.directions_run,
                            color: Colors.grey.shade300,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'trainee_progress_next_belt'.tr(),
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${_getNextBelt(_activeBelt)}${'trainee_progress_belt_suffix'.tr()}',
                            style: GoogleFonts.roboto(
                              color: accent,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    gradient: _customGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(_borderThickness),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1720),
                      borderRadius: BorderRadius.circular(
                        16 - _borderThickness,
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'trainee_progress_section_form'.tr(),
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => setState(
                            () => _isFormDropdownOpen = !_isFormDropdownOpen,
                          ),
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2B2F33),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: accent, width: 1.0),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedFormText,
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  _isFormDropdownOpen
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isFormDropdownOpen) _formList(),
                        const SizedBox(height: 12),

                        // Score Bar
                        Text(
                          'trainee_progress_score'.tr(),
                          style: TextStyle(
                            fontFamily: 'JejuGothic',
                            color: accent,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: _controller.currentScore.value,
                                    minHeight: 12,
                                    valueColor: const AlwaysStoppedAnimation(
                                      accent,
                                    ),
                                    backgroundColor: const Color(0xFF22262B),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0f1720),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: accent.withOpacity(0.15),
                                  ),
                                ),
                                child: Text(
                                  '${(_controller.currentScore.value * 100).round()}%',
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 12,
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
                const SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(
                    gradient: _customGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(_borderThickness),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1720),
                      borderRadius: BorderRadius.circular(
                        16 - _borderThickness,
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'trainee_progress_rate_techniques'.tr(),
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Expanded(flex: 2, child: SizedBox()),
                            Expanded(
                              flex: 3,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'trainee_progress_rating_poor'.tr(),
                                    style: TextStyle(
                                      fontFamily: 'JejuGothic',
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'trainee_progress_rating_medium'.tr(),
                                    style: TextStyle(
                                      fontFamily: 'JejuGothic',
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'trainee_progress_rating_good'.tr(),
                                    style: TextStyle(
                                      fontFamily: 'JejuGothic',
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'trainee_progress_blocks_strikes'.tr(),
                          style: TextStyle(
                            fontFamily: 'JejuGothic',
                            color: accent,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._blocksAndStrikes.keys
                            .map(
                              (k) => _ratingRow(
                                k,
                                _blocksAndStrikes[k]!,
                                (val) => _setRating(_blocksAndStrikes, k, val),
                              ),
                            )
                            .toList(),
                        const SizedBox(height: 12),
                        Text(
                          'trainee_progress_kicks'.tr(),
                          style: TextStyle(
                            fontFamily: 'JejuGothic',
                            color: accent,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._kicks.keys
                            .map(
                              (k) => _ratingRow(
                                k,
                                _kicks[k]!,
                                (val) => _setRating(_kicks, k, val),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ratingRow(String label, int value, ValueChanged<int> onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2B2F33),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'JejuGothic',
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(3, (i) {
                        final active = i == value;
                        return GestureDetector(
                          onTap: () => onChange(i),
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFF00FFA6)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF00FFA6,
                                        ).withOpacity(0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
