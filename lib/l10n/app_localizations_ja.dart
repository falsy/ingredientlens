// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get app_name => '成分レンズ';

  @override
  String get main_title => 'AI成分分析器';

  @override
  String get ingredient_screen_header_title_1 => 'マーケティングの裏に\n本当の成分を見よう！';

  @override
  String get ingredient_screen_header_text_1 => 'AIが客観的に分析いたします。';

  @override
  String get category_section_title => 'カテゴリー';

  @override
  String get category_section_subtitle => '成分分析カテゴリーを選んでください。';

  @override
  String get popular_category_section_title => '人気カテゴリー';

  @override
  String get popular_category_section_subtitle => '多くの人が分析しているカテゴリーです。';

  @override
  String get ingredient_recent_title => '最近の分析';

  @override
  String get ingredient_recent_subtitle => '最近の分析結果を再確認できます！';

  @override
  String get nutrition_screen_header_title => '栄養成分を撮って\n健康的に選ぼう！';

  @override
  String get nutrition_screen_header_text => 'AIが健康アドバイスをします。';

  @override
  String get nutrition_warnings => '栄養注意事項';

  @override
  String get nutrition_benefits => '栄養効果';

  @override
  String get calorie_screen_header_title_1 => '食べ物を撮って\nカロリーを見よう！';

  @override
  String get calorie_screen_header_text_1 => 'AIが簡単に計算いたします。';

  @override
  String get meal_type_main_meal => '正餐';

  @override
  String get meal_type_snack => '間食';

  @override
  String get meal_type_late_night => 'デザート';

  @override
  String get section_title => 'カテゴリ';

  @override
  String get section_subtitle => '写真を撮って成分を分析';

  @override
  String get ingredient_analysis_title => '成分分析';

  @override
  String get ingredient_analysis_subtitle => '写真を撮って成分を分析';

  @override
  String get recent_results_title => '最近の分析記録';

  @override
  String get recent_results_subtitle => '最近分析した結果です';

  @override
  String get no_recent_results => '最近の分析結果がありません';

  @override
  String get no_recent_nutrition_results => '最近の栄養分析結果がありません';

  @override
  String get ads_title => '広告';

  @override
  String get consent_required_title => '同意が必要です';

  @override
  String get consent_required_description =>
      'AI搭載の成分分析サービスを提供するために、パーソナライズされた広告を表示する必要があります。これはAI処理のコストをカバーするのに役立ちます。';

  @override
  String get consent_required_info =>
      'あなたのプライバシーは私たちにとって重要です。関連する広告の表示と体験の向上に必要なデータのみを収集します。';

  @override
  String get consent_agree_button => '同意して続行';

  @override
  String get consent_exit_button => 'アプリを終了';

  @override
  String get consent_decline_button => '同意しない';

  @override
  String get announcements_title => 'お知らせ';

  @override
  String get announcements_subtitle => '最新の更新情報とニュースをご確認ください';

  @override
  String get no_announcements => '新しいお知らせはありません';

  @override
  String get notifications => '通知';

  @override
  String get no_notifications => '通知がありません';

  @override
  String time_days_ago(Object days) {
    return '$days日前';
  }

  @override
  String time_hours_ago(Object hours) {
    return '$hours時間前';
  }

  @override
  String time_minutes_ago(Object minutes) {
    return '$minutes分前';
  }

  @override
  String get time_just_now => 'たった今';

  @override
  String get select_category => 'カテゴリを選択';

  @override
  String get select_action => '成分表を1つ確認するには「分析」、2つを比較するには「比較」を選んでください。';

  @override
  String get food => '食品';

  @override
  String get cosmetics => '化粧品';

  @override
  String get baby_products => 'ベビー用品';

  @override
  String get pet_products => 'ペット用品';

  @override
  String get medicine => '医薬品';

  @override
  String get household_products => '生活用品';

  @override
  String get cleaning_products => '洗剤';

  @override
  String get vegan_products => 'ビーガン製品';

  @override
  String get other => 'サブカテゴリ';

  @override
  String get nutrition_analysis => '栄養成分分析';

  @override
  String get nutrition_analysis_title => '栄養成分分析';

  @override
  String get nutrition_analysis_subtitle => '栄養成分を分析して\nバランスの取れた食事を維持しましょう。';

  @override
  String get calorie_analysis => 'カロリー分析';

  @override
  String get add_calorie => 'カロリー追加';

  @override
  String get processed_food => '加工食品';

  @override
  String get dessert => 'デザート';

  @override
  String get beverages => '飲料';

  @override
  String get subcategories => 'サブカテゴリ';

  @override
  String get select_none => '選択しない';

  @override
  String get subcategory_help_message => 'サブカテゴリを選択すると、より正確な結果が得られます。';

  @override
  String get food_health_food => '健康食品';

  @override
  String get food_diet_food => 'ダイエット食品';

  @override
  String get food_dairy => '乳製品';

  @override
  String get food_processed => '加工食品';

  @override
  String get food_instant => 'インスタント食品';

  @override
  String get food_beverages => '飲料';

  @override
  String get food_snacks => 'スナック';

  @override
  String get food_bakery => 'ベーカリー';

  @override
  String get food_seasoning => '調味料';

  @override
  String get cosmetics_skincare => 'スキンケア';

  @override
  String get cosmetics_cleansing => 'クレンジング';

  @override
  String get cosmetics_suncare => 'サンケア';

  @override
  String get cosmetics_mask => 'フェイスマスク';

  @override
  String get cosmetics_makeup => 'メイクアップ';

  @override
  String get cosmetics_bodycare => 'ボディケア';

  @override
  String get cosmetics_haircare => 'ヘアケア';

  @override
  String get cosmetics_handcare => 'ハンドケア';

  @override
  String get cosmetics_footcare => 'フットケア';

  @override
  String get cosmetics_mens => '男性用化粧品';

  @override
  String get medicine_skin_treatment => '皮膚疾患治療薬';

  @override
  String get medicine_allergy => 'アレルギー治療薬';

  @override
  String get medicine_womens => '女性用医薬品';

  @override
  String get medicine_general => '一般医薬品';

  @override
  String get medicine_supplements => '栄養補助食品';

  @override
  String get baby_skincare => 'ベビースキンケア';

  @override
  String get baby_cleansers => 'ベビー洗浄剤';

  @override
  String get baby_medicine => 'ベビー医薬品';

  @override
  String get baby_food => '離乳食';

  @override
  String get baby_formula => '粉ミルク';

  @override
  String get baby_sanitizers => '消毒用品';

  @override
  String get baby_detergent => 'ベビー洗剤';

  @override
  String get baby_toys => 'ベビー玩具';

  @override
  String get pet_supplements => 'ペット栄養補助食品';

  @override
  String get pet_medicine => 'ペット医薬品';

  @override
  String get pet_shampoo => 'ペットシャンプー';

  @override
  String get pet_special_food => 'ペット特別食';

  @override
  String get pet_food => 'ペットフード';

  @override
  String get pet_treats => 'ペットおやつ';

  @override
  String get pet_waste => '排泄用品';

  @override
  String get pet_toys => 'ペット玩具';

  @override
  String get household_products_dishwashing => '食器用洗剤';

  @override
  String get household_products_air_freshener => '芳香剤';

  @override
  String get household_products_cleaner => '洗浄剤';

  @override
  String get household_products_deodorizer => '消臭剤';

  @override
  String get analyze => '分析';

  @override
  String get select_image_source => '画像ソースを選択';

  @override
  String get ingredient_photography => '撮影';

  @override
  String get camera => 'カメラ';

  @override
  String get gallery => 'ギャラリー';

  @override
  String get crop_image => '画像をトリミング';

  @override
  String get crop_instruction =>
      '成分内容が白い枠内に収まるように位置とサイズを調整してください。2本指でピンチして拡大・縮小でき、白い線をドラッグして枠を移動できます。';

  @override
  String get nutrition_crop_instruction =>
      '栄養成分内容が白い枠内に収まるように位置とサイズを調整してください。2本指でピンチして拡大・縮小でき、白い線をドラッグして枠を移動できます。';

  @override
  String get reset_zoom => 'ズームをリセット';

  @override
  String get get_started => '始める';

  @override
  String get onboarding_step1_title => '成分カテゴリ選択';

  @override
  String get onboarding_step1_description => '成分分析タブで確認する製品種類を選んでください。';

  @override
  String get onboarding_step2_title => '成分撮影・分析';

  @override
  String get onboarding_step2_description => '製品の原材料名を撮影すると、AIが安全性と特徴を分析します。';

  @override
  String get onboarding_step3_title => '栄養カテゴリ選択';

  @override
  String get onboarding_step3_description => '栄養分析タブで確認する食品種類を選択してください。';

  @override
  String get onboarding_step4_title => '栄養成分撮影';

  @override
  String get onboarding_step4_description =>
      '炭水化物、脂質、タンパク質など栄養情報を撮影すると、AIが客観的に分析します。';

  @override
  String get onboarding_step5_title => '食事写真追加';

  @override
  String get onboarding_step5_description => '+ボタンを押して食事写真を撮って登録してください。';

  @override
  String get onboarding_step6_title => 'AIカロリー分析';

  @override
  String get onboarding_step6_description => 'AIが食事写真を分析しておおよそのカロリーをお知らせします。';

  @override
  String get confirm => '確認';

  @override
  String get cancel => 'キャンセル';

  @override
  String get analysis_notice =>
      'AI分析には5〜20秒かかります（ネットワーク状況により異なります）。分析中はサービス運営のため広告が表示され、5秒後に広告を閉じることができます。';

  @override
  String get dont_show_again => '次回から表示しない';

  @override
  String get positive_ingredients => '良い成分';

  @override
  String get negative_ingredients => '悪い成分';

  @override
  String get other_ingredients => 'その他の成分';

  @override
  String get overall_review => '総評';

  @override
  String get category_analysis => '指標分析';

  @override
  String get category_comparison => '指標比較';

  @override
  String get nutritional_value => '栄養価';

  @override
  String get safety => '安全性';

  @override
  String get natural_ingredients => '天然成分';

  @override
  String get functional_benefits => '機能性';

  @override
  String get taste_quality => '味の品質';

  @override
  String get moisturizing => '保湿力';

  @override
  String get hypoallergenic => '低アレルギー性';

  @override
  String get longevity => '持続性';

  @override
  String get stability => '安定性';

  @override
  String get absorption => '吸収力';

  @override
  String get effectiveness => '効果性';

  @override
  String get gentleness => '優しさ';

  @override
  String get safety_standards => '安全基準';

  @override
  String get nutritional_balance => '栄養バランス';

  @override
  String get digestibility => '消化性';

  @override
  String get palatability => '嗜好性';

  @override
  String get functionality => '機能性';

  @override
  String get side_effects => '低リスク';

  @override
  String get quality_standards => '品質基準';

  @override
  String get interactions => '相互作用';

  @override
  String get error => 'エラー';

  @override
  String get network_error => 'ネットワークエラーが発生しました。もう一度お試しください。';

  @override
  String get analysis_failed => '分析に失敗しました。もう一度お試しください。';

  @override
  String get no_ingredients_found => '成分が見つかりません。';

  @override
  String get loading => '読み込み中...';

  @override
  String get analyzing => '分析中...';

  @override
  String get ai_analysis_message => '少々お待ちください！AIが成分情報を精密分析しています✨ （約10秒かかります）';

  @override
  String get please_select_category => 'カテゴリを選択してください';

  @override
  String get enter_custom_category => 'カスタムカテゴリを入力してください';

  @override
  String take_photo_for_category(Object category) {
    return '$categoryカテゴリの製品を撮影してください';
  }

  @override
  String take_photo_of_ingredients(Object category) {
    return '$category成分表をカメラで撮影するか、ギャラリーから写真を選択してください';
  }

  @override
  String get camera_permission_needed => 'カメラの権限が必要です。';

  @override
  String get settings => '設定';

  @override
  String get menu => 'メニュー';

  @override
  String photo_error(Object error) {
    return '写真撮影中にエラーが発生しました：$error';
  }

  @override
  String get photo_taken => '撮影完了';

  @override
  String category_label(Object category) {
    return 'カテゴリ：$category';
  }

  @override
  String get taking_photo => '撮影中...';

  @override
  String get photo_instruction => '撮影後に成分表の範囲を指定できますので、ゆっくり撮影してください。';

  @override
  String get check_photo_in_range => '成分表は枠内にきちんと撮影されましたか？';

  @override
  String get take_photo => '写真撮影';

  @override
  String get horizontal_guide => '横向';

  @override
  String get vertical_guide => '縦向';

  @override
  String get close => '閉じる';

  @override
  String get rotate => '回転';

  @override
  String get done => '完了';

  @override
  String get confirm_analysis_notice => '分析を押すとAI分析がすぐに開始され、分析中は広告が表示されます。';

  @override
  String get app_subtitle => 'AI搭載の成分分析ツール';

  @override
  String get ai_disclaimer =>
      '本アプリの成分・栄養分析はAIによって自動生成された結果であり、特定の機関や公式資料に基づくものではありません。 提供された情報は参考用であり、エラーが含まれている可能性があります。重要な決定は必ず専門家にご相談ください。😊';

  @override
  String get save_screenshot => '結果を保存';

  @override
  String get screenshot_saved => '結果がギャラリーに保存されました';

  @override
  String get screenshot_failed => '保存に失敗しました';

  @override
  String get storage_permission_needed => 'ストレージの権限が必要です';

  @override
  String get save_result => '結果保存';

  @override
  String get result_name => '名前';

  @override
  String get enter_result_name => '結果名を入力してください';

  @override
  String get save => '保存';

  @override
  String get result_saved => '結果が保存されました';

  @override
  String get save_failed_simple => '保存に失敗しました';

  @override
  String get saved_results => '保存された結果';

  @override
  String get saved_analysis => '保存された分析';

  @override
  String get no_saved_results => '保存された結果がありません';

  @override
  String get analysis => '分析';

  @override
  String get comparison => '比較';

  @override
  String get edit_name => '名前編集';

  @override
  String get delete => '削除';

  @override
  String get confirm_delete => '削除確認';

  @override
  String get confirm_delete_message => '本当に削除しますか？';

  @override
  String get delete_success => '削除されました';

  @override
  String get delete_failed => '削除に失敗しました';

  @override
  String get analysis_results => '分析結果';

  @override
  String get compare => '比較';

  @override
  String get product_a => '製品 A';

  @override
  String get product_b => '製品 B';

  @override
  String get compare_ingredients => '成分比較';

  @override
  String get select_both_products => '比較する2つの製品を選択してください';

  @override
  String get overall_comparison => '総合比較';

  @override
  String get tap_to_add => 'タップして追加';

  @override
  String get compare_instruction => '各製品の成分表を撮影または選択してください。';

  @override
  String get ingredient_search => '成分検索';

  @override
  String ingredient_search_message(Object ingredient) {
    return '\"$ingredient\"について詳しく調べてみましょうか？';
  }

  @override
  String get search => '検索';

  @override
  String get save_ingredient => '成分情報保存';

  @override
  String get enter_save_name => '保存する名前を入力してください';

  @override
  String get save_name_hint => '例：ビタミンC情報';

  @override
  String get enter_name => '名前を入力してください';

  @override
  String get save_complete => '保存完了';

  @override
  String get recent_ingredients_title => '最近の成分検索';

  @override
  String get recent_ingredients_subtitle => '最近検索した成分情報';

  @override
  String get no_recent_ingredients => '最近の成分検索記録がありません';

  @override
  String get ingredients => '成分';

  @override
  String get no_saved_ingredients => '保存された成分がありません';

  @override
  String get searching => '検索中...';

  @override
  String get searching_ingredient_info => '成分情報を検索しています...';

  @override
  String get description => '説明';

  @override
  String get alternative_names => '別名';

  @override
  String get primary_functions => '主要機能';

  @override
  String get benefits => '効果・効能';

  @override
  String get precautions => '注意事項';

  @override
  String get additional_info => '追加情報';

  @override
  String get ingredient_detail_search => '詳細を見る';

  @override
  String get share => '共有';

  @override
  String get sharing => '共有中...';

  @override
  String get profile => 'プロフィール';

  @override
  String get user_info => 'ユーザー情報';

  @override
  String get language => '言語';

  @override
  String get privacy_policy => 'プライバシーポリシー';

  @override
  String get terms_of_service => '利用規約';

  @override
  String get help_feedback => 'ヘルプ & フィードバック';

  @override
  String get religion => '宗教';

  @override
  String get skin => '肌タイプ';

  @override
  String get allergy => 'アレルギー';

  @override
  String get diet => '食事制限';

  @override
  String get health => '健康状態';

  @override
  String get add_custom => 'カスタム追加';

  @override
  String get enter_custom_value => 'カスタム値を入力';

  @override
  String get custom_value_hint => '例：乳糖不耐症';

  @override
  String get value_already_exists => 'この値は既に存在します';

  @override
  String get preference_added => '設定が正常に追加されました';

  @override
  String get preference_removed => '設定が正常に削除されました';

  @override
  String get select_preferred_language => 'お好みの言語を選択してください';

  @override
  String language_changed_to(Object language) {
    return '言語が$languageに変更されました';
  }

  @override
  String get christianity => 'キリスト教';

  @override
  String get islam => 'イスラム教';

  @override
  String get hinduism => 'ヒンドゥー教';

  @override
  String get buddhism => '仏教';

  @override
  String get sensitive => '敏感肌';

  @override
  String get dry => '乾燥肌';

  @override
  String get oily => '脂性肌';

  @override
  String get combination => '混合肌';

  @override
  String get normal => '普通肌';

  @override
  String get acne_prone => 'ニキビ肌';

  @override
  String get atopic => 'アトピー性';

  @override
  String get nuts => 'ナッツ';

  @override
  String get dairy => '乳製品';

  @override
  String get eggs => '卵';

  @override
  String get soy => '大豆';

  @override
  String get gluten => 'グルテン';

  @override
  String get shellfish => '甲殻類';

  @override
  String get fish => '魚';

  @override
  String get sesame => 'ごま';

  @override
  String get vegetarian => 'ベジタリアン';

  @override
  String get vegan => 'ビーガン';

  @override
  String get low_carb => '低炭水化物';

  @override
  String get gluten_free => 'グルテンフリー';

  @override
  String get dairy_free => '乳製品フリー';

  @override
  String get sugar_free => '無糖';

  @override
  String get halal => 'ハラール';

  @override
  String get diabetes => '糖尿病';

  @override
  String get hypertension => '高血圧';

  @override
  String get heart_disease => '心疾患';

  @override
  String get kidney_disease => '腎疾患';

  @override
  String get pregnancy => '妊娠';

  @override
  String get breastfeeding => '授乳';

  @override
  String get daily_limit_reached => '日々の使用制限に達しました。明日再度お試しください。';

  @override
  String get custom_limit_reached => 'カスタム項目は最大3つまで追加できます';

  @override
  String get invalid_characters => '特殊文字は使用できません';

  @override
  String get text_too_long => '最大20文字まで入力できます';

  @override
  String get apply_profile => '自分のプロフィール設定を適用する';

  @override
  String get profile_settings => 'プロフィール設定';

  @override
  String get crop_area_required => '成分表エリアが選択されていません。白いボックスを調整して成分表を含めてください。';

  @override
  String get baby_info => '赤ちゃん情報';

  @override
  String get pet_info => 'ペット情報';

  @override
  String get baby_age => '年齢';

  @override
  String get pet_type => '種類';

  @override
  String get pet_breed => '品種';

  @override
  String get weight => '体重';

  @override
  String get neutered => '去勢状況';

  @override
  String get dog => '犬';

  @override
  String get cat => '猫';

  @override
  String get bird => '鳥';

  @override
  String get rabbit => 'ウサギ';

  @override
  String get hamster => 'ハムスター';

  @override
  String get neutered_yes => 'はい';

  @override
  String get neutered_no => 'いいえ';

  @override
  String get baby_age_0_6_months => '0-6ヶ月';

  @override
  String get baby_age_6_12_months => '6-12ヶ月';

  @override
  String get baby_age_1_2_years => '1-2歳';

  @override
  String get baby_age_2_3_years => '2-3歳';

  @override
  String get baby_age_3_5_years => '3-5歳';

  @override
  String get baby_age_5_plus_years => '5歳以上';

  @override
  String get baby_health_healthy => '健康';

  @override
  String get baby_health_asthma => '喘息';

  @override
  String get baby_health_digestive_sensitivity => '消化器過敏';

  @override
  String get baby_health_constipation => '便秘';

  @override
  String get baby_health_diarrhea => '下痢';

  @override
  String get pet_age_0_1_year => '0-1歳';

  @override
  String get pet_age_1_3_years => '1-3歳';

  @override
  String get pet_age_3_5_years => '3-5歳';

  @override
  String get pet_age_5_7_years => '5-7歳';

  @override
  String get pet_age_7_10_years => '7-10歳';

  @override
  String get pet_age_10_plus_years => '10歳以上';

  @override
  String get pet_weight_under_1kg => '1kg未満';

  @override
  String get pet_weight_1_3kg => '1-3kg';

  @override
  String get pet_weight_3_5kg => '3-5kg';

  @override
  String get pet_weight_5_10kg => '5-10kg';

  @override
  String get pet_weight_10_20kg => '10-20kg';

  @override
  String get pet_weight_over_20kg => '20kg以上';

  @override
  String get pet_allergy_grains => '穀物';

  @override
  String get pet_allergy_chicken => '鶏肉';

  @override
  String get pet_allergy_beef => '牛肉';

  @override
  String get pet_health_healthy => '健康';

  @override
  String get pet_health_arthritis => '関節炎';

  @override
  String get pet_health_heart_disease => '心疾患';

  @override
  String get pet_health_kidney_disease => '腎疾患';

  @override
  String get pet_health_liver_disease => '肝疾患';

  @override
  String get pet_health_diabetes => '糖尿病';

  @override
  String get pet_health_skin_disease => '皮膚病';

  @override
  String get pet_health_digestive_disease => '消化器疾患';

  @override
  String get pet_breed_input_message => '品種を直接入力してください';

  @override
  String get apply_user_info => 'ユーザー情報を適用';

  @override
  String get apply_baby_info => '赤ちゃん情報を適用';

  @override
  String get apply_pet_info => 'ペット情報を適用';

  @override
  String get vision_api_error => '画像から成分テキストを見つけることができませんでした。';

  @override
  String get ai_evaluation_score => 'AIスコア';

  @override
  String get excellent => '優秀';

  @override
  String get good => '良好';

  @override
  String get average => '普通';

  @override
  String get caution => '注意';

  @override
  String get points => '点';

  @override
  String get personalized_info_applied => '(カスタマイズ情報反映)';

  @override
  String get height => '身長';

  @override
  String get current_weight => '現在の体重';

  @override
  String get target_weight => '目標体重';

  @override
  String get height_cm => '身長 (cm)';

  @override
  String get weight_kg => '体重 (kg)';

  @override
  String get target_weight_kg => '目標体重 (kg)';

  @override
  String get physical_info => '身体情報';

  @override
  String get baby_weight => '体重';

  @override
  String get baby_weight_under_5kg => '5kg未満';

  @override
  String get baby_weight_5_10kg => '5-10kg';

  @override
  String get baby_weight_10_15kg => '10-15kg';

  @override
  String get baby_weight_15_20kg => '15-20kg';

  @override
  String get baby_weight_over_20kg => '20kg以上';

  @override
  String get direct_input => '直接入力';

  @override
  String get bottom_nav_ingredient_analysis => 'Ingredient Analysis';

  @override
  String get bottom_nav_nutrition_analysis => 'Nutrition Analysis';

  @override
  String get bottom_nav_storage => 'Storage';

  @override
  String get recent_history => '最近の記録';

  @override
  String get calorie_management => 'カロリー管理';

  @override
  String get ingredients_short => '成分';

  @override
  String get nutrition_short => '栄養';

  @override
  String get history_short => '履歴';

  @override
  String get calorie_short => 'カロリー';

  @override
  String get today_calories_section_title => '今日のカロリー';

  @override
  String get today_calories_section_subtitle => '今日記録したカロリーを確認してください。';

  @override
  String get no_calories_today => '今日記録されたカロリーはありません';

  @override
  String more_items_count(Object count) {
    return 'さらに$count件';
  }

  @override
  String get weekly_calories_section_title => '週間カロリー';

  @override
  String get weekly_calories_section_subtitle => '一週間の日別カロリー\n摂取量の変化を一目で確認。';

  @override
  String daily_average_calories(Object calories) {
    return '日平均 $calories kcal';
  }

  @override
  String get weekday_mon => '月';

  @override
  String get weekday_tue => '火';

  @override
  String get weekday_wed => '水';

  @override
  String get weekday_thu => '木';

  @override
  String get weekday_fri => '金';

  @override
  String get weekday_sat => '土';

  @override
  String get weekday_sun => '日';

  @override
  String get monthly_calorie_report => '月間カロリーレポート';

  @override
  String get calorie_analysis_result => 'カロリー分析結果';

  @override
  String get calorie_saved => 'カロリーが保存されました';

  @override
  String save_failed_with_error(Object error) {
    return '保存失敗: $error';
  }

  @override
  String get delete_error => '削除中にエラーが発生しました';

  @override
  String get total_calories => '総カロリー';

  @override
  String get meal_type => '食事の種類';

  @override
  String get date_and_time => '日付と時刻';

  @override
  String get food_detail => '食品詳細';

  @override
  String get nutrition_info => '栄養成分';

  @override
  String get delete_calorie => 'カロリー削除';

  @override
  String get delete_item => '削除する';

  @override
  String per_unit(Object amount, Object calories) {
    return '$amountあたり$calories kcal';
  }

  @override
  String get protein => 'タンパク質';

  @override
  String get fat => '脂質';

  @override
  String get carbohydrate => '炭水化物';

  @override
  String get sodium => 'ナトリウム';

  @override
  String get sugar => '糖類';

  @override
  String get trans_fat => 'トランス脂肪酸';

  @override
  String get saturated_fat => '飽和脂肪酸';

  @override
  String get cholesterol => 'コレステロール';

  @override
  String get food_name_edit => '食品名編集';

  @override
  String get enter_calorie => 'カロリー入力';

  @override
  String get enter_food_name => '食品名入力';

  @override
  String get valid_calorie_error => '正しいカロリーを入力してください';

  @override
  String get food_name_error => '食品名を入力してください';

  @override
  String get food_not_found => '画像から食品情報が見つかりません。';

  @override
  String get nutrition_not_found => '画像から栄養成分情報が見つかりません。';

  @override
  String share_error(Object error) {
    return '共有中にエラーが発生しました: $error';
  }

  @override
  String get daily_total_calories => '1日の総カロリー';

  @override
  String get ingredient_analysis_photo_subtitle => '成分表を撮影してAI分析を受けてください';

  @override
  String get nutrition_analysis_photo_subtitle => '栄養成分表を撮影して健康情報を確認してください';

  @override
  String get calorie_analysis_photo_subtitle => '食べ物を撮影するとAIがカロリーを分析します';
}
