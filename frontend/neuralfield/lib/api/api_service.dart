import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';  // ← Add this import for File class
import 'api_url.dart';
import 'api_request.dart';
import 'api_response.dart';
import '../services/otp_models.dart';
import '../services/location_helper.dart';
import '../services/location_service.dart';  // Add this import for Position and LocationService
import 'package:geolocator/geolocator.dart';  // Add this import for Position class



//--------------------------------------Login---------------------------------
class LoginService {
  final http.Client _client;
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userEmailKey = 'user_email';

  LoginService({http.Client? client}) : _client = client ?? http.Client();

  // Login user
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final url = Uri.parse(Urls.getFullUrl(Urls.login));

      print('📡 Sending login request to: $url');
      print('📧 Email: $email');

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(jsonResponse);

        if (loginResponse.isSuccess) {
          await _saveTokens(loginResponse);
          await saveUserEmail(email);
        }

        return loginResponse;
      } else {
        try {
          final errorResponse = jsonDecode(response.body);
          return LoginResponse(
            status: false,
            message: errorResponse['message'] ?? 'Login failed',
          );
        } catch (e) {
          return LoginResponse(
            status: false,
            message: 'Server error: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('Error during login: $e');
      return LoginResponse(
        status: false,
        message: 'Network error: $e',
      );
    }
  }

  // Logout with token blacklist
  Future<bool> logout() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken != null) {
        final url = Uri.parse(Urls.getFullUrl(Urls.logout));
        final accessToken = await getAccessToken();

        final response = await _client.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({'refresh_token': refreshToken}),
        ).timeout(const Duration(seconds: 10));

        print('📡 Logout response: ${response.statusCode}');
      }

      // Clear local storage regardless of server response
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userEmailKey);

      print('✅ User logged out successfully');
      return true;
    } catch (e) {
      print('Error during logout: $e');
      // Still clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userEmailKey);
      return false;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final url = Uri.parse(Urls.getFullUrl(Urls.tokenRefresh));
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, newAccessToken);

        print('✅ Token refreshed successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  // Save tokens
  Future<void> _saveTokens(LoginResponse response) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (response.accessToken != null) {
        await prefs.setString(_accessTokenKey, response.accessToken!);
      }
      if (response.refreshToken != null) {
        await prefs.setString(_refreshTokenKey, response.refreshToken!);
      }
      print('✅ Tokens saved successfully');
    } catch (e) {
      print('Error saving tokens: $e');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(_accessTokenKey);
      return accessToken != null && accessToken.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get access token
  Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_accessTokenKey);
    } catch (e) {
      return null;
    }
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      return null;
    }
  }

  // Save user email
  Future<void> saveUserEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userEmailKey, email);
    } catch (e) {
      print('Error saving user email: $e');
    }
  }

  // Get user email
  Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userEmailKey);
    } catch (e) {
      return null;
    }
  }

  // Dispose method
  void dispose() {
    _client.close();
  }
}


//--------------------------Register--------------------------------------
class RegisterService {
  final http.Client _client;

  RegisterService({http.Client? client}) : _client = client ?? http.Client();

  Future<RegisterResponse> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final request = RegisterRequest(
        email: email,
        username: username,
        password: password,
      );

      final url = Uri.parse(Urls.getFullUrl(Urls.register));

