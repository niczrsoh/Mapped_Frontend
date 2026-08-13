import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/controller/register_controller.dart';
import '../global/routes.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  // Make this method static so it can be accessed from state classes
  static InputDecoration _inputDecoration({
    required String label,
    bool hasError = false,
  }) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.white10,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? Colors.redAccent : const Color(0xFF00C7A7),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? Colors.redAccent : const Color(0xFF00C7A7),
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/registerBg.jpg',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.35),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1E1E1E), Color(0xFF2B2B2B)],
                  ),
                ),
              ),
            ),
          ),
          // dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.65)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  // logo
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 180,
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => ShaderMask(
                        shaderCallback: (rect) =>
                            LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF0A5848), Color(0xFF09FACA)],
                            ).createShader(
                              Rect.fromLTWH(0, 0, rect.width, rect.height),
                            ),
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          'MAPPED',
                          style: const TextStyle(
                            fontFamily: 'NicoMoji',
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Full Name Field
                  _FullNameTextField(controller: controller),
                  const SizedBox(height: 12),

                  // Email Field
                  _EmailTextField(controller: controller),
                  const SizedBox(height: 12),

                  // Password Field
                  _PasswordTextField(controller: controller),
                  const SizedBox(height: 12),

                  // Password Confirmation Field
                  _PasswordConfirmationTextField(controller: controller),

                  Obx(() {
                    if (controller.error.value.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Text(
                          controller.error.value,
                          style: GoogleFonts.poppins(
                            color: Colors.redAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  const SizedBox(height: 20),
                  Obx(
                    () => Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: controller.loading.value
                              ? null
                              : () {
                                  // Clear previous errors
                                  controller.fullNameError.value = '';
                                  controller.emailError.value = '';
                                  controller.passwordError.value = '';
                                  controller.passwordConfirmationError.value =
                                      '';

                                  // Validate form before registering
                                  if (controller.validateForm()) {
                                    controller.register();
                                  }
                                },
                          child: controller.loading.value
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'register_btn_register'.tr(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    height: 1.0,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            'register_msg_have_account'.tr(),
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4), // Small gap
                        InkWell(
                          onTap: () => Get.toNamed(AppRoutes.login),
                          child: Text(
                            'login'.tr(),
                            style: GoogleFonts.poppins(
                              color: Color(0xFF00C7A7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDB4437),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          controller.registerWithGoogle();
                        },
                        child: Obx(
                          () => controller.googleLoading.value
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'register_btn_google'.tr(),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
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

// Full Name TextField
class _FullNameTextField extends StatefulWidget {
  final RegisterController controller;

  const _FullNameTextField({required this.controller});

  @override
  __FullNameTextFieldState createState() => __FullNameTextFieldState();
}

class __FullNameTextFieldState extends State<_FullNameTextField> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.controller.fullName.value,
    );

    ever(widget.controller.fullName, (value) {
      if (_textController.text != value) {
        _textController.text = value;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final hasError = widget.controller.fullNameError.value.isNotEmpty;

          return TextField(
            controller: _textController,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            cursorColor: const Color(0xFF00C7A7),
            decoration: RegisterScreen._inputDecoration(
              label: 'register_hint_full_name'.tr(),
              hasError: hasError,
            ),
            onChanged: (value) {
              widget.controller.fullName.value = value;
              _textController.text = value;
              // Clear error when user starts typing
              if (hasError) {
                widget.controller.fullNameError.value = '';
              }
            },
          );
        }),
        // Error message below the field
        Obx(() {
          if (widget.controller.fullNameError.value.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Text(
                widget.controller.fullNameError.value,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}

// Email TextField
class _EmailTextField extends StatefulWidget {
  final RegisterController controller;

  const _EmailTextField({required this.controller});

  @override
  __EmailTextFieldState createState() => __EmailTextFieldState();
}

class __EmailTextFieldState extends State<_EmailTextField> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.controller.email.value,
    );

    ever(widget.controller.email, (value) {
      if (_textController.text != value) {
        _textController.text = value;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final hasError = widget.controller.emailError.value.isNotEmpty;

          return TextField(
            controller: _textController,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            cursorColor: const Color(0xFF00C7A7),
            decoration: RegisterScreen._inputDecoration(
              label: 'email'.tr(),
              hasError: hasError,
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              widget.controller.email.value = value;
              _textController.text = value;
              // Clear error when user starts typing
              if (hasError) {
                widget.controller.emailError.value = '';
              }
            },
          );
        }),
        // Error message below the field
        Obx(() {
          if (widget.controller.emailError.value.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Text(
                widget.controller.emailError.value,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}

// Password TextField
class _PasswordTextField extends StatefulWidget {
  final RegisterController controller;

  const _PasswordTextField({required this.controller});

  @override
  __PasswordTextFieldState createState() => __PasswordTextFieldState();
}

class __PasswordTextFieldState extends State<_PasswordTextField> {
  late TextEditingController _textController;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.controller.password.value,
    );

    ever(widget.controller.password, (value) {
      if (_textController.text != value) {
        _textController.text = value;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final hasError = widget.controller.passwordError.value.isNotEmpty;

          return TextField(
            controller: _textController,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            cursorColor: const Color(0xFF00C7A7),
            decoration: InputDecoration(
              hintText: 'password'.tr(),
              hintStyle: const TextStyle(color: Colors.white),
              filled: true,
              fillColor: Colors.white10,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? Colors.redAccent : const Color(0xFF00C7A7),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? Colors.redAccent : const Color(0xFF00C7A7),
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            obscureText: _obscureText,
            onChanged: (value) {
              widget.controller.password.value = value;
              _textController.text = value;
              // Clear error when user starts typing
              if (hasError) {
                widget.controller.passwordError.value = '';
              }
              // Also clear confirmation error if password changes
              if (widget
                  .controller
                  .passwordConfirmationError
                  .value
                  .isNotEmpty) {
                widget.controller.passwordConfirmationError.value = '';
              }
            },
          );
        }),
        // Error message below the field
        Obx(() {
          if (widget.controller.passwordError.value.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Text(
                widget.controller.passwordError.value,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}

// Password Confirmation TextField
class _PasswordConfirmationTextField extends StatefulWidget {
  final RegisterController controller;

  const _PasswordConfirmationTextField({required this.controller});

  @override
  __PasswordConfirmationTextFieldState createState() =>
      __PasswordConfirmationTextFieldState();
}

class __PasswordConfirmationTextFieldState
    extends State<_PasswordConfirmationTextField> {
  late TextEditingController _textController;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.controller.passwordConfirmation.value,
    );

    ever(widget.controller.passwordConfirmation, (value) {
      if (_textController.text != value) {
        _textController.text = value;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final hasError =
              widget.controller.passwordConfirmationError.value.isNotEmpty;

          return TextField(
            controller: _textController,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            cursorColor: const Color(0xFF00C7A7),
            decoration: InputDecoration(
              hintText: 'register_hint_password_confirm'.tr(),
              hintStyle: const TextStyle(color: Colors.white),
              filled: true,
              fillColor: Colors.white10,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? Colors.redAccent : const Color(0xFF00C7A7),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? Colors.redAccent : const Color(0xFF00C7A7),
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            obscureText: _obscureText,
            onChanged: (value) {
              widget.controller.passwordConfirmation.value = value;
              _textController.text = value;
              // Clear error when user starts typing
              if (hasError) {
                widget.controller.passwordConfirmationError.value = '';
              }
            },
          );
        }),
        // Error message below the field
        Obx(() {
          if (widget.controller.passwordConfirmationError.value.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Text(
                widget.controller.passwordConfirmationError.value,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
