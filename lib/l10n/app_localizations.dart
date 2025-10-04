import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_th.dart';
import 'app_localizations_vi.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('th'),
    Locale('vi')
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'IngredientLens'**
  String get app_name;

  /// No description provided for @main_title.
  ///
  /// In en, this message translates to:
  /// **'AI Ingredient Analyzer'**
  String get main_title;

  /// No description provided for @ingredient_screen_header_title_1.
  ///
  /// In en, this message translates to:
  /// **'Beyond marketing:\nreal ingredients.'**
  String get ingredient_screen_header_title_1;

  /// No description provided for @ingredient_screen_header_text_1.
  ///
  /// In en, this message translates to:
  /// **'AI gives you objective insights.'**
  String get ingredient_screen_header_text_1;

  /// No description provided for @category_section_title.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get category_section_title;

  /// No description provided for @category_section_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Please select a category to analyze ingredients.'**
  String get category_section_subtitle;

  /// No description provided for @popular_category_section_title.
  ///
  /// In en, this message translates to:
  /// **'Popular Categories'**
  String get popular_category_section_title;

  /// No description provided for @popular_category_section_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Categories people often explore'**
  String get popular_category_section_subtitle;

  /// No description provided for @ingredient_recent_title.
  ///
  /// In en, this message translates to:
  /// **'Recent Analysis'**
  String get ingredient_recent_title;

  /// No description provided for @ingredient_recent_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your recent analysis!'**
  String get ingredient_recent_subtitle;

  /// No description provided for @nutrition_screen_header_title.
  ///
  /// In en, this message translates to:
  /// **'Scan nutrition facts\nand choose better!'**
  String get nutrition_screen_header_title;

  /// No description provided for @nutrition_screen_header_text.
  ///
  /// In en, this message translates to:
  /// **'AI gives healthy advice.'**
  String get nutrition_screen_header_text;

  /// No description provided for @nutrition_warnings.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Warnings'**
  String get nutrition_warnings;

  /// No description provided for @nutrition_benefits.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Benefits'**
  String get nutrition_benefits;

  /// No description provided for @calorie_screen_header_title_1.
  ///
  /// In en, this message translates to:
  /// **'Capture food photos\nto check calories!'**
  String get calorie_screen_header_title_1;

  /// No description provided for @calorie_screen_header_text_1.
  ///
  /// In en, this message translates to:
  /// **'AI calculates it easily for you.'**
  String get calorie_screen_header_text_1;

  /// No description provided for @meal_type_main_meal.
  ///
  /// In en, this message translates to:
  /// **'Main Meal'**
  String get meal_type_main_meal;

  /// No description provided for @meal_type_snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get meal_type_snack;

  /// No description provided for @meal_type_late_night.
  ///
  /// In en, this message translates to:
  /// **'Dessert'**
  String get meal_type_late_night;

  /// No description provided for @section_title.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get section_title;

  /// No description provided for @section_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a picture and analyze the ingredients'**
  String get section_subtitle;

  /// No description provided for @ingredient_analysis_title.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Analysis'**
  String get ingredient_analysis_title;

  /// No description provided for @ingredient_analysis_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a picture and analyze the ingredients'**
  String get ingredient_analysis_subtitle;

  /// No description provided for @recent_results_title.
  ///
  /// In en, this message translates to:
  /// **'Recent Results'**
  String get recent_results_title;

  /// No description provided for @recent_results_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Here are the results of a recent analysis'**
  String get recent_results_subtitle;

  /// No description provided for @no_recent_results.
  ///
  /// In en, this message translates to:
  /// **'No recent analysis results'**
  String get no_recent_results;

  /// No description provided for @no_recent_nutrition_results.
  ///
  /// In en, this message translates to:
  /// **'No recent nutrition analysis results'**
  String get no_recent_nutrition_results;

  /// No description provided for @ads_title.
  ///
  /// In en, this message translates to:
  /// **'Advertisement'**
  String get ads_title;

  /// No description provided for @consent_required_title.
  ///
  /// In en, this message translates to:
  /// **'Consent Required'**
  String get consent_required_title;

  /// No description provided for @consent_required_description.
  ///
  /// In en, this message translates to:
  /// **'To provide our AI-powered ingredient analysis service, we need to show personalized ads. This helps us cover the costs of AI processing.'**
  String get consent_required_description;

  /// No description provided for @consent_required_info.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is important to us. We only collect data necessary for showing relevant ads and improving your experience.'**
  String get consent_required_info;

  /// No description provided for @consent_agree_button.
  ///
  /// In en, this message translates to:
  /// **'Agree and Continue'**
  String get consent_agree_button;

  /// No description provided for @consent_exit_button.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get consent_exit_button;

  /// No description provided for @consent_decline_button.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get consent_decline_button;

  /// No description provided for @announcements_title.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements_title;

  /// No description provided for @announcements_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Check out our latest updates and news'**
  String get announcements_subtitle;

  /// No description provided for @no_announcements.
  ///
  /// In en, this message translates to:
  /// **'No new announcements'**
  String get no_announcements;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @no_notifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get no_notifications;

  /// No description provided for @time_days_ago.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String time_days_ago(Object days);

  /// No description provided for @time_hours_ago.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String time_hours_ago(Object hours);

  /// No description provided for @time_minutes_ago.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String time_minutes_ago(Object minutes);

  /// No description provided for @time_just_now.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get time_just_now;

  /// No description provided for @select_category.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get select_category;

  /// No description provided for @select_action.
  ///
  /// In en, this message translates to:
  /// **'Tap ‘Analyze’ to check one ingredient list, or ‘Compare’ to view two side by side.'**
  String get select_action;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @cosmetics.
  ///
  /// In en, this message translates to:
  /// **'Cosmetics'**
  String get cosmetics;

  /// No description provided for @baby_products.
  ///
  /// In en, this message translates to:
  /// **'Baby'**
  String get baby_products;

  /// No description provided for @pet_products.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get pet_products;

  /// No description provided for @medicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get medicine;

  /// No description provided for @household_products.
  ///
  /// In en, this message translates to:
  /// **'Household'**
  String get household_products;

  /// No description provided for @cleaning_products.
  ///
  /// In en, this message translates to:
  /// **'Cleaning Products'**
  String get cleaning_products;

  /// No description provided for @vegan_products.
  ///
  /// In en, this message translates to:
  /// **'Vegan Products'**
  String get vegan_products;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get other;

  /// No description provided for @nutrition_analysis.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Analysis'**
  String get nutrition_analysis;

  /// No description provided for @nutrition_analysis_title.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Analysis'**
  String get nutrition_analysis_title;

  /// No description provided for @nutrition_analysis_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Analyze nutrition to\nmaintain a balanced diet.'**
  String get nutrition_analysis_subtitle;

  /// No description provided for @calorie_analysis.
  ///
  /// In en, this message translates to:
  /// **'Calorie Analysis'**
  String get calorie_analysis;

  /// No description provided for @add_calorie.
  ///
  /// In en, this message translates to:
  /// **'Add Calorie'**
  String get add_calorie;

  /// No description provided for @processed_food.
  ///
  /// In en, this message translates to:
  /// **'Processed Food'**
  String get processed_food;

  /// No description provided for @dessert.
  ///
  /// In en, this message translates to:
  /// **'Dessert'**
  String get dessert;

  /// No description provided for @beverages.
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get beverages;

  /// No description provided for @subcategories.
  ///
  /// In en, this message translates to:
  /// **'Subcategories'**
  String get subcategories;

  /// No description provided for @select_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get select_none;

  /// No description provided for @subcategory_help_message.
  ///
  /// In en, this message translates to:
  /// **'Selecting a subcategory will provide more accurate results.'**
  String get subcategory_help_message;

  /// No description provided for @food_health_food.
  ///
  /// In en, this message translates to:
  /// **'Health Food'**
  String get food_health_food;

  /// No description provided for @food_diet_food.
  ///
  /// In en, this message translates to:
  /// **'Diet Food'**
  String get food_diet_food;

  /// No description provided for @food_dairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy Products'**
  String get food_dairy;

  /// No description provided for @food_processed.
  ///
  /// In en, this message translates to:
  /// **'Processed Food'**
  String get food_processed;

  /// No description provided for @food_instant.
  ///
  /// In en, this message translates to:
  /// **'Instant Food'**
  String get food_instant;

  /// No description provided for @food_beverages.
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get food_beverages;

  /// No description provided for @food_snacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get food_snacks;

  /// No description provided for @food_bakery.
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get food_bakery;

  /// No description provided for @food_seasoning.
  ///
  /// In en, this message translates to:
  /// **'Seasoning'**
  String get food_seasoning;

  /// No description provided for @cosmetics_skincare.
  ///
  /// In en, this message translates to:
  /// **'Skincare'**
  String get cosmetics_skincare;

  /// No description provided for @cosmetics_cleansing.
  ///
  /// In en, this message translates to:
  /// **'Cleansing'**
  String get cosmetics_cleansing;

  /// No description provided for @cosmetics_suncare.
  ///
  /// In en, this message translates to:
  /// **'Sun Care'**
  String get cosmetics_suncare;

  /// No description provided for @cosmetics_mask.
  ///
  /// In en, this message translates to:
  /// **'Face Mask'**
  String get cosmetics_mask;

  /// No description provided for @cosmetics_makeup.
  ///
  /// In en, this message translates to:
  /// **'Makeup'**
  String get cosmetics_makeup;

  /// No description provided for @cosmetics_bodycare.
  ///
  /// In en, this message translates to:
  /// **'Body Care'**
  String get cosmetics_bodycare;

  /// No description provided for @cosmetics_haircare.
  ///
  /// In en, this message translates to:
  /// **'Hair Care'**
  String get cosmetics_haircare;

  /// No description provided for @cosmetics_handcare.
  ///
  /// In en, this message translates to:
  /// **'Hand Care'**
  String get cosmetics_handcare;

  /// No description provided for @cosmetics_footcare.
  ///
  /// In en, this message translates to:
  /// **'Foot Care'**
  String get cosmetics_footcare;

  /// No description provided for @cosmetics_mens.
  ///
  /// In en, this message translates to:
  /// **'Men\'s Cosmetics'**
  String get cosmetics_mens;

  /// No description provided for @medicine_skin_treatment.
  ///
  /// In en, this message translates to:
  /// **'Skin Treatment'**
  String get medicine_skin_treatment;

  /// No description provided for @medicine_allergy.
  ///
  /// In en, this message translates to:
  /// **'Allergy Medicine'**
  String get medicine_allergy;

  /// No description provided for @medicine_womens.
  ///
  /// In en, this message translates to:
  /// **'Women\'s Medicine'**
  String get medicine_womens;

  /// No description provided for @medicine_general.
  ///
  /// In en, this message translates to:
  /// **'General Medicine'**
  String get medicine_general;

  /// No description provided for @medicine_supplements.
  ///
  /// In en, this message translates to:
  /// **'Supplements'**
  String get medicine_supplements;

  /// No description provided for @baby_skincare.
  ///
  /// In en, this message translates to:
  /// **'Baby Skincare'**
  String get baby_skincare;

  /// No description provided for @baby_cleansers.
  ///
  /// In en, this message translates to:
  /// **'Baby Cleansers'**
  String get baby_cleansers;

  /// No description provided for @baby_medicine.
  ///
  /// In en, this message translates to:
  /// **'Baby Medicine'**
  String get baby_medicine;

  /// No description provided for @baby_food.
  ///
  /// In en, this message translates to:
  /// **'Baby Food'**
  String get baby_food;

  /// No description provided for @baby_formula.
  ///
  /// In en, this message translates to:
  /// **'Baby Formula'**
  String get baby_formula;

  /// No description provided for @baby_sanitizers.
  ///
  /// In en, this message translates to:
  /// **'Sanitizers'**
  String get baby_sanitizers;

  /// No description provided for @baby_detergent.
  ///
  /// In en, this message translates to:
  /// **'Baby Detergent'**
  String get baby_detergent;

  /// No description provided for @baby_toys.
  ///
  /// In en, this message translates to:
  /// **'Baby Toys'**
  String get baby_toys;

  /// No description provided for @pet_supplements.
  ///
  /// In en, this message translates to:
  /// **'Pet Supplements'**
  String get pet_supplements;

  /// No description provided for @pet_medicine.
  ///
  /// In en, this message translates to:
  /// **'Pet Medicine'**
  String get pet_medicine;

  /// No description provided for @pet_shampoo.
  ///
  /// In en, this message translates to:
  /// **'Pet Shampoo'**
  String get pet_shampoo;

  /// No description provided for @pet_special_food.
  ///
  /// In en, this message translates to:
  /// **'Pet Special Food'**
  String get pet_special_food;

  /// No description provided for @pet_food.
  ///
  /// In en, this message translates to:
  /// **'Pet Food'**
  String get pet_food;

  /// No description provided for @pet_treats.
  ///
  /// In en, this message translates to:
  /// **'Pet Treats'**
  String get pet_treats;

  /// No description provided for @pet_waste.
  ///
  /// In en, this message translates to:
  /// **'Waste Products'**
  String get pet_waste;

  /// No description provided for @pet_toys.
  ///
  /// In en, this message translates to:
  /// **'Pet Toys'**
  String get pet_toys;

  /// No description provided for @household_products_dishwashing.
  ///
  /// In en, this message translates to:
  /// **'Dishwashing Detergent'**
  String get household_products_dishwashing;

  /// No description provided for @household_products_air_freshener.
  ///
  /// In en, this message translates to:
  /// **'Air Freshener'**
  String get household_products_air_freshener;

  /// No description provided for @household_products_cleaner.
  ///
  /// In en, this message translates to:
  /// **'Cleaner'**
  String get household_products_cleaner;

  /// No description provided for @household_products_deodorizer.
  ///
  /// In en, this message translates to:
  /// **'Deodorizer'**
  String get household_products_deodorizer;

  /// No description provided for @analyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get analyze;

  /// No description provided for @select_image_source.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get select_image_source;

  /// No description provided for @ingredient_photography.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get ingredient_photography;

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

  /// No description provided for @crop_image.
  ///
  /// In en, this message translates to:
  /// **'Crop Image'**
  String get crop_image;

  /// No description provided for @crop_instruction.
  ///
  /// In en, this message translates to:
  /// **'Please adjust the position and size so that the ingredient content fits within the white box. You can pinch to zoom in/out and drag the white border to move the box.'**
  String get crop_instruction;

  /// No description provided for @nutrition_crop_instruction.
  ///
  /// In en, this message translates to:
  /// **'Please adjust the position and size so that the nutrition content fits within the white box. You can pinch to zoom in/out and drag the white border to move the box.'**
  String get nutrition_crop_instruction;

  /// No description provided for @reset_zoom.
  ///
  /// In en, this message translates to:
  /// **'Reset Zoom'**
  String get reset_zoom;

  /// No description provided for @get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get get_started;

  /// No description provided for @onboarding_step1_title.
  ///
  /// In en, this message translates to:
  /// **'Select Ingredient Category'**
  String get onboarding_step1_title;

  /// No description provided for @onboarding_step1_description.
  ///
  /// In en, this message translates to:
  /// **'Choose the product type to check in the Ingredient Analysis tab.'**
  String get onboarding_step1_description;

  /// No description provided for @onboarding_step2_title.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Photography & Analysis'**
  String get onboarding_step2_title;

  /// No description provided for @onboarding_step2_description.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the ingredient list and AI will analyze safety and characteristics.'**
  String get onboarding_step2_description;

  /// No description provided for @onboarding_step3_title.
  ///
  /// In en, this message translates to:
  /// **'Select Nutrition Category'**
  String get onboarding_step3_title;

  /// No description provided for @onboarding_step3_description.
  ///
  /// In en, this message translates to:
  /// **'Choose the food type to check in the Nutrition Analysis tab.'**
  String get onboarding_step3_description;

  /// No description provided for @onboarding_step4_title.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Photography'**
  String get onboarding_step4_title;

  /// No description provided for @onboarding_step4_description.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of nutrition information like carbs, fat, protein and AI will analyze objectively.'**
  String get onboarding_step4_description;

  /// No description provided for @onboarding_step5_title.
  ///
  /// In en, this message translates to:
  /// **'Add Meal Photos'**
  String get onboarding_step5_title;

  /// No description provided for @onboarding_step5_description.
  ///
  /// In en, this message translates to:
  /// **'Press the + button to take and register meal photos.'**
  String get onboarding_step5_description;

  /// No description provided for @onboarding_step6_title.
  ///
  /// In en, this message translates to:
  /// **'AI Calorie Analysis'**
  String get onboarding_step6_title;

  /// No description provided for @onboarding_step6_description.
  ///
  /// In en, this message translates to:
  /// **'AI analyzes meal photos to provide approximate calorie information.'**
  String get onboarding_step6_description;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @analysis_notice.
  ///
  /// In en, this message translates to:
  /// **'AI analysis takes 5-20 seconds (may vary depending on network conditions). Ads will be displayed during analysis to support the service. You can close the ad after 5 seconds.'**
  String get analysis_notice;

  /// No description provided for @dont_show_again.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get dont_show_again;

  /// No description provided for @positive_ingredients.
  ///
  /// In en, this message translates to:
  /// **'Positive Ingredients'**
  String get positive_ingredients;

  /// No description provided for @negative_ingredients.
  ///
  /// In en, this message translates to:
  /// **'Negative Ingredients'**
  String get negative_ingredients;

  /// No description provided for @other_ingredients.
  ///
  /// In en, this message translates to:
  /// **'Other Ingredients'**
  String get other_ingredients;

  /// No description provided for @overall_review.
  ///
  /// In en, this message translates to:
  /// **'Overall Review'**
  String get overall_review;

  /// No description provided for @category_analysis.
  ///
  /// In en, this message translates to:
  /// **'Indicator Analysis'**
  String get category_analysis;

  /// No description provided for @category_comparison.
  ///
  /// In en, this message translates to:
  /// **'Indicator Comparison'**
  String get category_comparison;

  /// No description provided for @nutritional_value.
  ///
  /// In en, this message translates to:
  /// **'Nutritional Value'**
  String get nutritional_value;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// No description provided for @natural_ingredients.
  ///
  /// In en, this message translates to:
  /// **'Natural Ingredients'**
  String get natural_ingredients;

  /// No description provided for @functional_benefits.
  ///
  /// In en, this message translates to:
  /// **'Functional Benefits'**
  String get functional_benefits;

  /// No description provided for @taste_quality.
  ///
  /// In en, this message translates to:
  /// **'Taste Quality'**
  String get taste_quality;

  /// No description provided for @moisturizing.
  ///
  /// In en, this message translates to:
  /// **'Moisturizing'**
  String get moisturizing;

  /// No description provided for @hypoallergenic.
  ///
  /// In en, this message translates to:
  /// **'Hypoallergenic'**
  String get hypoallergenic;

  /// No description provided for @longevity.
  ///
  /// In en, this message translates to:
  /// **'Longevity'**
  String get longevity;

  /// No description provided for @stability.
  ///
  /// In en, this message translates to:
  /// **'Stability'**
  String get stability;

  /// No description provided for @absorption.
  ///
  /// In en, this message translates to:
  /// **'Absorption'**
  String get absorption;

  /// No description provided for @effectiveness.
  ///
  /// In en, this message translates to:
  /// **'Effectiveness'**
  String get effectiveness;

  /// No description provided for @gentleness.
  ///
  /// In en, this message translates to:
  /// **'Gentleness'**
  String get gentleness;

  /// No description provided for @safety_standards.
  ///
  /// In en, this message translates to:
  /// **'Safety Standards'**
  String get safety_standards;

  /// No description provided for @nutritional_balance.
  ///
  /// In en, this message translates to:
  /// **'Nutritional Balance'**
  String get nutritional_balance;

  /// No description provided for @digestibility.
  ///
  /// In en, this message translates to:
  /// **'Digestibility'**
  String get digestibility;

  /// No description provided for @palatability.
  ///
  /// In en, this message translates to:
  /// **'Palatability'**
  String get palatability;

  /// No description provided for @functionality.
  ///
  /// In en, this message translates to:
  /// **'Functionality'**
  String get functionality;

  /// No description provided for @side_effects.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get side_effects;

  /// No description provided for @quality_standards.
  ///
  /// In en, this message translates to:
  /// **'Quality Standards'**
  String get quality_standards;

  /// No description provided for @interactions.
  ///
  /// In en, this message translates to:
  /// **'Interactions'**
  String get interactions;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @network_error.
  ///
  /// In en, this message translates to:
  /// **'Network error occurred. Please try again.'**
  String get network_error;

  /// No description provided for @analysis_failed.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed. Please try again.'**
  String get analysis_failed;

  /// No description provided for @no_ingredients_found.
  ///
  /// In en, this message translates to:
  /// **'No ingredients found.'**
  String get no_ingredients_found;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// No description provided for @ai_analysis_message.
  ///
  /// In en, this message translates to:
  /// **'Please wait a moment! AI is analyzing ingredients precisely✨\n(Takes about 10 seconds)'**
  String get ai_analysis_message;

  /// No description provided for @please_select_category.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get please_select_category;

  /// No description provided for @enter_custom_category.
  ///
  /// In en, this message translates to:
  /// **'Please enter a custom category'**
  String get enter_custom_category;

  /// No description provided for @take_photo_for_category.
  ///
  /// In en, this message translates to:
  /// **'Take a photo for {category} category'**
  String take_photo_for_category(Object category);

  /// No description provided for @take_photo_of_ingredients.
  ///
  /// In en, this message translates to:
  /// **'Please take a photo of {category} ingredients with camera or select a photo from gallery'**
  String take_photo_of_ingredients(Object category);

  /// No description provided for @camera_permission_needed.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required.'**
  String get camera_permission_needed;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @photo_error.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while taking photo: {error}'**
  String photo_error(Object error);

  /// No description provided for @photo_taken.
  ///
  /// In en, this message translates to:
  /// **'Photo taken'**
  String get photo_taken;

  /// No description provided for @category_label.
  ///
  /// In en, this message translates to:
  /// **'Category: {category}'**
  String category_label(Object category);

  /// No description provided for @taking_photo.
  ///
  /// In en, this message translates to:
  /// **'Taking photo...'**
  String get taking_photo;

  /// No description provided for @photo_instruction.
  ///
  /// In en, this message translates to:
  /// **'Take your time taking photos as you can specify the ingredient list area after shooting.'**
  String get photo_instruction;

  /// No description provided for @check_photo_in_range.
  ///
  /// In en, this message translates to:
  /// **'Is the ingredient list well captured within the frame?'**
  String get check_photo_in_range;

  /// No description provided for @take_photo.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get take_photo;

  /// No description provided for @horizontal_guide.
  ///
  /// In en, this message translates to:
  /// **'Horizontal'**
  String get horizontal_guide;

  /// No description provided for @vertical_guide.
  ///
  /// In en, this message translates to:
  /// **'Vertical'**
  String get vertical_guide;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @rotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get rotate;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @confirm_analysis_notice.
  ///
  /// In en, this message translates to:
  /// **'When you press analyze, AI analysis will proceed immediately, and ads will be displayed during analysis.'**
  String get confirm_analysis_notice;

  /// No description provided for @app_subtitle.
  ///
  /// In en, this message translates to:
  /// **'AI-powered ingredient analyzer'**
  String get app_subtitle;

  /// No description provided for @ai_disclaimer.
  ///
  /// In en, this message translates to:
  /// **'The ingredient and nutrition analysis in this app is automatically generated by AI and is not based on any specific organization or official source. The information is for reference only and may contain errors. Please consult professionals for important decisions. 😊'**
  String get ai_disclaimer;

  /// No description provided for @save_screenshot.
  ///
  /// In en, this message translates to:
  /// **'Save Results'**
  String get save_screenshot;

  /// No description provided for @screenshot_saved.
  ///
  /// In en, this message translates to:
  /// **'Results saved to gallery'**
  String get screenshot_saved;

  /// No description provided for @screenshot_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get screenshot_failed;

  /// No description provided for @storage_permission_needed.
  ///
  /// In en, this message translates to:
  /// **'Storage permission required'**
  String get storage_permission_needed;

  /// No description provided for @save_result.
  ///
  /// In en, this message translates to:
  /// **'Save Result'**
  String get save_result;

  /// No description provided for @result_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get result_name;

  /// No description provided for @enter_result_name.
  ///
  /// In en, this message translates to:
  /// **'Enter result name'**
  String get enter_result_name;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @result_saved.
  ///
  /// In en, this message translates to:
  /// **'Result saved successfully'**
  String get result_saved;

  /// No description provided for @save_failed_simple.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get save_failed_simple;

  /// No description provided for @saved_results.
  ///
  /// In en, this message translates to:
  /// **'Saved Results'**
  String get saved_results;

  /// No description provided for @saved_analysis.
  ///
  /// In en, this message translates to:
  /// **'Saved Analysis'**
  String get saved_analysis;

  /// No description provided for @no_saved_results.
  ///
  /// In en, this message translates to:
  /// **'No saved results'**
  String get no_saved_results;

  /// No description provided for @analysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysis;

  /// No description provided for @comparison.
  ///
  /// In en, this message translates to:
  /// **'comparison'**
  String get comparison;

  /// No description provided for @edit_name.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get edit_name;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete Confirmation'**
  String get confirm_delete;

  /// No description provided for @confirm_delete_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get confirm_delete_message;

  /// No description provided for @delete_success.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get delete_success;

  /// No description provided for @delete_failed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get delete_failed;

  /// No description provided for @analysis_results.
  ///
  /// In en, this message translates to:
  /// **'Analysis Results'**
  String get analysis_results;

  /// No description provided for @compare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get compare;

  /// No description provided for @product_a.
  ///
  /// In en, this message translates to:
  /// **'Product A'**
  String get product_a;

  /// No description provided for @product_b.
  ///
  /// In en, this message translates to:
  /// **'Product B'**
  String get product_b;

  /// No description provided for @compare_ingredients.
  ///
  /// In en, this message translates to:
  /// **'Compare Ingredients'**
  String get compare_ingredients;

  /// No description provided for @select_both_products.
  ///
  /// In en, this message translates to:
  /// **'Please select both products to compare'**
  String get select_both_products;

  /// No description provided for @overall_comparison.
  ///
  /// In en, this message translates to:
  /// **'Overall Comparison'**
  String get overall_comparison;

  /// No description provided for @tap_to_add.
  ///
  /// In en, this message translates to:
  /// **'Tap to add'**
  String get tap_to_add;

  /// No description provided for @compare_instruction.
  ///
  /// In en, this message translates to:
  /// **'Please capture or select the ingredient list for each product.'**
  String get compare_instruction;

  /// No description provided for @ingredient_search.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Search'**
  String get ingredient_search;

  /// No description provided for @ingredient_search_message.
  ///
  /// In en, this message translates to:
  /// **'Shall we learn more about \"{ingredient}\"?'**
  String ingredient_search_message(Object ingredient);

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @save_ingredient.
  ///
  /// In en, this message translates to:
  /// **'Save Ingredient Info'**
  String get save_ingredient;

  /// No description provided for @enter_save_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name to save'**
  String get enter_save_name;

  /// No description provided for @save_name_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Vitamin C Info'**
  String get save_name_hint;

  /// No description provided for @enter_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get enter_name;

  /// No description provided for @save_complete.
  ///
  /// In en, this message translates to:
  /// **'Save completed'**
  String get save_complete;

  /// No description provided for @recent_ingredients_title.
  ///
  /// In en, this message translates to:
  /// **'Recent Ingredient Searches'**
  String get recent_ingredients_title;

  /// No description provided for @recent_ingredients_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Recently searched ingredient information'**
  String get recent_ingredients_subtitle;

  /// No description provided for @no_recent_ingredients.
  ///
  /// In en, this message translates to:
  /// **'No recent ingredient searches'**
  String get no_recent_ingredients;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @no_saved_ingredients.
  ///
  /// In en, this message translates to:
  /// **'No saved ingredients'**
  String get no_saved_ingredients;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @searching_ingredient_info.
  ///
  /// In en, this message translates to:
  /// **'Searching for ingredient information...'**
  String get searching_ingredient_info;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @alternative_names.
  ///
  /// In en, this message translates to:
  /// **'Alternative Names'**
  String get alternative_names;

  /// No description provided for @primary_functions.
  ///
  /// In en, this message translates to:
  /// **'Primary Functions'**
  String get primary_functions;

  /// No description provided for @benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// No description provided for @precautions.
  ///
  /// In en, this message translates to:
  /// **'Precautions'**
  String get precautions;

  /// No description provided for @additional_info.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additional_info;

  /// No description provided for @ingredient_detail_search.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get ingredient_detail_search;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @sharing.
  ///
  /// In en, this message translates to:
  /// **'Sharing...'**
  String get sharing;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @user_info.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get user_info;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @terms_of_service.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms_of_service;

  /// No description provided for @help_feedback.
  ///
  /// In en, this message translates to:
  /// **'Help & Feedback'**
  String get help_feedback;

  /// No description provided for @religion.
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get religion;

  /// No description provided for @skin.
  ///
  /// In en, this message translates to:
  /// **'Skin Type'**
  String get skin;

  /// No description provided for @allergy.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergy;

  /// No description provided for @diet.
  ///
  /// In en, this message translates to:
  /// **'Dietary Restrictions'**
  String get diet;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health Conditions'**
  String get health;

  /// No description provided for @add_custom.
  ///
  /// In en, this message translates to:
  /// **'Add Custom'**
  String get add_custom;

  /// No description provided for @enter_custom_value.
  ///
  /// In en, this message translates to:
  /// **'Enter custom value'**
  String get enter_custom_value;

  /// No description provided for @custom_value_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Lactose intolerance'**
  String get custom_value_hint;

  /// No description provided for @value_already_exists.
  ///
  /// In en, this message translates to:
  /// **'This value already exists'**
  String get value_already_exists;

  /// No description provided for @preference_added.
  ///
  /// In en, this message translates to:
  /// **'Preference added successfully'**
  String get preference_added;

  /// No description provided for @preference_removed.
  ///
  /// In en, this message translates to:
  /// **'Preference removed successfully'**
  String get preference_removed;

  /// No description provided for @select_preferred_language.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get select_preferred_language;

  /// No description provided for @language_changed_to.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String language_changed_to(Object language);

  /// No description provided for @christianity.
  ///
  /// In en, this message translates to:
  /// **'Christianity'**
  String get christianity;

  /// No description provided for @islam.
  ///
  /// In en, this message translates to:
  /// **'Islam'**
  String get islam;

  /// No description provided for @hinduism.
  ///
  /// In en, this message translates to:
  /// **'Hinduism'**
  String get hinduism;

  /// No description provided for @buddhism.
  ///
  /// In en, this message translates to:
  /// **'Buddhism'**
  String get buddhism;

  /// No description provided for @sensitive.
  ///
  /// In en, this message translates to:
  /// **'Sensitive'**
  String get sensitive;

  /// No description provided for @dry.
  ///
  /// In en, this message translates to:
  /// **'Dry'**
  String get dry;

  /// No description provided for @oily.
  ///
  /// In en, this message translates to:
  /// **'Oily'**
  String get oily;

  /// No description provided for @combination.
  ///
  /// In en, this message translates to:
  /// **'Combination'**
  String get combination;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @acne_prone.
  ///
  /// In en, this message translates to:
  /// **'Acne-prone'**
  String get acne_prone;

  /// No description provided for @atopic.
  ///
  /// In en, this message translates to:
  /// **'Atopic'**
  String get atopic;

  /// No description provided for @nuts.
  ///
  /// In en, this message translates to:
  /// **'Nuts'**
  String get nuts;

  /// No description provided for @dairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get dairy;

  /// No description provided for @eggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get eggs;

  /// No description provided for @soy.
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get soy;

  /// No description provided for @gluten.
  ///
  /// In en, this message translates to:
  /// **'Gluten'**
  String get gluten;

  /// No description provided for @shellfish.
  ///
  /// In en, this message translates to:
  /// **'Shellfish'**
  String get shellfish;

  /// No description provided for @fish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get fish;

  /// No description provided for @sesame.
  ///
  /// In en, this message translates to:
  /// **'Sesame'**
  String get sesame;

  /// No description provided for @vegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get vegetarian;

  /// No description provided for @vegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get vegan;

  /// No description provided for @low_carb.
  ///
  /// In en, this message translates to:
  /// **'Low-carb'**
  String get low_carb;

  /// No description provided for @gluten_free.
  ///
  /// In en, this message translates to:
  /// **'Gluten-free'**
  String get gluten_free;

  /// No description provided for @dairy_free.
  ///
  /// In en, this message translates to:
  /// **'Dairy-free'**
  String get dairy_free;

  /// No description provided for @sugar_free.
  ///
  /// In en, this message translates to:
  /// **'Sugar-free'**
  String get sugar_free;

  /// No description provided for @halal.
  ///
  /// In en, this message translates to:
  /// **'Halal'**
  String get halal;

  /// No description provided for @diabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes'**
  String get diabetes;

  /// No description provided for @hypertension.
  ///
  /// In en, this message translates to:
  /// **'Hypertension'**
  String get hypertension;

  /// No description provided for @heart_disease.
  ///
  /// In en, this message translates to:
  /// **'Heart disease'**
  String get heart_disease;

  /// No description provided for @kidney_disease.
  ///
  /// In en, this message translates to:
  /// **'Kidney disease'**
  String get kidney_disease;

  /// No description provided for @pregnancy.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy'**
  String get pregnancy;

  /// No description provided for @breastfeeding.
  ///
  /// In en, this message translates to:
  /// **'Breastfeeding'**
  String get breastfeeding;

  /// No description provided for @daily_limit_reached.
  ///
  /// In en, this message translates to:
  /// **'Daily usage limit reached. Please try again tomorrow.'**
  String get daily_limit_reached;

  /// No description provided for @custom_limit_reached.
  ///
  /// In en, this message translates to:
  /// **'Maximum 3 custom items allowed'**
  String get custom_limit_reached;

  /// No description provided for @invalid_characters.
  ///
  /// In en, this message translates to:
  /// **'Special characters not allowed'**
  String get invalid_characters;

  /// No description provided for @text_too_long.
  ///
  /// In en, this message translates to:
  /// **'Maximum 20 characters allowed'**
  String get text_too_long;

  /// No description provided for @apply_profile.
  ///
  /// In en, this message translates to:
  /// **'Apply my profile preferences'**
  String get apply_profile;

  /// No description provided for @profile_settings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profile_settings;

  /// No description provided for @crop_area_required.
  ///
  /// In en, this message translates to:
  /// **'Ingredient area not selected. Please adjust the white box to include the ingredient list.'**
  String get crop_area_required;

  /// No description provided for @baby_info.
  ///
  /// In en, this message translates to:
  /// **'Baby Information'**
  String get baby_info;

  /// No description provided for @pet_info.
  ///
  /// In en, this message translates to:
  /// **'Pet Information'**
  String get pet_info;

  /// No description provided for @baby_age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get baby_age;

  /// No description provided for @pet_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get pet_type;

  /// No description provided for @pet_breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get pet_breed;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @neutered.
  ///
  /// In en, this message translates to:
  /// **'Neutered Status'**
  String get neutered;

  /// No description provided for @dog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get dog;

  /// No description provided for @cat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get cat;

  /// No description provided for @bird.
  ///
  /// In en, this message translates to:
  /// **'Bird'**
  String get bird;

  /// No description provided for @rabbit.
  ///
  /// In en, this message translates to:
  /// **'Rabbit'**
  String get rabbit;

  /// No description provided for @hamster.
  ///
  /// In en, this message translates to:
  /// **'Hamster'**
  String get hamster;

  /// No description provided for @neutered_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get neutered_yes;

  /// No description provided for @neutered_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get neutered_no;

  /// No description provided for @baby_age_0_6_months.
  ///
  /// In en, this message translates to:
  /// **'0-6 months'**
  String get baby_age_0_6_months;

  /// No description provided for @baby_age_6_12_months.
  ///
  /// In en, this message translates to:
  /// **'6-12 months'**
  String get baby_age_6_12_months;

  /// No description provided for @baby_age_1_2_years.
  ///
  /// In en, this message translates to:
  /// **'1-2 years'**
  String get baby_age_1_2_years;

  /// No description provided for @baby_age_2_3_years.
  ///
  /// In en, this message translates to:
  /// **'2-3 years'**
  String get baby_age_2_3_years;

  /// No description provided for @baby_age_3_5_years.
  ///
  /// In en, this message translates to:
  /// **'3-5 years'**
  String get baby_age_3_5_years;

  /// No description provided for @baby_age_5_plus_years.
  ///
  /// In en, this message translates to:
  /// **'5+ years'**
  String get baby_age_5_plus_years;

  /// No description provided for @baby_health_healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get baby_health_healthy;

  /// No description provided for @baby_health_asthma.
  ///
  /// In en, this message translates to:
  /// **'Asthma'**
  String get baby_health_asthma;

  /// No description provided for @baby_health_digestive_sensitivity.
  ///
  /// In en, this message translates to:
  /// **'Digestive sensitivity'**
  String get baby_health_digestive_sensitivity;

  /// No description provided for @baby_health_constipation.
  ///
  /// In en, this message translates to:
  /// **'Constipation'**
  String get baby_health_constipation;

  /// No description provided for @baby_health_diarrhea.
  ///
  /// In en, this message translates to:
  /// **'Diarrhea'**
  String get baby_health_diarrhea;

  /// No description provided for @pet_age_0_1_year.
  ///
  /// In en, this message translates to:
  /// **'0-1 year'**
  String get pet_age_0_1_year;

  /// No description provided for @pet_age_1_3_years.
  ///
  /// In en, this message translates to:
  /// **'1-3 years'**
  String get pet_age_1_3_years;

  /// No description provided for @pet_age_3_5_years.
  ///
  /// In en, this message translates to:
  /// **'3-5 years'**
  String get pet_age_3_5_years;

  /// No description provided for @pet_age_5_7_years.
  ///
  /// In en, this message translates to:
  /// **'5-7 years'**
  String get pet_age_5_7_years;

  /// No description provided for @pet_age_7_10_years.
  ///
  /// In en, this message translates to:
  /// **'7-10 years'**
  String get pet_age_7_10_years;

  /// No description provided for @pet_age_10_plus_years.
  ///
  /// In en, this message translates to:
  /// **'10+ years'**
  String get pet_age_10_plus_years;

  /// No description provided for @pet_weight_under_1kg.
  ///
  /// In en, this message translates to:
  /// **'Under 1kg'**
  String get pet_weight_under_1kg;

  /// No description provided for @pet_weight_1_3kg.
  ///
  /// In en, this message translates to:
  /// **'1-3kg'**
  String get pet_weight_1_3kg;

  /// No description provided for @pet_weight_3_5kg.
  ///
  /// In en, this message translates to:
  /// **'3-5kg'**
  String get pet_weight_3_5kg;

  /// No description provided for @pet_weight_5_10kg.
  ///
  /// In en, this message translates to:
  /// **'5-10kg'**
  String get pet_weight_5_10kg;

  /// No description provided for @pet_weight_10_20kg.
  ///
  /// In en, this message translates to:
  /// **'10-20kg'**
  String get pet_weight_10_20kg;

  /// No description provided for @pet_weight_over_20kg.
  ///
  /// In en, this message translates to:
  /// **'Over 20kg'**
  String get pet_weight_over_20kg;

  /// No description provided for @pet_allergy_grains.
  ///
  /// In en, this message translates to:
  /// **'Grains'**
  String get pet_allergy_grains;

  /// No description provided for @pet_allergy_chicken.
  ///
  /// In en, this message translates to:
  /// **'Chicken'**
  String get pet_allergy_chicken;

  /// No description provided for @pet_allergy_beef.
  ///
  /// In en, this message translates to:
  /// **'Beef'**
  String get pet_allergy_beef;

  /// No description provided for @pet_health_healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get pet_health_healthy;

  /// No description provided for @pet_health_arthritis.
  ///
  /// In en, this message translates to:
  /// **'Arthritis'**
  String get pet_health_arthritis;

  /// No description provided for @pet_health_heart_disease.
  ///
  /// In en, this message translates to:
  /// **'Heart disease'**
  String get pet_health_heart_disease;

  /// No description provided for @pet_health_kidney_disease.
  ///
  /// In en, this message translates to:
  /// **'Kidney disease'**
  String get pet_health_kidney_disease;

  /// No description provided for @pet_health_liver_disease.
  ///
  /// In en, this message translates to:
  /// **'Liver disease'**
  String get pet_health_liver_disease;

  /// No description provided for @pet_health_diabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes'**
  String get pet_health_diabetes;

  /// No description provided for @pet_health_skin_disease.
  ///
  /// In en, this message translates to:
  /// **'Skin disease'**
  String get pet_health_skin_disease;

  /// No description provided for @pet_health_digestive_disease.
  ///
  /// In en, this message translates to:
  /// **'Digestive disease'**
  String get pet_health_digestive_disease;

  /// No description provided for @pet_breed_input_message.
  ///
  /// In en, this message translates to:
  /// **'Please enter the breed directly'**
  String get pet_breed_input_message;

  /// No description provided for @apply_user_info.
  ///
  /// In en, this message translates to:
  /// **'Apply user information'**
  String get apply_user_info;

  /// No description provided for @apply_baby_info.
  ///
  /// In en, this message translates to:
  /// **'Apply baby information'**
  String get apply_baby_info;

  /// No description provided for @apply_pet_info.
  ///
  /// In en, this message translates to:
  /// **'Apply pet information'**
  String get apply_pet_info;

  /// No description provided for @vision_api_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to find ingredient text in the image.'**
  String get vision_api_error;

  /// No description provided for @ai_evaluation_score.
  ///
  /// In en, this message translates to:
  /// **'AI Score'**
  String get ai_evaluation_score;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @caution.
  ///
  /// In en, this message translates to:
  /// **'Caution'**
  String get caution;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get points;

  /// No description provided for @personalized_info_applied.
  ///
  /// In en, this message translates to:
  /// **'(Customized Info Applied)'**
  String get personalized_info_applied;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @current_weight.
  ///
  /// In en, this message translates to:
  /// **'Current Weight'**
  String get current_weight;

  /// No description provided for @target_weight.
  ///
  /// In en, this message translates to:
  /// **'Target Weight'**
  String get target_weight;

  /// No description provided for @height_cm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get height_cm;

  /// No description provided for @weight_kg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weight_kg;

  /// No description provided for @target_weight_kg.
  ///
  /// In en, this message translates to:
  /// **'Target Weight (kg)'**
  String get target_weight_kg;

  /// No description provided for @physical_info.
  ///
  /// In en, this message translates to:
  /// **'Physical Information'**
  String get physical_info;

  /// No description provided for @baby_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get baby_weight;

  /// No description provided for @baby_weight_under_5kg.
  ///
  /// In en, this message translates to:
  /// **'Under 5kg'**
  String get baby_weight_under_5kg;

  /// No description provided for @baby_weight_5_10kg.
  ///
  /// In en, this message translates to:
  /// **'5-10kg'**
  String get baby_weight_5_10kg;

  /// No description provided for @baby_weight_10_15kg.
  ///
  /// In en, this message translates to:
  /// **'10-15kg'**
  String get baby_weight_10_15kg;

  /// No description provided for @baby_weight_15_20kg.
  ///
  /// In en, this message translates to:
  /// **'15-20kg'**
  String get baby_weight_15_20kg;

  /// No description provided for @baby_weight_over_20kg.
  ///
  /// In en, this message translates to:
  /// **'Over 20kg'**
  String get baby_weight_over_20kg;

  /// No description provided for @direct_input.
  ///
  /// In en, this message translates to:
  /// **'Direct Input'**
  String get direct_input;

  /// No description provided for @bottom_nav_ingredient_analysis.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Analysis'**
  String get bottom_nav_ingredient_analysis;

  /// No description provided for @bottom_nav_nutrition_analysis.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Analysis'**
  String get bottom_nav_nutrition_analysis;

  /// No description provided for @bottom_nav_storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get bottom_nav_storage;

  /// No description provided for @recent_history.
  ///
  /// In en, this message translates to:
  /// **'Recent History'**
  String get recent_history;

  /// No description provided for @calorie_management.
  ///
  /// In en, this message translates to:
  /// **'Calorie Management'**
  String get calorie_management;

  /// No description provided for @ingredients_short.
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get ingredients_short;

  /// No description provided for @nutrition_short.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition_short;

  /// No description provided for @history_short.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history_short;

  /// No description provided for @calorie_short.
  ///
  /// In en, this message translates to:
  /// **'Calorie'**
  String get calorie_short;

  /// No description provided for @today_calories_section_title.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Calories'**
  String get today_calories_section_title;

  /// No description provided for @today_calories_section_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Check the calories you recorded today.'**
  String get today_calories_section_subtitle;

  /// No description provided for @no_calories_today.
  ///
  /// In en, this message translates to:
  /// **'No calories recorded today'**
  String get no_calories_today;

  /// No description provided for @more_items_count.
  ///
  /// In en, this message translates to:
  /// **'{count} more items'**
  String more_items_count(Object count);

  /// No description provided for @weekly_calories_section_title.
  ///
  /// In en, this message translates to:
  /// **'Weekly Calories'**
  String get weekly_calories_section_title;

  /// No description provided for @weekly_calories_section_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Check daily calorie\nintake changes for the week.'**
  String get weekly_calories_section_subtitle;

  /// No description provided for @daily_average_calories.
  ///
  /// In en, this message translates to:
  /// **'Daily avg {calories} kcal'**
  String daily_average_calories(Object calories);

  /// No description provided for @weekday_mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekday_mon;

  /// No description provided for @weekday_tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekday_tue;

  /// No description provided for @weekday_wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekday_wed;

  /// No description provided for @weekday_thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekday_thu;

  /// No description provided for @weekday_fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekday_fri;

  /// No description provided for @weekday_sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekday_sat;

  /// No description provided for @weekday_sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekday_sun;

  /// No description provided for @monthly_calorie_report.
  ///
  /// In en, this message translates to:
  /// **'Monthly Calorie Report'**
  String get monthly_calorie_report;

  /// No description provided for @calorie_analysis_result.
  ///
  /// In en, this message translates to:
  /// **'Calorie Analysis Result'**
  String get calorie_analysis_result;

  /// No description provided for @calorie_saved.
  ///
  /// In en, this message translates to:
  /// **'Calories saved successfully'**
  String get calorie_saved;

  /// No description provided for @save_failed_with_error.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String save_failed_with_error(Object error);

  /// No description provided for @delete_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting'**
  String get delete_error;

  /// No description provided for @total_calories.
  ///
  /// In en, this message translates to:
  /// **'Total Calories'**
  String get total_calories;

  /// No description provided for @meal_type.
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get meal_type;

  /// No description provided for @date_and_time.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get date_and_time;

  /// No description provided for @food_detail.
  ///
  /// In en, this message translates to:
  /// **'Food Details'**
  String get food_detail;

  /// No description provided for @nutrition_info.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Facts'**
  String get nutrition_info;

  /// No description provided for @delete_calorie.
  ///
  /// In en, this message translates to:
  /// **'Delete Calorie'**
  String get delete_calorie;

  /// No description provided for @delete_item.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete_item;

  /// No description provided for @per_unit.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal per {amount}'**
  String per_unit(Object amount, Object calories);

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @carbohydrate.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrate'**
  String get carbohydrate;

  /// No description provided for @sodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get sodium;

  /// No description provided for @sugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get sugar;

  /// No description provided for @trans_fat.
  ///
  /// In en, this message translates to:
  /// **'Trans Fat'**
  String get trans_fat;

  /// No description provided for @saturated_fat.
  ///
  /// In en, this message translates to:
  /// **'Saturated Fat'**
  String get saturated_fat;

  /// No description provided for @cholesterol.
  ///
  /// In en, this message translates to:
  /// **'Cholesterol'**
  String get cholesterol;

  /// No description provided for @food_name_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Food Name'**
  String get food_name_edit;

  /// No description provided for @enter_calorie.
  ///
  /// In en, this message translates to:
  /// **'Enter calories'**
  String get enter_calorie;

  /// No description provided for @enter_food_name.
  ///
  /// In en, this message translates to:
  /// **'Enter food name'**
  String get enter_food_name;

  /// No description provided for @valid_calorie_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid calories'**
  String get valid_calorie_error;

  /// No description provided for @food_name_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter food name'**
  String get food_name_error;

  /// No description provided for @food_not_found.
  ///
  /// In en, this message translates to:
  /// **'Food information not found in the image.'**
  String get food_not_found;

  /// No description provided for @nutrition_not_found.
  ///
  /// In en, this message translates to:
  /// **'Nutritional information not found in the image.'**
  String get nutrition_not_found;

  /// No description provided for @share_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while sharing: {error}'**
  String share_error(Object error);

  /// No description provided for @daily_total_calories.
  ///
  /// In en, this message translates to:
  /// **'Daily Total Calories'**
  String get daily_total_calories;

  /// No description provided for @ingredient_analysis_photo_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of ingredients to get AI analysis'**
  String get ingredient_analysis_photo_subtitle;

  /// No description provided for @nutrition_analysis_photo_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of nutrition facts to get health insights'**
  String get nutrition_analysis_photo_subtitle;

  /// No description provided for @calorie_analysis_photo_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo and AI will analyze the calories for you'**
  String get calorie_analysis_photo_subtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'en',
        'hi',
        'ja',
        'ko',
        'pt',
        'th',
        'vi'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'th':
      return AppLocalizationsTh();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