      print('📡 Sending register request to: $url');
      print('📧 Email: $email');
      print('👤 Username: $username');

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return RegisterResponse.fromJson(jsonResponse);
      } else {
        try {
          final errorResponse = jsonDecode(response.body);
          return RegisterResponse(
            status: false,
            message: errorResponse['message'] ?? 'Registration failed',
          );
        } catch (e) {
          return RegisterResponse(
            status: false,
            message: 'Server error: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('Error during registration: $e');
      return RegisterResponse(
        status: false,
        message: 'Network error: $e',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

//--------------------------Profile------------------------------------
class ProfileService {
  final http.Client _client;
  static const String _profileDataKey = 'profile_data';
  static const String _userDataKey = 'user_wrapper_data';

  ProfileService({http.Client? client}) : _client = client ?? http.Client();

  // Get auth token
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  // Get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get profile detail (POST method as per your Django backend)
  Future<ProfileResponse> getProfileDetail() async {
    try {
      final url = Uri.parse(Urls.getFullUrl(Urls.profileDetail));
      final headers = await _getHeaders();
      final request = ProfileDetailRequest();

      print('📡 Fetching profile detail from: $url');
      print('📦 Request body: ${jsonEncode(request.toJson())}');

      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final profileResponse = ProfileResponse.fromJson(jsonResponse);

        if (profileResponse.isSuccess && profileResponse.data != null) {
          await _saveProfileData(profileResponse.data!);
        }

        return profileResponse;
      } else if (response.statusCode == 401) {
        return ProfileResponse(
          status: false,
          data: null,
        );
      } else {
        try {
          final errorResponse = jsonDecode(response.body);
          return ProfileResponse(
            status: false,
            data: null,
          );
        } catch (e) {
          return ProfileResponse(
            status: false,
            data: null,
          );
        }
      }
    } catch (e) {
      print('Error fetching profile: $e');
      return ProfileResponse(
        status: false,
        data: null,
      );
    }
  }

  // Update profile (POST method to update-profile endpoint)
  Future<ProfileResponse> updateProfile({
    String? fullName,
    String? mobileNumber,
    String? state,
    String? district,
    String? taluka,
    String? city,
    String? pincode,
    String? address,
  }) async {
    try {
      final request = ProfileUpdateRequest(
        fullName: fullName,
        mobileNumber: mobileNumber,
        state: state,
        district: district,
        taluka: taluka,
        city: city,
        pincode: pincode,
        address: address,
      );

      final url = Uri.parse(Urls.getFullUrl(Urls.updateProfile));
      final headers = await _getHeaders();

      print('📡 Updating profile at: $url');
      print('📦 Request body: ${jsonEncode(request.toJson())}');

      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // After update, refresh the full profile to get updated data
        final updatedProfile = await getProfileDetail();

        return ProfileResponse(
          status: true,
          data: updatedProfile.data,
        );
      } else if (response.statusCode == 401) {
        return ProfileResponse(
          status: false,
          data: null,
        );
      } else {
        return ProfileResponse(
          status: false,
          data: null,
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
      return ProfileResponse(
        status: false,
        data: null,
      );
    }
  }

  // Update profile picture
  Future<ProfileResponse> updateProfilePicture(File imageFile) async {
    try {
      final url = Uri.parse(Urls.getFullUrl(Urls.updateProfile));
      final token = await _getAuthToken();

      // Create multipart request
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath('profile_picture', imageFile.path),
      );

      print('📡 Uploading profile picture to: $url');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: $responseBody');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);

        // Check if the response has the expected structure
        if (jsonResponse['status'] == true) {
          // Refresh profile after update
          final updatedProfile = await getProfileDetail();
          return ProfileResponse(
            status: true,
            data: updatedProfile.data,
          );
        } else {
          return ProfileResponse(
            status: false,
            data: null,
          );
        }
      } else {
        print('Failed to upload profile picture: ${response.statusCode}');
        return ProfileResponse(
          status: false,
          data: null,
        );
      }
    } catch (e) {
      print('Error updating profile picture: $e');
      return ProfileResponse(
        status: false,
        data: null,
      );
    }
  }

  // Save profile data to shared preferences
  Future<void> _saveProfileData(ProfileDataWrapper data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = jsonEncode(data.toJson());
      await prefs.setString(_profileDataKey, profileJson);
      print('✅ Profile data saved locally');
    } catch (e) {
      print('Error saving profile data: $e');
    }
  }

  // Get stored profile data
  Future<ProfileDataWrapper?> getStoredProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileDataKey);

      if (profileJson != null && profileJson.isNotEmpty) {
        final Map<String, dynamic> profileMap = jsonDecode(profileJson);
        return ProfileDataWrapper.fromJson(profileMap);
      }
    } catch (e) {
      print('Error getting stored profile data: $e');
    }
    return null;
  }

  // Clear profile data
  Future<void> clearProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileDataKey);
      print('✅ Profile data cleared');
    } catch (e) {
      print('Error clearing profile data: $e');
    }
  }

  // Dispose method
  void dispose() {
    _client.close();
  }
}

//-------------------------OTP-Service--------------------------------------
class OtpService {
  final http.Client _client;

  OtpService({http.Client? client}) : _client = client ?? http.Client();

