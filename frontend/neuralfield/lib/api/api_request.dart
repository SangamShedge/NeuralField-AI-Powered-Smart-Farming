import 'dart:io';
// import 'package:equatable/equatable.dart';

//--------------------------Login----------------------------
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  // Create from JSON
  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  @override
  String toString() {
    return 'LoginRequest(email: $email, password: ${'*' * password.length})';
  }
}

//--------------------------Register-------------------------------
class RegisterRequest {
  final String email;
  final String username;
  final String password;

  RegisterRequest({
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'password': password,
    };
  }

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
    );
  }

  @override
  String toString() {
    return 'RegisterRequest(email: $email, username: $username, password: ${'*' * password.length})';
  }
}

//---------------------------Profile-------------------------
// Profile Detail Request (POST with empty body)
class ProfileDetailRequest {
  ProfileDetailRequest();

  Map<String, dynamic> toJson() {
    return {};
  }

  factory ProfileDetailRequest.fromJson(Map<String, dynamic> json) {
    return ProfileDetailRequest();
  }
}

// Profile Update Request
class ProfileUpdateRequest {
  final String? fullName;
  final String? mobileNumber;
  final String? state;
  final String? district;
  final String? taluka;
  final String? city;
  final String? pincode;
  final String? address;

  ProfileUpdateRequest({
    this.fullName,
    this.mobileNumber,
    this.state,
    this.district,
    this.taluka,
    this.city,
    this.pincode,
    this.address,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (fullName != null) data['full_name'] = fullName;
    if (mobileNumber != null) data['mobile_number'] = mobileNumber;
    if (state != null) data['state'] = state;
    if (district != null) data['district'] = district;
    if (taluka != null) data['taluka'] = taluka;
    if (city != null) data['city'] = city;
    if (pincode != null) data['pincode'] = pincode;
    if (address != null) data['address'] = address;
    return data;
  }
}
//---------------------------Weather--------------------------
class WeatherRequest {
  final double lat;
  final double lon;

  WeatherRequest({
    required this.lat,
    required this.lon,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lon': lon,
    };
  }

  // Create from JSON
  factory WeatherRequest.fromJson(Map<String, dynamic> json) {
    return WeatherRequest(
      lat: json['lat']?.toDouble() ?? 0.0,
      lon: json['lon']?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'WeatherRequest(lat: $lat, lon: $lon)';
  }
}

//-------------------------CropRecommendation--------------
class CropRecommendationRequest {
  final String location;
  final String soilType;
  final String water;
  final String season;
  final String previousCrop;
  final String goal;

  CropRecommendationRequest({
    required this.location,
    required this.soilType,
    required this.water,
    required this.season,
    required this.previousCrop,
    required this.goal,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'soil_type': soilType,
      'water': water,
      'season': season,
      'previous_crop': previousCrop,
      'goal': goal,
    };
  }

  // Create from JSON
  factory CropRecommendationRequest.fromJson(Map<String, dynamic> json) {
    return CropRecommendationRequest(
      location: json['location'] ?? '',
      soilType: json['soil_type'] ?? '',
      water: json['water'] ?? '',
      season: json['season'] ?? '',
      previousCrop: json['previous_crop'] ?? '',
      goal: json['goal'] ?? '',
    );
  }

  @override
  String toString() {
    return 'CropRecommendationRequest(location: $location, soilType: $soilType, water: $water, season: $season, previousCrop: $previousCrop, goal: $goal)';
  }
}


//-----------------------News-Request---------------------------------
class NewsRequest {
  NewsRequest();

  Map<String, dynamic> toJson() {
    return {};
  }

  factory NewsRequest.fromJson(Map<String, dynamic> json) {
    return NewsRequest();
  }

  @override
  String toString() {
    return 'NewsRequest()';
  }
}




// ============ FERTILIZER REQUEST MODEL ============
class FertilizerRecommendationRequest {
  final String crop;
  final int cropAge;
  final String growthStage;
  final String soilType;
  final String plantCondition;
  final String irrigationType;
  final double temperature;
  final String soilMoisture;

  FertilizerRecommendationRequest({
    required this.crop,
    required this.cropAge,
    required this.growthStage,
    required this.soilType,
    required this.plantCondition,
    required this.irrigationType,
    required this.temperature,
    required this.soilMoisture,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'crop': crop,
      'crop_age': cropAge,
      'growth_stage': growthStage,
      'soil_type': soilType,
      'plant_condition': plantCondition,
      'irrigation_type': irrigationType,
      'temperature': temperature,
      'soil_moisture': soilMoisture,
    };
  }

