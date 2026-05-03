// Send OTP Request (for resend and verify existing)
class SendOtpRequest {
  final String email;

  SendOtpRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

// Send OTP Response
class SendOtpResponse {
  final bool status;
  final String message;

  SendOtpResponse({
    required this.status,
    required this.message,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }

  bool get isSuccess => status == true;
}

// OTP Verification Request
class VerifyOtpRequest {
  final String email;
  final String otp;

  VerifyOtpRequest({
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}

// OTP Verification Response
class VerifyOtpResponse {
  final bool status;
  final String message;

  VerifyOtpResponse({
    required this.status,
    required this.message,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }

  bool get isSuccess => status == true;
}

// Forgot Password Request
class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

// Reset Password Request
class ResetPasswordRequest {
  final String email;
  final String otp;
  final String newPassword;

  ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'new_password': newPassword,
    };
  }
}