  // Send OTP (for resend or verify existing account)
  Future<SendOtpResponse> sendOtp({
    required String email,
  }) async {
    try {
      final request = SendOtpRequest(email: email);
      final url = Uri.parse(Urls.getFullUrl(Urls.sendOtp));

      print('📡 Sending OTP request to: $url');
      print('📧 Email: $email');

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return SendOtpResponse.fromJson(jsonResponse);
      } else {
        try {
          final errorResponse = jsonDecode(response.body);
          return SendOtpResponse(
            status: false,
            message: errorResponse['message'] ?? 'Failed to send OTP',
          );
        } catch (e) {
          return SendOtpResponse(
            status: false,
            message: 'Server error: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('Error sending OTP: $e');
      return SendOtpResponse(
        status: false,
        message: 'Network error: $e',
      );
    }
  }

  // Verify OTP
  Future<VerifyOtpResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final request = VerifyOtpRequest(email: email, otp: otp);
      final url = Uri.parse(Urls.getFullUrl(Urls.verifyOtp));

      print('📡 Sending OTP verification request to: $url');
      print('📧 Email: $email');

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return VerifyOtpResponse.fromJson(jsonResponse);
      } else {
        try {
          final errorResponse = jsonDecode(response.body);
          return VerifyOtpResponse(
            status: false,
            message: errorResponse['message'] ?? 'OTP verification failed',
          );
        } catch (e) {
          return VerifyOtpResponse(
            status: false,
            message: 'Server error: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('Error during OTP verification: $e');
      return VerifyOtpResponse(
        status: false,
        message: 'Network error: $e',
      );
    }
  }

  // Forgot Password - Send OTP
  Future<SendOtpResponse> forgotPassword({required String email}) async {
    try {
      final request = ForgotPasswordRequest(email: email);
      final url = Uri.parse(Urls.getFullUrl(Urls.forgotPassword));

      print('📡 Sending forgot password request to: $url');
      print('📧 Email: $email');

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return SendOtpResponse.fromJson(jsonResponse);
      } else {
        try {
          final errorResponse = jsonDecode(response.body);
          return SendOtpResponse(
            status: false,
            message: errorResponse['message'] ?? 'Failed to send OTP',
          );
        } catch (e) {
          return SendOtpResponse(
            status: false,
            message: 'Server error: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('Error during forgot password: $e');
      return SendOtpResponse(
        status: false,
        message: 'Network error: $e',
      );
    }
  }

  // Reset Password
  Future<VerifyOtpResponse> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final request = ResetPasswordRequest(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      final url = Uri.parse(Urls.getFullUrl(Urls.resetPassword));

      print('📡 Sending reset password request to: $url');

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return VerifyOtpResponse.fromJson(jsonResponse);
      } else {
        try {
          final errorResponse = jsonDecode(response.body);
          return VerifyOtpResponse(
            status: false,
            message: errorResponse['message'] ?? 'Password reset failed',
          );
        } catch (e) {
          return VerifyOtpResponse(
            status: false,
            message: 'Server error: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('Error during password reset: $e');
      return VerifyOtpResponse(
        status: false,
        message: 'Network error: $e',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

//------------------------Weather-Service--------------------------------------
class WeatherService {
  final http.Client _client;

  // You need to add this reference to your API service
  // Add this if you have an GeminiAiService class
  // final GeminiAiService _GeminiAiService;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  // Get weather by coordinates with geocoding
  Future<WeatherResponse> getWeatherByCoordinates({
    required double lat,
    required double lon,
  }) async {
    try {
      final request = WeatherRequest(lat: lat, lon: lon);
      final url = Uri.parse(Urls.getFullUrl(Urls.weather));

      print('Fetching weather for lat: $lat, lon: $lon');

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        WeatherResponse weatherResponse = WeatherResponse.fromJson(jsonResponse);

        // Enhance the response with better location name using geocoding
        final locationDetails = await LocationHelper.getFullLocationDetails(lat, lon);

        // Create updated weather response with better location name
        if (locationDetails['fullAddress'] != null &&
            locationDetails['fullAddress']!.isNotEmpty &&
            locationDetails['fullAddress'] != '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}') {

          // Override the location name with actual city/state
          final updatedData = WeatherData(
            location: Location(
              city: locationDetails['city'] ?? weatherResponse.data.location.city,
              country: locationDetails['country'] ?? weatherResponse.data.location.country,
            ),
            weather: weatherResponse.data.weather,
            wind: weatherResponse.data.wind,
          );

          return WeatherResponse(
            status: weatherResponse.status,
            data: updatedData,
          );
        }

        return weatherResponse;
      } else {
        throw Exception('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  // Get weather using device GPS with geocoding
  Future<WeatherResponse> getWeatherFromGPS() async {
    try {
      // Get actual GPS location
      final Position position = await LocationService.getCurrentLocationWithFallback();

      print('📍 Got GPS location: ${position.latitude}, ${position.longitude}');

      // Get weather for this location (geocoding happens inside)
      return await getWeatherByCoordinates(
        lat: position.latitude,
        lon: position.longitude,
      );
    } catch (e) {
      print('Error getting GPS weather: $e');
      // Don't use default coordinates - throw the error instead
      throw Exception('Location service unavailable. Please enable GPS.');
    }
  }

  // Dispose method
  void dispose() {
    _client.close();
  }
}



//-----------------------Crop-Service----------------------------
class CropRecommendationService {
  final http.Client _client;

  CropRecommendationService({http.Client? client}) : _client = client ?? http.Client();

  // Get crop recommendations
  Future<CropRecommendationResponse> getCropRecommendations({
    required String location,
    required String soilType,
    required String water,
    required String season,
    required String previousCrop,
    required String goal,
  }) async {
    try {
      final request = CropRecommendationRequest(
        location: location,
        soilType: soilType,
        water: water,
        season: season,
        previousCrop: previousCrop,
        goal: goal,
      );

      final url = Uri.parse(Urls.getFullUrl(Urls.cropRecommendation));

      print('📡 Sending crop recommendation request to: $url');
      print('📦 Request body: ${jsonEncode(request.toJson())}');

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return CropRecommendationResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to get crop recommendations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching crop recommendations: $e');
      throw Exception('Error fetching crop recommendations: $e');
    }
  }

  // Dispose method
  void dispose() {
    _client.close();
  }
}


//-----------------------------------News-Service----------------------------
class NewsService {
  final http.Client _client;

  NewsService({http.Client? client}) : _client = client ?? http.Client();

  Future<NewsResponse> fetchNews() async {
    try {
      final request = NewsRequest();
      final url = Uri.parse(Urls.getFullUrl(Urls.agricultureNews));

      print('📡 Fetching news from: $url');
      print('📦 Request body: ${jsonEncode(request.toJson())}');

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return NewsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching news: $e');
      throw Exception('Error fetching news: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}




// ============ FERTILIZER SERVICE ============
class FertilizerRecommendationService {
  final http.Client _client;

  FertilizerRecommendationService({http.Client? client})
      : _client = client ?? http.Client();

  // Get fertilizer recommendation
  Future<FertilizerRecommendationResponse> getFertilizerRecommendation({
    required String crop,
    required int cropAge,
    required String growthStage,
    required String soilType,
    required String plantCondition,
    required String irrigationType,
    required double temperature,
    required String soilMoisture,
  }) async {
    try {
      final request = FertilizerRecommendationRequest(
        crop: crop,
        cropAge: cropAge,
        growthStage: growthStage,
        soilType: soilType,
        plantCondition: plantCondition,
        irrigationType: irrigationType,
        temperature: temperature,
        soilMoisture: soilMoisture,
      );

      final url = Uri.parse(Urls.getFullUrl(Urls.fertilizerRecommendation));

      print('📡 Sending fertilizer recommendation request to: $url');
      print('📦 Request body: ${jsonEncode(request.toJson())}');

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return FertilizerRecommendationResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to get fertilizer recommendation: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching fertilizer recommendation: $e');
      throw Exception('Error fetching fertilizer recommendation: $e');
    }
  }

  // Get default recommendation for offline/fallback
  Future<FertilizerRecommendationResponse> getDefaultRecommendation(String crop) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return FertilizerRecommendationResponse(
      status: true,
      data: FertilizerData(
        fertilizer: 'NPK (19:19:19)',
        recommendation: 'Apply NPK 25kg per acre as basal dose',
      ),
    );
  }

  // Dispose method
  void dispose() {
    _client.close();
  }
}










//------------------------Gemini-Service-----------------------------
// In api_service.dart - Updated GeminiAiService class
class GeminiAiService {
  final http.Client _client;

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  GeminiAiService({http.Client? client}) : _client = client ?? http.Client();

  Future<ChatResponse> sendChatMessage(ChatRequest request) async {
    try {
      // CHANGE THIS LINE:
      // final url = Uri.parse(Urls.fullGeminiChat);
      final url = Uri.parse(Urls.getFullUrl(Urls.geminiChat));  // ✅ Updated

      final response = await _client
          .post(
        url,
        headers: _headers,
        body: jsonEncode(request.toJson()),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return ChatResponse.fromJson(responseData);
      } else {
        return ChatResponse.error('Server error: ${response.statusCode}');
      }
    } catch (e) {
      return ChatResponse.error(e.toString());
    }
  }

  Future<ChatResponse> sendMessage(String message) async {
    final request = ChatRequest(message: message);
    return await sendChatMessage(request);
  }

  Future<ChatResponse> sendMessageWithSession(String message, String sessionId) async {
    final request = ChatRequest(message: message, sessionId: sessionId);
    return await sendChatMessage(request);
  }

  Future<AgricultureAdviceResponse> getAgricultureAdvice(
      String cropType,
      String issue, {
        String? location,
      }) async {
    try {
      // CHANGE THIS LINE:
      // final url = Uri.parse(Urls.fullAgricultureAdvice);
      final url = Uri.parse(Urls.getFullUrl(Urls.cropRecommendation));  // ✅ Updated

      final requestBody = {
        'crop_type': cropType,
        'issue': issue,
        if (location != null) 'location': location,
      };

      final response = await _client
          .post(
        url,
        headers: _headers,
        body: jsonEncode(requestBody),
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return AgricultureAdviceResponse.fromJson(responseData);
      } else {
        return AgricultureAdviceResponse(
          status: false,
          advice: '',
          recommendations: [],
          details: {'error': 'Server error: ${response.statusCode}'},
        );
      }
    } catch (e) {
      return AgricultureAdviceResponse(
        status: false,
        advice: '',
        recommendations: [],
        details: {'error': e.toString()},
      );
    }
  }

  Future<CropPredictionResponse> predictCrop({
    required double nitrogen,
    required double phosphorus,
    required double potassium,
    required double ph,
    required double rainfall,
    required double temperature,
  }) async {
    try {
      // CHANGE THIS LINE:
      // final url = Uri.parse(Urls.fullCropPrediction);
      final url = Uri.parse(Urls.getFullUrl(Urls.cropRecommendation));  // ✅ Updated

      final requestBody = {
        'nitrogen': nitrogen,
        'phosphorus': phosphorus,
        'potassium': potassium,
        'ph': ph,
        'rainfall': rainfall,
        'temperature': temperature,
      };

      final response = await _client
          .post(
        url,
        headers: _headers,
        body: jsonEncode(requestBody),
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return CropPredictionResponse.fromJson(responseData);
      } else {
        return CropPredictionResponse(
          status: false,
          predictedCrop: '',
          confidence: 0.0,
          alternatives: [],
        );
      }
    } catch (e) {
      return CropPredictionResponse(
        status: false,
        predictedCrop: '',
        confidence: 0.0,
        alternatives: [],
      );
    }
  }

  // Future<bool> checkHealth() async {
  //   try {
  //     // CHANGE THIS LINE:
  //
  //     final url = Uri.parse(Urls.getFullUrl(Urls.healthCheck));  // ✅ Updated
  //     final response = await _client.get(url).timeout(const Duration(seconds: 5));
  //     return response.statusCode == 200;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  void dispose() {
    _client.close();
  }
}


// ========================= NPK CALCULATOR ===============================
class FertilizerApiService {
  Future<NPKCalculatorResponse> calculateNPK(NPKCalculatorRequest request) async {
    final url = Uri.parse(Urls.getFullUrl(Urls.npkCalculator));
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return NPKCalculatorResponse.fromJson(jsonDecode(response.body));
    } else {
      String errorMessage = 'API Error (${response.statusCode})';
      try {
        final errorBody = jsonDecode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}



// ============ PEST DETECTION SERVICE ============
class PestDetectionService {
  final http.Client _client;

  PestDetectionService({http.Client? client})
      : _client = client ?? http.Client();

  // Get auth token if needed
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  // Detect pest/disease from image
  Future<PestDetectionResponse> detectPest(File imageFile) async {
    try {
      final url = Uri.parse(Urls.getFullUrl(Urls.pestDetection));
      final token = await _getAuthToken();

      print('📡 Sending pest detection request to: $url');
      print('📷 Image size: ${await imageFile.length()} bytes');

      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
      });

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      print('📡 Sending request...');

      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout - Server took too long to respond');
        },
      );

      final responseBody = await response.stream.bytesToString();

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        return PestDetectionResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 400) {
        throw Exception('Invalid image format. Please try another image.');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in pest detection: $e');
      return PestDetectionResponse(
        status: false,
        message: 'Detection failed: $e',
        data: null,
      );
    }
  }

  // Detect with retry logic
  Future<PestDetectionResponse> detectPestWithRetry(
      File imageFile, {
        int maxRetries = 2,
      }) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final result = await detectPest(imageFile);
        if (result.isSuccess) {
          return result;
        }
        attempt++;
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt));
        }
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          return PestDetectionResponse(
            status: false,
            message: 'Failed after $maxRetries attempts: $e',
            data: null,
          );
        }
        await Future.delayed(Duration(seconds: attempt));
      }
    }

    return PestDetectionResponse(
      status: false,
      message: 'Detection failed',
      data: null,
    );
  }

  // Dispose method
  void dispose() {
    _client.close();
  }
}



//---------------------------My Crop Service-----------------------------
class CropService {
  final http.Client _client;

  CropService({http.Client? client}) : _client = client ?? http.Client();

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Create crop
  Future<CropResponse> createCrop(CropCreateRequest request) async {
    final url = Uri.parse(Urls.getFullUrl(Urls.cropCreate));
    final headers = await _getHeaders();

    final response = await _client.post(
      url,
      headers: headers,
      body: jsonEncode(request.toJson()),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CropResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create crop: ${response.statusCode}');
    }
  }

  // List crops
  Future<CropListResponse> listCrops() async {
    final url = Uri.parse(Urls.getFullUrl(Urls.cropList));
    final headers = await _getHeaders();

    final response = await _client.post(
      url,
      headers: headers,
      body: jsonEncode({}),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return CropListResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load crops: ${response.statusCode}');
    }
  }

  // Update crop
  Future<CropResponse> updateCrop(CropUpdateRequest request) async {
    final url = Uri.parse(Urls.getFullUrl(Urls.cropUpdate));
    final headers = await _getHeaders();

    final response = await _client.post(
      url,
      headers: headers,
      body: jsonEncode(request.toJson()),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return CropResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update crop: ${response.statusCode}');
    }
  }

  // Soft delete crop
  Future<bool> deleteCrop(int id) async {
    final url = Uri.parse(Urls.getFullUrl(Urls.cropSoftDelete));
    final headers = await _getHeaders();
    final request = CropDeleteRequest(id: id);

    final response = await _client.post(
      url,
      headers: headers,
      body: jsonEncode(request.toJson()),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final jsonRes = jsonDecode(response.body);
      return jsonRes['status'] == true;
    } else {
      throw Exception('Failed to delete crop: ${response.statusCode}');
    }
  }

  void dispose() => _client.close();
}



//----------------------------Crop Note Service----------------------------
class CropNoteService {
  final http.Client _client;

  CropNoteService({http.Client? client}) : _client = client ?? http.Client();

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ---------- CREATE NOTE ----------
  Future<CropNoteResponse> createNote(CropNoteCreateRequest request) async {
    final url = Uri.parse(Urls.getFullUrl(Urls.cropNoteCreate));
    final headers = await _getHeaders();

    final response = await _client.post(
      url,
      headers: headers,
      body: jsonEncode(request.toJson()),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonRes = jsonDecode(response.body);
      // Assuming response body: { "status": true, "message": "...", "data": { ... } }
      if (jsonRes['status'] == true && jsonRes['data'] != null) {
        return CropNoteResponse.fromJson(jsonRes['data']);
      } else {
        throw Exception(jsonRes['message'] ?? 'Failed to create note');
      }
    } else {
      throw Exception('Failed to create note: ${response.statusCode}');
    }
  }

// ---------- LIST NOTES ----------
  Future<CropNoteListResponse> listNotes(int cropId) async {
    final url = Uri.parse(Urls.getFullUrl(Urls.cropNoteList));
    final headers = await _getHeaders();
    final requestBody = CropNoteListRequest(crop: cropId);

    final response = await _client.post(
      url,
      headers: headers,
      body: jsonEncode(requestBody.toJson()),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final jsonRes = jsonDecode(response.body);
      if (jsonRes['status'] == true) {
        return CropNoteListResponse.fromJson(jsonRes);
      } else {
        throw Exception(jsonRes['message'] ?? 'Failed to load notes');
      }
    } else {
      throw Exception('Failed to load notes: ${response.statusCode}');
    }
  }

  // -------------------- UPDATE NOTE --------------------
  Future<CropNoteResponse> updateNote(CropNoteUpdateRequest request) async {
    final url = Uri.parse(Urls.getFullUrl(Urls.cropNoteUpdate));
    final headers = await _getHeaders();

    final response = await _client.post(
      url,
      headers: headers,
      body: jsonEncode(request.toJson()),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final jsonRes = jsonDecode(response.body);
      if (jsonRes['status'] == true && jsonRes['data'] != null) {
        return CropNoteResponse.fromJson(jsonRes['data']);
      } else {
        throw Exception(jsonRes['message'] ?? 'Failed to update note');
      }
    } else {
      throw Exception('Failed to update note: ${response.statusCode}');
    }
  }

  // -------------------- SOFT DELETE NOTE --------------------
  Future<CropNoteDeleteResponse> deleteNote(int noteId) async {
    final url = Uri.parse(Urls.getFullUrl(Urls.cropNoteSoftDelete));
    final headers = await _getHeaders();
    final request = CropNoteDeleteRequest(id: noteId);

    final response = await _client.post(
      url,
      headers: headers,
      body: jsonEncode(request.toJson()),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final jsonRes = jsonDecode(response.body);
      return CropNoteDeleteResponse.fromJson(jsonRes);
    } else {
      throw Exception('Failed to delete note: ${response.statusCode}');
    }
  }

  void dispose() => _client.close();
}



// -------------------------- Crop Encyclopedia Service -----------------------------
class CropEncyclopediaService {
  final http.Client _client;

  CropEncyclopediaService({http.Client? client})
      : _client = client ?? http.Client();

  /// Fetch all crops with optional language override.
  Future<CropEncyclopediaResponse> getAllCrops({String? language}) async {
    try {
      final request = CropEncyclopediaRequest(lang: language ?? 'en');
      final url = Uri.parse(Urls.getFullUrl(Urls.cropEncyclopedia));

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return CropEncyclopediaResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load crops: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching crops: $e');
    }
  }

  List<CropInfo> searchCrops(List<CropInfo> crops, String query) {
    if (query.isEmpty) return crops;
    final lowerQuery = query.toLowerCase();
    return crops.where((crop) =>
    crop.name.toLowerCase().contains(lowerQuery) ||
        crop.scientificName.toLowerCase().contains(lowerQuery) ||
        crop.family.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  List<CropInfo> getCropsBySeason(List<CropInfo> crops, String season) {
    if (season == 'All') return crops;
    return crops.where((crop) =>
        crop.growingSeason.toLowerCase().contains(season.toLowerCase())
    ).toList();
  }

  void dispose() {
    _client.close();
  }
}

// -------------------------- Cultivation Tips Service -----------------------------
class CultivationTipsService {
  final http.Client _client;

  CultivationTipsService({http.Client? client})
      : _client = client ?? http.Client();

  /// Fetch all cultivation tips with optional language.
  Future<CultivationTipsResponse> getAllTips({String? language}) async {
    try {
      final request = CultivationTipsRequest(lang: language ?? 'en');
      final url = Uri.parse(Urls.getFullUrl(Urls.cultivationTips));

      print('📡 Fetching cultivation tips from: $url');

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return CultivationTipsResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load cultivation tips: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cultivation tips: $e');
      throw Exception('Error fetching cultivation tips: $e');
    }
  }

  List<CultivationTip> getTipsByCategory(
      List<CultivationTip> tips,
      TipCategory? category
      ) {
    if (category == null) return tips;
    return tips.where((tip) => tip.tipCategory == category).toList();
  }

  List<CultivationTip> searchTips(
      List<CultivationTip> tips,
      String query
      ) {
    if (query.isEmpty) return tips;
    final lowerQuery = query.toLowerCase();
    return tips.where((tip) =>
    tip.title.toLowerCase().contains(lowerQuery) ||
        tip.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  void dispose() {
    _client.close();
  }
}

// -------------------------- Pest Encyclopedia Service -----------------------------
class PestEncyclopediaService {
  final http.Client _client;

  PestEncyclopediaService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch all pests with optional language.
  Future<PestEncyclopediaResponse> getAllPests({String? language}) async {
    try {
      final request = PestEncyclopediaRequest(lang: language ?? 'en');
      final url = Uri.parse(Urls.getFullUrl(Urls.pests));

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return PestEncyclopediaResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load pests: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching pests: $e');
    }
  }

  List<Pest> searchPests(List<Pest> pests, String query) {
    if (query.isEmpty) return pests;
    final lowerQuery = query.toLowerCase();
    return pests.where((pest) =>
    pest.name.toLowerCase().contains(lowerQuery) ||
        pest.scientificName.toLowerCase().contains(lowerQuery)).toList();
  }

  void dispose() {
    _client.close();
  }
}

// -------------------------- Disease Encyclopedia Service -----------------------------
class DiseaseEncyclopediaService {
  final http.Client _client;

  DiseaseEncyclopediaService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch all diseases with optional language.
  Future<DiseaseEncyclopediaResponse> getAllDiseases({String? language}) async {
    try {
      final request = DiseaseEncyclopediaRequest(lang: language ?? 'en');
      final url = Uri.parse(Urls.getFullUrl(Urls.diseases));

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return DiseaseEncyclopediaResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load diseases: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching diseases: $e');
    }
  }

  List<Disease> searchDiseases(List<Disease> diseases, String query) {
    if (query.isEmpty) return diseases;
    final lowerQuery = query.toLowerCase();
    return diseases.where((disease) =>
    disease.name.toLowerCase().contains(lowerQuery) ||
        disease.scientificName.toLowerCase().contains(lowerQuery)).toList();
  }

  void dispose() {
    _client.close();
  }
}



// ----------------------------Market Service---------------------------

// ====================== Market Meta Service ======================
class MarketMetaService {
  final http.Client _client = http.Client();
  CancellationToken? _currentToken;

  Future<MarketMetaResponse> fetchMarketMeta(MarketMetaRequest request) async {
    _currentToken?.cancel();
    _currentToken = CancellationToken();
    final url = Uri.parse('${Urls.baseUrl}${Urls.marketMeta}');
    final response = await _client
        .post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    )
        .timeout(const Duration(seconds: 30))
        .cancelBy(_currentToken!);

    if (response.statusCode == 200) {
      return MarketMetaResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load market meta: ${response.statusCode}');
    }
  }

  void dispose() {
    _currentToken?.cancel();
    _client.close();
  }
}

// ====================== Market Dashboard Service ======================
class MarketDashboardService {
  final http.Client _client = http.Client();
  CancellationToken? _currentToken;

  Future<MarketDashboardResponse> fetchMarketDashboard(MarketDashboardRequest request) async {
    _currentToken?.cancel();
    _currentToken = CancellationToken();
    final url = Uri.parse('${Urls.baseUrl}${Urls.marketDashboard}');
    final response = await _client
        .post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    )
        .timeout(const Duration(seconds: 30))
        .cancelBy(_currentToken!);

    if (response.statusCode == 200) {
      return MarketDashboardResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load market dashboard: ${response.statusCode}');
    }
  }

  void dispose() {
    _currentToken?.cancel();
    _client.close();
  }
}

// Helper for cancellation (same as before, add to top of file if missing)
class CancellationToken {
  bool _isCancelled = false;
  void cancel() => _isCancelled = true;
  bool get isCancelled => _isCancelled;
}

extension CancelBy on Future<http.Response> {
  Future<http.Response> cancelBy(CancellationToken token) async {
    return timeout(const Duration(seconds: 30)).then((value) {
      if (token.isCancelled) throw Exception('Request cancelled');
      return value;
    });
  }
}



// ====================== Market Price Service ======================

class MarketPricesService {
  final http.Client _client = http.Client();
  CancellationToken? _currentToken;

  Future<MarketPricesResponse> fetchMarketPrices(MarketPricesRequest request) async {
    _currentToken?.cancel();
    _currentToken = CancellationToken();
    final url = Uri.parse('${Urls.baseUrl}${Urls.marketPrices}');
    final response = await _client
        .post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    )
        .timeout(const Duration(seconds: 30))
        .cancelBy(_currentToken!);

    if (response.statusCode == 200) {
      return MarketPricesResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load market prices: ${response.statusCode}');
    }
  }

  void dispose() {
    _currentToken?.cancel();
    _client.close();
  }
}


// ====================== Market Comparison Service ======================

class MarketComparisonService {
  final http.Client _client = http.Client();
  CancellationToken? _currentToken;

  Future<MarketComparisonResponse> fetchMarketComparison(MarketComparisonRequest request) async {
    _currentToken?.cancel();
    _currentToken = CancellationToken();
    final url = Uri.parse('${Urls.baseUrl}${Urls.marketComparison}');
    final response = await _client
        .post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    )
        .timeout(const Duration(seconds: 30))
        .cancelBy(_currentToken!);

    if (response.statusCode == 200) {
      return MarketComparisonResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load market comparison: ${response.statusCode}');
    }
  }

  void dispose() {
    _currentToken?.cancel();
    _client.close();
  }
}



// ====================== Market History ======================
// class MarketHistoryService {
//   final http.Client _client = http.Client();
//   CancellationToken? _currentToken;
//   Future<MarketHistoryResponse> fetchMarketHistory(MarketHistoryRequest request) async {
//     _currentToken?.cancel();
//     _currentToken = CancellationToken();
//     final url = Uri.parse('${Urls.baseUrl}${Urls.marketHistory}');
//     final response = await _client.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(request.toJson()),
//     ).timeout(const Duration(seconds: 30)).cancelBy(_currentToken!);
//     if (response.statusCode == 200) {
//       return MarketHistoryResponse.fromJson(jsonDecode(response.body));
//     } else {
//       throw Exception('Failed to load market history: ${response.statusCode}');
//     }
//   }
//   void dispose() { _currentToken?.cancel(); _client.close(); }
// }