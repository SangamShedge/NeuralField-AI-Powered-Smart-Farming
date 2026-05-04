import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_url.dart';

//------------------------------Login---------------------------------
class LoginResponse {
  final bool status;
  final String message;
  final String? accessToken;
  final String? refreshToken;

  LoginResponse({
    required this.status,
    required this.message,
    this.accessToken,
    this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  bool get isSuccess => status == true;
}

//------------------------------Register-----------------------------
class RegisterResponse {
  final bool status;
  final String message;

  RegisterResponse({
    required this.status,
    required this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }

  bool get isSuccess => status == true;
}

//------------------------------Profile-------------------------------
// Profile Response (wraps the API response)
class ProfileResponse {
  final bool status;
  final ProfileDataWrapper? data;

  ProfileResponse({
    required this.status,
    this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      status: json['status'] ?? false,
      data: json['data'] != null ? ProfileDataWrapper.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.toJson(),
    };
  }

  bool get isSuccess => status == true;
}

// Profile Data Wrapper (contains user and profile)
class ProfileDataWrapper {
  final String username;
  final String email;
  final String role;
  final ProfileData profile;

  ProfileDataWrapper({
    required this.username,
    required this.email,
    required this.role,
    required this.profile,
  });

  factory ProfileDataWrapper.fromJson(Map<String, dynamic> json) {
    return ProfileDataWrapper(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'farmer',
      profile: ProfileData.fromJson(json['profile'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'role': role,
      'profile': profile.toJson(),
    };
  }

  String getRoleIcon() {
    switch (role.toLowerCase()) {
      case 'admin':
        return '⚙️';
      case 'farmer':
        return '🌾';
      case 'trader':
        return '📊';
      default:
        return '🌾';
    }
  }

  String getRoleDisplayName() {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'farmer':
        return 'Farmer';
      case 'trader':
        return 'Trader';
      default:
        return 'Farmer';
    }
  }

  Color getRoleColor() {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.orange;
      case 'farmer':
        return const Color(0xFF4CAF50);
      case 'trader':
        return Colors.blue;
      default:
        return const Color(0xFF4CAF50);
    }
  }
}

// Profile Data Model
class ProfileData {
  final int id;
  final String fullName;
  final String mobileNumber;
  final String state;
  final String district;
  final String taluka;
  final String city;
  final String pincode;
  final String address;
  final String? profilePicture;
  final DateTime createdAt;
  final int user;

  ProfileData({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.state,
    required this.district,
    required this.taluka,
    required this.city,
    required this.pincode,
    required this.address,
    this.profilePicture,
    required this.createdAt,
    required this.user,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      taluka: json['taluka'] ?? '',
      city: json['city'] ?? '',
      pincode: json['pincode'] ?? '',
      address: json['address'] ?? '',
      profilePicture: json['profile_picture'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      user: json['user'] ?? 0,
    );
  }

  // Helper method to get full image URL
  String? getFullImageUrl() {
    if (profilePicture == null || profilePicture!.isEmpty) {
      return null;
    }
    // Remove leading slash if present and construct full URL
    String cleanPath = profilePicture!.startsWith('/')
        ? profilePicture!.substring(1)
        : profilePicture!;
    return '${Urls.baseUrl}/$cleanPath';
  }

  // Helper method to check if profile picture exists
  bool get hasProfilePicture => profilePicture != null && profilePicture!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'mobile_number': mobileNumber,
      'state': state,
      'district': district,
      'taluka': taluka,
      'city': city,
      'pincode': pincode,
      'address': address,
      'profile_picture': profilePicture,
      'created_at': createdAt.toIso8601String(),
      'user': user,
    };
  }

  String get displayName => fullName.isNotEmpty ? fullName : 'Farmer';

  String get displayLocation {
    if (city.isNotEmpty && state.isNotEmpty) {
      return '$city, $state';
    } else if (city.isNotEmpty) {
      return city;
    } else if (state.isNotEmpty) {
      return state;
    }
    return 'Location not set';
  }

  String get fullAddress {
    List<String> parts = [];
    if (address.isNotEmpty) parts.add(address);
    if (city.isNotEmpty) parts.add(city);
    if (taluka.isNotEmpty) parts.add(taluka);
    if (district.isNotEmpty) parts.add(district);
    if (state.isNotEmpty) parts.add(state);
    if (pincode.isNotEmpty) parts.add(pincode);
    return parts.join(', ');
  }

  String getInitials() {
    if (fullName.isNotEmpty) {
      final parts = fullName.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return fullName[0].toUpperCase();
    }
    return 'F';
  }
}
//------------------------------WeatherResponse-----------------------
class WeatherResponse {
  final bool status;
  final WeatherData data;

  WeatherResponse({
    required this.status,
    required this.data,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      status: json['status'] ?? false,
      data: WeatherData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
  }
}

class WeatherData {
  final Location location;
  final Weather weather;
  final Wind wind;

  WeatherData({
    required this.location,
    required this.weather,
    required this.wind,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: Location.fromJson(json['location'] ?? {}),
      weather: Weather.fromJson(json['weather'] ?? {}),
      wind: Wind.fromJson(json['wind'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'weather': weather.toJson(),
      'wind': wind.toJson(),
    };
  }
}

class Location {
  final String city;
  final String country;

  Location({
    required this.city,
    required this.country,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: json['city'] ?? 'Unknown',
      country: json['country'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'country': country,
    };
  }

  String get fullLocation => '$city, $country';
}

class Weather {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final String condition;

  Weather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.condition,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      feelsLike: (json['feels_like'] ?? 0.0).toDouble(),
      humidity: json['humidity'] ?? 0,
      condition: json['condition'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'feels_like': feelsLike,
      'humidity': humidity,
      'condition': condition,
    };
  }

  String get temperatureString => '${temperature.toInt()}°C';
  String get feelsLikeString => '${feelsLike.toInt()}°C';

  // Remove Color and IconData from model - these belong in UI
  String getWeatherIconName() {
    final conditionLower = condition.toLowerCase();
    if (conditionLower.contains('clear') || conditionLower.contains('sun')) {
      return 'wb_sunny';
    } else if (conditionLower.contains('cloud')) {
      return 'cloud';
    } else if (conditionLower.contains('rain')) {
      return 'umbrella';
    } else if (conditionLower.contains('thunder')) {
      return 'flash_on';
    } else {
      return 'wb_cloudy';
    }
  }

  String getWeatherColorHex() {
    final conditionLower = condition.toLowerCase();
    if (conditionLower.contains('clear') || conditionLower.contains('sun')) {
      return '#FFB74D';
    } else if (conditionLower.contains('cloud')) {
      return '#9E9E9E';
    } else if (conditionLower.contains('rain')) {
      return '#64B5F6';
    } else {
      return '#81C784';
    }
  }
}

class Wind {
  final double speed;

  Wind({
    required this.speed,
  });

  factory Wind.fromJson(Map<String, dynamic> json) {
    return Wind(
      speed: (json['speed'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speed': speed,
    };
  }

  String get speedString => '${speed.toStringAsFixed(1)} km/h';
}



//--------------------------CropRecommendationResponse-------------
class CropRecommendationResponse {
  final bool status;
  final List<String> recommendedCrops;

  CropRecommendationResponse({
    required this.status,
    required this.recommendedCrops,
  });

  factory CropRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return CropRecommendationResponse(
      status: json['status'] ?? false,
      recommendedCrops: List<String>.from(json['recommended_crops'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'recommended_crops': recommendedCrops,
    };
  }

  String get primaryCrop => recommendedCrops.isNotEmpty ? recommendedCrops[0] : 'No crop';
  List<String> get otherCrops => recommendedCrops.length > 1 ? recommendedCrops.sublist(1) : [];
}

//---------------------------------News-Response---------------------------
class NewsResponse {
  final bool status;
  final String type;
  final int total;
  final List<NewsItem> data;

  NewsResponse({
    required this.status,
    required this.type,
    required this.total,
    required this.data,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      status: json['status'] ?? false,
      type: json['type'] ?? '',
      total: json['total'] ?? 0,
      data: (json['data'] as List)
          .map((item) => NewsItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'type': type,
      'total': total,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class NewsItem {
  final String title;
  final String description;
  final String? image;
  final String link;
  final String source;
  final String date;

  NewsItem({
    required this.title,
    required this.description,
    this.image,
    required this.link,
    required this.source,
    required this.date,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      link: json['link'] ?? '',
      source: json['source'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'link': link,
      'source': source,
      'date': date,
    };
  }

  String getFormattedDate() {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      final difference = DateTime.now().difference(parsedDate);

      if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${(difference.inDays / 7).floor()} weeks ago';
      }
    } catch (e) {
      return date;
    }
  }

  String getSourceIcon() {
    switch (source.toLowerCase()) {
      case 'toi':
        return '📰';
      case 'google':
        return '🔍';
      case 'deccanchronicle':
        return '📱';
      case 'freepressjournal':
        return '📰';
      case 'yespunjab':
        return '📰';
      default:
        return '📰';
    }
  }

  String getSourceDisplayName() {
    switch (source.toLowerCase()) {
      case 'toi':
        return 'Times of India';
      case 'google':
        return 'Google News';
      case 'deccanchronicle':
        return 'Deccan Chronicle';
      case 'freepressjournal':
        return 'Free Press Journal';
      case 'yespunjab':
        return 'Yes Punjab';
      default:
        return source.toUpperCase();
    }
  }
}







// ============ FERTILIZER RESPONSE MODEL ============
class FertilizerRecommendationResponse {
  final bool status;
  final FertilizerData data;
  FertilizerRecommendationResponse({
    required this.status,
    required this.data,
  });
  factory FertilizerRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return FertilizerRecommendationResponse(
      status: json['status'] ?? false,
      data: FertilizerData.fromJson(json['data'] ?? {}),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.toJson(),
    };
  }
}
class FertilizerData {
  final String fertilizer;
  final String recommendation;
  FertilizerData({
    required this.fertilizer,
    required this.recommendation,
  });
  factory FertilizerData.fromJson(Map<String, dynamic> json) {
    return FertilizerData(
      fertilizer: json['fertilizer'] ?? '',
      recommendation: json['recommendation'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'fertilizer': fertilizer,
      'recommendation': recommendation,
    };
  }
  // Helper method to extract quantity from recommendation
  String get quantity {
    final regex = RegExp(r'(\d+(?:\.\d+)?)\s*(kg|g|ton|lb)');
    final match = regex.firstMatch(recommendation);
    if (match != null) {
      return '${match.group(1)} ${match.group(2)}';
    }
    return 'As recommended';
  }
  // Helper method to get fertilizer type category
  String get fertilizerCategory {
    final fertilizerLower = fertilizer.toLowerCase();
    if (fertilizerLower.contains('urea') || fertilizerLower.contains('nitrogen')) {
      return 'Nitrogen Fertilizer';
    } else if (fertilizerLower.contains('dap') || fertilizerLower.contains('phosphate')) {
      return 'Phosphate Fertilizer';
    } else if (fertilizerLower.contains('potash') || fertilizerLower.contains('mop')) {
      return 'Potash Fertilizer';
    } else if (fertilizerLower.contains('npk')) {
      return 'Complex Fertilizer';
    } else if (fertilizerLower.contains('compost') || fertilizerLower.contains('organic')) {
      return 'Organic Fertilizer';
    }
    return 'Chemical Fertilizer';
  }
  // Helper method to get icon name for UI
  String getFertilizerIcon() {
    final fertilizerLower = fertilizer.toLowerCase();
    if (fertilizerLower.contains('urea')) {
      return '💎';
    } else if (fertilizerLower.contains('dap')) {
      return '🔷';
    } else if (fertilizerLower.contains('potash') || fertilizerLower.contains('mop')) {
      return '💜';
    } else if (fertilizerLower.contains('npk')) {
      return '🧪';
    } else if (fertilizerLower.contains('compost')) {
      return '🌿';
    }
    return '🧴';
  }
  // Helper method to get color hex for UI
  String getFertilizerColorHex() {
    final fertilizerLower = fertilizer.toLowerCase();
    if (fertilizerLower.contains('urea')) {
      return '#4A90D9';
    } else if (fertilizerLower.contains('dap')) {
      return '#2E7D32';
    } else if (fertilizerLower.contains('potash') || fertilizerLower.contains('mop')) {
      return '#7B1FA2';
    } else if (fertilizerLower.contains('npk')) {
      return '#FF6F00';
    } else if (fertilizerLower.contains('compost')) {
      return '#8D6E63';
    }
    return '#1565C0';
  }
}





//--------------------------Gemini Chat Response------------------------
class ChatResponse {
  final bool status;
  final String userMessage;
  final String aiResponse;
  final String? sessionId;
  final Map<String, dynamic>? metadata;
  final String? errorMessage;

  ChatResponse({
    required this.status,
    required this.userMessage,
    required this.aiResponse,
    this.sessionId,
    this.metadata,
    this.errorMessage,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      status: json['status'] as bool? ?? false,
      userMessage: json['user_message'] as String? ?? '',
      aiResponse: json['ai_response'] as String? ?? '',
      sessionId: json['session_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      errorMessage: json['error_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'user_message': userMessage,
      'ai_response': aiResponse,
      if (sessionId != null) 'session_id': sessionId,
      if (metadata != null) 'metadata': metadata,
      if (errorMessage != null) 'error_message': errorMessage,
    };
  }

  bool get isSuccess => status && errorMessage == null;

  factory ChatResponse.error(String error) {
    return ChatResponse(
      status: false,
      userMessage: '',
      aiResponse: '',
      errorMessage: error,
    );
  }
}

class AgricultureAdviceResponse {
  final bool status;
  final String advice;
  final List<String> recommendations;
  final Map<String, dynamic>? details;

  AgricultureAdviceResponse({
    required this.status,
    required this.advice,
    required this.recommendations,
    this.details,
  });

  factory AgricultureAdviceResponse.fromJson(Map<String, dynamic> json) {
    return AgricultureAdviceResponse(
      status: json['status'] as bool? ?? false,
      advice: json['advice'] as String? ?? '',
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      details: json['details'] as Map<String, dynamic>?,
    );
  }
}

class CropPredictionResponse {
  final bool status;
  final String predictedCrop;
  final double confidence;
  final List<Map<String, dynamic>> alternatives;

  CropPredictionResponse({
    required this.status,
    required this.predictedCrop,
    required this.confidence,
    required this.alternatives,
  });

  factory CropPredictionResponse.fromJson(Map<String, dynamic> json) {
    return CropPredictionResponse(
      status: json['status'] as bool? ?? false,
      predictedCrop: json['predicted_crop'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      alternatives: (json['alternatives'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList() ?? [],
    );
  }
}



//-----------------------------NPK-Calculator---------------------------
class NPKCalculatorResponse {
  final bool status;
  final String message;
  final NPKData data;

  NPKCalculatorResponse.fromJson(Map<String, dynamic> json)
      : status = json['status'],
        message = json['message'],
        data = NPKData.fromJson(json['data']);
}

class NPKData {
  final InputSummary inputSummary;
  final Map<String, double> required;
  final Map<String, double> available;
  final Map<String, double> toApply;
  final Map<String, FertilizerInfo> fertilizers;
  final Map<String, double> efficiencyPercent;

  NPKData.fromJson(Map<String, dynamic> json)
      : inputSummary = InputSummary.fromJson(json['input_summary']),
        required = _toDoubleMap(json['required']),
        available = _toDoubleMap(json['available']),
        toApply = _toDoubleMap(json['to_apply']),
        fertilizers = (json['fertilizers'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, FertilizerInfo.fromJson(value)),
        ),
        efficiencyPercent = _toDoubleMap(json['efficiency_percent']);
}

class InputSummary {
  final double areaAcres;
  final double targetYieldTonPerAcre;
  final String crop;

  InputSummary.fromJson(Map<String, dynamic> json)
      : areaAcres = (json['area_acres'] as num).toDouble(),
        targetYieldTonPerAcre = (json['target_yield_ton_per_acre'] as num).toDouble(),
        crop = json['crop'];
}

class FertilizerInfo {
  final String name;
  final double quantityKg;

  FertilizerInfo.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        quantityKg = (json['quantity_kg'] as num).toDouble();
}

// Helper to convert dynamic values (int/double) to double safely
Map<String, double> _toDoubleMap(Map<String, dynamic> map) {
  return Map<String, double>.fromEntries(
    map.entries.map((entry) =>
        MapEntry(entry.key, (entry.value as num).toDouble())),
  );
}



//------------------------------Pest-Detection---------------------------
// Add this to api_response.dart after other response models

// Pest Detection Response
class PestDetectionResponse {
  final bool status;
  final String message;
  final PestDetectionData? data;

  PestDetectionResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory PestDetectionResponse.fromJson(Map<String, dynamic> json) {
    return PestDetectionResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? PestDetectionData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }

  bool get isSuccess => status == true;
}

class PestDetectionData {
  final String disease;
  final double confidence;

  PestDetectionData({
    required this.disease,
    required this.confidence,
  });

  factory PestDetectionData.fromJson(Map<String, dynamic> json) {
    return PestDetectionData(
      disease: json['disease'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disease': disease,
      'confidence': confidence,
    };
  }

  String get confidencePercentage => '${(confidence * 100).toInt()}%';

  bool get isDisease => true; // API returns disease names

  String get displayName {
    // Format the disease name for display
    return disease.replaceAll('_', ' ');
  }

  String getSolution() {
    final diseaseLower = disease.toLowerCase();
    if (diseaseLower.contains('late_blight')) {
      return 'Apply copper-based fungicides immediately. Remove and destroy infected plant parts. Avoid overhead irrigation.';
    } else if (diseaseLower.contains('early_blight')) {
      return 'Apply chlorothalonil or copper fungicides. Practice crop rotation. Remove infected leaves.';
    } else if (diseaseLower.contains('powdery_mildew')) {
      return 'Apply sulfur or potassium bicarbonate sprays. Improve air circulation. Water at base of plants.';
    } else if (diseaseLower.contains('leaf_curl')) {
      return 'Remove infected plants. Control whitefly population. Use insecticidal soap or neem oil.';
    } else if (diseaseLower.contains('mosaic')) {
      return 'Remove infected plants immediately. Control aphid vectors. Use virus-resistant varieties.';
    } else if (diseaseLower.contains('wilt')) {
      return 'Improve soil drainage. Apply fungicides. Remove infected plants. Practice crop rotation.';
    } else {
      return 'Consult local agricultural extension office for specific treatment recommendations.';
    }
  }

  List<String> getPreventionTips() {
    final diseaseLower = disease.toLowerCase();
    if (diseaseLower.contains('blight')) {
      return [
        'Use disease-resistant varieties',
        'Practice crop rotation (3-4 year cycle)',
        'Avoid overhead irrigation',
        'Ensure proper plant spacing for air circulation',
        'Remove crop debris after harvest',
      ];
    } else if (diseaseLower.contains('powdery_mildew')) {
      return [
        'Water plants at base, not on leaves',
        'Ensure good air circulation',
        'Apply preventive neem oil sprays',
        'Remove severely infected leaves',
        'Avoid overcrowding of plants',
      ];
    } else {
      return [
        'Maintain field hygiene',
        'Use certified disease-free seeds',
        'Regular field monitoring',
        'Apply preventive sprays as recommended',
        'Remove weed hosts around fields',
      ];
    }
  }

  String getSeverity() {
    if (confidence > 0.95) return 'Severe';
    if (confidence > 0.85) return 'High';
    if (confidence > 0.70) return 'Moderate';
    return 'Low';
  }

  Color getSeverityColor() {
    if (confidence > 0.95) return Colors.red;
    if (confidence > 0.85) return Colors.orange;
    if (confidence > 0.70) return Colors.yellow.shade700;
    return Colors.green;
  }
}



//-------------------------My Crops Response------------------------------------

class CropData {
  final int id;
  final String name;
  final String? variety;
  final String sowingDate;
  final double area;
  final String soilType;
  final String irrigationType;
  final String? location;
  final String growthStage;
  final String healthStatus;
  final String? lastFertilizer;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int user;

  CropData({
    required this.id,
    required this.name,
    this.variety,
    required this.sowingDate,
    required this.area,
    required this.soilType,
    required this.irrigationType,
    this.location,
    required this.growthStage,
    required this.healthStatus,
    this.lastFertilizer,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory CropData.fromJson(Map<String, dynamic> json) => CropData(
    id: json['id'],
    name: json['name'],
    variety: json['variety'],
    sowingDate: json['sowing_date'],
    area: (json['area'] as num).toDouble(),
    soilType: json['soil_type'],
    irrigationType: json['irrigation_type'],
    location: json['location'],
    growthStage: json['growth_stage'],
    healthStatus: json['health_status'],
    lastFertilizer: json['last_fertilizer'],
    isActive: json['is_active'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
    user: json['user'],
  );
}

class CropResponse {
  final bool status;
  final String message;
  final CropData? data;

  CropResponse({required this.status, required this.message, this.data});

  factory CropResponse.fromJson(Map<String, dynamic> json) => CropResponse(
    status: json['status'],
    message: json['message'] ?? '',
    data: json['data'] != null ? CropData.fromJson(json['data']) : null,
  );
}

class CropListResponse {
  final bool status;
  final int count;
  final List<CropData> data;

  CropListResponse({required this.status, required this.count, required this.data});

  factory CropListResponse.fromJson(Map<String, dynamic> json) => CropListResponse(
    status: json['status'],
    count: json['count'],
    data: (json['data'] as List).map((e) => CropData.fromJson(e)).toList(),
  );
}


//------------------------Crop Note Response-----------------------
class CropNoteResponse {
  final int id;
  final String title;
  final String description;
  final String noteDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int crop;

  CropNoteResponse({required this.id, required this.title, required this.description, required this.noteDate, required this.createdAt, required this.updatedAt, required this.isActive, required this.crop});

  factory CropNoteResponse.fromJson(Map<String, dynamic> json) => CropNoteResponse(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    noteDate: json['note_date'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
    isActive: json['is_active'],
    crop: json['crop'],
  );
}


class CropNoteListResponse {
  final bool status;
  final int count;
  final List<CropNoteResponse> data;

  CropNoteListResponse({
    required this.status,
    required this.count,
    required this.data,
  });

  factory CropNoteListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List)
        .map((noteJson) => CropNoteResponse.fromJson(noteJson))
        .toList();
    return CropNoteListResponse(
      status: json['status'],
      count: json['count'],
      data: list,
    );
  }
}


// Delete Response (simple)
class CropNoteDeleteResponse {
  final bool status;
  final String message;

  CropNoteDeleteResponse({required this.status, required this.message});

  factory CropNoteDeleteResponse.fromJson(Map<String, dynamic> json) {
    return CropNoteDeleteResponse(
      status: json['status'],
      message: json['message'],
    );
  }
}


//--------------------------Crop Encyclopedia Response----------------------------
class CropEncyclopediaResponse {
  final bool status;
  final int count;
  final List<CropInfo> data;

  CropEncyclopediaResponse({
    required this.status,
    required this.count,
    required this.data,
  });

  factory CropEncyclopediaResponse.fromJson(Map<String, dynamic> json) {
    return CropEncyclopediaResponse(
      status: json['status'] ?? false,
      count: json['count'] ?? 0,
      data: (json['data'] as List)
          .map((item) => CropInfo.fromJson(item))
          .toList(),
    );
  }

  bool get isSuccess => status == true;
}

class CropInfo {
  final String id;
  final String name;
  final String scientificName;
  final String family;
  final String growingSeason;
  final List<String> sowingMonths;
  final List<String> harvestingMonths;
  final int growingDays;
  final String waterRequirement;
  final String soilType;
  final double minTemperature;
  final double maxTemperature;
  final List<String> commonVarieties;
  final List<String> benefits;
  final String? imageAsset;
  final double yieldPerAcre;
  final String description;
  final List<String> companionCrops;
  final List<String> avoidCrops;

  String? get imageUrl {
    if (imageAsset == null || imageAsset!.isEmpty) return null;
    // If it's already a full URL, return as is
    if (imageAsset!.startsWith('http')) return imageAsset;
    // Use the existing helper to build the absolute URL
    return Urls.getMediaUrl(imageAsset!);
  }

  CropInfo({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.family,
    required this.growingSeason,
    required this.sowingMonths,
    required this.harvestingMonths,
    required this.growingDays,
    required this.waterRequirement,
    required this.soilType,
    required this.minTemperature,
    required this.maxTemperature,
    required this.commonVarieties,
    required this.benefits,
    this.imageAsset,
    required this.yieldPerAcre,
    required this.description,
    required this.companionCrops,
    required this.avoidCrops,
  });

  factory CropInfo.fromJson(Map<String, dynamic> json) {
    return CropInfo(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      scientificName: json['scientificName'] ?? '',
      family: json['family'] ?? '',
      growingSeason: json['growingSeason'] ?? '',
      sowingMonths: List<String>.from(json['sowingMonths'] ?? []),
      harvestingMonths: List<String>.from(json['harvestingMonths'] ?? []),
      growingDays: json['growingDays'] ?? 0,
      waterRequirement: json['waterRequirement'] ?? '',
      soilType: json['soilType'] ?? '',
      minTemperature: (json['minTemperature'] ?? 0).toDouble(),
      maxTemperature: (json['maxTemperature'] ?? 0).toDouble(),
      commonVarieties: List<String>.from(json['commonVarieties'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      imageAsset: json['imageAsset'],
      yieldPerAcre: (json['yieldPerAcre'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      companionCrops: List<String>.from(json['companionCrops'] ?? []),
      avoidCrops: List<String>.from(json['avoidCrops'] ?? []),
    );
  }

  String get temperatureRange => '$minTemperature°C - $maxTemperature°C';

  String getFormattedYield() {
    if (yieldPerAcre >= 20) {
      return '${yieldPerAcre.toStringAsFixed(0)} tons/acre';
    }
    return '${yieldPerAcre.toStringAsFixed(1)} tons/acre';
  }
}



//--------------------------Cultivation Tips Response----------------------------
class CultivationTipsResponse {
  final bool status;
  final int count;
  final List<CultivationTip> data;

  CultivationTipsResponse({
    required this.status,
    required this.count,
    required this.data,
  });

  factory CultivationTipsResponse.fromJson(Map<String, dynamic> json) {
    return CultivationTipsResponse(
      status: json['status'] ?? false,
      count: json['count'] ?? 0,
      data: (json['data'] as List)
          .map((item) => CultivationTip.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'count': count,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }

  bool get isSuccess => status == true;
}

// Cultivation Tip Model (matches API response)
class CultivationTip {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> steps;
  final int estimatedTime;
  final List<String> benefits;
  final List<String> requiredMaterials;
  final String season;
  final int difficulty;

  CultivationTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.steps,
    required this.estimatedTime,
    required this.benefits,
    required this.requiredMaterials,
    required this.season,
    required this.difficulty,
  });

  factory CultivationTip.fromJson(Map<String, dynamic> json) {
    return CultivationTip(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      steps: List<String>.from(json['steps'] ?? []),
      estimatedTime: json['estimatedTime'] ?? 0,
      benefits: List<String>.from(json['benefits'] ?? []),
      requiredMaterials: List<String>.from(json['requiredMaterials'] ?? []),
      season: json['season'] ?? '',
      difficulty: json['difficulty'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'steps': steps,
      'estimatedTime': estimatedTime,
      'benefits': benefits,
      'requiredMaterials': requiredMaterials,
      'season': season,
      'difficulty': difficulty,
    };
  }

  // Helper methods for UI
  String get difficultyText {
    switch(difficulty) {
      case 1: return 'Very Easy';
      case 2: return 'Easy';
      case 3: return 'Moderate';
      case 4: return 'Difficult';
      case 5: return 'Expert';
      default: return 'Moderate';
    }
  }

  Color get difficultyColor {
    switch(difficulty) {
      case 1: return Colors.green;
      case 2: return Colors.lightGreen;
      case 3: return Colors.orange;
      case 4: return Colors.deepOrange;
      case 5: return Colors.red;
      default: return Colors.orange;
    }
  }

  TipCategory get tipCategory {
    return TipCategory.fromString(category);
  }
}

// Tip Category Enum (matching API)
enum TipCategory {
  irrigation,
  soilHealth,
  cropRotation,
  companionPlanting,
  pestManagement,
  fertilizer,
  harvesting,
  weedControl;

  String get displayName {
    switch(this) {
      case TipCategory.irrigation:
        return 'Irrigation';
      case TipCategory.soilHealth:
        return 'Soil Health';
      case TipCategory.cropRotation:
        return 'Crop Rotation';
      case TipCategory.companionPlanting:
        return 'Companion Planting';
      case TipCategory.pestManagement:
        return 'Pest Management';
      case TipCategory.fertilizer:
        return 'Fertilizer';
      case TipCategory.harvesting:
        return 'Harvesting';
      case TipCategory.weedControl:
        return 'Weed Control';
    }
  }

  IconData get icon {
    switch(this) {
      case TipCategory.irrigation:
        return Icons.water_drop;
      case TipCategory.soilHealth:
        return Icons.medication_outlined;
      case TipCategory.cropRotation:
        return Icons.calendar_month;
      case TipCategory.companionPlanting:
        return Icons.spellcheck;
      case TipCategory.pestManagement:
        return Icons.pest_control;
      case TipCategory.fertilizer:
        return Icons.agriculture;
      case TipCategory.harvesting:
        return Icons.cleaning_services;
      case TipCategory.weedControl:
        return Icons.grass;
    }
  }

  Color get color {
    switch(this) {
      case TipCategory.irrigation:
        return Colors.blue;
      case TipCategory.soilHealth:
        return Colors.brown;
      case TipCategory.cropRotation:
        return Colors.purple;
      case TipCategory.companionPlanting:
        return Colors.teal;
      case TipCategory.pestManagement:
        return Colors.deepOrange;
      case TipCategory.fertilizer:
        return Colors.green;
      case TipCategory.harvesting:
        return Colors.amber;
      case TipCategory.weedControl:
        return Colors.lime;
    }
  }

  static TipCategory fromString(String value) {
    switch(value.toLowerCase()) {
      case 'irrigation':
        return TipCategory.irrigation;
      case 'soilhealth':
        return TipCategory.soilHealth;
      case 'croprotation':
        return TipCategory.cropRotation;
      case 'companionplanting':
        return TipCategory.companionPlanting;
      case 'pestmanagement':
        return TipCategory.pestManagement;
      case 'fertilizer':
        return TipCategory.fertilizer;
      case 'harvesting':
        return TipCategory.harvesting;
      case 'weedcontrol':
        return TipCategory.weedControl;
      default:
        return TipCategory.irrigation;
    }
  }
}


// -------------------------- Pest Encyclopedia Response -----------------------------
enum PestType {
  sucking,
  chewing,
  boring,
  rootFeeding;

  String get displayName {
    switch(this) {
      case PestType.sucking: return 'Sucking Pest';
      case PestType.chewing: return 'Chewing Pest';
      case PestType.boring: return 'Boring Pest';
      case PestType.rootFeeding: return 'Root Feeding Pest';
    }
  }

  IconData get icon {
    switch(this) {
      case PestType.sucking: return Icons.water_drop;
      case PestType.chewing: return Icons.bug_report;
      case PestType.boring: return Icons.timeline;
      case PestType.rootFeeding: return Icons.agriculture;
    }
  }
}

enum DiseaseType {
  fungal,
  bacterial,
  viral,
  nutritional;

  String get displayName {
    switch(this) {
      case DiseaseType.fungal: return 'Fungal Disease';
      case DiseaseType.bacterial: return 'Bacterial Disease';
      case DiseaseType.viral: return 'Viral Disease';
      case DiseaseType.nutritional: return 'Nutritional Deficiency';
    }
  }

  IconData get icon {
    switch(this) {
      case DiseaseType.fungal: return Icons.sick;
      case DiseaseType.bacterial: return Icons.coronavirus;
      case DiseaseType.viral: return Icons.dangerous_outlined;
      case DiseaseType.nutritional: return Icons.science;
    }
  }
}

enum Severity {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch(this) {
      case Severity.low: return 'Low';
      case Severity.medium: return 'Medium';
      case Severity.high: return 'High';
      case Severity.critical: return 'Critical';
    }
  }

  Color get color {
    switch(this) {
      case Severity.low: return Colors.green;
      case Severity.medium: return Colors.orange;
      case Severity.high: return Colors.deepOrange;
      case Severity.critical: return Colors.red;
    }
  }
}

class PestEncyclopediaResponse {
  final bool status;
  final int count;
  final List<Pest> data;

  PestEncyclopediaResponse({
    required this.status,
    required this.count,
    required this.data,
  });

  factory PestEncyclopediaResponse.fromJson(Map<String, dynamic> json) {
    return PestEncyclopediaResponse(
      status: json['status'] ?? false,
      count: json['count'] ?? 0,
      data: (json['data'] as List)
          .map((item) => Pest.fromJson(item))
          .toList(),
    );
  }

  bool get isSuccess => status;
}

class Pest {
  final String id;
  final String name;
  final String scientificName;
  final String type;
  final String severity;
  final List<String> affectedCrops;
  final List<String> symptoms;
  final List<String> organicControls;
  final List<String> chemicalControls;
  final List<String> preventiveMeasures;
  final String description;
  final String? imageAsset;           // ✅ changed from List<String> images
  final String favorableConditions;
  final String transmissionMethod;
  final String lifeCycle;
  final String economicImpact;
  final String globalDistribution;
  final String commonName;
  final String hostRange;
  final String pesticideResistance;

  Pest({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.type,
    required this.severity,
    required this.affectedCrops,
    required this.symptoms,
    required this.organicControls,
    required this.chemicalControls,
    required this.preventiveMeasures,
    required this.description,
    this.imageAsset,
    required this.favorableConditions,
    required this.transmissionMethod,
    required this.lifeCycle,
    required this.economicImpact,
    required this.globalDistribution,
    required this.commonName,
    required this.hostRange,
    required this.pesticideResistance,
  });

  factory Pest.fromJson(Map<String, dynamic> json) {
    return Pest(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      scientificName: json['scientificName'] ?? '',
      type: json['type'] ?? '',
      severity: json['severity'] ?? 'medium',
      affectedCrops: List<String>.from(json['affectedCrops'] ?? []),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      organicControls: List<String>.from(json['organicControls'] ?? []),
      chemicalControls: List<String>.from(json['chemicalControls'] ?? []),
      preventiveMeasures: List<String>.from(json['preventiveMeasures'] ?? []),
      description: json['description'] ?? '',
      imageAsset: json['imageAsset'],    // ✅ single imageAsset
      favorableConditions: json['favorableConditions'] ?? '',
      transmissionMethod: json['transmissionMethod'] ?? '',
      lifeCycle: json['lifeCycle'] ?? '',
      economicImpact: json['economicImpact'] ?? '',
      globalDistribution: json['globalDistribution'] ?? '',
      commonName: json['commonName'] ?? '',
      hostRange: json['hostRange'] ?? '',
      pesticideResistance: json['pesticideResistance'] ?? '',
    );
  }

  // ✅ imageUrl getter identical to CropInfo
  String? get imageUrl {
    if (imageAsset == null || imageAsset!.isEmpty) return null;
    if (imageAsset!.startsWith('http')) return imageAsset;
    return Urls.getMediaUrl(imageAsset!);
  }

  PestType get pestType {
    switch (type) {
      case 'sucking_pest': return PestType.sucking;
      case 'chewing_pest': return PestType.chewing;
      case 'boring_pest': return PestType.boring;
      case 'root_feeding_pest': return PestType.rootFeeding;
      default: return PestType.sucking;
    }
  }

  Severity get severityEnum {
    switch (severity) {
      case 'low': return Severity.low;
      case 'medium': return Severity.medium;
      case 'high': return Severity.high;
      case 'critical': return Severity.critical;
      default: return Severity.medium;
    }
  }

  String get activeSeason => favorableConditions;
}

// -------------------------- Disease Encyclopedia Response -----------------------------
class DiseaseEncyclopediaResponse {
  final bool status;
  final int count;
  final List<Disease> data;

  DiseaseEncyclopediaResponse({
    required this.status,
    required this.count,
    required this.data,
  });

  factory DiseaseEncyclopediaResponse.fromJson(Map<String, dynamic> json) {
    return DiseaseEncyclopediaResponse(
      status: json['status'] ?? false,
      count: json['count'] ?? 0,
      data: (json['data'] as List)
          .map((item) => Disease.fromJson(item))
          .toList(),
    );
  }

  bool get isSuccess => status;
}

class Disease {
  final String id;
  final String name;
  final String scientificName;
  final String type;
  final String severity;
  final List<String> affectedCrops;
  final List<String> symptoms;
  final List<String> organicControls;
  final List<String> chemicalControls;
  final List<String> preventiveMeasures;
  final String description;
  final String favorableConditions;
  final String transmissionMethod;
  final String incubationPeriod;
  final String economicImpact;
  final String globalDistribution;
  final String commonName;
  final String hostRange;
  final String fungicideResistance;
  final String? imageAsset;           // ✅ changed from List<String> images

  Disease({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.type,
    required this.severity,
    required this.affectedCrops,
    required this.symptoms,
    required this.organicControls,
    required this.chemicalControls,
    required this.preventiveMeasures,
    required this.description,
    required this.favorableConditions,
    required this.transmissionMethod,
    required this.incubationPeriod,
    required this.economicImpact,
    required this.globalDistribution,
    required this.commonName,
    required this.hostRange,
    required this.fungicideResistance,
    this.imageAsset,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      scientificName: json['scientificName'] ?? '',
      type: json['type'] ?? '',
      severity: json['severity'] ?? 'medium',
      affectedCrops: List<String>.from(json['affectedCrops'] ?? []),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      organicControls: List<String>.from(json['organicControls'] ?? []),
      chemicalControls: List<String>.from(json['chemicalControls'] ?? []),
      preventiveMeasures: List<String>.from(json['preventiveMeasures'] ?? []),
      description: json['description'] ?? '',
      favorableConditions: json['favorableConditions'] ?? '',
      transmissionMethod: json['transmissionMethod'] ?? '',
      incubationPeriod: json['incubationPeriod'] ?? '',
      economicImpact: json['economicImpact'] ?? '',
      globalDistribution: json['globalDistribution'] ?? '',
      commonName: json['commonName'] ?? '',
      hostRange: json['hostRange'] ?? '',
      fungicideResistance: json['fungicideResistance'] ?? '',
      imageAsset: json['imageAsset'],    // ✅ single imageAsset
    );
  }

  // ✅ imageUrl getter identical to CropInfo
  String? get imageUrl {
    if (imageAsset == null || imageAsset!.isEmpty) return null;
    if (imageAsset!.startsWith('http')) return imageAsset;
    return Urls.getMediaUrl(imageAsset!);
  }

  DiseaseType get diseaseType {
    switch (type) {
      case 'fungal': return DiseaseType.fungal;
      case 'bacterial': return DiseaseType.bacterial;
      case 'viral': return DiseaseType.viral;
      case 'nutritional': return DiseaseType.nutritional;
      default: return DiseaseType.fungal;
    }
  }

  Severity get severityEnum {
    switch (severity) {
      case 'low': return Severity.low;
      case 'medium': return Severity.medium;
      case 'high': return Severity.high;
      case 'critical': return Severity.critical;
      default: return Severity.medium;
    }
  }
}



// ====================== Market Meta ======================
class MarketMetaResponse {
  final bool status;
  final MarketMetaData data;

  MarketMetaResponse.fromJson(Map<String, dynamic> json)
      : status = json['status'] ?? false,
        data = MarketMetaData.fromJson(json['data'] ?? {});
}

class MarketMetaData {
  final List<String> states;
  final List<String> districts;
  final List<String> commodities;
  final String? selectedState;
  final String? selectedDistrict;

  MarketMetaData.fromJson(Map<String, dynamic> json)
      : states = List<String>.from(json['states'] ?? []),
        districts = List<String>.from(json['districts'] ?? []),
        commodities = List<String>.from(json['commodities'] ?? []),
        selectedState = json['selected_state'],
        selectedDistrict = json['selected_district'];
}

// ====================== Market Dashboard ======================
class MarketDashboardResponse {
  final bool status;
  final DashboardSummary summary;
  final List<TrendingCommodity> trending;
  final DashboardStats stats;

  MarketDashboardResponse.fromJson(Map<String, dynamic> json)
      : status = json['status'] ?? false,
        summary = DashboardSummary.fromJson(json['summary'] ?? {}),
        trending = (json['trending'] as List?)
            ?.map((e) => TrendingCommodity.fromJson(e))
            .toList() ??
            [],
        stats = DashboardStats.fromJson(json['stats'] ?? {});
}

class DashboardSummary {
  final TopGainerLoser topGainer;
  final TopGainerLoser topLoser;

  DashboardSummary.fromJson(Map<String, dynamic> json)
      : topGainer = TopGainerLoser.fromJson(json['top_gainer'] ?? {}),
        topLoser = TopGainerLoser.fromJson(json['top_loser'] ?? {});
}

class TopGainerLoser {
  final String commodity;
  final double percent;
  final String trend; // "up", "down", "stable"

  TopGainerLoser.fromJson(Map<String, dynamic> json)
      : commodity = json['commodity'] ?? '',
        percent = (json['percent'] ?? 0).toDouble(),
        trend = json['trend'] ?? 'stable';
}

class TrendingCommodity {
  final String commodity;
  final double percent;
  final String trend;

  TrendingCommodity.fromJson(Map<String, dynamic> json)
      : commodity = json['commodity'] ?? '',
        percent = (json['percent'] ?? 0).toDouble(),
        trend = json['trend'] ?? 'stable';
}

class DashboardStats {
  final int totalCommodities;
  final int totalMarkets;
  final double avgPrice;

  DashboardStats.fromJson(Map<String, dynamic> json)
      : totalCommodities = json['total_commodities'] ?? 0,
        totalMarkets = json['total_markets'] ?? 0,
        avgPrice = (json['avg_price'] ?? 0).toDouble();
}



// ====================== Market Price ======================
class MarketPricesResponse {
  final bool status;
  final int count;
  final List<MarketPriceItem> data;

  MarketPricesResponse.fromJson(Map<String, dynamic> json)
      : status = json['status'] ?? false,
        count = json['count'] ?? 0,
        data = (json['data'] as List?)
            ?.map((e) => MarketPriceItem.fromJson(e))
            .toList() ??
            [];
}

class MarketPriceItem {
  final String id;
  final String name;
  final double price;
  final double minPrice;
  final double maxPrice;
  final String unit;
  final double change;
  final double percentChange;
  final String trend;
  final String marketLocation;
  final String district;
  final String state;
  final DateTime lastUpdated;

  MarketPriceItem.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        name = json['name'] ?? '',
        price = (json['price'] ?? 0).toDouble(),
        minPrice = (json['min_price'] ?? 0).toDouble(),
        maxPrice = (json['max_price'] ?? 0).toDouble(),
        unit = json['unit'] ?? 'quintal',
        change = (json['change'] ?? 0).toDouble(),
        percentChange = (json['percent_change'] ?? 0).toDouble(),
        trend = json['trend'] ?? 'stable',
        marketLocation = json['marketLocation'] ?? '',
        district = json['district'] ?? '',
        state = json['state'] ?? '',
        lastUpdated = DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now();

  String get formattedPrice => '₹${NumberFormat('#,##0.00').format(price)}';
  String get formattedMinPrice => '₹${NumberFormat('#,##0.00').format(minPrice)}';
  String get formattedMaxPrice => '₹${NumberFormat('#,##0.00').format(maxPrice)}';
  String get formattedChange => '${change >= 0 ? '+' : ''}${change.toStringAsFixed(0)}';
  String get formattedPercentChange => '${percentChange >= 0 ? '+' : ''}${percentChange.toStringAsFixed(1)}%';
  Color get changeColor => change >= 0 ? Colors.green : Colors.red;
  String get formattedLastUpdated => DateFormat('dd MMM yyyy').format(lastUpdated);
}


// ====================== Market Comparison ======================
class MarketComparisonResponse {
  final bool status;
  final String commodity;
  final String bestMarket;
  final List<MarketComparisonItem> data;

  MarketComparisonResponse.fromJson(Map<String, dynamic> json)
      : status = json['status'] ?? false,
        commodity = json['commodity'] ?? '',
        bestMarket = json['best_market'] ?? '',
        data = (json['data'] as List?)
            ?.map((e) => MarketComparisonItem.fromJson(e))
            .toList() ??
            [];
}

class MarketComparisonItem {
  final String market;
  final double modalPrice;
  final bool isBest;

  MarketComparisonItem.fromJson(Map<String, dynamic> json)
      : market = json['market'] ?? '',
        modalPrice = (json['modal_price'] ?? 0).toDouble(),
        isBest = json['is_best'] ?? false;

  String get formattedPrice => '₹${NumberFormat('#,##0.00').format(modalPrice)}';
}


// ====================== Market History ======================
// class MarketHistoryResponse {
//   final bool status;
//   final List<MarketHistoryPoint> data;
//   MarketHistoryResponse.fromJson(Map<String, dynamic> json)
//       : status = json['status'] ?? false,
//         data = (json['data'] as List?)?.map((e) => MarketHistoryPoint.fromJson(e)).toList() ?? [];
// }
//
// class MarketHistoryPoint {
//   final DateTime date;
//   final double price;
//   MarketHistoryPoint.fromJson(Map<String, dynamic> json)
//       : date = DateTime.parse(json['date']),
//         price = (json['price']).toDouble();
//   String get formattedDate => DateFormat('dd MMM yyyy').format(date);
//   String get formattedPrice => '₹${NumberFormat('#,##0.00').format(price)}';
// }