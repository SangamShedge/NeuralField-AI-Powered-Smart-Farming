import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../api/api_service.dart';
import '../main.dart';
import 'register_screen.dart';

// Enum declared outside the class
enum ScreenState { login, forgotPassword, resetPassword }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Login related
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _loginService = LoginService();
  bool _isLoginLoading = false;
  bool _obscureLoginPassword = true;
  bool _imageError = false;

  // Forgot Password related
  final _forgotPasswordFormKey = GlobalKey<FormState>();
  final _forgotPasswordEmailController = TextEditingController();
  final _otpService = OtpService();
  bool _isForgotPasswordLoading = false;

  // Reset Password related
  final _resetPasswordFormKey = GlobalKey<FormState>();
  final _resetOtpController = TextEditingController();
  final _resetPasswordController = TextEditingController();
  final _resetConfirmPasswordController = TextEditingController();
  bool _isResetPasswordLoading = false;
  bool _isResendingOtp = false;
  bool _obscureResetPassword = true;
  bool _obscureResetConfirmPassword = true;
  String? _resetEmail;

  // Screen state management
  ScreenState _currentScreen = ScreenState.login;

  @override
  void dispose() {
    // Login controllers
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _loginService.dispose();

    // Forgot password controllers
    _forgotPasswordEmailController.dispose();

    // Reset password controllers
    _resetOtpController.dispose();
    _resetPasswordController.dispose();
    _resetConfirmPasswordController.dispose();
    _otpService.dispose();

    super.dispose();
  }

  // Login Methods
  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() {
      _isLoginLoading = true;
    });

    try {
      final response = await _loginService.login(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        await _loginService.saveUserEmail(_loginEmailController.text.trim());

        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.loginSuccess),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      final localizations = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.errorPrefix} $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoginLoading = false;
        });
      }
    }
  }

  // Forgot Password Methods
  Future<void> _handleSendOtp() async {
    if (!_forgotPasswordFormKey.currentState!.validate()) return;

    setState(() {
      _isForgotPasswordLoading = true;
    });

    try {
      final response = await _otpService.forgotPassword(
        email: _forgotPasswordEmailController.text.trim(),
      );

      if (!mounted) return;

      if (response.isSuccess) {
        setState(() {
          _resetEmail = _forgotPasswordEmailController.text.trim();
          _currentScreen = ScreenState.resetPassword;
        });
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.otpSentSuccess),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      final localizations = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.errorPrefix} $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isForgotPasswordLoading = false;
        });
      }
    }
  }

  // Reset Password Methods
  Future<void> _handleResetPassword() async {
    if (!_resetPasswordFormKey.currentState!.validate()) return;

    setState(() {
      _isResetPasswordLoading = true;
    });

    try {
      final response = await _otpService.resetPassword(
        email: _resetEmail!,
        otp: _resetOtpController.text.trim(),
        newPassword: _resetPasswordController.text,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.resetPasswordSuccess),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        setState(() {
          _currentScreen = ScreenState.login;
          _loginEmailController.text = _resetEmail!;
          _resetEmail = null;
          _resetOtpController.clear();
          _resetPasswordController.clear();
          _resetConfirmPasswordController.clear();
        });
      } else {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      final localizations = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.errorPrefix} $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResetPasswordLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResendingOtp = true;
    });

    try {
      final response = await _otpService.forgotPassword(
        email: _resetEmail!,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.otpResentSuccess),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      final localizations = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.errorResendingOtp} $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResendingOtp = false;
        });
      }
    }
  }

  void _goToForgotPassword() {
    setState(() {
      _currentScreen = ScreenState.forgotPassword;
      _forgotPasswordEmailController.clear();
    });
  }

  void _goBackToLogin() {
    setState(() {
      _currentScreen = ScreenState.login;
      _resetEmail = null;
      _resetOtpController.clear();
      _resetPasswordController.clear();
      _resetConfirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF00B4DB),
              Color(0xFF0083B0),
              Color(0xFF00A86B),
              Color(0xFF7CB342),
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Header (Common for all screens)
                  _buildLogo(),
                  const SizedBox(height: 24),
                  _buildHeaderText(localizations),
                  const SizedBox(height: 32),

                  // Dynamic Content based on screen state
                  _buildCurrentScreen(localizations),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText(AppLocalizations localizations) {
    String tagline;
    if (_currentScreen == ScreenState.forgotPassword) {
      tagline = localizations.forgotPasswordTagline;
    } else if (_currentScreen == ScreenState.resetPassword) {
      tagline = localizations.resetPasswordTagline;
    } else {
      tagline = localizations.smartFarmingPlatform;
    }

    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: localizations.neural,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              TextSpan(
                text: localizations.field,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            tagline,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentScreen(AppLocalizations localizations) {
    switch (_currentScreen) {
      case ScreenState.login:
        return _buildLoginForm(localizations);
      case ScreenState.forgotPassword:
        return _buildForgotPasswordForm(localizations);
      case ScreenState.resetPassword:
        return _buildResetPasswordForm(localizations);
    }
  }

  Widget _buildLoginForm(AppLocalizations localizations) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _loginFormKey,
          child: Column(
            children: [
              // Email Field
              TextFormField(
                controller: _loginEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: localizations.emailLabel,
                  hintText: localizations.emailHint,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.enterEmail;
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return localizations.validEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _loginPasswordController,
                obscureText: _obscureLoginPassword,
                decoration: InputDecoration(
                  labelText: localizations.passwordLabel,
                  hintText: localizations.passwordHint,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureLoginPassword = !_obscureLoginPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.enterPassword;
                  }
                  if (value.length < 4) {
                    return localizations.passwordMinLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _goToForgotPassword,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF00A86B),
                  ),
                  child: Text(localizations.forgotPassword),
                ),
              ),
              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoginLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A86B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoginLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    localizations.loginButton,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Register Hint
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(localizations.noAccount),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      localizations.registerButton,
                      style: const TextStyle(
                        color: Color(0xFF00A86B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordForm(AppLocalizations localizations) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _forgotPasswordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lock_reset,
                size: 48,
                color: Color(0xFF00A86B),
              ),
              const SizedBox(height: 16),
              Text(
                localizations.resetPasswordTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localizations.resetPasswordDescription,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _forgotPasswordEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: localizations.emailLabel,
                  hintText: localizations.emailHint,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.enterEmail;
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return localizations.validEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isForgotPasswordLoading ? null : _handleSendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A86B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isForgotPasswordLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    localizations.sendOtpButton,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(localizations.rememberPassword),
                  GestureDetector(
                    onTap: _goBackToLogin,
                    child: Text(
                      localizations.backToLogin,
                      style: const TextStyle(
                        color: Color(0xFF00A86B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResetPasswordForm(AppLocalizations localizations) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _resetPasswordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.security,
                size: 48,
                color: Color(0xFF00A86B),
              ),
              const SizedBox(height: 16),
              Text(
                localizations.createNewPasswordTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localizations.createNewPasswordDescription(_resetEmail ?? ''),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _resetOtpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: localizations.otpLabel,
                  hintText: localizations.otpHint,
                  prefixIcon: const Icon(Icons.pin),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.enterOtp;
                  }
                  if (value.length != 6) {
                    return localizations.otpLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _resetPasswordController,
                obscureText: _obscureResetPassword,
                decoration: InputDecoration(
                  labelText: localizations.newPasswordLabel,
                  hintText: localizations.newPasswordHint,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureResetPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureResetPassword = !_obscureResetPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.enterNewPassword;
                  }
                  if (value.length < 4) {
                    return localizations.passwordMinLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _resetConfirmPasswordController,
                obscureText: _obscureResetConfirmPassword,
                decoration: InputDecoration(
                  labelText: localizations.confirmPasswordLabel,
                  hintText: localizations.confirmPasswordHint,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureResetConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureResetConfirmPassword = !_obscureResetConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.confirmPasswordRequired;
                  }
                  if (value != _resetPasswordController.text) {
                    return localizations.passwordsDoNotMatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isResetPasswordLoading ? null : _handleResetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A86B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isResetPasswordLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    localizations.resetPasswordButton,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(localizations.didNotReceiveOtp),
                  GestureDetector(
                    onTap: _isResendingOtp ? null : _resendOtp,
                    child: _isResendingOtp
                        ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF00A86B),
                      ),
                    )
                        : Text(
                      localizations.resendOtp,
                      style: const TextStyle(
                        color: Color(0xFF00A86B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Center(
                child: GestureDetector(
                  onTap: _goBackToLogin,
                  child: Text(
                    localizations.useDifferentEmail,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
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

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: Colors.white,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: _imageError
            ? _buildFallbackLogo()
            : Image.asset(
          'assets/icon/lc_icon.png',
          fit: BoxFit.contain,
          width: 90,
          height: 90,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading logo: $error');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _imageError = true;
                });
              }
            });
            return _buildFallbackLogo();
          },
        ),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Icon(
          Icons.agriculture,
          size: 50,
          color: Color(0xFF00A86B),
        ),
      ),
    );
  }
}