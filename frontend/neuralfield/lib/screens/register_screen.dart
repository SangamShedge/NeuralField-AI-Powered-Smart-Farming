import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../api/api_service.dart';
import '../main.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _verifyEmailController = TextEditingController();
  final _verifyOtpController = TextEditingController();
  final _registerService = RegisterService();
  final _otpService = OtpService();
  final _loginService = LoginService();

  bool _isLoading = false;
  bool _isVerifying = false;
  bool _isResending = false;
  bool _isSendingOtp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isOtpSent = false;
  bool _showVerifyExisting = false;
  bool _imageError = false;
  String _otp = '';
  String? _registeredEmail;
  String? _registeredPassword;
  String? _registeredUsername;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _verifyEmailController.dispose();
    _verifyOtpController.dispose();
    _registerService.dispose();
    _otpService.dispose();
    _loginService.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _registerService.register(
        email: _emailController.text.trim(),
        username: _nameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        _registeredEmail = _emailController.text.trim();
        _registeredPassword = _passwordController.text;
        _registeredUsername = _nameController.text.trim();

        setState(() {
          _isOtpSent = true;
          _isLoading = false;
        });

        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.otpSentToEmailVerify),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Check if the error is because email already exists but not verified
        if (response.message.contains('already exists')) {
          _showVerificationDialog();
        } else {
          final localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      final localizations = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.errorPrefix} $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showVerificationDialog() {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(localizations.accountAlreadyExistsTitle),
        content: Text(localizations.accountAlreadyExistsMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _emailController.clear();
              _passwordController.clear();
              _confirmPasswordController.clear();
              _nameController.clear();
            },
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showVerifyExistingAccount();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF00A86B),
            ),
            child: Text(localizations.verifyAccount),
          ),
        ],
      ),
    );
  }

  void _showVerifyExistingAccount() {
    setState(() {
      _showVerifyExisting = true;
      _verifyEmailController.text = _emailController.text.trim();
    });
  }

  // Send OTP for existing account verification
  Future<void> _sendVerificationOtp() async {
    final email = _verifyEmailController.text.trim();
    final localizations = AppLocalizations.of(context)!;
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.enterEmail),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSendingOtp = true;
    });

    try {
      final response = await _otpService.sendOtp(email: email);

      if (!mounted) return;

      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.verificationOtpSent),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.errorPrefix} $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingOtp = false;
        });
      }
    }
  }

  // Verify existing account
  Future<void> _verifyExistingAccount() async {
    final email = _verifyEmailController.text.trim();
    final otp = _verifyOtpController.text.trim();
    final localizations = AppLocalizations.of(context)!;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.enterEmail),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (otp.isEmpty || otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.otpInvalidLength),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final response = await _otpService.verifyOtp(
        email: email,
        otp: otp,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.accountVerifiedSuccess),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.errorPrefix} $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  // Resend OTP for new registration using send-otp API
  Future<void> _resendOtp() async {
    if (_registeredEmail == null) {
      final localizations = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.unableToResendOtp),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isResending = true;
    });

    try {
      final response = await _otpService.sendOtp(email: _registeredEmail!);

      if (!mounted) return;

      final localizations = AppLocalizations.of(context)!;
      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.otpResentSuccessRegister),
            backgroundColor: Colors.green,
          ),
        );
      } else {
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
          _isResending = false;
        });
      }
    }
  }

  Future<void> _handleVerifyOtp() async {
    final localizations = AppLocalizations.of(context)!;
    if (_otp.isEmpty || _otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.otpInvalidLength),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final response = await _otpService.verifyOtp(
        email: _registeredEmail!,
        otp: _otp,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        final loginResponse = await _loginService.login(
          email: _registeredEmail!,
          password: _registeredPassword!,
        );

        if (loginResponse.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.accountVerifiedAndLoggedIn),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.accountVerifiedPleaseLogin),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.errorPrefix} $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
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
                  // Logo
                  _buildLogo(),
                  const SizedBox(height: 24),

                  // Dynamic Header Text
                  _buildHeaderText(localizations),
                  const SizedBox(height: 32),

                  // Dynamic Content based on state
                  Container(
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
                      child: _showVerifyExisting
                          ? _buildVerifyExistingForm(localizations)
                          : (_isOtpSent ? _buildOtpVerification(localizations) : _buildRegistrationForm(localizations)),
                    ),
                  ),
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
    if (_showVerifyExisting) {
      tagline = localizations.verifyExistingTagline;
    } else if (_isOtpSent) {
      tagline = localizations.enterOtpTagline;
    } else {
      tagline = localizations.startSmartFarmingJourney;
    }

    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: localizations.neural,
                style: const TextStyle(
                  fontSize: 32,
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
              const TextSpan(
                text: ' ',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: localizations.field,
                style: const TextStyle(
                  fontSize: 32,
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
          size: 40,
          color: Color(0xFF00A86B),
        ),
      ),
    );
  }

  Widget _buildVerifyExistingForm(AppLocalizations localizations) {
    return Column(
      children: [
        Text(
          localizations.verifyExistingDescription,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),

        // Email Field
        TextFormField(
          controller: _verifyEmailController,
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
        ),
        const SizedBox(height: 16),

        // OTP Field
        TextFormField(
          controller: _verifyOtpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            labelText: localizations.otpLabel,
            hintText: localizations.otpHint,
            prefixIcon: const Icon(Icons.pin),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            counterText: '',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Send OTP Button
        SizedBox(
          width: double.infinity,
          height: 45,
          child: OutlinedButton(
            onPressed: _isSendingOtp ? null : _sendVerificationOtp,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF00A86B),
              side: const BorderSide(color: Color(0xFF00A86B)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSendingOtp
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : Text(localizations.sendOtpButton),
          ),
        ),
        const SizedBox(height: 16),

        // Verify Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isVerifying ? null : _verifyExistingAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A86B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isVerifying
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              ),
            )
                : Text(
              localizations.verifyAccountButton,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Back to registration
        TextButton(
          onPressed: () {
            setState(() {
              _showVerifyExisting = false;
              _verifyEmailController.clear();
              _verifyOtpController.clear();
            });
          },
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF00A86B),
          ),
          child: Text(localizations.backToRegistration),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(AppLocalizations localizations) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name Field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: localizations.usernameLabel,
              hintText: localizations.usernameHint,
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.enterUsername;
              }
              if (value.length < 3) {
                return localizations.usernameMinLength;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email Field
          TextFormField(
            controller: _emailController,
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
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: localizations.passwordLabel,
              hintText: localizations.passwordHintRegister,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
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
          const SizedBox(height: 16),

          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: localizations.confirmPasswordLabel,
              hintText: localizations.confirmPasswordHint,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
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
              if (value != _passwordController.text) {
                return localizations.passwordsDoNotMatch;
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Register Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A86B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
                  : Text(
                localizations.registerButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Login Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(localizations.alreadyHaveAccount),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: Text(
                  localizations.loginButton,
                  style: const TextStyle(
                    color: Color(0xFF00A86B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Verify Existing Account Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showVerifyExisting = true;
                  });
                },
                child: Text(
                  localizations.verifyExistingAccountLink,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtpVerification(AppLocalizations localizations) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          localizations.enterOtpDescription,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          _registeredEmail ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00A86B),
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          onChanged: (value) {
            _otp = value;
          },
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            labelText: localizations.otpLabel,
            hintText: localizations.otpHint,
            prefixIcon: const Icon(Icons.pin),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            counterText: '',
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isVerifying ? null : _handleVerifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A86B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isVerifying
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              ),
            )
                : Text(
              localizations.verifyOtpButton,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Resend OTP Button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(localizations.didNotReceiveOtp),
            GestureDetector(
              onTap: (_isResending || _isLoading) ? null : _resendOtp,
              child: _isResending
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

        // Back to registration button
        GestureDetector(
          onTap: () {
            setState(() {
              _isOtpSent = false;
              _otp = '';
            });
          },
          child: Text(
            localizations.backToRegistration,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}