  // Create from JSON
  factory FertilizerRecommendationRequest.fromJson(Map<String, dynamic> json) {
    return FertilizerRecommendationRequest(
      crop: json['crop'] ?? '',
      cropAge: json['crop_age'] ?? 0,
      growthStage: json['growth_stage'] ?? '',
      soilType: json['soil_type'] ?? '',
      plantCondition: json['plant_condition'] ?? '',
      irrigationType: json['irrigation_type'] ?? '',
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      soilMoisture: json['soil_moisture'] ?? '',
    );
  }

  @override
  String toString() {
    return 'FertilizerRecommendationRequest(crop: $crop, cropAge: $cropAge, growthStage: $growthStage, soilType: $soilType, plantCondition: $plantCondition, irrigationType: $irrigationType, temperature: $temperature, soilMoisture: $soilMoisture)';
  }
}




//----------------------------Gemini-Request--------------------------
class ChatRequest {
  final String message;
  final String? sessionId;
  final Map<String, dynamic>? metadata;

  ChatRequest({
    required this.message,
    this.sessionId,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (sessionId != null) 'session_id': sessionId,
      if (metadata != null) 'metadata': metadata,
    };
  }

  factory ChatRequest.fromJson(Map<String, dynamic> json) {
    return ChatRequest(
      message: json['message'] as String,
      sessionId: json['session_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  ChatRequest copyWith({
    String? message,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) {
    return ChatRequest(
      message: message ?? this.message,
      sessionId: sessionId ?? this.sessionId,
      metadata: metadata ?? this.metadata,
    );
  }
}

class AgricultureAdviceRequest {
  final String cropType;
  final String issue;
  final String? location;

  AgricultureAdviceRequest({
    required this.cropType,
    required this.issue,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'crop_type': cropType,
      'issue': issue,
      if (location != null) 'location': location,
    };
  }
}

class CropPredictionRequest {
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double ph;
  final double rainfall;
  final double temperature;

  CropPredictionRequest({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.ph,
    required this.rainfall,
    required this.temperature,
  });

  Map<String, dynamic> toJson() {
    return {
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'ph': ph,
      'rainfall': rainfall,
      'temperature': temperature,
    };
  }
}

//------------------------NPK-Calculator----------------------------
class NPKCalculatorRequest {
  final double area;           // in acres
  final double targetYield;    // tons per acre
  final double soilN;          // kg per acre
  final double soilP;          // kg per acre
  final double soilK;          // kg per acre
  final String crop;
  final String nitrogenSource;
  final String phosphorusSource;
  final String potassiumSource;

  NPKCalculatorRequest({
    required this.area,
    required this.targetYield,
    required this.soilN,
    required this.soilP,
    required this.soilK,
    required this.crop,
    required this.nitrogenSource,
    required this.phosphorusSource,
    required this.potassiumSource,
  });

  Map<String, dynamic> toJson() => {
    'area': area,
    'target_yield': targetYield,
    'soil_n': soilN,
    'soil_p': soilP,
    'soil_k': soilK,
    'crop': crop,
    'nitrogen_source': nitrogenSource,
    'phosphorus_source': phosphorusSource,
    'potassium_source': potassiumSource,
  };
}


//-------------------------Pest-Detection---------------------------
// Add this to api_request.dart after other request models

// Pest Detection Request
class PestDetectionRequest {
  final File imageFile;

  PestDetectionRequest({
    required this.imageFile,
  });

  // For multipart form data
  Map<String, String> toFields() {
    return {};
  }
}


// ------------------------My Crops Request------------------------------
class CropCreateRequest {
  final String name;
  final String? variety;
  final String sowingDate; // YYYY-MM-DD
  final double area;
  final String soilType;
  final String irrigationType;
  final String? location;
  final String growthStage;
  final String healthStatus;
  final String? lastFertilizer;

  CropCreateRequest({
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
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    if (variety != null) 'variety': variety,
    'sowing_date': sowingDate,
    'area': area,
    'soil_type': soilType,
    'irrigation_type': irrigationType,
    if (location != null) 'location': location,
    'growth_stage': growthStage,
    'health_status': healthStatus,
    if (lastFertilizer != null) 'last_fertilizer': lastFertilizer,
  };
}

class CropUpdateRequest {
  final int id;
  final String? name;
  final String? variety;
  final String? sowingDate;
  final double? area;
  final String? soilType;
  final String? irrigationType;
  final String? location;
  final String? growthStage;
  final String? healthStatus;
  final String? lastFertilizer;

  CropUpdateRequest({
    required this.id,
    this.name,
    this.variety,
    this.sowingDate,
    this.area,
    this.soilType,
    this.irrigationType,
    this.location,
    this.growthStage,
    this.healthStatus,
    this.lastFertilizer,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    if (name != null) 'name': name,
    if (variety != null) 'variety': variety,
    if (sowingDate != null) 'sowing_date': sowingDate,
    if (area != null) 'area': area,
    if (soilType != null) 'soil_type': soilType,
    if (irrigationType != null) 'irrigation_type': irrigationType,
    if (location != null) 'location': location,
    if (growthStage != null) 'growth_stage': growthStage,
    if (healthStatus != null) 'health_status': healthStatus,
    if (lastFertilizer != null) 'last_fertilizer': lastFertilizer,
  };
}

class CropDeleteRequest {
  final int id;

  CropDeleteRequest({required this.id});

  Map<String, dynamic> toJson() => {'id': id};
}


//--------------------------Crop Encyclopedia----------------------------
class CropEncyclopediaRequest {
  final String lang;

  CropEncyclopediaRequest({this.lang = 'en'});

  Map<String, dynamic> toJson() {
    return {'lang': lang};
  }

  factory CropEncyclopediaRequest.fromJson(Map<String, dynamic> json) {
    return CropEncyclopediaRequest(
      lang: json['lang'] as String? ?? 'en',
    );
  }
}



//--------------------------Cultivation Tips----------------------------
class CultivationTipsRequest {
  final String lang;

  CultivationTipsRequest({this.lang = 'en'});

  Map<String, dynamic> toJson() {
    return {'lang': lang};
  }

  factory CultivationTipsRequest.fromJson(Map<String, dynamic> json) {
    return CultivationTipsRequest(
      lang: json['lang'] as String? ?? 'en',
    );
  }

  @override
  String toString() => 'CultivationTipsRequest(lang: $lang)';
}



// -------------------------- Pest Encyclopedia -----------------------------
class PestEncyclopediaRequest {
  final String lang;

  PestEncyclopediaRequest({this.lang = 'en'});

  Map<String, dynamic> toJson() => {'lang': lang};

  factory PestEncyclopediaRequest.fromJson(Map<String, dynamic> json) =>
      PestEncyclopediaRequest(
        lang: json['lang'] as String? ?? 'en',
      );

  @override
  String toString() => 'PestEncyclopediaRequest(lang: $lang)';
}

// -------------------------- Disease Encyclopedia -----------------------------
class DiseaseEncyclopediaRequest {
  final String lang;

  DiseaseEncyclopediaRequest({this.lang = 'en'});

  Map<String, dynamic> toJson() => {'lang': lang};

  factory DiseaseEncyclopediaRequest.fromJson(Map<String, dynamic> json) =>
      DiseaseEncyclopediaRequest(
        lang: json['lang'] as String? ?? 'en',
      );

  @override
  String toString() => 'DiseaseEncyclopediaRequest(lang: $lang)';
}




// ---------------------------- Market Screen -------------------------------

// ====================== Market Meta ======================
class MarketMetaRequest {
  final String? state;
  final String? district;

  MarketMetaRequest({this.state, this.district});

  Map<String, dynamic> toJson() => {
    if (state != null) 'state': state,
    if (district != null) 'district': district,
  };
}

// ====================== Market Dashboard ======================
class MarketDashboardRequest {
  final String? state;
  final String? district;

  MarketDashboardRequest({this.state, this.district});

  Map<String, dynamic> toJson() => {
    if (state != null) 'state': state,
    if (district != null) 'district': district,
  };
}


// ====================== Market Price ======================
class MarketPricesRequest {
  final String? state;
  final String? district;
  final String? commodity;
  final int page;
  final int limit;

  MarketPricesRequest({
    this.state,
    this.district,
    this.commodity,
    this.page = 1,
    this.limit = 10,
  });

  Map<String, dynamic> toJson() => {
    if (state != null) 'state': state,
    if (district != null) 'district': district,
    if (commodity != null) 'commodity': commodity,
    'page': page,
    'limit': limit,
  };
}


// ====================== Market Comparison ======================
class MarketComparisonRequest {
  final String state;
  final String commodity;

  MarketComparisonRequest({required this.state, required this.commodity});

  Map<String, dynamic> toJson() => {
    'state': state,
    'commodity': commodity,
  };
}


// ====================== Market History ======================
// class MarketHistoryRequest {
//   final String commodity;
//   final String market;
//   MarketHistoryRequest({required this.commodity, required this.market});
//   Map<String, dynamic> toJson() => {'commodity': commodity, 'market': market};
// }