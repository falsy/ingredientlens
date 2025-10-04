// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get app_name => '성분렌즈';

  @override
  String get main_title => 'AI 성분 분석기';

  @override
  String get ingredient_screen_header_title_1 => '마케팅에 숨겨진\n진짜 성분을 확인하세요!';

  @override
  String get ingredient_screen_header_text_1 => 'AI가 객관적으로 분석해 드립니다.';

  @override
  String get category_section_title => '카테고리';

  @override
  String get category_section_subtitle => '성분을 분석할 카테고리를 선택해 주세요.';

  @override
  String get popular_category_section_title => '인기 카테고리';

  @override
  String get popular_category_section_subtitle => '많은 사람들이 분석하는 카테고리입니다.';

  @override
  String get ingredient_recent_title => '최근 분석';

  @override
  String get ingredient_recent_subtitle => '최근 분석 결과를 다시 확인할 수 있어요!';

  @override
  String get nutrition_screen_header_title => '영양성분을 촬영해서\n건강한 선택을 하세요!';

  @override
  String get nutrition_screen_header_text => 'AI가 건강한 조언을 해 드립니다.';

  @override
  String get nutrition_warnings => '영양 주의사항';

  @override
  String get nutrition_benefits => '영양 이점';

  @override
  String get calorie_screen_header_title_1 => '음식을 촬영해서\n칼로리를 확인하세요!';

  @override
  String get calorie_screen_header_text_1 => 'AI가 간편하게 계산해 드립니다.';

  @override
  String get meal_type_main_meal => '정식';

  @override
  String get meal_type_snack => '간식';

  @override
  String get meal_type_late_night => '후식';

  @override
  String get section_title => '카테고리';

  @override
  String get section_subtitle => '사진을 찍고 성분을 분석하세요';

  @override
  String get ingredient_analysis_title => '성분 분석';

  @override
  String get ingredient_analysis_subtitle => '사진을 찍고 성분을 분석하세요';

  @override
  String get recent_results_title => '최근 분석 기록';

  @override
  String get recent_results_subtitle => '최근 분석한 결과입니다';

  @override
  String get no_recent_results => '최근 분석 결과가 없습니다';

  @override
  String get no_recent_nutrition_results => '최근 영양 분석 결과가 없습니다';

  @override
  String get ads_title => '광고';

  @override
  String get consent_required_title => '동의가 필요합니다';

  @override
  String get consent_required_description =>
      'AI 기반 성분 분석 서비스를 제공하기 위해 맞춤형 광고를 표시해야 합니다. 이는 AI 처리 비용을 충당하는 데 도움이 됩니다.';

  @override
  String get consent_required_info =>
      '귀하의 개인정보는 저희에게 중요합니다. 관련 광고 표시와 사용자 경험 개선에 필요한 데이터만 수집합니다.';

  @override
  String get consent_agree_button => '동의하고 계속하기';

  @override
  String get consent_exit_button => '앱 종료';

  @override
  String get consent_decline_button => '동의 안 함';

  @override
  String get announcements_title => '공지사항';

  @override
  String get announcements_subtitle => '최신 업데이트와 소식을 확인하세요';

  @override
  String get no_announcements => '새로운 공지사항이 없습니다';

  @override
  String get notifications => '알림';

  @override
  String get no_notifications => '알림이 없습니다';

  @override
  String time_days_ago(Object days) {
    return '$days일 전';
  }

  @override
  String time_hours_ago(Object hours) {
    return '$hours시간 전';
  }

  @override
  String time_minutes_ago(Object minutes) {
    return '$minutes분 전';
  }

  @override
  String get time_just_now => '방금 전';

  @override
  String get select_category => '카테고리 선택';

  @override
  String get select_action =>
      '하나의 성분표를 확인은 \'분석\', 두 개의 성분표 비교는 \'비교\' 버튼을 선택하세요.';

  @override
  String get food => '식품';

  @override
  String get cosmetics => '화장품';

  @override
  String get baby_products => '육아용품';

  @override
  String get pet_products => '펫용품';

  @override
  String get medicine => '의약품';

  @override
  String get household_products => '생활용품';

  @override
  String get cleaning_products => '세정용품';

  @override
  String get vegan_products => '비건품';

  @override
  String get other => '기타';

  @override
  String get nutrition_analysis => '영양성분 분석';

  @override
  String get nutrition_analysis_title => '영양성분 분석';

  @override
  String get nutrition_analysis_subtitle => '영양성분을 분석하여\n균형 잡힌 식단을 유지하세요.';

  @override
  String get calorie_analysis => '열량 분석';

  @override
  String get add_calorie => '칼로리 추가';

  @override
  String get processed_food => '가공식품';

  @override
  String get dessert => '디저트';

  @override
  String get beverages => '음료수';

  @override
  String get subcategories => '세부 카테고리';

  @override
  String get select_none => '선택 안함';

  @override
  String get subcategory_help_message => '세부 카테고리를 선택하면 보다 정확한 결과를 얻을 수 있습니다.';

  @override
  String get food_health_food => '건강식품';

  @override
  String get food_diet_food => '다이어트식품';

  @override
  String get food_dairy => '유제품';

  @override
  String get food_processed => '가공식품';

  @override
  String get food_instant => '즉석식품';

  @override
  String get food_beverages => '음료';

  @override
  String get food_snacks => '스낵';

  @override
  String get food_bakery => '베이커리';

  @override
  String get food_seasoning => '조미료';

  @override
  String get cosmetics_skincare => '스킨케어';

  @override
  String get cosmetics_cleansing => '클렌징';

  @override
  String get cosmetics_suncare => '선케어';

  @override
  String get cosmetics_mask => '마스크팩';

  @override
  String get cosmetics_makeup => '메이크업';

  @override
  String get cosmetics_bodycare => '바디케어';

  @override
  String get cosmetics_haircare => '헤어케어';

  @override
  String get cosmetics_handcare => '핸드케어';

  @override
  String get cosmetics_footcare => '풋케어';

  @override
  String get cosmetics_mens => '남성용 화장품';

  @override
  String get medicine_skin_treatment => '피부질환 치료제';

  @override
  String get medicine_allergy => '알레르기 치료제';

  @override
  String get medicine_womens => '여성용 의약품';

  @override
  String get medicine_general => '일반의약품';

  @override
  String get medicine_supplements => '영양제';

  @override
  String get baby_skincare => '유아용 스킨케어';

  @override
  String get baby_cleansers => '유아용 세정제';

  @override
  String get baby_medicine => '유아용 의약품';

  @override
  String get baby_food => '이유식';

  @override
  String get baby_formula => '분유';

  @override
  String get baby_sanitizers => '소독용품';

  @override
  String get baby_detergent => '유아세제';

  @override
  String get baby_toys => '유아용 장난감';

  @override
  String get pet_supplements => '펫 영양제';

  @override
  String get pet_medicine => '펫 의약품';

  @override
  String get pet_shampoo => '펫 샴푸';

  @override
  String get pet_special_food => '펫 특수식';

  @override
  String get pet_food => '펫 사료';

  @override
  String get pet_treats => '펫 간식';

  @override
  String get pet_waste => '배변용품';

  @override
  String get pet_toys => '펫 장난감';

  @override
  String get household_products_dishwashing => '주방세제';

  @override
  String get household_products_air_freshener => '방향제';

  @override
  String get household_products_cleaner => '세정제';

  @override
  String get household_products_deodorizer => '탈취제';

  @override
  String get analyze => '분석';

  @override
  String get select_image_source => '이미지 선택';

  @override
  String get ingredient_photography => '촬영';

  @override
  String get camera => '카메라';

  @override
  String get gallery => '갤러리';

  @override
  String get crop_image => '이미지 자르기';

  @override
  String get crop_instruction =>
      '성분 내용이 흰색 박스 안에 들어오도록 위치와 크기를 조절해 주세요. 두 손가락으로 확대/축소할 수 있고 흰색 선을 선택해 박스를 이동시킬 수 있습니다.';

  @override
  String get nutrition_crop_instruction =>
      '영양 성분 내용이 흰색 박스 안에 들어오도록 위치와 크기를 조절해 주세요. 두 손가락으로 확대/축소할 수 있고 흰색 선을 선택해 박스를 이동시킬 수 있습니다.';

  @override
  String get reset_zoom => '확대/축소 초기화';

  @override
  String get get_started => '시작하기';

  @override
  String get onboarding_step1_title => '성분 카테고리 선택';

  @override
  String get onboarding_step1_description => '성분 분석 탭에서 확인할 제품 종류를 고르세요.';

  @override
  String get onboarding_step2_title => '성분 촬영 및 분석';

  @override
  String get onboarding_step2_description =>
      '제품의 원재료명을 촬영하면 AI가 안전성과 특징을 분석해 드립니다.';

  @override
  String get onboarding_step3_title => '영양 카테고리 선택';

  @override
  String get onboarding_step3_description => '영양 분석 탭에서 확인할 식품 종류를 선택하세요.';

  @override
  String get onboarding_step4_title => '영양 성분 촬영';

  @override
  String get onboarding_step4_description =>
      '탄수화물, 지방, 단백질 등 영양 정보를 촬영하면 AI가 객관적으로 분석합니다.';

  @override
  String get onboarding_step5_title => '식사 사진 추가';

  @override
  String get onboarding_step5_description => '+ 버튼을 눌러 식사 사진을 찍어 등록하세요.';

  @override
  String get onboarding_step6_title => 'AI 열량 분석';

  @override
  String get onboarding_step6_description => 'AI가 식사 사진을 분석해 대략적인 칼로리를 알려드립니다.';

  @override
  String get confirm => '확인';

  @override
  String get cancel => '취소';

  @override
  String get analysis_notice =>
      'AI 분석에는 5-20초 정도 시간이 소요되며(네트워크 상태에 따라 달라질 수 있음) 분석을 진행하는 동안 서비스 운영을 위해 광고가 노출되며 5초 이후에 광고를 닫을 수 있습니다.';

  @override
  String get dont_show_again => '다시 보지 않음';

  @override
  String get positive_ingredients => '긍정적인 성분';

  @override
  String get negative_ingredients => '부정적인 성분';

  @override
  String get other_ingredients => '기타 성분';

  @override
  String get overall_review => '총평';

  @override
  String get category_analysis => '지표 분석';

  @override
  String get category_comparison => '지표 비교';

  @override
  String get nutritional_value => '영양가';

  @override
  String get safety => '안전성';

  @override
  String get natural_ingredients => '천연성분';

  @override
  String get functional_benefits => '기능성';

  @override
  String get taste_quality => '맛품질';

  @override
  String get moisturizing => '보습력';

  @override
  String get hypoallergenic => '저자극성';

  @override
  String get longevity => '지속력';

  @override
  String get stability => '안정성';

  @override
  String get absorption => '흡수력';

  @override
  String get effectiveness => '효과성';

  @override
  String get gentleness => '순함';

  @override
  String get safety_standards => '안전기준';

  @override
  String get nutritional_balance => '영양균형';

  @override
  String get digestibility => '소화성';

  @override
  String get palatability => '기호성';

  @override
  String get functionality => '기능성';

  @override
  String get side_effects => '저위험성';

  @override
  String get quality_standards => '품질기준';

  @override
  String get interactions => '상호작용';

  @override
  String get error => '오류';

  @override
  String get network_error => '네트워크 오류가 발생했습니다. 다시 시도해주세요.';

  @override
  String get analysis_failed => '분석에 실패했습니다. 다시 시도해주세요.';

  @override
  String get no_ingredients_found => '성분을 찾을 수 없습니다.';

  @override
  String get loading => '로딩 중...';

  @override
  String get analyzing => '분석 중...';

  @override
  String get ai_analysis_message =>
      '조금만 기다려 주세요!\nAI가 성분 정보를 정밀 분석하고 있어요✨\n(약 10초 소요)';

  @override
  String get please_select_category => '카테고리를 선택해주세요';

  @override
  String get enter_custom_category => '맞춤 카테고리를 입력해주세요';

  @override
  String take_photo_for_category(Object category) {
    return '$category 카테고리의 제품을 촬영해주세요';
  }

  @override
  String take_photo_of_ingredients(Object category) {
    return '$category 성분표를 카메라로 찍거나 갤러리에서 사진을 선택해주세요';
  }

  @override
  String get camera_permission_needed => '카메라 권한이 필요합니다.';

  @override
  String get settings => '설정';

  @override
  String get menu => '메뉴';

  @override
  String photo_error(Object error) {
    return '사진 촬영 중 오류가 발생했습니다: $error';
  }

  @override
  String get photo_taken => '사진 촬영 완료';

  @override
  String category_label(Object category) {
    return '카테고리: $category';
  }

  @override
  String get taking_photo => '사진 촬영 중...';

  @override
  String get photo_instruction => '사진 촬영 후에 성분표 영역을 지정할 수 있기 때문에 여유롭게 촬영해 주세요.';

  @override
  String get check_photo_in_range => '성분표가 범위 안에 잘 찍혔나요?';

  @override
  String get take_photo => '사진 촬영';

  @override
  String get horizontal_guide => '가로';

  @override
  String get vertical_guide => '세로';

  @override
  String get close => '닫기';

  @override
  String get rotate => '회전';

  @override
  String get done => '완료';

  @override
  String get confirm_analysis_notice =>
      '분석을 누르시면 AI 분석이 즉시 진행되며,\n분석 중에는 광고가 함께 표시됩니다.';

  @override
  String get app_subtitle => 'AI를 활용한 성분표 분석기';

  @override
  String get ai_disclaimer =>
      '본 앱의 성분·영양 분석은 AI에 의해 자동 생성된 결과로, 특정 기관이나 공식 자료를 근거로 하지 않습니다. 제공된 정보는 참고용이며 오류가 있을 수 있으니, 중요한 결정은 반드시 전문가와 상담하세요. 😊';

  @override
  String get save_screenshot => '결과 저장하기';

  @override
  String get screenshot_saved => '결과가 갤러리에 저장되었습니다';

  @override
  String get screenshot_failed => '저장에 실패했습니다';

  @override
  String get storage_permission_needed => '저장소 권한이 필요합니다';

  @override
  String get save_result => '결과 저장';

  @override
  String get result_name => '이름';

  @override
  String get enter_result_name => '결과 이름을 입력하세요';

  @override
  String get save => '저장';

  @override
  String get result_saved => '결과가 저장되었습니다';

  @override
  String get save_failed_simple => '저장에 실패했습니다';

  @override
  String get saved_results => '저장된 결과';

  @override
  String get saved_analysis => '저장된 분석';

  @override
  String get no_saved_results => '저장된 결과가 없습니다';

  @override
  String get analysis => '분석';

  @override
  String get comparison => '비교';

  @override
  String get edit_name => '이름 변경';

  @override
  String get delete => '삭제';

  @override
  String get confirm_delete => '삭제 확인';

  @override
  String get confirm_delete_message => '정말로 삭제하시겠습니까?';

  @override
  String get delete_success => '삭제되었습니다';

  @override
  String get delete_failed => '삭제에 실패했습니다';

  @override
  String get analysis_results => '분석 결과';

  @override
  String get compare => '비교';

  @override
  String get product_a => '제품 A';

  @override
  String get product_b => '제품 B';

  @override
  String get compare_ingredients => '성분 비교';

  @override
  String get select_both_products => '비교할 두 제품을 모두 선택해주세요';

  @override
  String get overall_comparison => '종합 비교';

  @override
  String get tap_to_add => '탭하여 추가';

  @override
  String get compare_instruction => '각 제품의 성분표를 촬영하거나 선택해 주세요.';

  @override
  String get ingredient_search => '성분 검색';

  @override
  String ingredient_search_message(Object ingredient) {
    return '\"$ingredient\"을 자세히 알아볼까요?';
  }

  @override
  String get search => '검색';

  @override
  String get save_ingredient => '성분 정보 저장';

  @override
  String get enter_save_name => '저장할 이름을 입력해주세요';

  @override
  String get save_name_hint => '예: 비타민C 정보';

  @override
  String get enter_name => '이름을 입력해주세요';

  @override
  String get save_complete => '저장이 완료되었습니다';

  @override
  String get recent_ingredients_title => '최근 성분 검색';

  @override
  String get recent_ingredients_subtitle => '최근 검색한 성분 정보입니다';

  @override
  String get no_recent_ingredients => '최근 성분 검색 기록이 없습니다';

  @override
  String get ingredients => '성분';

  @override
  String get no_saved_ingredients => '저장된 성분이 없습니다';

  @override
  String get searching => '검색 중...';

  @override
  String get searching_ingredient_info => '성분 정보를 검색하고 있습니다...';

  @override
  String get description => '설명';

  @override
  String get alternative_names => '다른 이름';

  @override
  String get primary_functions => '주요 기능';

  @override
  String get benefits => '효능 및 이점';

  @override
  String get precautions => '주의사항';

  @override
  String get additional_info => '추가 정보';

  @override
  String get ingredient_detail_search => '성분 상세 검색';

  @override
  String get share => '공유하기';

  @override
  String get sharing => '공유 중...';

  @override
  String get profile => '프로필';

  @override
  String get user_info => '사용자 정보';

  @override
  String get language => '언어';

  @override
  String get privacy_policy => '개인정보 처리방침';

  @override
  String get terms_of_service => '이용약관';

  @override
  String get help_feedback => '도움 & 피드백';

  @override
  String get religion => '종교';

  @override
  String get skin => '피부 타입';

  @override
  String get allergy => '알레르기';

  @override
  String get diet => '식이 제한';

  @override
  String get health => '건강 상태';

  @override
  String get add_custom => '직접 추가';

  @override
  String get enter_custom_value => '직접 입력하세요';

  @override
  String get custom_value_hint => '예: 유당불내증';

  @override
  String get value_already_exists => '이미 존재하는 값입니다';

  @override
  String get preference_added => '설정이 추가되었습니다';

  @override
  String get preference_removed => '설정이 제거되었습니다';

  @override
  String get select_preferred_language => '원하는 언어를 선택하세요';

  @override
  String language_changed_to(Object language) {
    return '언어가 $language로 변경되었습니다';
  }

  @override
  String get christianity => '기독교';

  @override
  String get islam => '이슬람교';

  @override
  String get hinduism => '힌두교';

  @override
  String get buddhism => '불교';

  @override
  String get sensitive => '민감성';

  @override
  String get dry => '건성';

  @override
  String get oily => '지성';

  @override
  String get combination => '복합성';

  @override
  String get normal => '보통';

  @override
  String get acne_prone => '여드름성';

  @override
  String get atopic => '아토피';

  @override
  String get nuts => '견과류';

  @override
  String get dairy => '유제품';

  @override
  String get eggs => '계란';

  @override
  String get soy => '콩';

  @override
  String get gluten => '글루텐';

  @override
  String get shellfish => '갑각류';

  @override
  String get fish => '생선';

  @override
  String get sesame => '참깨';

  @override
  String get vegetarian => '채식주의';

  @override
  String get vegan => '비건';

  @override
  String get low_carb => '저탄수화물';

  @override
  String get gluten_free => '글루텐 프리';

  @override
  String get dairy_free => '유제품 프리';

  @override
  String get sugar_free => '무설탕';

  @override
  String get halal => '할랄';

  @override
  String get diabetes => '당뇨병';

  @override
  String get hypertension => '고혈압';

  @override
  String get heart_disease => '심장병';

  @override
  String get kidney_disease => '신장병';

  @override
  String get pregnancy => '임신';

  @override
  String get breastfeeding => '수유';

  @override
  String get daily_limit_reached => '일일 사용 한도에 도달했습니다. 내일 다시 시도해 주세요.';

  @override
  String get custom_limit_reached => '사용자 정의 항목은 최대 3개까지 가능합니다';

  @override
  String get invalid_characters => '특수문자는 사용할 수 없습니다';

  @override
  String get text_too_long => '최대 20자까지 입력 가능합니다';

  @override
  String get apply_profile => '내 프로필 설정 반영하기';

  @override
  String get profile_settings => '프로필 설정';

  @override
  String get crop_area_required =>
      '성분표 영역이 선택되지 않았어요. 흰색 박스를 조절해서 성분표를 포함해주세요.';

  @override
  String get baby_info => '아기 정보';

  @override
  String get pet_info => '반려동물 정보';

  @override
  String get baby_age => '나이';

  @override
  String get pet_type => '종류';

  @override
  String get pet_breed => '품종';

  @override
  String get weight => '체중';

  @override
  String get neutered => '중성화 여부';

  @override
  String get dog => '강아지';

  @override
  String get cat => '고양이';

  @override
  String get bird => '새';

  @override
  String get rabbit => '토끼';

  @override
  String get hamster => '햄스터';

  @override
  String get neutered_yes => '완료';

  @override
  String get neutered_no => '미완료';

  @override
  String get baby_age_0_6_months => '0-6개월';

  @override
  String get baby_age_6_12_months => '6-12개월';

  @override
  String get baby_age_1_2_years => '1-2세';

  @override
  String get baby_age_2_3_years => '2-3세';

  @override
  String get baby_age_3_5_years => '3-5세';

  @override
  String get baby_age_5_plus_years => '5세 이상';

  @override
  String get baby_health_healthy => '건강함';

  @override
  String get baby_health_asthma => '천식';

  @override
  String get baby_health_digestive_sensitivity => '장 민감성';

  @override
  String get baby_health_constipation => '변비';

  @override
  String get baby_health_diarrhea => '설사';

  @override
  String get pet_age_0_1_year => '0-1세';

  @override
  String get pet_age_1_3_years => '1-3세';

  @override
  String get pet_age_3_5_years => '3-5세';

  @override
  String get pet_age_5_7_years => '5-7세';

  @override
  String get pet_age_7_10_years => '7-10세';

  @override
  String get pet_age_10_plus_years => '10세 이상';

  @override
  String get pet_weight_under_1kg => '1kg 미만';

  @override
  String get pet_weight_1_3kg => '1-3kg';

  @override
  String get pet_weight_3_5kg => '3-5kg';

  @override
  String get pet_weight_5_10kg => '5-10kg';

  @override
  String get pet_weight_10_20kg => '10-20kg';

  @override
  String get pet_weight_over_20kg => '20kg 이상';

  @override
  String get pet_allergy_grains => '곡물';

  @override
  String get pet_allergy_chicken => '닭고기';

  @override
  String get pet_allergy_beef => '소고기';

  @override
  String get pet_health_healthy => '건강함';

  @override
  String get pet_health_arthritis => '관절염';

  @override
  String get pet_health_heart_disease => '심장질환';

  @override
  String get pet_health_kidney_disease => '신장질환';

  @override
  String get pet_health_liver_disease => '간질환';

  @override
  String get pet_health_diabetes => '당뇨';

  @override
  String get pet_health_skin_disease => '피부질환';

  @override
  String get pet_health_digestive_disease => '소화기질환';

  @override
  String get pet_breed_input_message => '품종은 직접 입력해 주세요';

  @override
  String get apply_user_info => '사용자 정보 반영하기';

  @override
  String get apply_baby_info => '아기 정보 반영하기';

  @override
  String get apply_pet_info => '반려동물 정보 반영하기';

  @override
  String get vision_api_error => '이미지에서 성분 텍스트를 찾는데 실패하였습니다.';

  @override
  String get ai_evaluation_score => 'AI 점수';

  @override
  String get excellent => '우수';

  @override
  String get good => '양호';

  @override
  String get average => '보통';

  @override
  String get caution => '주의';

  @override
  String get points => '점';

  @override
  String get personalized_info_applied => '(맞춤형 정보 반영)';

  @override
  String get height => '키';

  @override
  String get current_weight => '현재 체중';

  @override
  String get target_weight => '목표 체중';

  @override
  String get height_cm => '키 (cm)';

  @override
  String get weight_kg => '체중 (kg)';

  @override
  String get target_weight_kg => '목표 체중 (kg)';

  @override
  String get physical_info => '신체 정보';

  @override
  String get baby_weight => '체중';

  @override
  String get baby_weight_under_5kg => '5kg 미만';

  @override
  String get baby_weight_5_10kg => '5-10kg';

  @override
  String get baby_weight_10_15kg => '10-15kg';

  @override
  String get baby_weight_15_20kg => '15-20kg';

  @override
  String get baby_weight_over_20kg => '20kg 이상';

  @override
  String get direct_input => '직접 입력';

  @override
  String get bottom_nav_ingredient_analysis => 'Ingredient Analysis';

  @override
  String get bottom_nav_nutrition_analysis => 'Nutrition Analysis';

  @override
  String get bottom_nav_storage => 'Storage';

  @override
  String get recent_history => '최근 기록';

  @override
  String get calorie_management => '열량 관리';

  @override
  String get ingredients_short => '성분';

  @override
  String get nutrition_short => '영양';

  @override
  String get history_short => '기록';

  @override
  String get calorie_short => '열량';

  @override
  String get today_calories_section_title => '오늘의 칼로리';

  @override
  String get today_calories_section_subtitle => '오늘 하루 기록한 칼로리를 확인하세요.';

  @override
  String get no_calories_today => '오늘 기록된 칼로리가 없습니다';

  @override
  String more_items_count(Object count) {
    return '$count개 더 있음';
  }

  @override
  String get weekly_calories_section_title => '주간 칼로리';

  @override
  String get weekly_calories_section_subtitle =>
      '일주일 동안의 하루별 칼로리\n섭취 변화를 한눈에 확인하세요.';

  @override
  String daily_average_calories(Object calories) {
    return '일평균 $calories kcal';
  }

  @override
  String get weekday_mon => '월';

  @override
  String get weekday_tue => '화';

  @override
  String get weekday_wed => '수';

  @override
  String get weekday_thu => '목';

  @override
  String get weekday_fri => '금';

  @override
  String get weekday_sat => '토';

  @override
  String get weekday_sun => '일';

  @override
  String get monthly_calorie_report => '월간 열량 리포트';

  @override
  String get calorie_analysis_result => '칼로리 분석 결과';

  @override
  String get calorie_saved => '칼로리가 저장되었습니다';

  @override
  String save_failed_with_error(Object error) {
    return '저장 실패: $error';
  }

  @override
  String get delete_error => '삭제 중 오류가 발생했습니다';

  @override
  String get total_calories => '총 칼로리';

  @override
  String get meal_type => '식사 종류';

  @override
  String get date_and_time => '날짜 및 시간';

  @override
  String get food_detail => '음식 상세';

  @override
  String get nutrition_info => '영양성분';

  @override
  String get delete_calorie => '칼로리 삭제';

  @override
  String get delete_item => '삭제하기';

  @override
  String per_unit(Object amount, Object calories) {
    return '$amount 당 $calories kcal';
  }

  @override
  String get protein => '단백질';

  @override
  String get fat => '지방';

  @override
  String get carbohydrate => '탄수화물';

  @override
  String get sodium => '나트륨';

  @override
  String get sugar => '당류';

  @override
  String get trans_fat => '트랜스지방';

  @override
  String get saturated_fat => '포화지방';

  @override
  String get cholesterol => '콜레스테롤';

  @override
  String get food_name_edit => '음식 이름 수정';

  @override
  String get enter_calorie => '칼로리 입력';

  @override
  String get enter_food_name => '음식 이름 입력';

  @override
  String get valid_calorie_error => '올바른 칼로리를 입력해주세요';

  @override
  String get food_name_error => '음식 이름을 입력해주세요';

  @override
  String get food_not_found => '이미지에서 음식 정보를 찾을 수 없습니다.';

  @override
  String get nutrition_not_found => '이미지에서 영양성분 정보를 찾을 수 없습니다.';

  @override
  String share_error(Object error) {
    return '공유 중 오류가 발생했습니다: $error';
  }

  @override
  String get daily_total_calories => '하루 총 칼로리';

  @override
  String get ingredient_analysis_photo_subtitle => '성분표를 촬영하여 AI 분석을 받아보세요';

  @override
  String get nutrition_analysis_photo_subtitle => '영양성분표를 촬영하여 건강 정보를 확인하세요';

  @override
  String get calorie_analysis_photo_subtitle => '음식을 촬영하면 AI가 칼로리를 분석해 드립니다';
}
