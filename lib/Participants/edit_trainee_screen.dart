import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart' as img;
import 'trainee_controller.dart';
import 'trainee_progress.dart';
import 'progress_controller.dart';
import '../TProgress/data/belt_definitions.dart';

const double _borderThicknessEdit = 1.5;

const LinearGradient _customGradientEdit = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0x1AFFFFFF), Color(0xFA00FFA6)],
);

const RadialGradient _saveButtonGradient = RadialGradient(
  center: Alignment(0.0, -1.0),
  radius: 2.5,
  colors: [Color(0xFFCBD5D2), Color(0xFF00FFA6)],
  stops: [0.0, 1.0],
);

const RadialGradient _deleteButtonGradient = RadialGradient(
  center: Alignment(0.0, -1.0),
  radius: 1.5,
  colors: [Color(0xFFE02141), Color(0xFFFF0004)],
  stops: [0.0, 1.0],
);

class EditTraineeScreen extends StatefulWidget {
  final Map<String, dynamic> trainee;
  final bool showDeleteDialog;

  const EditTraineeScreen({
    Key? key,
    required this.trainee,
    this.showDeleteDialog = false,
  }) : super(key: key);

  @override
  State<EditTraineeScreen> createState() => _EditTraineeScreenState();
}

class _EditTraineeScreenState extends State<EditTraineeScreen> {
  final TraineeController traineeController = Get.find<TraineeController>();
  final ProgressController progressController = Get.put(ProgressController());
  final Map<String, Map<String, dynamic>> _pendingProgressUpdates = {};

  late TextEditingController _nameCtrl;
  late TextEditingController _beltCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _genderCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _guardianNameCtrl;
  late TextEditingController _guardianContactCtrl;
  late TextEditingController _guardianAddressCtrl;
  late TextEditingController _goalsCtrl;
  late TextEditingController _conditionsCtrl;
  late TextEditingController _competencyCtrl;

  DateTime? _selectedDob;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _beltFocus = FocusNode();
  final FocusNode _dobFocus = FocusNode();
  final FocusNode _genderFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _guardianNameFocus = FocusNode();
  final FocusNode _guardianContactFocus = FocusNode();
  final FocusNode _guardianAddressFocus = FocusNode();
  final FocusNode _goalsFocus = FocusNode();
  final FocusNode _conditionsFocus = FocusNode();
  final FocusNode _competencyFocus = FocusNode();
  final Map<String, String?> _errors = {};

