// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get app_name => 'IngredientLens';

  @override
  String get main_title => 'AI घटक विश्लेषक';

  @override
  String get ingredient_screen_header_title_1 =>
      'मार्केटिंग में छिपी\nसच्ची सामग्री देखें!';

  @override
  String get ingredient_screen_header_text_1 =>
      'एआई निष्पक्ष विश्लेषण प्रदान करता है।';

  @override
  String get category_section_title => 'श्रेणियां';

  @override
  String get category_section_subtitle =>
      'कृपया सामग्री विश्लेषण के लिए श्रेणी चुनें।';

  @override
  String get popular_category_section_title => 'लोकप्रिय श्रेणियां';

  @override
  String get popular_category_section_subtitle =>
      'श्रेणियां जिनका अधिकतर लोग विश्लेषण करते हैं।';

  @override
  String get ingredient_recent_title => 'हाल का विश्लेषण';

  @override
  String get ingredient_recent_subtitle =>
      'आप अपने हाल के विश्लेषण परिणामों को\nफिर से देख सकते हैं!';

  @override
  String get nutrition_screen_header_title =>
      'पोषण तत्वों की तस्वीर लें\nस्वस्थ विकल्प के लिए!';

  @override
  String get nutrition_screen_header_text => 'AI आपको स्वस्थ सलाह देता है।';

  @override
  String get nutrition_warnings => 'पोषण चेतावनी';

  @override
  String get nutrition_benefits => 'पोषण लाभ';

  @override
  String get calorie_screen_header_title_1 =>
      'भोजन की तस्वीर लें\nकैलोरी जांचने के लिए!';

  @override
  String get calorie_screen_header_text_1 => 'AI आसानी से गणना करता है।';

  @override
  String get meal_type_main_meal => 'मुख्य भोजन';

  @override
  String get meal_type_snack => 'नाश्ता';

  @override
  String get meal_type_late_night => 'मिठाई';

  @override
  String get section_title => 'श्रेणी';

  @override
  String get section_subtitle => 'तस्वीर लें और घटकों का विश्लेषण करें';

  @override
  String get ingredient_analysis_title => 'सामग्री विश्लेषण';

  @override
  String get ingredient_analysis_subtitle =>
      'तस्वीर लें और घटकों का विश्लेषण करें';

  @override
  String get recent_results_title => 'हाल के परिणाम';

  @override
  String get recent_results_subtitle => 'यहाँ हाल के विश्लेषण के परिणाम हैं';

  @override
  String get no_recent_results => 'कोई हाल के विश्लेषण परिणाम नहीं';

  @override
  String get no_recent_nutrition_results =>
      'कोई हाल के पोषण विश्लेषण परिणाम नहीं';

  @override
  String get ads_title => 'विज्ञापन';

  @override
  String get consent_required_title => 'सहमति आवश्यक';

  @override
  String get consent_required_description =>
      'हमारी AI-संचालित घटक विश्लेषण सेवा प्रदान करने के लिए, हमें व्यक्तिगत विज्ञापन दिखाने की आवश्यकता है। यह हमें AI प्रसंस्करण की लागत को कवर करने में मदद करता है।';

  @override
  String get consent_required_info =>
      'आपकी गोपनीयता हमारे लिए महत्वपूर्ण है। हम केवल प्रासंगिक विज्ञापन दिखाने और आपके अनुभव में सुधार के लिए आवश्यक डेटा एकत्र करते हैं।';

  @override
  String get consent_agree_button => 'सहमत हैं और जारी रखें';

  @override
  String get consent_exit_button => 'ऐप से बाहर निकलें';

  @override
  String get consent_decline_button => 'मना करें';

  @override
  String get announcements_title => 'घोषणाएं';

  @override
  String get announcements_subtitle => 'हमारे नवीनतम अपडेट और समाचार देखें';

  @override
  String get no_announcements => 'कोई नई घोषणाएं नहीं';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get no_notifications => 'कोई सूचना नहीं';

  @override
  String time_days_ago(Object days) {
    return '$days दिन पहले';
  }

  @override
  String time_hours_ago(Object hours) {
    return '$hours घंटे पहले';
  }

  @override
  String time_minutes_ago(Object minutes) {
    return '$minutes मिनट पहले';
  }

  @override
  String get time_just_now => 'अभी';

  @override
  String get select_category => 'श्रेणी चुनें';

  @override
  String get select_action =>
      'एक घटक सूची देखने के लिए ‘विश्लेषण’ और दो की तुलना करने के लिए ‘तुलना’ चुनें।';

  @override
  String get food => 'भोजन';

  @override
  String get cosmetics => 'सौंदर्य प्रसाधन';

  @override
  String get baby_products => 'बच्चे';

  @override
  String get pet_products => 'पालतू जानवर';

  @override
  String get medicine => 'दवा';

  @override
  String get household_products => 'घरेलू उत्पाद';

  @override
  String get cleaning_products => 'सफाई उत्पाद';

  @override
  String get vegan_products => 'शाकाहारी उत्पाद';

  @override
  String get other => 'कस्टम';

  @override
  String get nutrition_analysis => 'पोषण विश्लेषण';

  @override
  String get nutrition_analysis_title => 'पोषण विश्लेषण';

  @override
  String get nutrition_analysis_subtitle =>
      'पोषण का विश्लेषण करें\nसंतुलित आहार बनाए रखने के लिए।';

  @override
  String get calorie_analysis => 'कैलोरी विश्लेषण';

  @override
  String get add_calorie => 'कैलोरी जोड़ें';

  @override
  String get processed_food => 'प्रसंस्कृत भोजन';

  @override
  String get dessert => 'मिठाई';

  @override
  String get beverages => 'पेय';

  @override
  String get subcategories => 'उप श्रेणियाँ';

  @override
  String get select_none => 'कोई नहीं';

  @override
  String get subcategory_help_message =>
      'उप-श्रेणी चुनने से अधिक सटीक परिणाम मिलेंगे।';

  @override
  String get food_health_food => 'स्वास्थ्य भोजन';

  @override
  String get food_diet_food => 'आहार भोजन';

  @override
  String get food_dairy => 'डेयरी उत्पाद';

  @override
  String get food_processed => 'प्रसंस्कृत भोजन';

  @override
  String get food_instant => 'तत्काल भोजन';

  @override
  String get food_beverages => 'पेय';

  @override
  String get food_snacks => 'स्नैक्स';

  @override
  String get food_bakery => 'बेकरी';

  @override
  String get food_seasoning => 'मसाला';

  @override
  String get cosmetics_skincare => 'त्वचा देखभाल';

  @override
  String get cosmetics_cleansing => 'सफाई';

  @override
  String get cosmetics_suncare => 'सन केयर';

  @override
  String get cosmetics_mask => 'फेस मास्क';

  @override
  String get cosmetics_makeup => 'मेकअप';

  @override
  String get cosmetics_bodycare => 'बॉडी केयर';

  @override
  String get cosmetics_haircare => 'बाल देखभाल';

  @override
  String get cosmetics_handcare => 'हाथ की देखभाल';

  @override
  String get cosmetics_footcare => 'पैर की देखभाल';

  @override
  String get cosmetics_mens => 'पुरुषों के सौंदर्य प्रसाधन';

  @override
  String get medicine_skin_treatment => 'त्वचा उपचार';

  @override
  String get medicine_allergy => 'एलर्जी की दवा';

  @override
  String get medicine_womens => 'महिलाओं की दवा';

  @override
  String get medicine_general => 'सामान्य दवा';

  @override
  String get medicine_supplements => 'पूरक आहार';

  @override
  String get baby_skincare => 'बच्चे की त्वचा देखभाल';

  @override
  String get baby_cleansers => 'बच्चे की सफाई';

  @override
  String get baby_medicine => 'बच्चे की दवा';

  @override
  String get baby_food => 'बच्चे का भोजन';

  @override
  String get baby_formula => 'बच्चे का दूध';

  @override
  String get baby_sanitizers => 'कीटाणुनाशक';

  @override
  String get baby_detergent => 'बच्चे का डिटर्जेंट';

  @override
  String get baby_toys => 'बच्चे के खिलौने';

  @override
  String get pet_supplements => 'पालतू पूरक आहार';

  @override
  String get pet_medicine => 'पालतू दवा';

  @override
  String get pet_shampoo => 'पालतू शैम्पू';

  @override
  String get pet_special_food => 'पालतू विशेष भोजन';

  @override
  String get pet_food => 'पालतू भोजन';

  @override
  String get pet_treats => 'पालतू स्नैक्स';

  @override
  String get pet_waste => 'सफाई उत्पाद';

  @override
  String get pet_toys => 'पालतू खिलौने';

  @override
  String get household_products_dishwashing => 'डिश वॉशिंग';

  @override
  String get household_products_air_freshener => 'एयर फ्रेशनर';

  @override
  String get household_products_cleaner => 'क्लीनर';

  @override
  String get household_products_deodorizer => 'डिओडोराइजर';

  @override
  String get analyze => 'विश्लेषण';

  @override
  String get select_image_source => 'छवि स्रोत चुनें';

  @override
  String get ingredient_photography => 'कैप्चर';

  @override
  String get camera => 'कैमरा';

  @override
  String get gallery => 'गैलरी';

  @override
  String get crop_image => 'छवि क्रॉप करें';

  @override
  String get crop_instruction =>
      'कृपया स्थिति और आकार को समायोजित करें ताकि सामग्री की सामग्री सफेद बॉक्स के भीतर फिट हो जाए। आप ज़ूम इन/आउट करने के लिए पिंच कर सकते हैं और बॉक्स को स्थानांतरित करने के लिए सफेद बॉर्डर को खींच सकते हैं।';

  @override
  String get nutrition_crop_instruction =>
      'कृपया स्थिति और आकार को समायोजित करें ताकि पोषण सामग्री सफेद बॉक्स के भीतर फिट हो जाए। आप ज़ूम इन/आउट करने के लिए पिंच कर सकते हैं और बॉक्स को स्थानांतरित करने के लिए सफेद बॉर्डर को खींच सकते हैं।';

  @override
  String get reset_zoom => 'ज़ूम रीसेट करें';

  @override
  String get get_started => 'शुरू करें';

  @override
  String get onboarding_step1_title => 'स्मार्ट घटक विश्लेषण शुरू करें';

  @override
  String get onboarding_step1_description =>
      'खाद्य, कॉस्मेटिक, बेबी उत्पाद आदि विभिन्न श्रेणियों में से चुनें। अधिक सटीक विश्लेषण के लिए उप-श्रेणी चुनने से बेहतर परिणाम मिलते हैं।';

  @override
  String get onboarding_step2_title => 'AI द्वारा स्मार्ट घटक विश्लेषण';

  @override
  String get onboarding_step2_description =>
      'उत्पाद घटक सूची की फोटो लेते ही AI तुरंत सुरक्षता, विशेषताएं, और व्यक्तिगत फिटनेस का विश्लेषण करता है। प्रत्येक घटक के लिए विस्तृत जानकारी भी देखें!';

  @override
  String get onboarding_step3_title => 'दैनिक भोजन के लिए पोषण विश्लेषण';

  @override
  String get onboarding_step3_description =>
      'सुपरमार्केट, कैफे, रेस्टोरेंट में पोषण तालिका या मेनू की फोटो लें। कौन सा भोजन स्वास्थ्य के लिए बेहतर है, AI बताता है!';

  @override
  String get onboarding_step4_title => 'पोषण संतुलन की जांच करें';

  @override
  String get onboarding_step4_description =>
      'AI पोषण तालिका का विश्लेषण करके कार्बोहाइड्रेट, वसा, प्रोटीन की संतुलित मात्रा और स्वास्थ्य पर प्रभाव बताता है। स्वस्थ विकल्प चुनें!';

  @override
  String get onboarding_step5_title => 'दैनिक भोजन कैलोरी रिकॉर्डिंग';

  @override
  String get onboarding_step5_description =>
      'नाश्ता, दोपहर का भोजन, रात का भोजन, और स्नैक्स की फोटो लें। + बटन दबाकर आसानी से रिकॉर्ड करें। दैनिक कैलोरी सेवन को ट्रैक करें!';

  @override
  String get onboarding_step6_title => 'AI कैलोरी विश्लेषण और डेटा ट्रैकिंग';

  @override
  String get onboarding_step6_description =>
      'AI केवल फोटो से भोजन की पहचान करके सटीक कैलोरी गणना करता है। दैनिक, साप्ताहिक डेटा चार्ट के साथ स्वस्थ आहार प्रबंधन करें!';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get analysis_notice =>
      'AI विश्लेषण में 5-20 सेकंड लगते हैं (नेटवर्क स्थितियों के आधार पर भिन्न हो सकता है)। सेवा का समर्थन करने के लिए विश्लेषण के दौरान विज्ञापन प्रदर्शित होंगे। आप 5 सेकंड बाद विज्ञापन बंद कर सकते हैं।';

  @override
  String get dont_show_again => 'फिर न दिखाएं';

  @override
  String get positive_ingredients => 'सकारात्मक घटक';

  @override
  String get negative_ingredients => 'नकारात्मक घटक';

  @override
  String get other_ingredients => 'अन्य घटक';

  @override
  String get overall_review => 'समग्र समीक्षा';

  @override
  String get category_analysis => 'संकेतक विश्लेषण';

  @override
  String get category_comparison => 'संकेतक तुलना';

  @override
  String get nutritional_value => 'पोषण मूल्य';

  @override
  String get safety => 'सुरक्षा';

  @override
  String get natural_ingredients => 'प्राकृतिक तत्व';

  @override
  String get functional_benefits => 'कार्यात्मक लाभ';

  @override
  String get taste_quality => 'स्वाद गुणवत्ता';

  @override
  String get moisturizing => 'मॉइस्चराइजिंग';

  @override
  String get hypoallergenic => 'हाइपोएलर्जेनिक';

  @override
  String get longevity => 'स्थायित्व';

  @override
  String get stability => 'स्थिरता';

  @override
  String get absorption => 'अवशोषण';

  @override
  String get effectiveness => 'प्रभावशीलता';

  @override
  String get gentleness => 'कोमलता';

  @override
  String get safety_standards => 'सुरक्षा मानक';

  @override
  String get nutritional_balance => 'पोषण संतुलन';

  @override
  String get digestibility => 'पाचन क्षमता';

  @override
  String get palatability => 'स्वादिष्टता';

  @override
  String get functionality => 'कार्यक्षमता';

  @override
  String get side_effects => 'कम जोखिम';

  @override
  String get quality_standards => 'गुणवत्ता मानक';

  @override
  String get interactions => 'इंटरैक्शन';

  @override
  String get error => 'त्रुटि';

  @override
  String get network_error => 'नेटवर्क त्रुटि हुई। कृपया पुनः प्रयास करें।';

  @override
  String get analysis_failed => 'विश्लेषण असफल। कृपया पुनः प्रयास करें।';

  @override
  String get no_ingredients_found => 'कोई घटक नहीं मिले।';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get analyzing => 'विश्लेषण कर रहे हैं...';

  @override
  String get ai_analysis_message =>
      'Please wait a moment! AI is analyzing ingredients precisely✨\n(Takes about 10 seconds)';

  @override
  String get please_select_category => 'कृपया एक श्रेणी चुनें';

  @override
  String get enter_custom_category => 'कृपया एक कस्टम श्रेणी दर्ज करें';

  @override
  String take_photo_for_category(Object category) {
    return '$category श्रेणी के लिए एक फोटो लें';
  }

  @override
  String take_photo_of_ingredients(Object category) {
    return 'कृपया कैमरे से $category घटकों की फोटो लें या गैलरी से फोटो चुनें';
  }

  @override
  String get camera_permission_needed => 'कैमरा अनुमति आवश्यक है।';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get menu => 'मेनू';

  @override
  String photo_error(Object error) {
    return 'फोटो लेते समय त्रुटि हुई: $error';
  }

  @override
  String get photo_taken => 'फोटो ली गई';

  @override
  String category_label(Object category) {
    return 'श्रेणी: $category';
  }

  @override
  String get taking_photo => 'फोटो ली जा रही है...';

  @override
  String get photo_instruction =>
      'फोटो लेने में अपना समय लें क्योंकि आप शूटिंग के बाद घटक सूची क्षेत्र निर्दिष्ट कर सकते हैं।';

  @override
  String get check_photo_in_range =>
      'क्या घटक सूची फ्रेम के भीतर अच्छी तरह से कैप्चर हुई है?';

  @override
  String get take_photo => 'फोटो लें';

  @override
  String get horizontal_guide => 'क्षैतिज';

  @override
  String get vertical_guide => 'लंबवत';

  @override
  String get close => 'बंद करें';

  @override
  String get rotate => 'घुमाएं';

  @override
  String get done => 'पूर्ण';

  @override
  String get confirm_analysis_notice =>
      'जब आप विश्लेषण दबाते हैं, AI विश्लेषण तुरंत आगे बढ़ेगा, और विश्लेषण के दौरान विज्ञापन प्रदर्शित होंगे।';

  @override
  String get app_subtitle => 'AI-संचालित घटक विश्लेषक';

  @override
  String get ai_disclaimer =>
      'इस ऐप में घटक और पोषण विश्लेषण AI द्वारा स्वचालित रूप से जेनरेट किया गया है और यह किसी विशिष्ट संगठन या सरकारी स्रोत पर आधारित नहीं है। प्रदान की गई जानकारी केवल संदर्भ के लिए है और इसमें त्रुटियां हो सकती हैं। महत्वपूर्ण निर्णयों के लिए कृपया पेशेवरों से सलाह लें। 😊';

  @override
  String get save_screenshot => 'परिणाम सहेजें';

  @override
  String get screenshot_saved => 'परिणाम गैलरी में सहेजे गए';

  @override
  String get screenshot_failed => 'सहेजने में असफल';

  @override
  String get storage_permission_needed => 'संग्रहण अनुमति आवश्यक';

  @override
  String get save_result => 'परिणाम सहेजें';

  @override
  String get result_name => 'नाम';

  @override
  String get enter_result_name => 'परिणाम का नाम दर्ज करें';

  @override
  String get save => 'सहेजें';

  @override
  String get result_saved => 'परिणाम सफलतापूर्वक सहेजा गया';

  @override
  String get save_failed_simple => 'सहेजना असफल';

  @override
  String get saved_results => 'सहेजे गए परिणाम';

  @override
  String get saved_analysis => 'सहेजे गए विश्लेषण';

  @override
  String get no_saved_results => 'कोई सहेजे गए परिणाम नहीं';

  @override
  String get analysis => 'विश्लेषण';

  @override
  String get comparison => 'तुलना';

  @override
  String get edit_name => 'नाम संपादित करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get confirm_delete => 'हटाने की पुष्टि';

  @override
  String get confirm_delete_message => 'क्या आप वाकई हटाना चाहते हैं?';

  @override
  String get delete_success => 'सफलतापूर्वक हटा दिया गया';

  @override
  String get delete_failed => 'हटाना असफल';

  @override
  String get analysis_results => 'विश्लेषण परिणाम';

  @override
  String get compare => 'तुलना करें';

  @override
  String get product_a => 'उत्पाद A';

  @override
  String get product_b => 'उत्पाद B';

  @override
  String get compare_ingredients => 'घटकों की तुलना करें';

  @override
  String get select_both_products =>
      'तुलना करने के लिए कृपया दोनों उत्पाद चुनें';

  @override
  String get overall_comparison => 'समग्र तुलना';

  @override
  String get tap_to_add => 'जोड़ने के लिए टैप करें';

  @override
  String get compare_instruction =>
      'कृपया प्रत्येक उत्पाद की सामग्री सूची को कैप्चर करें या चुनें।';

  @override
  String get ingredient_search => 'घटक खोज';

  @override
  String ingredient_search_message(Object ingredient) {
    return 'चलिए \"$ingredient\" के बारे में और जानते हैं?';
  }

  @override
  String get search => 'खोजें';

  @override
  String get save_ingredient => 'घटक जानकारी सहेजें';

  @override
  String get enter_save_name => 'कृपया सहेजने के लिए एक नाम दर्ज करें';

  @override
  String get save_name_hint => 'उदाहरण: विटामिन सी जानकारी';

  @override
  String get enter_name => 'कृपया एक नाम दर्ज करें';

  @override
  String get save_complete => 'सहेजना पूरा';

  @override
  String get recent_ingredients_title => 'हाल की घटक खोजें';

  @override
  String get recent_ingredients_subtitle => 'हाल ही में खोजी गई घटक जानकारी';

  @override
  String get no_recent_ingredients => 'कोई हाल की घटक खोजें नहीं';

  @override
  String get ingredients => 'घटक';

  @override
  String get no_saved_ingredients => 'कोई सहेजे गए घटक नहीं';

  @override
  String get searching => 'खोज रहे हैं...';

  @override
  String get searching_ingredient_info => 'घटक जानकारी खोजी जा रही है...';

  @override
  String get description => 'विवरण';

  @override
  String get alternative_names => 'वैकल्पिक नाम';

  @override
  String get primary_functions => 'प्राथमिक कार्य';

  @override
  String get benefits => 'लाभ';

  @override
  String get precautions => 'सावधानियां';

  @override
  String get additional_info => 'अतिरिक्त जानकारी';

  @override
  String get ingredient_detail_search => 'विवरण देखें';

  @override
  String get share => 'साझा करें';

  @override
  String get sharing => 'साझा कर रहे हैं...';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get user_info => 'उपयोगकर्ता जानकारी';

  @override
  String get language => 'भाषा';

  @override
  String get privacy_policy => 'गोपनीयता नीति';

  @override
  String get terms_of_service => 'सेवा की शर्तें';

  @override
  String get help_feedback => 'सहायता और फीडबैक';

  @override
  String get religion => 'धर्म';

  @override
  String get skin => 'त्वचा का प्रकार';

  @override
  String get allergy => 'एलर्जी';

  @override
  String get diet => 'आहार प्रतिबंध';

  @override
  String get health => 'स्वास्थ्य स्थिति';

  @override
  String get add_custom => 'कस्टम जोड़ें';

  @override
  String get enter_custom_value => 'कस्टम मान दर्ज करें';

  @override
  String get custom_value_hint => 'उदाहरण: लैक्टोज असहनशीलता';

  @override
  String get value_already_exists => 'यह मान पहले से मौजूद है';

  @override
  String get preference_added => 'प्राथमिकता सफलतापूर्वक जोड़ी गई';

  @override
  String get preference_removed => 'प्राथमिकता सफलतापूर्वक हटाई गई';

  @override
  String get select_preferred_language => 'अपनी पसंदीदा भाषा चुनें';

  @override
  String language_changed_to(Object language) {
    return 'भाषा $language में बदल दी गई';
  }

  @override
  String get christianity => 'ईसाई धर्म';

  @override
  String get islam => 'इस्लाम';

  @override
  String get hinduism => 'हिंदू धर्म';

  @override
  String get buddhism => 'बौद्ध धर्म';

  @override
  String get sensitive => 'संवेदनशील';

  @override
  String get dry => 'शुष्क';

  @override
  String get oily => 'तैलीय';

  @override
  String get combination => 'मिश्रित';

  @override
  String get normal => 'सामान्य';

  @override
  String get acne_prone => 'मुंहासे वाली';

  @override
  String get atopic => 'एटोपिक';

  @override
  String get nuts => 'मेवे';

  @override
  String get dairy => 'डेयरी';

  @override
  String get eggs => 'अंडे';

  @override
  String get soy => 'सोया';

  @override
  String get gluten => 'ग्लूटेन';

  @override
  String get shellfish => 'शेलफिश';

  @override
  String get fish => 'मछली';

  @override
  String get sesame => 'तिल';

  @override
  String get vegetarian => 'शाकाहारी';

  @override
  String get vegan => 'वीगन';

  @override
  String get low_carb => 'कम कार्ब';

  @override
  String get gluten_free => 'ग्लूटेन फ्री';

  @override
  String get dairy_free => 'डेयरी फ्री';

  @override
  String get sugar_free => 'शुगर फ्री';

  @override
  String get halal => 'हलाल';

  @override
  String get diabetes => 'मधुमेह';

  @override
  String get hypertension => 'उच्च रक्तचाप';

  @override
  String get heart_disease => 'हृदय रोग';

  @override
  String get kidney_disease => 'गुर्दे की बीमारी';

  @override
  String get pregnancy => 'गर्भावस्था';

  @override
  String get breastfeeding => 'स्तनपान';

  @override
  String get daily_limit_reached =>
      'दैनिक उपयोग सीमा पहुँच गई। कृपया कल पुनः प्रयास करें।';

  @override
  String get custom_limit_reached => 'अधिकतम 3 कस्टम आइटम की अनुमति है';

  @override
  String get invalid_characters => 'विशेष वर्णों की अनुमति नहीं है';

  @override
  String get text_too_long => 'अधिकतम 20 अक्षरों की अनुमति है';

  @override
  String get apply_profile => 'मेरी प्रोफ़ाइल वरीयताएँ लागू करें';

  @override
  String get profile_settings => 'प्रोफ़ाइल सेटिंग्स';

  @override
  String get crop_area_required =>
      'सामग्री क्षेत्र चयनित नहीं है। कृपया सफेद बॉक्स को समायोजित करके सामग्री सूची शामिल करें।';

  @override
  String get baby_info => 'बच्चे की जानकारी';

  @override
  String get pet_info => 'पालतू जानवर की जानकारी';

  @override
  String get baby_age => 'आयु';

  @override
  String get pet_type => 'प्रकार';

  @override
  String get pet_breed => 'नस्ल';

  @override
  String get weight => 'वजन';

  @override
  String get neutered => 'नपुंसक स्थिति';

  @override
  String get dog => 'कुत्ता';

  @override
  String get cat => 'बिल्ली';

  @override
  String get bird => 'पक्षी';

  @override
  String get rabbit => 'खरगोश';

  @override
  String get hamster => 'हैम्स्टर';

  @override
  String get neutered_yes => 'हाँ';

  @override
  String get neutered_no => 'नहीं';

  @override
  String get baby_age_0_6_months => '0-6 महीने';

  @override
  String get baby_age_6_12_months => '6-12 महीने';

  @override
  String get baby_age_1_2_years => '1-2 साल';

  @override
  String get baby_age_2_3_years => '2-3 साल';

  @override
  String get baby_age_3_5_years => '3-5 साल';

  @override
  String get baby_age_5_plus_years => '5+ साल';

  @override
  String get baby_health_healthy => 'स्वस्थ';

  @override
  String get baby_health_asthma => 'अस्थमा';

  @override
  String get baby_health_digestive_sensitivity => 'पाचन संवेदनशीलता';

  @override
  String get baby_health_constipation => 'कब्ज';

  @override
  String get baby_health_diarrhea => 'दस्त';

  @override
  String get pet_age_0_1_year => '0-1 साल';

  @override
  String get pet_age_1_3_years => '1-3 साल';

  @override
  String get pet_age_3_5_years => '3-5 साल';

  @override
  String get pet_age_5_7_years => '5-7 साल';

  @override
  String get pet_age_7_10_years => '7-10 साल';

  @override
  String get pet_age_10_plus_years => '10+ साल';

  @override
  String get pet_weight_under_1kg => '1kg से कम';

  @override
  String get pet_weight_1_3kg => '1-3kg';

  @override
  String get pet_weight_3_5kg => '3-5kg';

  @override
  String get pet_weight_5_10kg => '5-10kg';

  @override
  String get pet_weight_10_20kg => '10-20kg';

  @override
  String get pet_weight_over_20kg => '20kg से अधिक';

  @override
  String get pet_allergy_grains => 'अनाज';

  @override
  String get pet_allergy_chicken => 'चिकन';

  @override
  String get pet_allergy_beef => 'गोमांस';

  @override
  String get pet_health_healthy => 'स्वस्थ';

  @override
  String get pet_health_arthritis => 'गठिया';

  @override
  String get pet_health_heart_disease => 'हृदय रोग';

  @override
  String get pet_health_kidney_disease => 'गुर्दे की बीमारी';

  @override
  String get pet_health_liver_disease => 'लिवर रोग';

  @override
  String get pet_health_diabetes => 'मधुमेह';

  @override
  String get pet_health_skin_disease => 'त्वचा रोग';

  @override
  String get pet_health_digestive_disease => 'पाचन रोग';

  @override
  String get pet_breed_input_message => 'कृपया नस्ल सीधे दर्ज करें';

  @override
  String get apply_user_info => 'उपयोगकर्ता जानकारी लागू करें';

  @override
  String get apply_baby_info => 'बच्चे की जानकारी लागू करें';

  @override
  String get apply_pet_info => 'पालतू जानवर की जानकारी लागू करें';

  @override
  String get vision_api_error => 'छवि में सामग्री टेक्स्ट खोजने में विफलता।';

  @override
  String get ai_evaluation_score => 'AI स्कोर';

  @override
  String get excellent => 'उत्कृष्ट';

  @override
  String get good => 'अच्छा';

  @override
  String get average => 'औसत';

  @override
  String get caution => 'सावधानी';

  @override
  String get points => 'अंक';

  @override
  String get personalized_info_applied => '(अनुकूलित जानकारी लागू)';

  @override
  String get height => 'कद';

  @override
  String get current_weight => 'वर्तमान वजन';

  @override
  String get target_weight => 'लक्ष्य वजन';

  @override
  String get height_cm => 'कद (cm)';

  @override
  String get weight_kg => 'वजन (kg)';

  @override
  String get target_weight_kg => 'लक्ष्य वजन (kg)';

  @override
  String get physical_info => 'शारीरिक जानकारी';

  @override
  String get baby_weight => 'वजन';

  @override
  String get baby_weight_under_5kg => '5kg से कम';

  @override
  String get baby_weight_5_10kg => '5-10kg';

  @override
  String get baby_weight_10_15kg => '10-15kg';

  @override
  String get baby_weight_15_20kg => '15-20kg';

  @override
  String get baby_weight_over_20kg => '20kg से अधिक';

  @override
  String get direct_input => 'Direct Input';

  @override
  String get bottom_nav_ingredient_analysis => 'Ingredient Analysis';

  @override
  String get bottom_nav_nutrition_analysis => 'Nutrition Analysis';

  @override
  String get bottom_nav_storage => 'Storage';

  @override
  String get recent_history => 'हाल का इतिहास';

  @override
  String get calorie_management => 'कैलोरी प्रबंधन';

  @override
  String get ingredients_short => 'सामग्री';

  @override
  String get nutrition_short => 'पोषण';

  @override
  String get history_short => 'इतिहास';

  @override
  String get calorie_short => 'कैलोरी';

  @override
  String get today_calories_section_title => 'आज की कैलोरी';

  @override
  String get today_calories_section_subtitle =>
      'आज आपने जो कैलोरी रिकॉर्ड की है उसे चेक करें।';

  @override
  String get no_calories_today => 'आज कोई कैलोरी रिकॉर्ड नहीं की गई';

  @override
  String more_items_count(Object count) {
    return '$count और आइटम';
  }

  @override
  String get weekly_calories_section_title => 'साप्ताहिक कैलोरी';

  @override
  String get weekly_calories_section_subtitle =>
      'सप्ताह में दैनिक कैलोरी सेवन में बदलाव देखें।';

  @override
  String daily_average_calories(Object calories) {
    return 'दैनिक औसत $calories kcal';
  }

  @override
  String get weekday_mon => 'सोम';

  @override
  String get weekday_tue => 'मंगल';

  @override
  String get weekday_wed => 'बुध';

  @override
  String get weekday_thu => 'गुरु';

  @override
  String get weekday_fri => 'शुक्र';

  @override
  String get weekday_sat => 'शनि';

  @override
  String get weekday_sun => 'रवि';

  @override
  String get monthly_calorie_report => 'मासिक कैलोरी रिपोर्ट';

  @override
  String get calorie_analysis_result => 'कैलोरी विश्लेषण परिणाम';

  @override
  String get calorie_saved => 'कैलोरी सफलतापूर्वक सेव हो गई';

  @override
  String save_failed_with_error(Object error) {
    return 'सेव विफल: $error';
  }

  @override
  String get delete_error => 'डिलीट करते समय एरर आया';

  @override
  String get total_calories => 'कुल कैलोरी';

  @override
  String get meal_type => 'भोजन का प्रकार';

  @override
  String get date_and_time => 'तारीख और समय';

  @override
  String get food_detail => 'भोजन विवरण';

  @override
  String get nutrition_info => 'पोषण तत्व';

  @override
  String get delete_calorie => 'कैलोरी डिलीट';

  @override
  String get delete_item => 'डिलीट करें';

  @override
  String per_unit(Object amount, Object calories) {
    return '$amount पर $calories kcal';
  }

  @override
  String get protein => 'प्रोटीन';

  @override
  String get fat => 'चर्बी';

  @override
  String get carbohydrate => 'कार्बोहाइड्रेट';

  @override
  String get sodium => 'सोडियम';

  @override
  String get sugar => 'शुगर';

  @override
  String get trans_fat => 'ट्रांस फैट';

  @override
  String get saturated_fat => 'सेचुरेटेड फैट';

  @override
  String get cholesterol => 'कोलेस्ट्रॉल';

  @override
  String get food_name_edit => 'भोजन का नाम एडिट करें';

  @override
  String get enter_calorie => 'कैलोरी दर्ज करें';

  @override
  String get enter_food_name => 'भोजन का नाम दर्ज करें';

  @override
  String get valid_calorie_error => 'कृपया सही कैलोरी दर्ज करें';

  @override
  String get food_name_error => 'कृपया भोजन का नाम दर्ज करें';

  @override
  String get food_not_found => 'छवि में भोजन की जानकारी नहीं मिली।';

  @override
  String get nutrition_not_found => 'छवि में पोषण संबंधी जानकारी नहीं मिली।';

  @override
  String share_error(Object error) {
    return 'साझा करते समय त्रुटि हुई: $error';
  }

  @override
  String get daily_total_calories => 'दैनिक कुल कैलोरी';

  @override
  String get ingredient_analysis_photo_subtitle =>
      'AI विश्लेषण के लिए सामग्री की तस्वीर खींचें';

  @override
  String get nutrition_analysis_photo_subtitle =>
      'स्वास्थ्य जानकारी के लिए पोषण तालिका की तस्वीर खींचें';

  @override
  String get calorie_analysis_photo_subtitle =>
      'फोटो लें और AI आपके लिए कैलोरी का विश्लेषण करेगा';
}
