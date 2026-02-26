import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart' as img;
import 'trainee_controller.dart';
import 'trainee_model.dart';
import '../controller/controller/trainer_controller.dart';

class AddTraineeScreen extends StatefulWidget {
  const AddTraineeScreen({super.key});

  @override
  State<AddTraineeScreen> createState() => _AddTraineeScreenState();
}

class _AddTraineeScreenState extends State<AddTraineeScreen> {
  static const double borderThickness = 1.5;
  static const double formFieldHeight = 18;
  final LinearGradient customGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x1AFFFFFF), Color(0xFA00FFA6)],
  );
  static const Color innerCardBackgroundColor = Color(0xFF141823);
  static const double boxedFieldInnerHeight = 30.0;

  final _nameCtrl = TextEditingController();
  final _beltCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _genderCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _guardianNameCtrl = TextEditingController();
  final _guardianContactCtrl = TextEditingController();
  final _guardianAddressCtrl = TextEditingController();

  final _goalsCtrl = TextEditingController();
  final _conditionsCtrl = TextEditingController();
  final _competencyCtrl = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _beltFocus = FocusNode();
  final FocusNode _genderFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _guardianNameFocus = FocusNode();
  final FocusNode _guardianContactFocus = FocusNode();
  final FocusNode _guardianAddressFocus = FocusNode();

  final _goalsFocus = FocusNode();
  final _conditionsFocus = FocusNode();
  final _competencyFocus = FocusNode();

  final Map<String, String?> _errors = {};

  img.XFile? _pickedImage;
  final img.ImagePicker _picker = img.ImagePicker();

  final TraineeController traineeController =
      Get.isRegistered<TraineeController>()
      ? Get.find<TraineeController>()
      : Get.put(TraineeController());
  final TrainerController trainerController =
      Get.isRegistered<TrainerController>()
      ? Get.find<TrainerController>()
      : Get.put(TrainerController());

  @override
  void initState() {
    super.initState();
    traineeController.error.value = '';

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
  }

  void _onFocusChange(FocusNode node, String fieldKey, String value) {
    if (!node.hasFocus) {
      _validateField(fieldKey, value);
    }
  }

  void _validateField(String key, String value) {
    String? error;
    final trimmedValue = value.trim();
    final lowerCaseValue = trimmedValue.toLowerCase();

    if (trimmedValue.isEmpty) {
      error = 'trainee_error_required'.tr();
    } else {
      if (key == 'gender') {
        if (lowerCaseValue != 'male' && lowerCaseValue != 'female') {
          error = 'trainee_error_gender'.tr();
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
          error = 'trainee_error_belt'.tr();
        }
      } else if (key == 'email' && !GetUtils.isEmail(trimmedValue)) {
        error = 'trainee_error_email'.tr();
      } else if ((key == 'phone' || key == 'guardianContact') &&
          (trimmedValue.length < 9 || trimmedValue.length > 12)) {
        error = 'trainee_error_phone'.tr();
      } else if (key == 'conditions' && !trimmedValue.contains('-')) {
        error = 'trainee_error_conditions_format'.tr();
      }
    }

    setState(() {
      _errors[key] = error;
    });
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

  Widget _gradientBox({required Widget child, double radius = 20}) {
    return Container(
      decoration: BoxDecoration(
        gradient: customGradient,
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: const EdgeInsets.all(borderThickness),
      child: Container(
        decoration: BoxDecoration(
          color: innerCardBackgroundColor,
          borderRadius: BorderRadius.circular(radius - borderThickness),
        ),
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }

  Widget _boxedField(
    String? label,
    TextEditingController ctrl,
    FocusNode focusNode,
    String fieldKey, {
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    int maxLines = 1,
    double? height,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x8A72777A),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Text(
              label,
              style: GoogleFonts.poppins(color: Colors.grey[350], fontSize: 13),
            ),
          if (label != null) const SizedBox(height: 4),
          SizedBox(
            height: height ?? (maxLines > 1 ? null : boxedFieldInnerHeight),
            child: TextField(
              controller: ctrl,
              focusNode: focusNode,
              keyboardType: maxLines > 1
                  ? TextInputType.multiline
                  : keyboardType,
              inputFormatters: formatters,
              maxLines: maxLines,
              maxLength: maxLength,
              textAlignVertical: maxLines > 1
                  ? TextAlignVertical.top
                  : TextAlignVertical.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.0,
                letterSpacing: 0,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: maxLines > 1
                    ? const EdgeInsets.symmetric(vertical: 8)
                    : const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                counterText: '',
                hintText: hint ?? '',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                  letterSpacing: 0,
                ),
                border: InputBorder.none,
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
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
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
    final initial = DateTime(now.year - 10);
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
      _dobCtrl.text = _formatDate(picked);
      setState(() {
        _errors['dob'] = null;
      });
    }
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
                  'trainee_error_image_size'.tr(
                    namedArgs: {
                      'size': (fileSize / 1048576).toStringAsFixed(2),
                    },
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        _pickedImage = picked;
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
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
              title: Text(
                'trainee_image_gallery'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(img.ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: Text(
                'trainee_image_camera'.tr(),
                style: const TextStyle(color: Colors.white),
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

  Future<void> _submitTraineeData() async {
    if (traineeController.loading.value) return;

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
      setState(() => _errors['dob'] = 'trainee_error_required'.tr());
    }

    bool hasErrors = _errors.values.any((e) => e != null);
    if (hasErrors) {
      traineeController.error.value = 'trainee_error_fix_fields'.tr();
      return;
    }

    if (_nameCtrl.text.isEmpty ||
        _beltCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _guardianNameCtrl.text.isEmpty ||
        _guardianContactCtrl.text.isEmpty) {
      traineeController.error.value = 'add_trainee_error_fill_all'.tr();
      return;
    }

    final newTrainee = TraineeModel(
      trainerId: trainerController.currentUserId.value,
      name: _nameCtrl.text,
      belt: _beltCtrl.text,
      dateOfBirth: _dobCtrl.text,
      gender: _genderCtrl.text,
      phone: _phoneCtrl.text,
      email: _emailCtrl.text,
      address: _addressCtrl.text,
      guardianName: _guardianNameCtrl.text,
      guardianContact: _guardianContactCtrl.text,
      guardianAddress: _guardianAddressCtrl.text,
      goals: _goalsCtrl.text,
      conditions: _conditionsCtrl.text,
      competency: _competencyCtrl.text,
      imagePath: _pickedImage?.path,
    );

    await traineeController.addTrainee(newTrainee);

    if (traineeController.success.value) {
      // Navigation will be handled by the dialog's OK button
      Get.snackbar(
        "success".tr(),
        "add_trainee_snackbar_success_msg".tr(),
        backgroundColor: const Color(0xFF00FFA6),
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _showAddConfirmDialog() async {
    traineeController.error.value = '';

    await showDialog<void>(
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
            child: Obx(
              () => Column(
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
                    'add_trainee_dialog_confirm_msg'.tr(),
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
                              color: const Color(0xFF00FFA6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'cancel_caps'.tr(),
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
                          onTap: () async {
                            await _submitTraineeData();
                            if (traineeController.success.value) {
                              Navigator.of(ctx).pop();
                              Navigator.of(context).pop();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00FFA6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'ok'.tr(),
                              style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (traineeController.error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        traineeController.error.value,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopFieldContainer({
    required Widget child,
    required String label,
    required String fieldKey,
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
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 3),
          child,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1114),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'add_trainee_title_dashboard'.tr(),
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _gradientBox(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'add_trainee_title_main'.tr(),
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        margin: const EdgeInsets.only(right: 8),
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
                        child: _outlinedText(
                          'cancel'.tr(),
                          GoogleFonts.roboto(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showAddConfirmDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
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
                              color: Colors.black.withValues(alpha: 0.22),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _outlinedText(
                          'add'.tr(),
                          GoogleFonts.roboto(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _gradientBox(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 88,
                              height: 88,
                              color: Colors.grey.shade800,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0),
                                child: _pickedImage != null
                                    ? Image.file(
                                        File(_pickedImage!.path),
                                        fit: BoxFit.cover,
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Colors.white54,
                                          size: 36,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _showImageSourceActionSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D3136),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'add_trainee_btn_upload'.tr(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildTopFieldContainer(
                                    label: 'trainee_lbl_name'.tr(),
                                    fieldKey: 'name',
                                    child: SizedBox(
                                      height: formFieldHeight,
                                      child: TextField(
                                        controller: _nameCtrl,
                                        focusNode: _nameFocus,
                                        maxLength: 50,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 0,
                                              ),
                                          hintText: 'trainee_hint_name'.tr(),
                                          hintStyle: GoogleFonts.poppins(
                                            color: Colors.white54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          border: InputBorder.none,
                                          counterText: '',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 1,
                                  child: _buildTopFieldContainer(
                                    label: 'trainee_lbl_belt'.tr(),
                                    fieldKey: 'belt',
                                    child: SizedBox(
                                      height: formFieldHeight,
                                      child: TextField(
                                        controller: _beltCtrl,
                                        focusNode: _beltFocus,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 0,
                                              ),
                                          hintText: 'trainee_hint_belt'.tr(),
                                          hintStyle: GoogleFonts.poppins(
                                            color: Colors.white54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildTopFieldContainer(
                                    label: 'trainee_lbl_dob'.tr(),
                                    fieldKey: 'dob',
                                    child: GestureDetector(
                                      onTap: _pickDob,
                                      child: AbsorbPointer(
                                        child: SizedBox(
                                          height: formFieldHeight,
                                          child: TextField(
                                            controller: _dobCtrl,
                                            readOnly: true,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 0,
                                                  ),
                                              hintText: 'trainee_hint_dob'.tr(),
                                              hintStyle: GoogleFonts.poppins(
                                                color: Colors.white54,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 1,
                                  child: _buildTopFieldContainer(
                                    label: 'trainee_lbl_gender'.tr(),
                                    fieldKey: 'gender',
                                    child: SizedBox(
                                      height: formFieldHeight,
                                      child: TextField(
                                        controller: _genderCtrl,
                                        focusNode: _genderFocus,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 0,
                                              ),
                                          hintText: 'trainee_hint_gender'.tr(),
                                          hintStyle: GoogleFonts.poppins(
                                            color: Colors.white54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          border: InputBorder.none,
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _gradientBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'trainee_title_contact'.tr(),
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _boxedField(
                      'trainee_lbl_phone'.tr(),
                      _phoneCtrl,
                      _phoneFocus,
                      'phone',
                      hint: 'trainee_hint_phone'.tr(),
                      keyboardType: TextInputType.phone,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 8),
                    _boxedField(
                      'trainee_lbl_email'.tr(),
                      _emailCtrl,
                      _emailFocus,
                      'email',
                      hint: 'trainee_hint_email'.tr(),
                    ),
                    const SizedBox(height: 8),
                    _boxedField(
                      'trainee_lbl_address'.tr(),
                      _addressCtrl,
                      _addressFocus,
                      'address',
                      hint: 'trainee_hint_address'.tr(),
                      maxLines: 3,
                      maxLength: 2000,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _gradientBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'trainee_title_guardian'.tr(),
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _boxedField(
                      'trainee_lbl_guardian_name'.tr(),
                      _guardianNameCtrl,
                      _guardianNameFocus,
                      'guardianName',
                      hint: 'trainee_hint_guardian_name'.tr(),
                      maxLength: 50,
                    ),
                    const SizedBox(height: 8),
                    _boxedField(
                      'trainee_lbl_guardian_contact'.tr(),
                      _guardianContactCtrl,
                      _guardianContactFocus,
                      'guardianContact',
                      hint: 'trainee_hint_phone'.tr(),
                      keyboardType: TextInputType.phone,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 8),
                    _boxedField(
                      'trainee_lbl_address'.tr(),
                      _guardianAddressCtrl,
                      _guardianAddressFocus,
                      'guardianAddress',
                      hint: 'trainee_hint_address'.tr(),
                      maxLines: 3,
                      maxLength: 2000,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _gradientBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'trainee_title_goals_long'.tr(),
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _boxedField(
                      'trainee_lbl_goals'.tr(),
                      _goalsCtrl,
                      _goalsFocus,
                      'goals',
                      hint: 'trainee_hint_goals'.tr(),
                      maxLines: 3,
                      height: 60,
                      maxLength: 2000,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _gradientBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'trainee_title_medical'.tr(),
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _boxedField(
                      'trainee_lbl_conditions'.tr(),
                      _conditionsCtrl,
                      _conditionsFocus,
                      'conditions',
                      hint: 'trainee_hint_conditions_long'.tr(),
                      maxLines: 8,
                      height: 140,
                      maxLength: 2000,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _gradientBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'trainee_title_competency'.tr(),
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _boxedField(
                      'trainee_lbl_competency'.tr(),
                      _competencyCtrl,
                      _competencyFocus,
                      'competency',
                      hint: 'trainee_hint_competency'.tr(),
                      maxLines: 3,
                      height: 60,
                      maxLength: 2000,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
