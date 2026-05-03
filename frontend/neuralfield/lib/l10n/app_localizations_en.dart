// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get changeLanguage => 'Change app language';

  @override
  String get settings => 'Settings';

  @override
  String get settingsSubtitle => 'App preferences';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Manage alerts';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get helpSupportSubtitle => 'FAQs, contact us';

  @override
  String get about => 'About';

  @override
  String get aboutSubtitle => 'Version 1.0.0';

  @override
  String get logout => 'Logout';

  @override
  String get logoutSubtitle => 'Sign out from account';

  @override
  String get settingsComingSoon => 'Settings - Coming Soon';

  @override
  String get notificationsComingSoon => 'Notifications - Coming Soon';

  @override
  String get helpSupportComingSoon => 'Help & Support - Coming Soon';

  @override
  String get aboutTitle => 'About NeuralField';

  @override
  String get appName => 'NeuralField';

  @override
  String get smartFarmingPlatform => 'Smart Farming Platform';

  @override
  String get version => 'Version';

  @override
  String get close => 'Close';

  @override
  String get logoutConfirmTitle => 'Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get logoutButton => 'Logout';

  @override
  String get loggingOut => 'Logging out...';

  @override
  String get errorLogout => 'Error during logout:';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिंदी';

  @override
  String get marathi => 'मराठी';

  @override
  String get locationServicesRequired => 'Location Services Required';

  @override
  String get locationServicesRequiredMessage => 'Please enable location services to get weather data for your area.';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get permissionRequiredMessage => 'Location permission is required to get weather data. Please grant permission in settings.';

  @override
  String get enable => 'Enable';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get home => 'Home';

  @override
  String get myCrops => 'My Crops';

  @override
  String get market => 'Market';

  @override
  String get me => 'Me';

  @override
  String get crops => 'Crops';

  @override
  String get pestsAndDiseases => 'Pests &\ndiseases';

  @override
  String get cultivationTips => 'Cultivation\ntips';

  @override
  String get allAgricultureNews => 'All Agriculture News';

  @override
  String get refresh => 'Refresh';

  @override
  String get noNewsAvailable => 'No news available';

  @override
  String get readFullArticle => 'Read Full Article';

  @override
  String get imageNotAvailable => 'Image not available';

  @override
  String get publishedLabel => 'Published:';

  @override
  String get unableToLoadNews => 'Unable to load news';

  @override
  String get retry => 'Retry';

  @override
  String get viewAllNews => 'View All News →';

  @override
  String get failedToRefresh => 'Failed to refresh:';

  @override
  String get cropRecommendationTitle => 'Crop Recommendation';

  @override
  String get cropRecommendationSubtitle => 'AI-based suggestions';

  @override
  String get fertilizerRecommendationTitle => 'Fertilizer Recommendation';

  @override
  String get fertilizerRecommendationSubtitle => 'Smart recommendations';

  @override
  String get fertilizerCalculatorTitle => 'Fertilizer Calculator';

  @override
  String get fertilizerCalculatorSubtitle => 'Smart NPK guide';

  @override
  String get pestDetectionTitle => 'Pest Detection';

  @override
  String get pestDetectionSubtitle => 'Upload & identify';

  @override
  String get detectingLocation => 'Detecting your location...';

  @override
  String get enableGpsForAccurateWeather => 'Please enable GPS for accurate weather';

  @override
  String get locationServiceRequired => 'Location Service Required';

  @override
  String get enableLocationAndRetry => 'Enable Location & Retry';

  @override
  String get feelsLike => 'Feels like';

  @override
  String get humidityLabel => 'Humidity:';

  @override
  String get windLabel => 'Wind:';

  @override
  String get refreshWeather => 'Refresh Weather';

  @override
  String get locationServicesUnavailable => 'Location services unavailable. Please enable GPS and location permission.';

  @override
  String get locationServiceUnavailableEnableGps => 'Location service unavailable. Please enable GPS.';

  @override
  String get sprayingAdviceTooHot => '🚫 Avoid spraying - Too hot';

  @override
  String get sprayingAdviceLowTemp => '⚠️ Low temperature - Delay spraying';

  @override
  String get sprayingAdviceHighHumidity => '⚠️ High humidity - Risk of fungal growth';

  @override
  String get sprayingAdviceLowHumidity => '⚠️ Low humidity - Spray in morning/evening';

  @override
  String get sprayingAdviceGood => '✅ Good conditions for spraying';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String get fertilizerCalculator => 'Fertilizer Calculator';

  @override
  String get newCalculationTooltip => 'New Calculation';

  @override
  String get smartNpkCalculator => 'Smart NPK Calculator';

  @override
  String get calculatePreciseFertilizerRequirementsSubtitle => 'Calculate precise fertilizer requirements based on soil test results';

  @override
  String get targetYieldLabel => 'Target Yield';

  @override
  String get unitHectares => 'Hectares';

  @override
  String get unitAcres => 'Acres';

  @override
  String get unitSquareMeters => 'Square Meters';

  @override
  String soilTestResultsKgPerUnit(String unit) {
    return 'Soil Test Results (kg per $unit)';
  }

  @override
  String get nitrogenN => 'Nitrogen (N)';

  @override
  String get phosphorusP => 'Phosphorus (P)';

  @override
  String get potassiumK => 'Potassium (K)';

  @override
  String get fertilizerSelection => 'Fertilizer Selection';

  @override
  String get nitrogenSource => 'Nitrogen Source';

  @override
  String get phosphorusSource => 'Phosphorus Source';

  @override
  String get potassiumSource => 'Potassium Source';

  @override
  String get calculateFertilizerRequirementsButton => 'Calculate Fertilizer Requirements';

  @override
  String get npkRequirementSummary => 'NPK REQUIREMENT SUMMARY';

  @override
  String get npkAnalysisKg => 'NPK Analysis (kg)';

  @override
  String get npkRequired => 'Required';

  @override
  String get soilAvailable => 'Soil Available';

  @override
  String get toApply => 'To Apply';

  @override
  String get efficiencyLabel => 'Efficiency:';

  @override
  String get applicationInstructions => 'Application Instructions';

  @override
  String get timingInstructionTitle => 'Timing';

  @override
  String get applyBeforeSowingInstruction => 'Apply before sowing or at early growth stage';

  @override
  String get methodInstructionTitle => 'Method';

  @override
  String get broadcastEvenlyInstruction => 'Broadcast evenly or apply in bands near root zone';

  @override
  String get irrigationInstructionTitle => 'Irrigation';

  @override
  String get irrigateImmediatelyInstruction => 'Irrigate immediately after fertilizer application';

  @override
  String get cautionInstructionTitle => 'Caution';

  @override
  String get avoidOverapplicationInstruction => 'Avoid over-application to prevent environmental damage';

  @override
  String get newCalculationButtonLabel => 'New Calculation';

  @override
  String get calculationSavedSnackbar => 'Calculation saved!';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get cropEncyclopediaTitle => 'Crop Encyclopedia';

  @override
  String get searchCropsHint => 'Search crops...';

  @override
  String get loadingCrops => 'Loading crops...';

  @override
  String get noCropsFound => 'No crops found';

  @override
  String get failedToLoadCrops => 'Failed to load crops:';

  @override
  String get seasonAll => 'All';

  @override
  String get seasonKharif => 'Kharif';

  @override
  String get seasonRabi => 'Rabi';

  @override
  String get seasonZaid => 'Zaid';

  @override
  String get clearSearchPrefix => 'Clear Search:';

  @override
  String get noCropsMatchSearch => 'No crops match your search';

  @override
  String get tryDifferentSearchTerm => 'Try a different search term';

  @override
  String get daysLabel => 'days';

  @override
  String get detailDescriptionTitle => '🌾 Description';

  @override
  String get detailGrowingInfoTitle => '📊 Growing Information';

  @override
  String get detailSowingHarvestingTitle => '📅 Sowing & Harvesting';

  @override
  String get detailCommonVarietiesTitle => '🌱 Common Varieties';

  @override
  String get detailHealthBenefitsTitle => '💚 Health Benefits';

  @override
  String get detailCompanionCropsTitle => '🤝 Companion Crops';

  @override
  String get detailAvoidCropsTitle => '⚠️ Crops to Avoid';

  @override
  String get detailFamily => 'Family';

  @override
  String get detailGrowingSeason => 'Growing Season';

  @override
  String get detailGrowingPeriod => 'Growing Period';

  @override
  String get detailWaterRequirement => 'Water Requirement';

  @override
  String get detailSoilType => 'Soil Type';

  @override
  String get detailTemperatureRange => 'Temperature Range';

  @override
  String get detailExpectedYield => 'Expected Yield';

  @override
  String get detailSowingMonths => 'Sowing Months';

  @override
  String get detailHarvestingMonths => 'Harvesting Months';

  @override
  String get cultivationTipsTitle => 'Cultivation Tips';

  @override
  String get searchCultivationTipsHint => 'Search cultivation tips...';

  @override
  String get loadingCultivationTips => 'Loading cultivation tips...';

  @override
  String get noCultivationTipsFound => 'No cultivation tips found';

  @override
  String get failedToLoadTips => 'Failed to load tips:';

  @override
  String get noTipsFound => 'No tips found';

  @override
  String get tryDifferentCategory => 'Try selecting a different category';

  @override
  String get all => 'All';

  @override
  String get clearAllFilters => 'Clear All Filters';

  @override
  String showingTipsCount(Object count, Object total) {
    return 'Showing $count of $total tips';
  }

  @override
  String get minutesUnit => 'min';

  @override
  String get stepsUnit => 'steps';

  @override
  String get shareFeatureComingSoon => 'Share feature coming soon';

  @override
  String get timeRequired => 'Time Required';

  @override
  String get difficultyLabel => 'Difficulty';

  @override
  String get bestSeason => 'Best Season';

  @override
  String get sectionDescription => '📖 Description';

  @override
  String get sectionStepByStepGuide => '📋 Step-by-Step Guide';

  @override
  String get sectionBenefits => '✅ Benefits';

  @override
  String get sectionMaterialsRequired => '🛠️ Materials Required';

  @override
  String get pestsDiseasesTitle => 'Pests & Diseases';

  @override
  String get searchPestsDiseasesHint => 'Search pests or diseases...';

  @override
  String get tabPests => 'Pests';

  @override
  String get tabDiseases => 'Diseases';

  @override
  String get noPestsFound => 'No pests found';

  @override
  String get noDiseasesFound => 'No diseases found';

  @override
  String get failedToLoadPests => 'Failed to load pests:';

  @override
  String get failedToLoadDiseases => 'Failed to load diseases:';

  @override
  String searchResultsPests(Object count) {
    return 'Search results: $count pests found';
  }

  @override
  String searchResultsDiseases(Object count) {
    return 'Search results: $count diseases found';
  }

  @override
  String get clear => 'Clear';

  @override
  String cropsCount(Object count) {
    return '$count crops';
  }

  @override
  String get typeLabel => 'Type';

  @override
  String get severityLabel => 'Severity';

  @override
  String get sectionSymptoms => '⚠️ Symptoms';

  @override
  String get sectionOrganicControl => '🌱 Organic Control';

  @override
  String get sectionChemicalControl => '🧪 Chemical Control';

  @override
  String get sectionPreventiveMeasures => '🛡️ Preventive Measures';

  @override
  String get sectionAffectedCrops => '🌾 Affected Crops';

  @override
  String get sectionFavorableConditions => '🌡️ Favorable Conditions';

  @override
  String get cropRecommendationAppBarTitle => 'Crop Recommendation';

  @override
  String get newRecommendationTooltip => 'New Recommendation';

  @override
  String get analyzingFarmData => 'Analyzing your farm data...';

  @override
  String get aiPoweredRecommendationsTitle => 'AI-Powered Recommendations';

  @override
  String get aiPoweredRecommendationsSubtitle => 'Get personalized crop suggestions based on your farm conditions';

  @override
  String get locationLabel => 'Location';

  @override
  String get soilTypeLabel => 'Soil Type';

  @override
  String get waterAvailabilityLabel => 'Water Availability';

  @override
  String get seasonLabel => 'Season';

  @override
  String get previousCropLabel => 'Previous Crop';

  @override
  String get goalLabel => 'Goal';

  @override
  String get getRecommendationsButton => 'Get Recommendations';

  @override
  String get recommendedForYouBadge => '⭐ RECOMMENDED FOR YOU';

  @override
  String get bestMatchBadge => 'Best Match';

  @override
  String get otherSuggestionsTitle => 'Other Suggestions';

  @override
  String get inputSummaryTitle => 'Input Summary';

  @override
  String get newAnalysisButton => 'New Analysis';

  @override
  String get saveButton => 'Save';

  @override
  String get suggestionSubtext => 'Good alternative for your farm conditions';

  @override
  String get soilTypeAlluvial => 'Alluvial';

  @override
  String get soilTypeBlack => 'Black';

  @override
  String get soilTypeClay => 'Clay';

  @override
  String get soilTypeLaterite => 'Laterite';

  @override
  String get soilTypeLoamy => 'Loamy';

  @override
  String get soilTypeRed => 'Red';

  @override
  String get soilTypeSandy => 'Sandy';

  @override
  String get waterHigh => 'High';

  @override
  String get waterLow => 'Low';

  @override
  String get waterMedium => 'Medium';

  @override
  String get waterVeryHigh => 'Very High';

  @override
  String get seasonSummer => 'Summer';

  @override
  String get previousCropNone => 'None';

  @override
  String get previousCropBajra => 'Bajra';

  @override
  String get previousCropChickpea => 'Chickpea';

  @override
  String get previousCropCotton => 'Cotton';

  @override
  String get previousCropGroundnut => 'Groundnut';

  @override
  String get previousCropJowar => 'Jowar';

  @override
  String get previousCropMaize => 'Maize';

  @override
  String get previousCropRice => 'Rice';

  @override
  String get previousCropSoybean => 'Soybean';

  @override
  String get previousCropSugarcane => 'Sugarcane';

  @override
  String get previousCropTur => 'Tur';

  @override
  String get previousCropWheat => 'Wheat';

  @override
  String get goalFastGrowth => 'Fast Growth';

  @override
  String get goalHighYield => 'High Yield';

  @override
  String get goalLowCost => 'Low Cost';

  @override
  String get goalProfit => 'Profit';

  @override
  String get fertilizerRecommendationAppBarTitle => 'Fertilizer Recommendation';

  @override
  String get analyzingCropText => 'Analyzing your crop...';

  @override
  String get aiPoweredAnalysisTitle => 'AI-Powered Analysis';

  @override
  String get aiPoweredAnalysisSubtitle => 'Get precise fertilizer recommendations based on your crop conditions';

  @override
  String get cropTypeLabel => 'Crop Type';

  @override
  String get cropAgeLabel => 'Crop Age (Days)';

  @override
  String get growthStageLabel => 'Growth Stage';

  @override
  String get plantConditionLabel => 'Plant Condition';

  @override
  String get irrigationTypeLabel => 'Irrigation Type';

  @override
  String get temperatureLabel => 'Temperature (°C)';

  @override
  String get soilMoistureLabel => 'Soil Moisture';

  @override
  String get getFertilizerRecommendationButton => 'Get Fertilizer Recommendation';

  @override
  String get applicationDetailsTitle => 'Application Details';

  @override
  String get fertilizerLabel => 'Fertilizer';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get recommendationLabel => 'Recommendation';

  @override
  String get savedMessage => 'Recommendation saved!';

  @override
  String get errorPrefix => 'Error:';

  @override
  String get cropBajra => 'Bajra';

  @override
  String get cropChickpea => 'Chickpea';

  @override
  String get cropCotton => 'Cotton';

  @override
  String get cropGrapes => 'Grapes';

  @override
  String get cropGroundnut => 'Groundnut';

  @override
  String get cropJowar => 'Jowar';

  @override
  String get cropMaize => 'Maize';

  @override
  String get cropMillet => 'Millet';

  @override
  String get cropOnion => 'Onion';

  @override
  String get cropPomegranate => 'Pomegranate';

  @override
  String get cropPotato => 'Potato';

  @override
  String get cropRice => 'Rice';

  @override
  String get cropSoybean => 'Soybean';

  @override
  String get cropSugarcane => 'Sugarcane';

  @override
  String get cropSunflower => 'Sunflower';

  @override
  String get cropTomato => 'Tomato';

  @override
  String get cropTur => 'Tur';

  @override
  String get cropWheat => 'Wheat';

  @override
  String get stageSeedling => 'Seedling';

  @override
  String get stageVegetative => 'Vegetative';

  @override
  String get stageFlowering => 'Flowering';

  @override
  String get stageFruiting => 'Fruiting';

  @override
  String get stageMaturity => 'Maturity';

  @override
  String get soilAlluvial => 'Alluvial';

  @override
  String get soilBlack => 'Black';

  @override
  String get soilClay => 'Clay';

  @override
  String get soilLoamy => 'Loamy';

  @override
  String get soilRed => 'Red';

  @override
  String get soilSandy => 'Sandy';

  @override
  String get conditionHealthy => 'Healthy';

  @override
  String get conditionSlowGrowth => 'Slow growth';

  @override
  String get conditionYellowLeaves => 'Yellow leaves';

  @override
  String get conditionPaleLeaves => 'Pale leaves';

  @override
  String get conditionBrownSpots => 'Brown spots';

  @override
  String get conditionWeakStem => 'Weak stem';

  @override
  String get irrigationCanal => 'Canal';

  @override
  String get irrigationBorewell => 'Borewell';

  @override
  String get irrigationDrip => 'Drip';

  @override
  String get irrigationSprinkler => 'Sprinkler';

  @override
  String get irrigationRain => 'Rain';

  @override
  String get moistureLow => 'Low';

  @override
  String get moistureMedium => 'Medium';

  @override
  String get moistureHigh => 'High';

  @override
  String get smartFarmingToolsTitle => 'Smart Farming Tools';

  @override
  String get aiPoweredRecommendationsSubtitleHS => 'AI-Powered Recommendations';

  @override
  String get knowledgeHubTitle => 'Knowledge Hub';

  @override
  String get agricultureNewsTitle => 'Agriculture News';

  @override
  String get refreshNewsTooltip => 'Refresh News';

  @override
  String get viewAllLabel => 'View All';

  @override
  String get pestDetectionAppBarTitle => 'Pest & Disease Detection';

  @override
  String get newDetectionTooltip => 'New Detection';

  @override
  String get aiPoweredBadge => 'AI POWERED';

  @override
  String get smartPestDetectionTitle => 'Smart Pest Detection';

  @override
  String get smartPestDetectionDescription => 'Upload a photo of affected crops and our AI will instantly identify diseases, suggest treatments, and provide prevention tips.';

  @override
  String get featureFastAnalysis => 'Fast Analysis';

  @override
  String get featureTreatmentPlans => 'Treatment Plans';

  @override
  String get featureVoiceOutput => 'Voice Output';

  @override
  String get uploadOrTakePhoto => 'Upload or take a photo';

  @override
  String get ofAffectedCropForAnalysis => 'of affected crop for analysis';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get takePhoto => 'Take a Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get analyzingImage => 'Analyzing image...';

  @override
  String get detectedDiseaseLabel => 'Detected Disease';

  @override
  String get severityLabelPDS => 'Severity:';

  @override
  String get recommendedSolutionTitle => 'Recommended Solution';

  @override
  String get preventionTipsTitle => 'Prevention Tips';

  @override
  String get errorPickingImage => 'Error picking image:';

  @override
  String get failedToAnalyzeImage => 'Failed to analyze image. Please check your internet connection and try again.';

  @override
  String get failedToAnalyzeImageShort => 'Failed to analyze image. Please try again.';

  @override
  String get profileUpdated => 'Profile updated!';

  @override
  String get profileUpdateFailed => 'Failed to update profile';

  @override
  String get profilePictureUpdated => 'Profile picture updated!';

  @override
  String get profilePictureUpdateFailed => 'Failed to update profile picture';

  @override
  String get uploadingProfilePicture => 'Uploading profile picture...';

  @override
  String get failedToLoadProfile => 'Failed to load profile';

  @override
  String get checkConnection => 'Please check your connection';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get mobileNumberLabel => 'Mobile Number';

  @override
  String get addressLabel => 'Address';

  @override
  String get cityLabel => 'City';

  @override
  String get talukaLabel => 'Taluka';

  @override
  String get districtLabel => 'District';

  @override
  String get stateLabel => 'State';

  @override
  String get pincodeLabel => 'Pincode';

  @override
  String get notSet => 'Not set';

  @override
  String get personalInformationTitle => 'Personal Information';

  @override
  String get addressDetailsTitle => 'Address Details';

  @override
  String get streetAddressLabel => 'Street Address';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get enterFullName => 'Enter full name';

  @override
  String get enterMobileNumber => 'Enter mobile number';

  @override
  String get invalidMobileNumber => 'Invalid number';

  @override
  String get noCropsAddedYet => 'No Crops Added Yet';

  @override
  String get tapAddFirstCrop => 'Tap the + button to add your first crop';

  @override
  String cropAddedSuccessfully(String cropName) {
    return '$cropName added successfully!';
  }

  @override
  String get failedToLoadCropsCS => 'Failed to load crops';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: '0 days',
    );
    return '$_temp0';
  }

  @override
  String acresCount(num area) {
    String _temp0 = intl.Intl.pluralLogic(
      area,
      locale: localeName,
      other: '$area acres',
      one: '1 acre',
    );
    return '$_temp0';
  }

  @override
  String get acresUnit => 'acres';

  @override
  String get addNewCrop => 'Add New Crop';

  @override
  String editCrop(String cropName) {
    return 'Edit $cropName';
  }

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get farmConditions => 'Farm Conditions';

  @override
  String get currentCropStatus => 'Current Crop Status';

  @override
  String get cropNameLabel => 'Crop Name';

  @override
  String get varietyLabel => 'Variety';

  @override
  String get sowingDateLabel => 'Sowing Date';

  @override
  String get fieldAreaLabel => 'Field Area';

  @override
  String get healthStatusLabel => 'Health Status';

  @override
  String get lastFertilizerLabel => 'Last Fertilizer Used';

  @override
  String get selectCropTypeHint => 'Select crop type';

  @override
  String get varietyHint => 'e.g., Arka Vikas, HD-2967';

  @override
  String get enterAreaHint => 'Enter area in acres';

  @override
  String get selectSoilTypeHint => 'Select soil type';

  @override
  String get selectIrrigationHint => 'Select irrigation method';

  @override
  String get locationHint => 'e.g., Pune, Maharashtra';

  @override
  String get selectGrowthStageHint => 'Select current growth stage';

  @override
  String get selectHealthStatusHint => 'Select current health status';

  @override
  String get lastFertilizerHint => 'e.g., Urea, DAP, Potash';

  @override
  String get optional => 'Optional';

  @override
  String get pleaseSelectCrop => 'Please select a crop';

  @override
  String get pleaseEnterArea => 'Please enter area';

  @override
  String get enterValidPositiveNumber => 'Enter a valid positive number';

  @override
  String get addCropButton => 'ADD CROP';

  @override
  String get updateCropButton => 'UPDATE CROP';

  @override
  String get editCropTooltip => 'Edit Crop';

  @override
  String get deleteCropTooltip => 'Delete Crop';

  @override
  String cropUpdatedSuccessfully(String cropName) {
    return '$cropName updated successfully!';
  }

  @override
  String cropDeletedSuccessfully(String cropName) {
    return '$cropName deleted';
  }

  @override
  String get deleteCropTitle => 'Delete Crop';

  @override
  String deleteCropConfirmation(String cropName) {
    return 'Are you sure you want to delete \"$cropName\"? This action cannot be undone.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get fieldInformation => 'Field Information';

  @override
  String get growthInformation => 'Growth Information';

  @override
  String get growthTimeline => 'Growth Timeline';

  @override
  String get fieldAreaLabelDetail => 'Field Area';

  @override
  String get soilTypeLabelDetail => 'Soil Type';

  @override
  String get irrigationTypeLabelDetail => 'Irrigation Type';

  @override
  String get locationLabelDetail => 'Location';

  @override
  String get lastFertilizerLabelDetail => 'Last Fertilizer';

  @override
  String get currentGrowthStageLabel => 'Current Growth Stage';

  @override
  String get daysSinceSowingLabel => 'Days Since Sowing';

  @override
  String sownWithDateAndDays(String date, int days) {
    return 'Sown: $date ($days days ago)';
  }

  @override
  String dayWithNumber(int day) {
    return 'Day $day';
  }

  @override
  String get germinationStage => 'Germination';

  @override
  String get vegetativeStage => 'Vegetative';

  @override
  String get floweringStage => 'Flowering';

  @override
  String get fruitingStage => 'Fruiting';

  @override
  String get harvestingStage => 'Harvesting';

  @override
  String get harvest => 'Harvest';

  @override
  String get blackSoil => 'Black Soil';

  @override
  String get redSoil => 'Red Soil';

  @override
  String get sandySoil => 'Sandy Soil';

  @override
  String get claySoil => 'Clay Soil';

  @override
  String get loamySoil => 'Loamy Soil';

  @override
  String get dripIrrigation => 'Drip Irrigation';

  @override
  String get sprinklerSystem => 'Sprinkler System';

  @override
  String get canalWater => 'Canal Water';

  @override
  String get rainfed => 'Rainfed';

  @override
  String get manual => 'Manual';

  @override
  String get healthy => 'Healthy';

  @override
  String get minorIssues => 'Minor Issues';

  @override
  String get majorIssues => 'Major Issues';

  @override
  String get critical => 'Critical';

  @override
  String get aiTyping => 'NeuralField AI is typing...';

  @override
  String get aiThinking => 'Thinking...';

  @override
  String get aiGreeting => 'Namaste! I\'m NeuralField AI, your AI farming assistant! How can I help you with your crops today?';

  @override
  String get promptInstruction => 'Please respond in English.';

  @override
  String get micPermissionRequired => 'Microphone permission is required';

  @override
  String get micPermissionDenied => 'Microphone permission denied';

  @override
  String get speechUnavailable => 'Speech not available';

  @override
  String get speechErrorPrefix => 'Error: ';

  @override
  String get ttsError => 'Could not speak text';

  @override
  String get pleaseEnterMessage => 'Please enter a message';

  @override
  String get listeningHint => '🎤 Listening... Tap pause to stop';

  @override
  String get listeningHintField => 'Listening...';

  @override
  String get typeHint => 'Type your farming problem...';

  @override
  String get sending => 'Sending...';

  @override
  String get errorUnknown => 'Error: Unknown error';

  @override
  String get connectionFailed => '❌ Connection failed. Please check your internet.';

  @override
  String get neural => 'Neural';

  @override
  String get field => 'Field';

  @override
  String get forgotPasswordTagline => 'We\'ll help you recover your account';

  @override
  String get resetPasswordTagline => 'Set up your new password';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get enterEmail => 'Please enter your email';

  @override
  String get validEmail => 'Please enter a valid email';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 4 characters';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get loginButton => 'Login';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get registerButton => 'Register';

  @override
  String get resetPasswordTitle => 'Reset Your Password';

  @override
  String get resetPasswordDescription => 'Enter your email address and we\'ll send you an OTP to reset your password.';

  @override
  String get sendOtpButton => 'Send OTP';

  @override
  String get rememberPassword => 'Remember your password? ';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get createNewPasswordTitle => 'Create New Password';

  @override
  String createNewPasswordDescription(Object email) {
    return 'Enter the OTP sent to $email and create a new password.';
  }

  @override
  String get otpLabel => 'OTP';

  @override
  String get otpHint => 'Enter 6-digit OTP';

  @override
  String get enterOtp => 'Please enter OTP';

  @override
  String get otpLength => 'OTP must be 6 digits';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get newPasswordHint => 'Enter new password';

  @override
  String get enterNewPassword => 'Please enter a password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Confirm new password';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get resetPasswordButton => 'Reset Password';

  @override
  String get didNotReceiveOtp => 'Didn\'t receive OTP? ';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get useDifferentEmail => 'Use different email';

  @override
  String get loginSuccess => 'Login successful! Welcome back!';

  @override
  String get otpSentSuccess => 'OTP sent successfully! Check your email.';

  @override
  String get resetPasswordSuccess => 'Password reset successful! Please login.';

  @override
  String get otpResentSuccess => 'OTP resent successfully! Check your email.';

  @override
  String get errorResendingOtp => 'Error resending OTP:';

  @override
  String get startSmartFarmingJourney => 'Start your smart farming journey';

  @override
  String get verifyExistingTagline => 'Complete your verification process';

  @override
  String get enterOtpTagline => 'Enter the OTP sent to your email';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'Choose a username';

  @override
  String get enterUsername => 'Please enter a username';

  @override
  String get usernameMinLength => 'Username must be at least 3 characters';

  @override
  String get passwordHintRegister => 'Create a password';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get verifyExistingAccountLink => 'Verify existing account';

  @override
  String get verifyExistingDescription => 'Enter your email to receive verification OTP';

  @override
  String get verifyAccountButton => 'Verify Account';

  @override
  String get backToRegistration => 'Back to Registration';

  @override
  String get otpSentToEmailVerify => 'OTP sent to your email! Please verify.';

  @override
  String get accountAlreadyExistsTitle => 'Account Already Exists';

  @override
  String get accountAlreadyExistsMessage => 'An account with this email already exists but is not verified. Would you like to verify it now?';

  @override
  String get verifyAccount => 'Verify Account';

  @override
  String get verificationOtpSent => 'Verification OTP sent to your email!';

  @override
  String get otpInvalidLength => 'Please enter a valid 6-digit OTP';

  @override
  String get accountVerifiedSuccess => 'Account verified successfully! Please login.';

  @override
  String get unableToResendOtp => 'Unable to resend OTP. Please try again.';

  @override
  String get otpResentSuccessRegister => 'OTP resent successfully! Check your email.';

  @override
  String get accountVerifiedAndLoggedIn => 'Account verified and logged in successfully!';

  @override
  String get accountVerifiedPleaseLogin => 'Account verified! Please login.';

  @override
  String get enterOtpDescription => 'Please enter the 6-digit OTP sent to';

  @override
  String get verifyOtpButton => 'Verify OTP';

  @override
  String get refreshTooltip => 'Refresh';

  @override
  String get viewAll => 'View All';

  @override
  String get badgeCount => '3';

  @override
  String get loading => 'Loading...';

  @override
  String get selectState => 'Select State';

  @override
  String get selectDistrict => 'Select District';

  @override
  String get selectCommodityOptional => 'Select Commodity (Optional)';

  @override
  String get topGainer => 'Top Gainer';

  @override
  String get topLoser => 'Top Loser';

  @override
  String get marketOverview => 'Market Overview';

  @override
  String get commodities => 'Commodities';

  @override
  String get markets => 'Markets';

  @override
  String get avgPrice => 'Avg Price';

  @override
  String get trendingNow => 'Trending Now';

  @override
  String get marketPrices => 'Market Prices';

  @override
  String get marketPricesSubtitle => 'View detailed prices from mandis';

  @override
  String get marketComparison => 'Market Comparison';

  @override
  String get resetComparisonFilters => 'Reset Comparison Filters';

  @override
  String get selectCommodity => 'Select Commodity';

  @override
  String failedToLoadComparison(String error) {
    return 'Failed to load comparison: $error';
  }

  @override
  String bestPriceFor(String commodity) {
    return 'Best Price for $commodity';
  }

  @override
  String get bestMarket => 'Best Market';

  @override
  String get otherMarkets => 'Other Markets';

  @override
  String get noComparisonDataAvailable => 'No comparison data available';

  @override
  String get marketDashboard => 'Market Dashboard';

  @override
  String get marketDashboardSubtitle => 'Real-time market insights & trends';

  @override
  String get failedToLoadDashboard => 'Failed to load dashboard';

  @override
  String get marketPricesTitle => 'Market Prices';

  @override
  String get exportToCsvTooltip => 'Export to CSV';

  @override
  String get clearFiltersTooltip => 'Clear all filters';

  @override
  String get firstPageTooltip => 'First page';

  @override
  String get previousPageTooltip => 'Previous page';

  @override
  String get nextPageTooltip => 'Next page';

  @override
  String get lastPageTooltip => 'Last page';

  @override
  String get noDataToExport => 'No data to export';

  @override
  String exportedRecordsCount(int count) {
    return 'Exported $count records';
  }

  @override
  String get failedToExportFile => 'Failed to export file';

  @override
  String get priceLabel => 'Price';

  @override
  String get minPriceLabel => 'Min Price';

  @override
  String get maxPriceLabel => 'Max Price';

  @override
  String get unitLabel => 'Unit';

  @override
  String get changeLabel => 'Change';

  @override
  String get trendLabel => 'Trend';

  @override
  String get marketLabel => 'Market';

  @override
  String get lastUpdatedLabel => 'Last Updated';

  @override
  String get closeButton => 'Close';

  @override
  String get updatedPrefix => 'Updated:';

  @override
  String get failedToLoadPrices => 'Failed to load prices';

  @override
  String get retryButton => 'Retry';

  @override
  String get shareText => 'Market Prices Export';

  @override
  String get shareSubject => 'Market Prices Export';

  @override
  String get csvHeaderName => 'Name';

  @override
  String get csvHeaderPrice => 'Price';

  @override
  String get csvHeaderMinPrice => 'Min Price';

  @override
  String get csvHeaderMaxPrice => 'Max Price';

  @override
  String get csvHeaderUnit => 'Unit';

  @override
  String get csvHeaderChangePercent => 'Change %';

  @override
  String get csvHeaderTrend => 'Trend';

  @override
  String get csvHeaderMarket => 'Market';

  @override
  String get csvHeaderDistrict => 'District';

  @override
  String get csvHeaderState => 'State';

  @override
  String get csvHeaderLastUpdated => 'Last Updated';
}