  img.XFile? _pickedImage;
  final img.ImagePicker _picker = img.ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.trainee['name']);
    _beltCtrl = TextEditingController(text: widget.trainee['belt']);

    _dobCtrl = TextEditingController();
    _initializeDob(widget.trainee['dateOfBirth']);

    _genderCtrl = TextEditingController(text: widget.trainee['gender']);
    _phoneCtrl = TextEditingController(text: widget.trainee['phone']);
    _emailCtrl = TextEditingController(text: widget.trainee['email']);
    _addressCtrl = TextEditingController(text: widget.trainee['address']);
    _guardianNameCtrl = TextEditingController(
      text: widget.trainee['guardianName'],
    );
    _guardianContactCtrl = TextEditingController(
      text: widget.trainee['guardianContact'],
    );
    _guardianAddressCtrl = TextEditingController(
      text: widget.trainee['guardianAddress'],
    );

    _goalsCtrl = TextEditingController(
      text: widget.trainee['goals']?.toString() ?? '',
    );
    _conditionsCtrl = TextEditingController(
      text: widget.trainee['conditions']?.toString() ?? '',
    );
    _competencyCtrl = TextEditingController(
      text: widget.trainee['competency']?.toString() ?? '',
    );

    _nameFocus.addListener(
      () => _onFocusChange(_nameFocus, 'name', _nameCtrl.text),
    );
    _beltFocus.addListener(
      () => _onFocusChange(_beltFocus, 'belt', _beltCtrl.text),
    );
    _genderFocus.addListener(
      () => _onFocusChange(_genderFocus, 'gender', _genderCtrl.text),
    );
    _phoneFocus.addListener(
      () => _onFocusChange(_phoneFocus, 'phone', _phoneCtrl.text),
    );
    _emailFocus.addListener(
      () => _onFocusChange(_emailFocus, 'email', _emailCtrl.text),
    );
    _addressFocus.addListener(
      () => _onFocusChange(_addressFocus, 'address', _addressCtrl.text),
    );
    _guardianNameFocus.addListener(
      () => _onFocusChange(
        _guardianNameFocus,
        'guardianName',
        _guardianNameCtrl.text,
      ),
    );
    _guardianContactFocus.addListener(
      () => _onFocusChange(
        _guardianContactFocus,
        'guardianContact',
        _guardianContactCtrl.text,
      ),
    );
    _guardianAddressFocus.addListener(
      () => _onFocusChange(
        _guardianAddressFocus,
        'guardianAddress',
        _guardianAddressCtrl.text,
      ),
    );
    _goalsFocus.addListener(
      () => _onFocusChange(_goalsFocus, 'goals', _goalsCtrl.text),
    );
    _conditionsFocus.addListener(
      () =>
          _onFocusChange(_conditionsFocus, 'conditions', _conditionsCtrl.text),
    );
    _competencyFocus.addListener(
      () =>
          _onFocusChange(_competencyFocus, 'competency', _competencyCtrl.text),
    );

    if (widget.showDeleteDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showConfirmDialog(
          message: 'Are you sure want to Delete a Participant?',
          confirmButtonText: 'OK',
          onConfirm: _deleteTrainee,
          isDelete: true,
        );
      });
    }
  }

  void _initializeDob(String? dateString) {
    if (dateString == null || dateString.isEmpty) return;
    try {
      DateTime utcDate = DateTime.parse(dateString);
      _selectedDob = utcDate.toLocal();
      _dobCtrl.text = _formatDate(_selectedDob!);
    } catch (e) {
      _dobCtrl.text = dateString;
    }
  }

  void _onFocusChange(FocusNode node, String fieldKey, String value) {
    if (!node.hasFocus) {
      _validateField(fieldKey, value);
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _selectedDob ?? DateTime(now.year - 10);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF00FFA6),
            onPrimary: Colors.white,
            surface: const Color(0xFF141823),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobCtrl.text = _formatDate(picked);
        _errors['dob'] = null;
      });
    }
  }

  void _validateField(String key, String value) {
    String? error;
    final trimmedValue = value.trim();
    final lowerCaseValue = trimmedValue.toLowerCase();

    if (trimmedValue.isEmpty) {
      error = 'This field is required to fill';
    } else {
      if (key == 'gender') {
        if (lowerCaseValue != 'male' && lowerCaseValue != 'female') {
          error = 'Must be Male or Female';
        }
      } else if (key == 'belt') {
        const allowedBelts = [
          'white',
          'yellow',
          'blue',
          'brown',
          'black',
          'green',
        ];
        if (!allowedBelts.contains(lowerCaseValue)) {
          error = 'Invalid belt color';
        }
      } else if (key == 'email' && !GetUtils.isEmail(trimmedValue)) {
        error = 'Invalid Email';
      } else if ((key == 'phone' || key == 'guardianContact') &&
          (trimmedValue.length < 9 || trimmedValue.length > 12)) {
        error = 'Invalid Phone';
      } else if (key == 'conditions' && !trimmedValue.contains('-')) {
        error = 'Must use "-" for each different disability';
      }
    }
    setState(() {
      _errors[key] = error;
    });
  }

  bool _validateAllFields() {
    _validateField('name', _nameCtrl.text);
    _validateField('belt', _beltCtrl.text);
    _validateField('gender', _genderCtrl.text);
    _validateField('phone', _phoneCtrl.text);
    _validateField('email', _emailCtrl.text);
    _validateField('address', _addressCtrl.text);
    _validateField('guardianName', _guardianNameCtrl.text);
    _validateField('guardianContact', _guardianContactCtrl.text);
    _validateField('guardianAddress', _guardianAddressCtrl.text);
    _validateField('goals', _goalsCtrl.text);
    _validateField('conditions', _conditionsCtrl.text);
    _validateField('competency', _competencyCtrl.text);

    if (_dobCtrl.text.isEmpty) {
      setState(() => _errors['dob'] = 'This field is required to fill');
    }

    return _errors.values.any((e) => e != null);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _beltCtrl.dispose();
    _dobCtrl.dispose();
    _genderCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _guardianNameCtrl.dispose();
    _guardianContactCtrl.dispose();
    _guardianAddressCtrl.dispose();

    _goalsCtrl.dispose();
    _conditionsCtrl.dispose();
    _competencyCtrl.dispose();

    _nameFocus.dispose();
    _beltFocus.dispose();
    _dobFocus.dispose();
    _genderFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _addressFocus.dispose();
    _guardianNameFocus.dispose();
    _guardianContactFocus.dispose();
    _guardianAddressFocus.dispose();

    _goalsFocus.dispose();
    _conditionsFocus.dispose();
    _competencyFocus.dispose();

    super.dispose();
  }

  void _saveChanges() async {
    if (_pendingProgressUpdates.isNotEmpty) {
      for (var form in _pendingProgressUpdates.keys) {
        var data = _pendingProgressUpdates[form]!;
        await progressController.saveProgress(
          traineeId: widget.trainee['id'],
          beltColor: _beltCtrl.text,
          form: form,
          techniques: Map<String, int>.from(data['techniques']),
          kicks: Map<String, int>.from(data['kicks']),
        );
      }
    }

    String rawBelt = _beltCtrl.text.trim();
    String beltNameForLookup = rawBelt;
    if (beltNameForLookup.toLowerCase().endsWith(' belt')) {
      beltNameForLookup = beltNameForLookup
          .substring(0, beltNameForLookup.length - 5)
          .trim();
    }

    final currentBeltDef = BeltDefinitions.getByName(beltNameForLookup);
    final String canonicalBeltName = currentBeltDef.name;

    await progressController.fetchOverallStats(widget.trainee['id'], rawBelt);

    if (progressController.overallAverage.value < 0.01 &&
        rawBelt.toLowerCase() != canonicalBeltName.toLowerCase()) {
      await progressController.fetchOverallStats(
        widget.trainee['id'],
        canonicalBeltName,
      );
    }

    String nextBelt = rawBelt;
    bool isPromoted = false;

    if (progressController.overallAverage.value >= 0.99) {
      if (canonicalBeltName.toLowerCase() == 'black') {
        // Stay Black
      } else {
        final nextBeltDef = BeltDefinitions.getNext(currentBeltDef.id);
        if (nextBeltDef != null) {
          nextBelt = nextBeltDef.name;
          isPromoted = true;
        }
      }
    }

    String formattedDateForApi = "";
    if (_selectedDob != null) {
      String year = _selectedDob!.year.toString();
      String month = _selectedDob!.month.toString().padLeft(2, '0');
      String day = _selectedDob!.day.toString().padLeft(2, '0');
      formattedDateForApi = "$year-$month-$day";
    } else {
      formattedDateForApi = _dobCtrl.text;
    }

    final Map<String, dynamic> updateData = {
      'name': _nameCtrl.text,
      'belt': nextBelt,
      'dateOfBirth': formattedDateForApi,
      'gender': _genderCtrl.text,
      'phone': _phoneCtrl.text,
      'email': _emailCtrl.text,
      'address': _addressCtrl.text,
      'guardianName': _guardianNameCtrl.text,
      'guardianContact': _guardianContactCtrl.text,
      'guardianAddress': _guardianAddressCtrl.text,
      'goals': _goalsCtrl.text,
      'conditions': _conditionsCtrl.text,
      'competency': _competencyCtrl.text,
    };

    // Pass the new image path if user picked a new image
    await traineeController.updateTrainee(
      widget.trainee['id'],
      updateData,
      newImagePath: _pickedImage?.path,
    );
    if (isPromoted) {
      await Future.delayed(const Duration(milliseconds: 300));

      Get.snackbar(
        "Congratulations!",
        "Trainee promoted to $nextBelt Belt!",
        backgroundColor: const Color(0xFF00FFA6),
        colorText: Colors.black,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    }
  }

  void _deleteTrainee() {
    traineeController.deleteTrainee(widget.trainee['id']);
  }

  Future<void> _pickImage(img.ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        final fileSize = await File(picked.path).length();
        const maxSize = 1048576; // 1MB in bytes

        if (fileSize > maxSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Image size must be 1MB or less. Selected image is ${(fileSize / 1048576).toStringAsFixed(2)}MB',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        setState(() {
          _pickedImage = picked;
        });
      }
    } catch (e) {}
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141823),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text(
                'Choose from gallery',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(img.ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text(
                'Take a photo',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(img.ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _getDisplayImage() {
    if (_pickedImage != null) {
      return FileImage(File(_pickedImage!.path));
    }
    final String? imgData = widget.trainee['image'];
    if (imgData != null && imgData.isNotEmpty) {
      if (imgData.startsWith('http')) return NetworkImage(imgData);
      if (imgData.startsWith('assets/')) return AssetImage(imgData);
      try {
        final f = File(imgData);
        if (f.existsSync()) return FileImage(f);
      } catch (e) {}
    }
    return const AssetImage('assets/images/placeholder_avatar.png');
  }

  Widget _boxedField(
    String label,
    TextEditingController ctrl, {
    required FocusNode focusNode,
    required String fieldKey,
    double height = 30,
    bool readOnly = false,
    VoidCallback? onTap,
    String? hintText,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3D42),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 3),
          ],
          SizedBox(
            height: height == 30 && maxLines == 1 ? 18 : height,
            child: TextField(
              controller: ctrl,
              focusNode: focusNode,
              readOnly: readOnly,
              onTap: onTap,
              maxLines: maxLines,
              maxLength: maxLength,
              textAlignVertical: maxLines > 1
                  ? TextAlignVertical.top
                  : TextAlignVertical.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: height == 30 || maxLines > 1 ? 14 : 12,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                counterText: '',
                hintText: hintText,
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: height == 30 || maxLines > 1 ? 14 : 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          if (_errors[fieldKey] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _errors[fieldKey]!,
                style: GoogleFonts.poppins(
                  color: Colors.redAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        gradient: _customGradientEdit,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(_borderThicknessEdit),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1720),
          borderRadius: BorderRadius.circular(16 - _borderThicknessEdit),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty) ...[
              Text(
                title,
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
            ],
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _outlinedText(String text) {
    return Stack(
      children: [
        Text(
          text,
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5
              ..color = Colors.black,
          ),
        ),
        Text(
          text,
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Future<void> _showConfirmDialog({
    required String message,
    required String confirmButtonText,
    required VoidCallback onConfirm,
    bool isDelete = false,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF09FACA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'CANCEL',
                            style: GoogleFonts.roboto(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          onConfirm();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF09FACA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            confirmButtonText,
                            style: GoogleFonts.roboto(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
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
      backgroundColor: const Color(0xFF141823),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Participant',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _section('', [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image(
                                      image: _getDisplayImage(),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person,
                                        color: Colors.white54,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _showImageSourceActionSheet,
                                  child: Container(
                                    height: 34,
                                    width: 88,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2D3136),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Edit',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: _boxedField(
                                          'Name',
                                          _nameCtrl,
                                          focusNode: _nameFocus,
                                          fieldKey: 'name',
                                          maxLength: 50,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 1,
                                        child: _boxedField(
                                          'Belt',
                                          _beltCtrl,
                                          focusNode: _beltFocus,
                                          fieldKey: 'belt',
                                          readOnly: true,
                                          // onTap: () async {
                                          //   final result = await Get.to(
                                          //     () => TraineeProgressScreen(
                                          //       traineeId: widget.trainee['id']
                                          //           .toString(),
                                          //       traineeName: _nameCtrl.text,
                                          //       currentBelt: _beltCtrl.text,
                                          //       initialPendingUpdates:
                                          //           _pendingProgressUpdates,
                                          //     ),
                                          //   );

                                          //   if (result != null &&
                                          //       result is Map) {
                                          //     setState(() {
                                          //       result.forEach((key, value) {
                                          //         if (key is String &&
                                          //             value is Map) {
                                          //           _pendingProgressUpdates[key] =
                                          //               Map<
                                          //                 String,
                                          //                 dynamic
                                          //               >.from(value);
                                          //         }
                                          //       });
                                          //     });
                                          //   }
                                          // },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: _boxedField(
                                          'Date of Birth',
                                          _dobCtrl,
                                          focusNode: _dobFocus,
                                          fieldKey: 'dob',
                                          readOnly: true,
                                          onTap: _pickDob,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 1,
                                        child: _boxedField(
                                          'Gender',
                                          _genderCtrl,
                                          focusNode: _genderFocus,
                                          fieldKey: 'gender',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _section('Contact', [
                      _boxedField(
                        'Phone',
                        _phoneCtrl,
                        focusNode: _phoneFocus,
                        fieldKey: 'phone',
                      ),
                      const SizedBox(height: 8),
                      _boxedField(
                        'Email',
                        _emailCtrl,
                        focusNode: _emailFocus,
                        fieldKey: 'email',
                      ),
                      const SizedBox(height: 8),
                      _boxedField(
                        'Address',
                        _addressCtrl,
                        focusNode: _addressFocus,
                        fieldKey: 'address',
                        maxLines: 3,
                        height: 60,
                        maxLength: 2000,
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _section('Guardian & Emergency', [
                      _boxedField(
                        'Guardian',
                        _guardianNameCtrl,
                        focusNode: _guardianNameFocus,
                        fieldKey: 'guardianName',
                        maxLength: 50,
                      ),
                      const SizedBox(height: 8),
                      _boxedField(
                        'Guardian Contact',
                        _guardianContactCtrl,
                        focusNode: _guardianContactFocus,
                        fieldKey: 'guardianContact',
                      ),
                      const SizedBox(height: 8),
                      _boxedField(
                        'Address',
                        _guardianAddressCtrl,
                        focusNode: _guardianAddressFocus,
                        fieldKey: 'guardianAddress',
                        maxLines: 3,
                        height: 60,
                        maxLength: 2000,
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _section('Goals', [
                      _boxedField(
                        '',
                        _goalsCtrl,
                        focusNode: _goalsFocus,
                        fieldKey: 'goals',
                        hintText: 'I want ...',
                        maxLines: 4,
                        height: 80,
                        maxLength: 2000,
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _section('Disability & Medical Concern', [
                      _boxedField(
                        '',
                        _conditionsCtrl,
                        focusNode: _conditionsFocus,
                        fieldKey: 'conditions',
                        hintText: 'List disabilities...',
                        maxLines: 4,
                        height: 80,
                        maxLength: 2000,
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _section('Competency', [
                      _boxedField(
                        '',
                        _competencyCtrl,
                        focusNode: _competencyFocus,
                        fieldKey: 'competency',
                        hintText: 'I want ...',
                        maxLines: 4,
                        height: 80,
                        maxLength: 2000,
                      ),
                    ]),
                    const SizedBox(height: 18),

                    Container(
                      decoration: BoxDecoration(
                        gradient: _customGradientEdit,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(_borderThicknessEdit),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1720),
                          borderRadius: BorderRadius.circular(
                            16 - _borderThicknessEdit,
                          ),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (traineeController.loading.value) return;

                                  bool hasErrors = _validateAllFields();
                                  if (hasErrors) {
                                    Get.snackbar(
                                      'Validation Error',
                                      'Please correct the invalid fields',
                                      backgroundColor: Colors.redAccent,
                                      colorText: Colors.white,
                                      margin: const EdgeInsets.all(10),
                                    );
                                    return;
                                  }

                                  _showConfirmDialog(
                                    message:
                                        'Are you sure want to Save a trainee?',
                                    confirmButtonText: 'OK',
                                    onConfirm: _saveChanges,
                                    isDelete: false,
                                  );
                                },
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: _saveButtonGradient,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(child: _outlinedText('Save')),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (traineeController.loading.value) return;
                                  _showConfirmDialog(
                                    message:
                                        'Are you sure want to Delete a Participant?',
                                    confirmButtonText: 'OK',
                                    onConfirm: _deleteTrainee,
                                    isDelete: true,
                                  );
                                },
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: _deleteButtonGradient,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(child: _outlinedText('Delete')),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
              if (traineeController.loading.value)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00FFA6)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
