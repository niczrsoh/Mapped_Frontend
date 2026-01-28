import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart' as img;
import '../controller/controller/trainee_controller.dart';

class AddTraineeScreen extends StatefulWidget {
  const AddTraineeScreen({Key? key}) : super(key: key);

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

  // Controllers
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

  // Focus Nodes
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _beltFocus = FocusNode();
  final FocusNode _genderFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _guardianNameFocus = FocusNode();
  final FocusNode _guardianContactFocus = FocusNode();
  final FocusNode _guardianAddressFocus = FocusNode();

  // Error State
  final Map<String, String?> _errors = {};

  img.XFile? _pickedImage;
  final img.ImagePicker _picker = img.ImagePicker();

  final TraineeController traineeController = Get.find<TraineeController>();

  @override
  void initState() {
    super.initState();
    // Clear any previous controller errors
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
  }

  void _onFocusChange(FocusNode node, String fieldKey, String value) {
    if (!node.hasFocus) {
      _validateField(fieldKey, value);
    }
  }

  // --- UPDATED VALIDATION LOGIC ---
  void _validateField(String key, String value) {
    String? error;
    final trimmedValue = value.trim();
    final lowerCaseValue = trimmedValue.toLowerCase();

    if (trimmedValue.isEmpty) {
      error = 'This field is required to fill';
    } else {
      // 1. Gender Validation
      if (key == 'gender') {
        if (lowerCaseValue != 'male' && lowerCaseValue != 'female') {
          error = 'Must be Male or Female';
        }
      }
      // 2. Belt Validation
      else if (key == 'belt') {
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
      }
      // Email Validation
      else if (key == 'email' && !GetUtils.isEmail(trimmedValue)) {
        error = 'Invalid Email';
      }
      // Phone Validation
      else if ((key == 'phone' || key == 'guardianContact') &&
          trimmedValue.length < 9) {
        error = 'Invalid Phone';
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

    _nameFocus.dispose();
    _beltFocus.dispose();
    _genderFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _addressFocus.dispose();
    _guardianNameFocus.dispose();
    _guardianContactFocus.dispose();
    _guardianAddressFocus.dispose();
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
    String label,
    TextEditingController ctrl,
    FocusNode focusNode,
    String fieldKey, {
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
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
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.grey[350], fontSize: 13),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: boxedFieldInnerHeight,
            child: TextField(
              controller: ctrl,
              focusNode: focusNode,
              keyboardType: keyboardType,
              inputFormatters: formatters,
              textAlignVertical: TextAlignVertical.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.0,
                letterSpacing: 0,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 6,
                ),
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
        _pickedImage = picked;
        setState(() {});
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDialog() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Adding Trainee...'),
      ],
    );
  }

  Future<void> _submitTraineeData() async {
    // 1. Run validation on ALL fields immediately
    _validateField('name', _nameCtrl.text);
    _validateField('belt', _beltCtrl.text);
    _validateField('gender', _genderCtrl.text);
    _validateField('phone', _phoneCtrl.text);
    _validateField('email', _emailCtrl.text);
    _validateField('address', _addressCtrl.text);
    _validateField('guardianName', _guardianNameCtrl.text);
    _validateField('guardianContact', _guardianContactCtrl.text);
    _validateField('guardianAddress', _guardianAddressCtrl.text);
    if (_dobCtrl.text.isEmpty) {
      setState(() => _errors['dob'] = 'This field is required to fill');
    }

    // 2. Check if there are any errors in the map
    bool hasErrors = _errors.values.any((e) => e != null);

    // 3. If there are errors, STOP
    if (hasErrors) {
      traineeController.error.value = 'Please correct the invalid fields above';
      return;
    }

    if (_nameCtrl.text.isEmpty ||
        _beltCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _guardianNameCtrl.text.isEmpty ||
        _guardianContactCtrl.text.isEmpty) {
      traineeController.error.value = 'Please fill in all required fields';
      return;
    }

    // 4. Proceed to Add (Use await to wait for result)
    await traineeController.addTrainee(
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
      imagePath: _pickedImage?.path,
    );

    // 5. Check success status from controller
    if (traineeController.success.value) {
      // Close the "Confirm Add" dialog (the one with the warning icon)
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show the Success Dialog
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFA6).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF00FFA6),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Success!',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Trainee has been added to the list.',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // 1. Close the Success Dialog
                  Navigator.of(ctx).pop();

                  // 2. Close the Add Trainee Screen (Go back to list)
                  Get.back();

                  // NOTE: Since we used GetX Obx on the previous screen,
                  // it will automatically show the new trainee!
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFA6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'GO TO LIST',
                    style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddConfirmDialog() async {
    // Reset any previous dialog errors when opening
    traineeController.error.value = '';

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Obx(
          () => Dialog(
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
              child: traineeController.loading.value
                  ? _buildLoadingDialog()
                  : Column(
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
                          'Are you sure want to add a Trainee?',
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00FFA6),
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
                                onTap: _submitTraineeData, // Validates on click
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00FFA6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'OK',
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
                        // Error message shown inside dialog if validation fails
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
          'Trainee Dashboard',
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
                        'Add Trainee',
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
                          'Cancel',
                          GoogleFonts.roboto(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      // We open the dialog first, but validate only when OK is clicked inside
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
                              color: Colors.black.withOpacity(0.22),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _outlinedText(
                          'Add',
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
                                'Upload',
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
                                    label: 'Name',
                                    fieldKey: 'name',
                                    child: SizedBox(
                                      height: formFieldHeight,
                                      child: TextField(
                                        controller: _nameCtrl,
                                        focusNode: _nameFocus,
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
                                          hintText: 'Rayyan Firas',
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
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 1,
                                  child: _buildTopFieldContainer(
                                    label: 'Belt',
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
                                          hintText: 'White',
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
                                    label: 'Date of Birth',
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
                                              hintText: '16 January 2013',
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
                                    label: 'Gender',
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
                                          hintText: 'Female',
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
                      'Contact',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _boxedField(
                      'Phone',
                      _phoneCtrl,
                      _phoneFocus,
                      'phone',
                      hint: '+60 ...',
                      keyboardType: TextInputType.phone,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 8),
                    _boxedField(
                      'Email',
                      _emailCtrl,
                      _emailFocus,
                      'email',
                      hint: 'email@gmail.com',
                    ),
                    const SizedBox(height: 8),
                    _boxedField(
                      'Address',
                      _addressCtrl,
                      _addressFocus,
                      'address',
                      hint: 'Address ...',
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
                      'Guardian & Emergency',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _boxedField(
                      'Guardian',
                      _guardianNameCtrl,
                      _guardianNameFocus,
                      'guardianName',
                      hint: 'Name ...',
                    ),
                    const SizedBox(height: 8),
                    _boxedField(
                      'Guardian Contact',
                      _guardianContactCtrl,
                      _guardianContactFocus,
                      'guardianContact',
                      hint: '+60 ...',
                      keyboardType: TextInputType.phone,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 8),
                    _boxedField(
                      'Address',
                      _guardianAddressCtrl,
                      _guardianAddressFocus,
                      'guardianAddress',
                      hint: 'Address ...',
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
