import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr')
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get changeLanguage;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get settingsSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage alerts'**
  String get notificationsSubtitle;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @helpSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FAQs, contact us'**
  String get helpSupportSubtitle;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get aboutSubtitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out from account'**
  String get logoutSubtitle;

  /// No description provided for @settingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Settings - Coming Soon'**
  String get settingsComingSoon;

  /// No description provided for @notificationsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Notifications - Coming Soon'**
  String get notificationsComingSoon;

  /// No description provided for @helpSupportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Help & Support - Coming Soon'**
  String get helpSupportComingSoon;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About NeuralField'**
  String get aboutTitle;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'NeuralField'**
  String get appName;

  /// No description provided for @smartFarmingPlatform.
  ///
  /// In en, this message translates to:
  /// **'Smart Farming Platform'**
  String get smartFarmingPlatform;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @loggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get loggingOut;

  /// No description provided for @errorLogout.
  ///
  /// In en, this message translates to:
  /// **'Error during logout:'**
  String get errorLogout;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get hindi;

  /// No description provided for @marathi.
  ///
  /// In en, this message translates to:
  /// **'मराठी'**
  String get marathi;

  /// No description provided for @locationServicesRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Services Required'**
  String get locationServicesRequired;

  /// No description provided for @locationServicesRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enable location services to get weather data for your area.'**
  String get locationServicesRequiredMessage;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @permissionRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to get weather data. Please grant permission in settings.'**
  String get permissionRequiredMessage;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @myCrops.
  ///
  /// In en, this message translates to:
  /// **'My Crops'**
  String get myCrops;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get market;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @crops.
  ///
  /// In en, this message translates to:
  /// **'Crops'**
  String get crops;

  /// No description provided for @pestsAndDiseases.
  ///
  /// In en, this message translates to:
  /// **'Pests &\ndiseases'**
  String get pestsAndDiseases;

  /// No description provided for @cultivationTips.
  ///
  /// In en, this message translates to:
  /// **'Cultivation\ntips'**
  String get cultivationTips;

  /// No description provided for @allAgricultureNews.
  ///
  /// In en, this message translates to:
  /// **'All Agriculture News'**
  String get allAgricultureNews;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @noNewsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No news available'**
  String get noNewsAvailable;

  /// No description provided for @readFullArticle.
  ///
  /// In en, this message translates to:
  /// **'Read Full Article'**
  String get readFullArticle;

  /// No description provided for @imageNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Image not available'**
  String get imageNotAvailable;

  /// No description provided for @publishedLabel.
  ///
  /// In en, this message translates to:
  /// **'Published:'**
  String get publishedLabel;

  /// No description provided for @unableToLoadNews.
  ///
  /// In en, this message translates to:
  /// **'Unable to load news'**
  String get unableToLoadNews;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @viewAllNews.
  ///
  /// In en, this message translates to:
  /// **'View All News →'**
  String get viewAllNews;

  /// No description provided for @failedToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh:'**
  String get failedToRefresh;

  /// No description provided for @cropRecommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop Recommendation'**
  String get cropRecommendationTitle;

  /// No description provided for @cropRecommendationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI-based suggestions'**
  String get cropRecommendationSubtitle;

  /// No description provided for @fertilizerRecommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer Recommendation'**
  String get fertilizerRecommendationTitle;

  /// No description provided for @fertilizerRecommendationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart recommendations'**
  String get fertilizerRecommendationSubtitle;

  /// No description provided for @fertilizerCalculatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer Calculator'**
  String get fertilizerCalculatorTitle;

  /// No description provided for @fertilizerCalculatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart NPK guide'**
  String get fertilizerCalculatorSubtitle;

  /// No description provided for @pestDetectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Pest Detection'**
  String get pestDetectionTitle;

  /// No description provided for @pestDetectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload & identify'**
  String get pestDetectionSubtitle;

  /// No description provided for @detectingLocation.
  ///
  /// In en, this message translates to:
  /// **'Detecting your location...'**
  String get detectingLocation;

  /// No description provided for @enableGpsForAccurateWeather.
  ///
  /// In en, this message translates to:
  /// **'Please enable GPS for accurate weather'**
  String get enableGpsForAccurateWeather;

  /// No description provided for @locationServiceRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Service Required'**
  String get locationServiceRequired;

  /// No description provided for @enableLocationAndRetry.
  ///
  /// In en, this message translates to:
  /// **'Enable Location & Retry'**
  String get enableLocationAndRetry;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels like'**
  String get feelsLike;

  /// No description provided for @humidityLabel.
  ///
  /// In en, this message translates to:
  /// **'Humidity:'**
  String get humidityLabel;

  /// No description provided for @windLabel.
  ///
  /// In en, this message translates to:
  /// **'Wind:'**
  String get windLabel;

  /// No description provided for @refreshWeather.
  ///
  /// In en, this message translates to:
  /// **'Refresh Weather'**
  String get refreshWeather;

  /// No description provided for @locationServicesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location services unavailable. Please enable GPS and location permission.'**
  String get locationServicesUnavailable;

  /// No description provided for @locationServiceUnavailableEnableGps.
  ///
  /// In en, this message translates to:
  /// **'Location service unavailable. Please enable GPS.'**
  String get locationServiceUnavailableEnableGps;

  /// No description provided for @sprayingAdviceTooHot.
  ///
  /// In en, this message translates to:
  /// **'🚫 Avoid spraying - Too hot'**
  String get sprayingAdviceTooHot;

  /// No description provided for @sprayingAdviceLowTemp.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Low temperature - Delay spraying'**
  String get sprayingAdviceLowTemp;

  /// No description provided for @sprayingAdviceHighHumidity.
  ///
  /// In en, this message translates to:
  /// **'⚠️ High humidity - Risk of fungal growth'**
  String get sprayingAdviceHighHumidity;

  /// No description provided for @sprayingAdviceLowHumidity.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Low humidity - Spray in morning/evening'**
  String get sprayingAdviceLowHumidity;

  /// No description provided for @sprayingAdviceGood.
  ///
  /// In en, this message translates to:
  /// **'✅ Good conditions for spraying'**
  String get sprayingAdviceGood;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// No description provided for @fertilizerCalculator.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer Calculator'**
  String get fertilizerCalculator;

  /// No description provided for @newCalculationTooltip.
  ///
  /// In en, this message translates to:
  /// **'New Calculation'**
  String get newCalculationTooltip;

  /// No description provided for @smartNpkCalculator.
  ///
  /// In en, this message translates to:
  /// **'Smart NPK Calculator'**
  String get smartNpkCalculator;

  /// No description provided for @calculatePreciseFertilizerRequirementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calculate precise fertilizer requirements based on soil test results'**
  String get calculatePreciseFertilizerRequirementsSubtitle;

  /// No description provided for @targetYieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Yield'**
  String get targetYieldLabel;

  /// No description provided for @unitHectares.
  ///
  /// In en, this message translates to:
  /// **'Hectares'**
  String get unitHectares;

  /// No description provided for @unitAcres.
  ///
  /// In en, this message translates to:
  /// **'Acres'**
  String get unitAcres;

  /// No description provided for @unitSquareMeters.
  ///
  /// In en, this message translates to:
  /// **'Square Meters'**
  String get unitSquareMeters;

  /// No description provided for @soilTestResultsKgPerUnit.
  ///
  /// In en, this message translates to:
  /// **'Soil Test Results (kg per {unit})'**
  String soilTestResultsKgPerUnit(String unit);

  /// No description provided for @nitrogenN.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen (N)'**
  String get nitrogenN;

  /// No description provided for @phosphorusP.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus (P)'**
  String get phosphorusP;

  /// No description provided for @potassiumK.
  ///
  /// In en, this message translates to:
  /// **'Potassium (K)'**
  String get potassiumK;

  /// No description provided for @fertilizerSelection.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer Selection'**
  String get fertilizerSelection;

  /// No description provided for @nitrogenSource.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen Source'**
  String get nitrogenSource;

  /// No description provided for @phosphorusSource.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus Source'**
  String get phosphorusSource;

  /// No description provided for @potassiumSource.
  ///
  /// In en, this message translates to:
  /// **'Potassium Source'**
  String get potassiumSource;

  /// No description provided for @calculateFertilizerRequirementsButton.
  ///
  /// In en, this message translates to:
  /// **'Calculate Fertilizer Requirements'**
  String get calculateFertilizerRequirementsButton;

  /// No description provided for @npkRequirementSummary.
  ///
  /// In en, this message translates to:
  /// **'NPK REQUIREMENT SUMMARY'**
  String get npkRequirementSummary;

  /// No description provided for @npkAnalysisKg.
  ///
  /// In en, this message translates to:
  /// **'NPK Analysis (kg)'**
  String get npkAnalysisKg;

  /// No description provided for @npkRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get npkRequired;

  /// No description provided for @soilAvailable.
  ///
  /// In en, this message translates to:
  /// **'Soil Available'**
  String get soilAvailable;

  /// No description provided for @toApply.
  ///
  /// In en, this message translates to:
  /// **'To Apply'**
  String get toApply;

  /// No description provided for @efficiencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Efficiency:'**
  String get efficiencyLabel;

  /// No description provided for @applicationInstructions.
  ///
  /// In en, this message translates to:
  /// **'Application Instructions'**
  String get applicationInstructions;

  /// No description provided for @timingInstructionTitle.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get timingInstructionTitle;

  /// No description provided for @applyBeforeSowingInstruction.
  ///
  /// In en, this message translates to:
  /// **'Apply before sowing or at early growth stage'**
  String get applyBeforeSowingInstruction;

  /// No description provided for @methodInstructionTitle.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get methodInstructionTitle;

  /// No description provided for @broadcastEvenlyInstruction.
  ///
  /// In en, this message translates to:
  /// **'Broadcast evenly or apply in bands near root zone'**
  String get broadcastEvenlyInstruction;

  /// No description provided for @irrigationInstructionTitle.
  ///
  /// In en, this message translates to:
  /// **'Irrigation'**
  String get irrigationInstructionTitle;

  /// No description provided for @irrigateImmediatelyInstruction.
  ///
  /// In en, this message translates to:
  /// **'Irrigate immediately after fertilizer application'**
  String get irrigateImmediatelyInstruction;

  /// No description provided for @cautionInstructionTitle.
  ///
  /// In en, this message translates to:
  /// **'Caution'**
  String get cautionInstructionTitle;

  /// No description provided for @avoidOverapplicationInstruction.
  ///
  /// In en, this message translates to:
  /// **'Avoid over-application to prevent environmental damage'**
  String get avoidOverapplicationInstruction;

  /// No description provided for @newCalculationButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'New Calculation'**
  String get newCalculationButtonLabel;

  /// No description provided for @calculationSavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Calculation saved!'**
  String get calculationSavedSnackbar;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @cropEncyclopediaTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop Encyclopedia'**
  String get cropEncyclopediaTitle;

  /// No description provided for @searchCropsHint.
  ///
  /// In en, this message translates to:
  /// **'Search crops...'**
  String get searchCropsHint;

  /// No description provided for @loadingCrops.
  ///
  /// In en, this message translates to:
  /// **'Loading crops...'**
  String get loadingCrops;

  /// No description provided for @noCropsFound.
  ///
  /// In en, this message translates to:
  /// **'No crops found'**
  String get noCropsFound;

  /// No description provided for @failedToLoadCrops.
  ///
  /// In en, this message translates to:
  /// **'Failed to load crops:'**
  String get failedToLoadCrops;

  /// No description provided for @seasonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get seasonAll;

  /// No description provided for @seasonKharif.
  ///
  /// In en, this message translates to:
  /// **'Kharif'**
  String get seasonKharif;

  /// No description provided for @seasonRabi.
  ///
  /// In en, this message translates to:
  /// **'Rabi'**
  String get seasonRabi;

  /// No description provided for @seasonZaid.
  ///
  /// In en, this message translates to:
  /// **'Zaid'**
  String get seasonZaid;

  /// No description provided for @clearSearchPrefix.
  ///
  /// In en, this message translates to:
  /// **'Clear Search:'**
  String get clearSearchPrefix;

  /// No description provided for @noCropsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No crops match your search'**
  String get noCropsMatchSearch;

  /// No description provided for @tryDifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearchTerm;

  /// No description provided for @daysLabel.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysLabel;

  /// No description provided for @detailDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'🌾 Description'**
  String get detailDescriptionTitle;

  /// No description provided for @detailGrowingInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'📊 Growing Information'**
  String get detailGrowingInfoTitle;

  /// No description provided for @detailSowingHarvestingTitle.
  ///
  /// In en, this message translates to:
  /// **'📅 Sowing & Harvesting'**
  String get detailSowingHarvestingTitle;

  /// No description provided for @detailCommonVarietiesTitle.
  ///
  /// In en, this message translates to:
  /// **'🌱 Common Varieties'**
  String get detailCommonVarietiesTitle;

  /// No description provided for @detailHealthBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'💚 Health Benefits'**
  String get detailHealthBenefitsTitle;

  /// No description provided for @detailCompanionCropsTitle.
  ///
  /// In en, this message translates to:
  /// **'🤝 Companion Crops'**
  String get detailCompanionCropsTitle;

  /// No description provided for @detailAvoidCropsTitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Crops to Avoid'**
  String get detailAvoidCropsTitle;

  /// No description provided for @detailFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get detailFamily;

  /// No description provided for @detailGrowingSeason.
  ///
  /// In en, this message translates to:
  /// **'Growing Season'**
  String get detailGrowingSeason;

  /// No description provided for @detailGrowingPeriod.
  ///
  /// In en, this message translates to:
  /// **'Growing Period'**
  String get detailGrowingPeriod;

  /// No description provided for @detailWaterRequirement.
  ///
  /// In en, this message translates to:
  /// **'Water Requirement'**
  String get detailWaterRequirement;

  /// No description provided for @detailSoilType.
  ///
  /// In en, this message translates to:
  /// **'Soil Type'**
  String get detailSoilType;

  /// No description provided for @detailTemperatureRange.
  ///
  /// In en, this message translates to:
  /// **'Temperature Range'**
  String get detailTemperatureRange;

  /// No description provided for @detailExpectedYield.
  ///
  /// In en, this message translates to:
  /// **'Expected Yield'**
  String get detailExpectedYield;

  /// No description provided for @detailSowingMonths.
  ///
  /// In en, this message translates to:
  /// **'Sowing Months'**
  String get detailSowingMonths;

  /// No description provided for @detailHarvestingMonths.
  ///
  /// In en, this message translates to:
  /// **'Harvesting Months'**
  String get detailHarvestingMonths;

  /// No description provided for @cultivationTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cultivation Tips'**
  String get cultivationTipsTitle;

  /// No description provided for @searchCultivationTipsHint.
  ///
  /// In en, this message translates to:
  /// **'Search cultivation tips...'**
  String get searchCultivationTipsHint;

  /// No description provided for @loadingCultivationTips.
  ///
  /// In en, this message translates to:
  /// **'Loading cultivation tips...'**
  String get loadingCultivationTips;

  /// No description provided for @noCultivationTipsFound.
  ///
  /// In en, this message translates to:
  /// **'No cultivation tips found'**
  String get noCultivationTipsFound;

  /// No description provided for @failedToLoadTips.
  ///
  /// In en, this message translates to:
  /// **'Failed to load tips:'**
  String get failedToLoadTips;

  /// No description provided for @noTipsFound.
  ///
  /// In en, this message translates to:
  /// **'No tips found'**
  String get noTipsFound;

  /// No description provided for @tryDifferentCategory.
  ///
  /// In en, this message translates to:
  /// **'Try selecting a different category'**
  String get tryDifferentCategory;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @clearAllFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear All Filters'**
  String get clearAllFilters;

  /// No description provided for @showingTipsCount.
  ///
  /// In en, this message translates to:
  /// **'Showing {count} of {total} tips'**
  String showingTipsCount(Object count, Object total);

  /// No description provided for @minutesUnit.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesUnit;

  /// No description provided for @stepsUnit.
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get stepsUnit;

  /// No description provided for @shareFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Share feature coming soon'**
  String get shareFeatureComingSoon;

  /// No description provided for @timeRequired.
  ///
  /// In en, this message translates to:
  /// **'Time Required'**
  String get timeRequired;

  /// No description provided for @difficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficultyLabel;

  /// No description provided for @bestSeason.
  ///
  /// In en, this message translates to:
  /// **'Best Season'**
  String get bestSeason;

  /// No description provided for @sectionDescription.
  ///
  /// In en, this message translates to:
  /// **'📖 Description'**
  String get sectionDescription;

  /// No description provided for @sectionStepByStepGuide.
  ///
  /// In en, this message translates to:
  /// **'📋 Step-by-Step Guide'**
  String get sectionStepByStepGuide;

  /// No description provided for @sectionBenefits.
  ///
  /// In en, this message translates to:
  /// **'✅ Benefits'**
  String get sectionBenefits;

  /// No description provided for @sectionMaterialsRequired.
  ///
  /// In en, this message translates to:
  /// **'🛠️ Materials Required'**
  String get sectionMaterialsRequired;

  /// No description provided for @pestsDiseasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Pests & Diseases'**
  String get pestsDiseasesTitle;

  /// No description provided for @searchPestsDiseasesHint.
  ///
  /// In en, this message translates to:
  /// **'Search pests or diseases...'**
  String get searchPestsDiseasesHint;

  /// No description provided for @tabPests.
  ///
  /// In en, this message translates to:
  /// **'Pests'**
  String get tabPests;

  /// No description provided for @tabDiseases.
  ///
  /// In en, this message translates to:
  /// **'Diseases'**
  String get tabDiseases;

  /// No description provided for @noPestsFound.
  ///
  /// In en, this message translates to:
  /// **'No pests found'**
  String get noPestsFound;

  /// No description provided for @noDiseasesFound.
  ///
  /// In en, this message translates to:
  /// **'No diseases found'**
  String get noDiseasesFound;

  /// No description provided for @failedToLoadPests.
  ///
  /// In en, this message translates to:
  /// **'Failed to load pests:'**
  String get failedToLoadPests;

  /// No description provided for @failedToLoadDiseases.
  ///
  /// In en, this message translates to:
  /// **'Failed to load diseases:'**
  String get failedToLoadDiseases;

  /// No description provided for @searchResultsPests.
  ///
  /// In en, this message translates to:
  /// **'Search results: {count} pests found'**
  String searchResultsPests(Object count);

  /// No description provided for @searchResultsDiseases.
  ///
  /// In en, this message translates to:
  /// **'Search results: {count} diseases found'**
  String searchResultsDiseases(Object count);

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @cropsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} crops'**
  String cropsCount(Object count);

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @severityLabel.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severityLabel;

  /// No description provided for @sectionSymptoms.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Symptoms'**
  String get sectionSymptoms;

  /// No description provided for @sectionOrganicControl.
  ///
  /// In en, this message translates to:
  /// **'🌱 Organic Control'**
  String get sectionOrganicControl;

  /// No description provided for @sectionChemicalControl.
  ///
  /// In en, this message translates to:
  /// **'🧪 Chemical Control'**
  String get sectionChemicalControl;

  /// No description provided for @sectionPreventiveMeasures.
  ///
  /// In en, this message translates to:
  /// **'🛡️ Preventive Measures'**
  String get sectionPreventiveMeasures;

  /// No description provided for @sectionAffectedCrops.
  ///
  /// In en, this message translates to:
  /// **'🌾 Affected Crops'**
  String get sectionAffectedCrops;

  /// No description provided for @sectionFavorableConditions.
  ///
  /// In en, this message translates to:
  /// **'🌡️ Favorable Conditions'**
  String get sectionFavorableConditions;

  /// No description provided for @cropRecommendationAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop Recommendation'**
  String get cropRecommendationAppBarTitle;

  /// No description provided for @newRecommendationTooltip.
  ///
  /// In en, this message translates to:
  /// **'New Recommendation'**
  String get newRecommendationTooltip;

  /// No description provided for @analyzingFarmData.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your farm data...'**
  String get analyzingFarmData;

  /// No description provided for @aiPoweredRecommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Recommendations'**
  String get aiPoweredRecommendationsTitle;

  /// No description provided for @aiPoweredRecommendationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get personalized crop suggestions based on your farm conditions'**
  String get aiPoweredRecommendationsSubtitle;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @soilTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Soil Type'**
  String get soilTypeLabel;

  /// No description provided for @waterAvailabilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Water Availability'**
  String get waterAvailabilityLabel;

  /// No description provided for @seasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get seasonLabel;

  /// No description provided for @previousCropLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous Crop'**
  String get previousCropLabel;

  /// No description provided for @goalLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goalLabel;

  /// No description provided for @getRecommendationsButton.
  ///
  /// In en, this message translates to:
  /// **'Get Recommendations'**
  String get getRecommendationsButton;

  /// No description provided for @recommendedForYouBadge.
  ///
  /// In en, this message translates to:
  /// **'⭐ RECOMMENDED FOR YOU'**
  String get recommendedForYouBadge;

  /// No description provided for @bestMatchBadge.
  ///
  /// In en, this message translates to:
  /// **'Best Match'**
  String get bestMatchBadge;

  /// No description provided for @otherSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Other Suggestions'**
  String get otherSuggestionsTitle;

  /// No description provided for @inputSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Input Summary'**
  String get inputSummaryTitle;

  /// No description provided for @newAnalysisButton.
  ///
  /// In en, this message translates to:
  /// **'New Analysis'**
  String get newAnalysisButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @suggestionSubtext.
  ///
  /// In en, this message translates to:
  /// **'Good alternative for your farm conditions'**
  String get suggestionSubtext;

  /// No description provided for @soilTypeAlluvial.
  ///
  /// In en, this message translates to:
  /// **'Alluvial'**
  String get soilTypeAlluvial;

  /// No description provided for @soilTypeBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get soilTypeBlack;

  /// No description provided for @soilTypeClay.
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get soilTypeClay;

  /// No description provided for @soilTypeLaterite.
  ///
  /// In en, this message translates to:
  /// **'Laterite'**
  String get soilTypeLaterite;

  /// No description provided for @soilTypeLoamy.
  ///
  /// In en, this message translates to:
  /// **'Loamy'**
  String get soilTypeLoamy;

  /// No description provided for @soilTypeRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get soilTypeRed;

  /// No description provided for @soilTypeSandy.
  ///
  /// In en, this message translates to:
  /// **'Sandy'**
  String get soilTypeSandy;

  /// No description provided for @waterHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get waterHigh;

  /// No description provided for @waterLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get waterLow;

  /// No description provided for @waterMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get waterMedium;

  /// No description provided for @waterVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very High'**
  String get waterVeryHigh;

  /// No description provided for @seasonSummer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get seasonSummer;

  /// No description provided for @previousCropNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get previousCropNone;

  /// No description provided for @previousCropBajra.
  ///
  /// In en, this message translates to:
  /// **'Bajra'**
  String get previousCropBajra;

  /// No description provided for @previousCropChickpea.
  ///
  /// In en, this message translates to:
  /// **'Chickpea'**
  String get previousCropChickpea;

  /// No description provided for @previousCropCotton.
  ///
  /// In en, this message translates to:
  /// **'Cotton'**
  String get previousCropCotton;

  /// No description provided for @previousCropGroundnut.
  ///
  /// In en, this message translates to:
  /// **'Groundnut'**
  String get previousCropGroundnut;

  /// No description provided for @previousCropJowar.
  ///
  /// In en, this message translates to:
  /// **'Jowar'**
  String get previousCropJowar;

  /// No description provided for @previousCropMaize.
  ///
  /// In en, this message translates to:
  /// **'Maize'**
  String get previousCropMaize;

  /// No description provided for @previousCropRice.
  ///
  /// In en, this message translates to:
  /// **'Rice'**
  String get previousCropRice;

  /// No description provided for @previousCropSoybean.
  ///
  /// In en, this message translates to:
  /// **'Soybean'**
  String get previousCropSoybean;

  /// No description provided for @previousCropSugarcane.
  ///
  /// In en, this message translates to:
  /// **'Sugarcane'**
  String get previousCropSugarcane;

  /// No description provided for @previousCropTur.
  ///
  /// In en, this message translates to:
  /// **'Tur'**
  String get previousCropTur;

  /// No description provided for @previousCropWheat.
  ///
  /// In en, this message translates to:
  /// **'Wheat'**
  String get previousCropWheat;

  /// No description provided for @goalFastGrowth.
  ///
  /// In en, this message translates to:
  /// **'Fast Growth'**
  String get goalFastGrowth;

  /// No description provided for @goalHighYield.
  ///
  /// In en, this message translates to:
  /// **'High Yield'**
  String get goalHighYield;

  /// No description provided for @goalLowCost.
  ///
  /// In en, this message translates to:
  /// **'Low Cost'**
  String get goalLowCost;

  /// No description provided for @goalProfit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get goalProfit;

  /// No description provided for @fertilizerRecommendationAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer Recommendation'**
  String get fertilizerRecommendationAppBarTitle;

  /// No description provided for @analyzingCropText.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your crop...'**
  String get analyzingCropText;

  /// No description provided for @aiPoweredAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Analysis'**
  String get aiPoweredAnalysisTitle;

  /// No description provided for @aiPoweredAnalysisSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get precise fertilizer recommendations based on your crop conditions'**
  String get aiPoweredAnalysisSubtitle;

  /// No description provided for @cropTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Crop Type'**
  String get cropTypeLabel;

  /// No description provided for @cropAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Crop Age (Days)'**
  String get cropAgeLabel;

  /// No description provided for @growthStageLabel.
  ///
  /// In en, this message translates to:
  /// **'Growth Stage'**
  String get growthStageLabel;

  /// No description provided for @plantConditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Plant Condition'**
  String get plantConditionLabel;

  /// No description provided for @irrigationTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Irrigation Type'**
  String get irrigationTypeLabel;

  /// No description provided for @temperatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Temperature (°C)'**
  String get temperatureLabel;

  /// No description provided for @soilMoistureLabel.
  ///
  /// In en, this message translates to:
  /// **'Soil Moisture'**
  String get soilMoistureLabel;

  /// No description provided for @getFertilizerRecommendationButton.
  ///
  /// In en, this message translates to:
  /// **'Get Fertilizer Recommendation'**
  String get getFertilizerRecommendationButton;

  /// No description provided for @applicationDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Details'**
  String get applicationDetailsTitle;

  /// No description provided for @fertilizerLabel.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer'**
  String get fertilizerLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @recommendationLabel.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recommendationLabel;

  /// No description provided for @savedMessage.
  ///
  /// In en, this message translates to:
  /// **'Recommendation saved!'**
  String get savedMessage;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get errorPrefix;

  /// No description provided for @cropBajra.
  ///
  /// In en, this message translates to:
  /// **'Bajra'**
  String get cropBajra;

  /// No description provided for @cropChickpea.
  ///
  /// In en, this message translates to:
  /// **'Chickpea'**
  String get cropChickpea;

  /// No description provided for @cropCotton.
  ///
  /// In en, this message translates to:
  /// **'Cotton'**
  String get cropCotton;

  /// No description provided for @cropGrapes.
  ///
  /// In en, this message translates to:
  /// **'Grapes'**
  String get cropGrapes;

  /// No description provided for @cropGroundnut.
  ///
  /// In en, this message translates to:
  /// **'Groundnut'**
  String get cropGroundnut;

  /// No description provided for @cropJowar.
  ///
  /// In en, this message translates to:
  /// **'Jowar'**
  String get cropJowar;

  /// No description provided for @cropMaize.
  ///
  /// In en, this message translates to:
  /// **'Maize'**
  String get cropMaize;

  /// No description provided for @cropMillet.
  ///
  /// In en, this message translates to:
  /// **'Millet'**
  String get cropMillet;

  /// No description provided for @cropOnion.
  ///
  /// In en, this message translates to:
  /// **'Onion'**
  String get cropOnion;

  /// No description provided for @cropPomegranate.
  ///
  /// In en, this message translates to:
  /// **'Pomegranate'**
  String get cropPomegranate;

  /// No description provided for @cropPotato.
  ///
  /// In en, this message translates to:
  /// **'Potato'**
  String get cropPotato;

  /// No description provided for @cropRice.
  ///
  /// In en, this message translates to:
  /// **'Rice'**
  String get cropRice;

  /// No description provided for @cropSoybean.
  ///
  /// In en, this message translates to:
  /// **'Soybean'**
  String get cropSoybean;

  /// No description provided for @cropSugarcane.
  ///
  /// In en, this message translates to:
  /// **'Sugarcane'**
  String get cropSugarcane;

  /// No description provided for @cropSunflower.
  ///
  /// In en, this message translates to:
  /// **'Sunflower'**
  String get cropSunflower;

  /// No description provided for @cropTomato.
  ///
  /// In en, this message translates to:
  /// **'Tomato'**
  String get cropTomato;

  /// No description provided for @cropTur.
  ///
  /// In en, this message translates to:
  /// **'Tur'**
  String get cropTur;

  /// No description provided for @cropWheat.
  ///
  /// In en, this message translates to:
  /// **'Wheat'**
  String get cropWheat;

  /// No description provided for @stageSeedling.
  ///
  /// In en, this message translates to:
  /// **'Seedling'**
  String get stageSeedling;

  /// No description provided for @stageVegetative.
  ///
  /// In en, this message translates to:
  /// **'Vegetative'**
  String get stageVegetative;

  /// No description provided for @stageFlowering.
  ///
  /// In en, this message translates to:
  /// **'Flowering'**
  String get stageFlowering;

  /// No description provided for @stageFruiting.
  ///
  /// In en, this message translates to:
  /// **'Fruiting'**
  String get stageFruiting;

  /// No description provided for @stageMaturity.
  ///
  /// In en, this message translates to:
  /// **'Maturity'**
  String get stageMaturity;

  /// No description provided for @soilAlluvial.
  ///
  /// In en, this message translates to:
  /// **'Alluvial'**
  String get soilAlluvial;

  /// No description provided for @soilBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get soilBlack;

  /// No description provided for @soilClay.
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get soilClay;

  /// No description provided for @soilLoamy.
  ///
  /// In en, this message translates to:
  /// **'Loamy'**
  String get soilLoamy;

  /// No description provided for @soilRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get soilRed;

  /// No description provided for @soilSandy.
  ///
  /// In en, this message translates to:
  /// **'Sandy'**
  String get soilSandy;

  /// No description provided for @conditionHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get conditionHealthy;

  /// No description provided for @conditionSlowGrowth.
  ///
  /// In en, this message translates to:
  /// **'Slow growth'**
  String get conditionSlowGrowth;

  /// No description provided for @conditionYellowLeaves.
  ///
  /// In en, this message translates to:
  /// **'Yellow leaves'**
  String get conditionYellowLeaves;

  /// No description provided for @conditionPaleLeaves.
  ///
  /// In en, this message translates to:
  /// **'Pale leaves'**
  String get conditionPaleLeaves;

  /// No description provided for @conditionBrownSpots.
  ///
  /// In en, this message translates to:
  /// **'Brown spots'**
  String get conditionBrownSpots;

  /// No description provided for @conditionWeakStem.
  ///
  /// In en, this message translates to:
  /// **'Weak stem'**
  String get conditionWeakStem;

  /// No description provided for @irrigationCanal.
  ///
  /// In en, this message translates to:
  /// **'Canal'**
  String get irrigationCanal;

  /// No description provided for @irrigationBorewell.
  ///
  /// In en, this message translates to:
  /// **'Borewell'**
  String get irrigationBorewell;

  /// No description provided for @irrigationDrip.
  ///
  /// In en, this message translates to:
  /// **'Drip'**
  String get irrigationDrip;

  /// No description provided for @irrigationSprinkler.
  ///
  /// In en, this message translates to:
  /// **'Sprinkler'**
  String get irrigationSprinkler;

  /// No description provided for @irrigationRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get irrigationRain;

  /// No description provided for @moistureLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get moistureLow;

  /// No description provided for @moistureMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get moistureMedium;

  /// No description provided for @moistureHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get moistureHigh;

  /// No description provided for @smartFarmingToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Farming Tools'**
  String get smartFarmingToolsTitle;

  /// No description provided for @aiPoweredRecommendationsSubtitleHS.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Recommendations'**
  String get aiPoweredRecommendationsSubtitleHS;

  /// No description provided for @knowledgeHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Hub'**
  String get knowledgeHubTitle;

  /// No description provided for @agricultureNewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Agriculture News'**
  String get agricultureNewsTitle;

  /// No description provided for @refreshNewsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh News'**
  String get refreshNewsTooltip;

  /// No description provided for @viewAllLabel.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAllLabel;

  /// No description provided for @pestDetectionAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Pest & Disease Detection'**
  String get pestDetectionAppBarTitle;

  /// No description provided for @newDetectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'New Detection'**
  String get newDetectionTooltip;

  /// No description provided for @aiPoweredBadge.
  ///
  /// In en, this message translates to:
  /// **'AI POWERED'**
  String get aiPoweredBadge;

  /// No description provided for @smartPestDetectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Pest Detection'**
  String get smartPestDetectionTitle;

  /// No description provided for @smartPestDetectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload a photo of affected crops and our AI will instantly identify diseases, suggest treatments, and provide prevention tips.'**
  String get smartPestDetectionDescription;

  /// No description provided for @featureFastAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Fast Analysis'**
  String get featureFastAnalysis;

  /// No description provided for @featureTreatmentPlans.
  ///
  /// In en, this message translates to:
  /// **'Treatment Plans'**
  String get featureTreatmentPlans;

  /// No description provided for @featureVoiceOutput.
  ///
  /// In en, this message translates to:
  /// **'Voice Output'**
  String get featureVoiceOutput;

  /// No description provided for @uploadOrTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload or take a photo'**
  String get uploadOrTakePhoto;

  /// No description provided for @ofAffectedCropForAnalysis.
  ///
  /// In en, this message translates to:
  /// **'of affected crop for analysis'**
  String get ofAffectedCropForAnalysis;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @analyzingImage.
  ///
  /// In en, this message translates to:
  /// **'Analyzing image...'**
  String get analyzingImage;

  /// No description provided for @detectedDiseaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Detected Disease'**
  String get detectedDiseaseLabel;

  /// No description provided for @severityLabelPDS.
  ///
  /// In en, this message translates to:
  /// **'Severity:'**
  String get severityLabelPDS;

  /// No description provided for @recommendedSolutionTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended Solution'**
  String get recommendedSolutionTitle;

  /// No description provided for @preventionTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Prevention Tips'**
  String get preventionTipsTitle;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image:'**
  String get errorPickingImage;

  /// No description provided for @failedToAnalyzeImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to analyze image. Please check your internet connection and try again.'**
  String get failedToAnalyzeImage;

  /// No description provided for @failedToAnalyzeImageShort.
  ///
  /// In en, this message translates to:
  /// **'Failed to analyze image. Please try again.'**
  String get failedToAnalyzeImageShort;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get profileUpdated;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profileUpdateFailed;

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated!'**
  String get profilePictureUpdated;

  /// No description provided for @profilePictureUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile picture'**
  String get profilePictureUpdateFailed;

  /// No description provided for @uploadingProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Uploading profile picture...'**
  String get uploadingProfilePicture;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection'**
  String get checkConnection;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @mobileNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumberLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @talukaLabel.
  ///
  /// In en, this message translates to:
  /// **'Taluka'**
  String get talukaLabel;

  /// No description provided for @districtLabel.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get districtLabel;

  /// No description provided for @stateLabel.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get stateLabel;

  /// No description provided for @pincodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get pincodeLabel;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @personalInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformationTitle;

  /// No description provided for @addressDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Address Details'**
  String get addressDetailsTitle;

  /// No description provided for @streetAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get streetAddressLabel;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enterFullName;

  /// No description provided for @enterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter mobile number'**
  String get enterMobileNumber;

  /// No description provided for @invalidMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidMobileNumber;

  /// No description provided for @noCropsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No Crops Added Yet'**
  String get noCropsAddedYet;

  /// No description provided for @tapAddFirstCrop.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first crop'**
  String get tapAddFirstCrop;

  /// No description provided for @cropAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{cropName} added successfully!'**
  String cropAddedSuccessfully(String cropName);

  /// No description provided for @failedToLoadCropsCS.
  ///
  /// In en, this message translates to:
  /// **'Failed to load crops'**
  String get failedToLoadCropsCS;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{0 days} =1{1 day} other{{count} days}}'**
  String daysCount(int count);

  /// No description provided for @acresCount.
  ///
  /// In en, this message translates to:
  /// **'{area,plural, =1{1 acre} other{{area} acres}}'**
  String acresCount(num area);

  /// No description provided for @acresUnit.
  ///
  /// In en, this message translates to:
  /// **'acres'**
  String get acresUnit;

  /// No description provided for @addNewCrop.
  ///
  /// In en, this message translates to:
  /// **'Add New Crop'**
  String get addNewCrop;

  /// No description provided for @editCrop.
  ///
  /// In en, this message translates to:
  /// **'Edit {cropName}'**
  String editCrop(String cropName);

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @farmConditions.
  ///
  /// In en, this message translates to:
  /// **'Farm Conditions'**
  String get farmConditions;

  /// No description provided for @currentCropStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Crop Status'**
  String get currentCropStatus;

  /// No description provided for @cropNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Crop Name'**
  String get cropNameLabel;

  /// No description provided for @varietyLabel.
  ///
  /// In en, this message translates to:
  /// **'Variety'**
  String get varietyLabel;

  /// No description provided for @sowingDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Sowing Date'**
  String get sowingDateLabel;

  /// No description provided for @fieldAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Field Area'**
  String get fieldAreaLabel;

  /// No description provided for @healthStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Health Status'**
  String get healthStatusLabel;

  /// No description provided for @lastFertilizerLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Fertilizer Used'**
  String get lastFertilizerLabel;

  /// No description provided for @selectCropTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select crop type'**
  String get selectCropTypeHint;

  /// No description provided for @varietyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Arka Vikas, HD-2967'**
  String get varietyHint;

  /// No description provided for @enterAreaHint.
  ///
  /// In en, this message translates to:
  /// **'Enter area in acres'**
  String get enterAreaHint;

  /// No description provided for @selectSoilTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select soil type'**
  String get selectSoilTypeHint;

  /// No description provided for @selectIrrigationHint.
  ///
  /// In en, this message translates to:
  /// **'Select irrigation method'**
  String get selectIrrigationHint;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Pune, Maharashtra'**
  String get locationHint;

  /// No description provided for @selectGrowthStageHint.
  ///
  /// In en, this message translates to:
  /// **'Select current growth stage'**
  String get selectGrowthStageHint;

  /// No description provided for @selectHealthStatusHint.
  ///
  /// In en, this message translates to:
  /// **'Select current health status'**
  String get selectHealthStatusHint;

  /// No description provided for @lastFertilizerHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Urea, DAP, Potash'**
  String get lastFertilizerHint;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @pleaseSelectCrop.
  ///
  /// In en, this message translates to:
  /// **'Please select a crop'**
  String get pleaseSelectCrop;

  /// No description provided for @pleaseEnterArea.
  ///
  /// In en, this message translates to:
  /// **'Please enter area'**
  String get pleaseEnterArea;

  /// No description provided for @enterValidPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive number'**
  String get enterValidPositiveNumber;

  /// No description provided for @addCropButton.
  ///
  /// In en, this message translates to:
  /// **'ADD CROP'**
  String get addCropButton;

  /// No description provided for @updateCropButton.
  ///
  /// In en, this message translates to:
  /// **'UPDATE CROP'**
  String get updateCropButton;

  /// No description provided for @editCropTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Crop'**
  String get editCropTooltip;

  /// No description provided for @deleteCropTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Crop'**
  String get deleteCropTooltip;

  /// No description provided for @cropUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{cropName} updated successfully!'**
  String cropUpdatedSuccessfully(String cropName);

  /// No description provided for @cropDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{cropName} deleted'**
  String cropDeletedSuccessfully(String cropName);

  /// No description provided for @deleteCropTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Crop'**
  String get deleteCropTitle;

  /// No description provided for @deleteCropConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{cropName}\"? This action cannot be undone.'**
  String deleteCropConfirmation(String cropName);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @fieldInformation.
  ///
  /// In en, this message translates to:
  /// **'Field Information'**
  String get fieldInformation;

  /// No description provided for @growthInformation.
  ///
  /// In en, this message translates to:
  /// **'Growth Information'**
  String get growthInformation;

  /// No description provided for @growthTimeline.
  ///
  /// In en, this message translates to:
  /// **'Growth Timeline'**
  String get growthTimeline;

  /// No description provided for @fieldAreaLabelDetail.
  ///
  /// In en, this message translates to:
  /// **'Field Area'**
  String get fieldAreaLabelDetail;

  /// No description provided for @soilTypeLabelDetail.
  ///
  /// In en, this message translates to:
  /// **'Soil Type'**
  String get soilTypeLabelDetail;

  /// No description provided for @irrigationTypeLabelDetail.
  ///
  /// In en, this message translates to:
  /// **'Irrigation Type'**
  String get irrigationTypeLabelDetail;

  /// No description provided for @locationLabelDetail.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabelDetail;

  /// No description provided for @lastFertilizerLabelDetail.
  ///
  /// In en, this message translates to:
  /// **'Last Fertilizer'**
  String get lastFertilizerLabelDetail;

  /// No description provided for @currentGrowthStageLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Growth Stage'**
  String get currentGrowthStageLabel;

  /// No description provided for @daysSinceSowingLabel.
  ///
  /// In en, this message translates to:
  /// **'Days Since Sowing'**
  String get daysSinceSowingLabel;

  /// No description provided for @sownWithDateAndDays.
  ///
  /// In en, this message translates to:
  /// **'Sown: {date} ({days} days ago)'**
  String sownWithDateAndDays(String date, int days);

  /// No description provided for @dayWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String dayWithNumber(int day);

  /// No description provided for @germinationStage.
  ///
  /// In en, this message translates to:
  /// **'Germination'**
  String get germinationStage;

  /// No description provided for @vegetativeStage.
  ///
  /// In en, this message translates to:
  /// **'Vegetative'**
  String get vegetativeStage;

  /// No description provided for @floweringStage.
  ///
  /// In en, this message translates to:
  /// **'Flowering'**
  String get floweringStage;

  /// No description provided for @fruitingStage.
  ///
  /// In en, this message translates to:
  /// **'Fruiting'**
  String get fruitingStage;

  /// No description provided for @harvestingStage.
  ///
  /// In en, this message translates to:
  /// **'Harvesting'**
  String get harvestingStage;

  /// No description provided for @harvest.
  ///
  /// In en, this message translates to:
  /// **'Harvest'**
  String get harvest;

  /// No description provided for @blackSoil.
  ///
  /// In en, this message translates to:
  /// **'Black Soil'**
  String get blackSoil;

  /// No description provided for @redSoil.
  ///
  /// In en, this message translates to:
  /// **'Red Soil'**
  String get redSoil;

  /// No description provided for @sandySoil.
  ///
  /// In en, this message translates to:
  /// **'Sandy Soil'**
  String get sandySoil;

  /// No description provided for @claySoil.
  ///
  /// In en, this message translates to:
  /// **'Clay Soil'**
  String get claySoil;

  /// No description provided for @loamySoil.
  ///
  /// In en, this message translates to:
  /// **'Loamy Soil'**
  String get loamySoil;

  /// No description provided for @dripIrrigation.
  ///
  /// In en, this message translates to:
  /// **'Drip Irrigation'**
  String get dripIrrigation;

  /// No description provided for @sprinklerSystem.
  ///
  /// In en, this message translates to:
  /// **'Sprinkler System'**
  String get sprinklerSystem;

  /// No description provided for @canalWater.
  ///
  /// In en, this message translates to:
  /// **'Canal Water'**
  String get canalWater;

  /// No description provided for @rainfed.
  ///
  /// In en, this message translates to:
  /// **'Rainfed'**
  String get rainfed;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @minorIssues.
  ///
  /// In en, this message translates to:
  /// **'Minor Issues'**
  String get minorIssues;

  /// No description provided for @majorIssues.
  ///
  /// In en, this message translates to:
  /// **'Major Issues'**
  String get majorIssues;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @aiTyping.
  ///
  /// In en, this message translates to:
  /// **'NeuralField AI is typing...'**
  String get aiTyping;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get aiThinking;

  /// No description provided for @aiGreeting.
  ///
  /// In en, this message translates to:
  /// **'Namaste! I\'m NeuralField AI, your AI farming assistant! How can I help you with your crops today?'**
  String get aiGreeting;

  /// No description provided for @promptInstruction.
  ///
  /// In en, this message translates to:
  /// **'Please respond in English.'**
  String get promptInstruction;

  /// No description provided for @micPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required'**
  String get micPermissionRequired;

  /// No description provided for @micPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied'**
  String get micPermissionDenied;

  /// No description provided for @speechUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech not available'**
  String get speechUnavailable;

  /// No description provided for @speechErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get speechErrorPrefix;

  /// No description provided for @ttsError.
  ///
  /// In en, this message translates to:
  /// **'Could not speak text'**
  String get ttsError;

  /// No description provided for @pleaseEnterMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a message'**
  String get pleaseEnterMessage;

  /// No description provided for @listeningHint.
  ///
  /// In en, this message translates to:
  /// **'🎤 Listening... Tap pause to stop'**
  String get listeningHint;

  /// No description provided for @listeningHintField.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listeningHintField;

  /// No description provided for @typeHint.
  ///
  /// In en, this message translates to:
  /// **'Type your farming problem...'**
  String get typeHint;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Error: Unknown error'**
  String get errorUnknown;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Connection failed. Please check your internet.'**
  String get connectionFailed;

  /// No description provided for @neural.
  ///
  /// In en, this message translates to:
  /// **'Neural'**
  String get neural;

  /// No description provided for @field.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get field;

  /// No description provided for @forgotPasswordTagline.
  ///
  /// In en, this message translates to:
  /// **'We\'ll help you recover your account'**
  String get forgotPasswordTagline;

  /// No description provided for @resetPasswordTagline.
  ///
  /// In en, this message translates to:
  /// **'Set up your new password'**
  String get resetPasswordTagline;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmail;

  /// No description provided for @validEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 4 characters'**
  String get passwordMinLength;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Your Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you an OTP to reset your password.'**
  String get resetPasswordDescription;

  /// No description provided for @sendOtpButton.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtpButton;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password? '**
  String get rememberPassword;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @createNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get createNewPasswordTitle;

  /// No description provided for @createNewPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP sent to {email} and create a new password.'**
  String createNewPasswordDescription(Object email);

  /// No description provided for @otpLabel.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get otpLabel;

  /// No description provided for @otpHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get otpHint;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter OTP'**
  String get enterOtp;

  /// No description provided for @otpLength.
  ///
  /// In en, this message translates to:
  /// **'OTP must be 6 digits'**
  String get otpLength;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get newPasswordHint;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get enterNewPassword;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmPasswordHint;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordButton;

  /// No description provided for @didNotReceiveOtp.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive OTP? '**
  String get didNotReceiveOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @useDifferentEmail.
  ///
  /// In en, this message translates to:
  /// **'Use different email'**
  String get useDifferentEmail;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful! Welcome back!'**
  String get loginSuccess;

  /// No description provided for @otpSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully! Check your email.'**
  String get otpSentSuccess;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successful! Please login.'**
  String get resetPasswordSuccess;

  /// No description provided for @otpResentSuccess.
  ///
  /// In en, this message translates to:
  /// **'OTP resent successfully! Check your email.'**
  String get otpResentSuccess;

  /// No description provided for @errorResendingOtp.
  ///
  /// In en, this message translates to:
  /// **'Error resending OTP:'**
  String get errorResendingOtp;

  /// No description provided for @startSmartFarmingJourney.
  ///
  /// In en, this message translates to:
  /// **'Start your smart farming journey'**
  String get startSmartFarmingJourney;

  /// No description provided for @verifyExistingTagline.
  ///
  /// In en, this message translates to:
  /// **'Complete your verification process'**
  String get verifyExistingTagline;

  /// No description provided for @enterOtpTagline.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP sent to your email'**
  String get enterOtpTagline;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a username'**
  String get usernameHint;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get enterUsername;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameMinLength;

  /// No description provided for @passwordHintRegister.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get passwordHintRegister;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @verifyExistingAccountLink.
  ///
  /// In en, this message translates to:
  /// **'Verify existing account'**
  String get verifyExistingAccountLink;

  /// No description provided for @verifyExistingDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive verification OTP'**
  String get verifyExistingDescription;

  /// No description provided for @verifyAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Verify Account'**
  String get verifyAccountButton;

  /// No description provided for @backToRegistration.
  ///
  /// In en, this message translates to:
  /// **'Back to Registration'**
  String get backToRegistration;

  /// No description provided for @otpSentToEmailVerify.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your email! Please verify.'**
  String get otpSentToEmailVerify;

  /// No description provided for @accountAlreadyExistsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Already Exists'**
  String get accountAlreadyExistsTitle;

  /// No description provided for @accountAlreadyExistsMessage.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists but is not verified. Would you like to verify it now?'**
  String get accountAlreadyExistsMessage;

  /// No description provided for @verifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify Account'**
  String get verifyAccount;

  /// No description provided for @verificationOtpSent.
  ///
  /// In en, this message translates to:
  /// **'Verification OTP sent to your email!'**
  String get verificationOtpSent;

  /// No description provided for @otpInvalidLength.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 6-digit OTP'**
  String get otpInvalidLength;

  /// No description provided for @accountVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account verified successfully! Please login.'**
  String get accountVerifiedSuccess;

  /// No description provided for @unableToResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Unable to resend OTP. Please try again.'**
  String get unableToResendOtp;

  /// No description provided for @otpResentSuccessRegister.
  ///
  /// In en, this message translates to:
  /// **'OTP resent successfully! Check your email.'**
  String get otpResentSuccessRegister;

  /// No description provided for @accountVerifiedAndLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Account verified and logged in successfully!'**
  String get accountVerifiedAndLoggedIn;

  /// No description provided for @accountVerifiedPleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Account verified! Please login.'**
  String get accountVerifiedPleaseLogin;

  /// No description provided for @enterOtpDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit OTP sent to'**
  String get enterOtpDescription;

  /// No description provided for @verifyOtpButton.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtpButton;

  /// No description provided for @refreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshTooltip;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @badgeCount.
  ///
  /// In en, this message translates to:
  /// **'3'**
  String get badgeCount;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @selectState.
  ///
  /// In en, this message translates to:
  /// **'Select State'**
  String get selectState;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get selectDistrict;

  /// No description provided for @selectCommodityOptional.
  ///
  /// In en, this message translates to:
  /// **'Select Commodity (Optional)'**
  String get selectCommodityOptional;

  /// No description provided for @topGainer.
  ///
  /// In en, this message translates to:
  /// **'Top Gainer'**
  String get topGainer;

  /// No description provided for @topLoser.
  ///
  /// In en, this message translates to:
  /// **'Top Loser'**
  String get topLoser;

  /// No description provided for @marketOverview.
  ///
  /// In en, this message translates to:
  /// **'Market Overview'**
  String get marketOverview;

  /// No description provided for @commodities.
  ///
  /// In en, this message translates to:
  /// **'Commodities'**
  String get commodities;

  /// No description provided for @markets.
  ///
  /// In en, this message translates to:
  /// **'Markets'**
  String get markets;

  /// No description provided for @avgPrice.
  ///
  /// In en, this message translates to:
  /// **'Avg Price'**
  String get avgPrice;

  /// No description provided for @trendingNow.
  ///
  /// In en, this message translates to:
  /// **'Trending Now'**
  String get trendingNow;

  /// No description provided for @marketPrices.
  ///
  /// In en, this message translates to:
  /// **'Market Prices'**
  String get marketPrices;

  /// No description provided for @marketPricesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View detailed prices from mandis'**
  String get marketPricesSubtitle;

  /// No description provided for @marketComparison.
  ///
  /// In en, this message translates to:
  /// **'Market Comparison'**
  String get marketComparison;

  /// No description provided for @resetComparisonFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset Comparison Filters'**
  String get resetComparisonFilters;

  /// No description provided for @selectCommodity.
  ///
  /// In en, this message translates to:
  /// **'Select Commodity'**
  String get selectCommodity;

  /// No description provided for @failedToLoadComparison.
  ///
  /// In en, this message translates to:
  /// **'Failed to load comparison: {error}'**
  String failedToLoadComparison(String error);

  /// No description provided for @bestPriceFor.
  ///
  /// In en, this message translates to:
  /// **'Best Price for {commodity}'**
  String bestPriceFor(String commodity);

  /// No description provided for @bestMarket.
  ///
  /// In en, this message translates to:
  /// **'Best Market'**
  String get bestMarket;

  /// No description provided for @otherMarkets.
  ///
  /// In en, this message translates to:
  /// **'Other Markets'**
  String get otherMarkets;

  /// No description provided for @noComparisonDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No comparison data available'**
  String get noComparisonDataAvailable;

  /// No description provided for @marketDashboard.
  ///
  /// In en, this message translates to:
  /// **'Market Dashboard'**
  String get marketDashboard;

  /// No description provided for @marketDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time market insights & trends'**
  String get marketDashboardSubtitle;

  /// No description provided for @failedToLoadDashboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to load dashboard'**
  String get failedToLoadDashboard;

  /// No description provided for @marketPricesTitle.
  ///
  /// In en, this message translates to:
  /// **'Market Prices'**
  String get marketPricesTitle;

  /// No description provided for @exportToCsvTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get exportToCsvTooltip;

  /// No description provided for @clearFiltersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear all filters'**
  String get clearFiltersTooltip;

  /// No description provided for @firstPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'First page'**
  String get firstPageTooltip;

  /// No description provided for @previousPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPageTooltip;

  /// No description provided for @nextPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPageTooltip;

  /// No description provided for @lastPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Last page'**
  String get lastPageTooltip;

  /// No description provided for @noDataToExport.
  ///
  /// In en, this message translates to:
  /// **'No data to export'**
  String get noDataToExport;

  /// No description provided for @exportedRecordsCount.
  ///
  /// In en, this message translates to:
  /// **'Exported {count} records'**
  String exportedRecordsCount(int count);

  /// No description provided for @failedToExportFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to export file'**
  String get failedToExportFile;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @minPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Min Price'**
  String get minPriceLabel;

  /// No description provided for @maxPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Max Price'**
  String get maxPriceLabel;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @changeLabel.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeLabel;

  /// No description provided for @trendLabel.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trendLabel;

  /// No description provided for @marketLabel.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get marketLabel;

  /// No description provided for @lastUpdatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdatedLabel;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @updatedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Updated:'**
  String get updatedPrefix;

  /// No description provided for @failedToLoadPrices.
  ///
  /// In en, this message translates to:
  /// **'Failed to load prices'**
  String get failedToLoadPrices;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Market Prices Export'**
  String get shareText;

  /// No description provided for @shareSubject.
  ///
  /// In en, this message translates to:
  /// **'Market Prices Export'**
  String get shareSubject;

  /// No description provided for @csvHeaderName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get csvHeaderName;

  /// No description provided for @csvHeaderPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get csvHeaderPrice;

  /// No description provided for @csvHeaderMinPrice.
  ///
  /// In en, this message translates to:
  /// **'Min Price'**
  String get csvHeaderMinPrice;

  /// No description provided for @csvHeaderMaxPrice.
  ///
  /// In en, this message translates to:
  /// **'Max Price'**
  String get csvHeaderMaxPrice;

  /// No description provided for @csvHeaderUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get csvHeaderUnit;

  /// No description provided for @csvHeaderChangePercent.
  ///
  /// In en, this message translates to:
  /// **'Change %'**
  String get csvHeaderChangePercent;

  /// No description provided for @csvHeaderTrend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get csvHeaderTrend;

  /// No description provided for @csvHeaderMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get csvHeaderMarket;

  /// No description provided for @csvHeaderDistrict.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get csvHeaderDistrict;

  /// No description provided for @csvHeaderState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get csvHeaderState;

  /// No description provided for @csvHeaderLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get csvHeaderLastUpdated;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'hi': return AppLocalizationsHi();
    case 'mr': return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
