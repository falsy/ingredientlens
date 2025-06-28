import 'package:flutter/material.dart';
import 'preferences_service.dart';

class LocalizationService extends ChangeNotifier {
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('ko', 'KR'), // Korean
    Locale('zh', 'CN'), // Chinese
    Locale('ja', 'JP'), // Japanese
    Locale('es', 'ES'), // Spanish
    Locale('pt', 'BR'), // Portuguese
    Locale('th', 'TH'), // Thai
    Locale('vi', 'VN'), // Vietnamese
  ];

  Locale _locale = supportedLocales.first;

  Locale get locale => _locale;

  LocalizationService() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final languageCode = PreferencesService.instance.getLanguageCode();
    if (languageCode != null) {
      _locale = supportedLocales.firstWhere(
        (locale) => locale.languageCode == languageCode,
        orElse: () => supportedLocales.first,
      );
    } else {
      // 시스템 언어 감지
      _locale = _getSystemLocale();
    }
    notifyListeners();
  }

  Locale _getSystemLocale() {
    // 시스템 언어를 확인하여 지원되는 언어 중에 있으면 사용
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;

    // 지원하는 언어인지 확인
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == systemLocale.languageCode) {
        return supportedLocale;
      }
    }

    // 지원하지 않는 언어면 영어 사용
    return supportedLocales.first;
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;

    _locale = locale;
    await PreferencesService.instance.setLanguageCode(locale.languageCode);
    notifyListeners();
  }

  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ko':
        return '한국어';
      case 'zh':
        return '中文';
      case 'ja':
        return '日本語';
      case 'es':
        return 'Español';
      case 'pt':
        return 'Português';
      case 'th':
        return 'ไทย';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return 'English';
    }
  }
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  final Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'app_name': 'IngredientLens',
      'main_title': 'AI ingredient analyzer',
      'section_title': 'Category',
      'section_subtitle': 'Take a picture and analyze the ingredients',
      'recent_results_title': 'Recent Results',
      'recent_results_subtitle': 'Here are the results of a recent analysis',
      'no_recent_results': 'No recent analysis results',
      'announcements_title': 'Announcements',
      'announcements_subtitle': 'Check out our latest updates and news',
      'no_announcements': 'No new announcements',
      'time_days_ago': '{days} days ago',
      'time_hours_ago': '{hours} hours ago',
      'time_minutes_ago': '{minutes} minutes ago',
      'time_just_now': 'Just now',
      'select_category': 'Select Category',
      'select_action': 'Choose what you want to do',
      'food': 'Food',
      'cosmetics': 'Cosmetics',
      'baby_products': 'Baby',
      'pet_products': 'Pets',
      'medicine': 'Medicine',
      'cleaning_products': 'Cleaning Products',
      'vegan_products': 'Vegan Products',
      'other': 'Custom',
      'analyze': 'Analyze',
      'select_image_source': 'Select Image Source',
      'ingredient_photography': 'Capture',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'crop_image': 'Crop Image',
      'crop_instruction':
          'Please drag to select the area where the ingredient list is located',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'analysis_notice':
          'AI analysis takes 5-20 seconds (may vary depending on network conditions). Ads will be displayed during analysis to support the service. You can close the ad after 5 seconds.',
      'dont_show_again': 'Don\'t show again',
      'positive_ingredients': 'Positive Ingredients',
      'negative_ingredients': 'Negative Ingredients',
      'other_ingredients': 'Other Ingredients',
      'overall_review': 'Overall Review',
      'error': 'Error',
      'network_error': 'Network error occurred. Please try again.',
      'analysis_failed': 'Analysis failed. Please try again.',
      'no_ingredients_found': 'No ingredients found.',
      'loading': 'Loading...',
      'analyzing': 'Analyzing...',
      'please_select_category': 'Please select a category',
      'enter_custom_category': 'Please enter a custom category',
      'take_photo_for_category': 'Take a photo for {category} category',
      'take_photo_of_ingredients':
          'Please take a photo of {category} ingredients with camera or select a photo from gallery',
      'camera_permission_needed': 'Camera permission is required.',
      'settings': 'Settings',
      'photo_error': 'Error occurred while taking photo: {error}',
      'photo_taken': 'Photo taken',
      'category_label': 'Category: {category}',
      'taking_photo': 'Taking photo...',
      'photo_instruction':
          'Take your time taking photos as you can specify the ingredient list area after shooting.',
      'check_photo_in_range':
          'Is the ingredient list well captured within the frame?',
      'take_photo': 'Take Photo',
      'horizontal_guide': 'Horizontal',
      'vertical_guide': 'Vertical',
      'close': 'Close',
      'confirm_analysis_notice':
          'Clicking Confirm will start AI analysis immediately and display ads.\n(AI analysis takes about 10 seconds.)',
      'app_subtitle': 'AI-powered ingredient analyzer',
      'ai_disclaimer':
          'AI-provided information may contain errors. Please consult with professionals for important decisions. 😊',
      'save_screenshot': 'Save Results',
      'screenshot_saved': 'Results saved to gallery',
      'screenshot_failed': 'Failed to save',
      'storage_permission_needed': 'Storage permission required',
      'save_result': 'Save Result',
      'result_name': 'Name',
      'enter_result_name': 'Enter result name',
      'cancel': 'Cancel',
      'save': 'Save',
      'result_saved': 'Result saved successfully',
      'save_failed': 'Save failed',
      'saved_results': 'Saved Results',
      'no_saved_results': 'No saved results',
      'analysis': 'analysis',
      'comparison': 'comparison',
      'edit_name': 'Edit Name',
      'delete': 'Delete',
      'confirm_delete': 'Delete Confirmation',
      'confirm_delete_message': 'Are you sure you want to delete?',
      'delete_success': 'Deleted successfully',
      'delete_failed': 'Delete failed',
      'analysis_results': 'Analysis Results',
      'compare': 'Compare',
      'product_a': 'Product A',
      'product_b': 'Product B',
      'compare_ingredients': 'Compare Ingredients',
      'select_both_products': 'Please select both products to compare',
      'overall_comparison': 'Overall Comparison',
      'tap_to_add': 'Tap to add',
      'compare_instruction':
          'Capture or select the ingredient list for each product to compare'
    },
    'ko': {
      'app_name': '성분렌즈',
      'main_title': 'AI 성분 분석기',
      'section_title': '카테고리',
      'section_subtitle': '사진을 찍고 성분을 분석하세요',
      'recent_results_title': '최근 분석 기록',
      'recent_results_subtitle': '최근 분석한 결과입니다',
      'no_recent_results': '최근 분석 결과가 없습니다',
      'announcements_title': '공지사항',
      'announcements_subtitle': '최신 업데이트와 소식을 확인하세요',
      'no_announcements': '새로운 공지사항이 없습니다',
      'time_days_ago': '{days}일 전',
      'time_hours_ago': '{hours}시간 전',
      'time_minutes_ago': '{minutes}분 전',
      'time_just_now': '방금 전',
      'select_category': '카테고리 선택',
      'select_action': '원하는 작업을 선택하세요',
      'food': '식품',
      'cosmetics': '화장품',
      'baby_products': '육아용품',
      'pet_products': '반려용품',
      'medicine': '의약품',
      'cleaning_products': '세정용품',
      'vegan_products': '비건품',
      'other': '기타',
      'analyze': '분석',
      'select_image_source': '이미지 선택',
      'ingredient_photography': '촬영',
      'camera': '카메라',
      'gallery': '갤러리',
      'crop_image': '이미지 자르기',
      'crop_instruction': '성분표가 위치한 영역을 드래그하여 선택해주세요',
      'confirm': '확인',
      'cancel': '취소',
      'analysis_notice':
          'AI 분석에는 5-20초 정도 시간이 소요되며(네트워크 상태에 따라 달라질 수 있음) 분석을 진행하는 동안 서비스 운영을 위해 광고가 노출되며 5초 이후에 광고를 닫을 수 있습니다.',
      'dont_show_again': '다시 보지 않음',
      'positive_ingredients': '긍정적인 성분',
      'negative_ingredients': '부정적인 성분',
      'other_ingredients': '기타 성분',
      'overall_review': '총평',
      'error': '오류',
      'network_error': '네트워크 오류가 발생했습니다. 다시 시도해주세요.',
      'analysis_failed': '분석에 실패했습니다. 다시 시도해주세요.',
      'no_ingredients_found': '성분을 찾을 수 없습니다.',
      'loading': '로딩 중...',
      'analyzing': '분석 중...',
      'please_select_category': '카테고리를 선택해주세요',
      'enter_custom_category': '맞춤 카테고리를 입력해주세요',
      'take_photo_for_category': '{category} 카테고리의 제품을 촬영해주세요',
      'take_photo_of_ingredients': '{category} 성분표를 카메라로 찍거나 갤러리에서 사진을 선택해주세요',
      'camera_permission_needed': '카메라 권한이 필요합니다.',
      'settings': '설정',
      'photo_error': '사진 촬영 중 오류가 발생했습니다: {error}',
      'photo_taken': '사진 촬영 완료',
      'category_label': '카테고리: {category}',
      'taking_photo': '사진 촬영 중...',
      'photo_instruction': '사진 촬영 후에 성분표 영역을 지정할 수 있기 때문에 여유롭게 촬영해 주세요.',
      'check_photo_in_range': '성분표가 범위 안에 잘 찍혔나요?',
      'take_photo': '사진 촬영',
      'horizontal_guide': '가로',
      'vertical_guide': '세로',
      'close': '닫기',
      'confirm_analysis_notice':
          '확인을 클릭하면 광고가 표시되며 AI 분석이 시작됩니다.\n(AI 분석에는 10초 정도의 시간이 소요됩니다.)',
      'app_subtitle': 'AI를 활용한 성분표 분석기',
      'ai_disclaimer':
          'AI가 제공하는 정보에는 오류가 있을 수 있습니다. 중요한 결정은 반드시 전문가와 상담해 주세요. 😊',
      'save_screenshot': '결과 저장하기',
      'screenshot_saved': '결과가 갤러리에 저장되었습니다',
      'screenshot_failed': '저장에 실패했습니다',
      'storage_permission_needed': '저장소 권한이 필요합니다',
      'save_result': '결과 저장',
      'result_name': '이름',
      'enter_result_name': '결과 이름을 입력하세요',
      'cancel': '취소',
      'save': '저장',
      'result_saved': '결과가 저장되었습니다',
      'save_failed': '저장에 실패했습니다',
      'saved_results': '저장된 결과',
      'no_saved_results': '저장된 결과가 없습니다',
      'analysis': '분석',
      'comparison': '비교',
      'edit_name': '이름 변경',
      'delete': '삭제',
      'confirm_delete': '삭제 확인',
      'confirm_delete_message': '정말로 삭제하시겠습니까?',
      'delete_success': '삭제되었습니다',
      'delete_failed': '삭제에 실패했습니다',
      'analysis_results': '분석 결과',
      'compare': '비교',
      'product_a': '제품 A',
      'product_b': '제품 B',
      'compare_ingredients': '성분 비교',
      'select_both_products': '비교할 두 제품을 모두 선택해주세요',
      'overall_comparison': '종합 비교 분석',
      'tap_to_add': '탭하여 추가',
      'compare_instruction': '각 제품의 성분표를 촬영하거나 선택하여 비교해보세요'
    },
    'zh': {
      'app_name': 'AI成分分析器',
      'main_title': 'AI成分分析器',
      'section_title': '类别',
      'section_subtitle': '拍照并分析成分',
      'recent_results_title': '最近分析记录',
      'recent_results_subtitle': '这是最近分析的结果',
      'no_recent_results': '没有最近的分析结果',
      'announcements_title': '公告',
      'announcements_subtitle': '查看我们的最新更新和新闻',
      'no_announcements': '没有新公告',
      'time_days_ago': '{days}天前',
      'time_hours_ago': '{hours}小时前',
      'time_minutes_ago': '{minutes}分钟前',
      'time_just_now': '刚刚',
      'select_category': '选择类别',
      'select_action': '选择您想要的操作',
      'food': '食品',
      'cosmetics': '化妆品',
      'baby_products': '婴儿用品',
      'pet_products': '宠物用品',
      'medicine': '药品',
      'cleaning_products': '清洁用品',
      'vegan_products': '纯素产品',
      'other': '其他',
      'analyze': '分析',
      'select_image_source': '选择图片来源',
      'ingredient_photography': '拍摄',
      'camera': '相机',
      'gallery': '图库',
      'crop_image': '裁剪图片',
      'crop_instruction': '请拖拽选择成分表所在的区域',
      'confirm': '确认',
      'cancel': '取消',
      'analysis_notice': 'AI分析需要5-20秒（可能因网络状况而异）。分析期间将显示广告以支持服务运营。您可以在5秒后关闭广告。',
      'dont_show_again': '不再显示',
      'positive_ingredients': '有益成分',
      'negative_ingredients': '有害成分',
      'other_ingredients': '其他成分',
      'overall_review': '总评',
      'error': '错误',
      'network_error': '网络错误，请重试。',
      'analysis_failed': '分析失败，请重试。',
      'no_ingredients_found': '未找到成分。',
      'loading': '加载中...',
      'analyzing': '分析中...',
      'please_select_category': '请选择类别',
      'enter_custom_category': '请输入自定义类别',
      'take_photo_for_category': '请为{category}类别拍照',
      'take_photo_of_ingredients': '请用相机拍摄{category}成分表或从图库选择照片',
      'camera_permission_needed': '需要相机权限。',
      'settings': '设置',
      'photo_error': '拍照时出错：{error}',
      'photo_taken': '拍照完成',
      'category_label': '类别：{category}',
      'taking_photo': '正在拍照...',
      'photo_instruction': '拍照后可以指定成分表区域，请放心拍摄。',
      'check_photo_in_range': '成分表是否在框内拍摄清楚？',
      'take_photo': '拍照',
      'horizontal_guide': '横向',
      'vertical_guide': '纵向',
      'close': '关闭',
      'confirm_analysis_notice': '点击确认将立即开始AI分析并显示广告。\n(AI分析大约需要10秒时间。)',
      'app_subtitle': '基于AI的成分分析器',
      'ai_disclaimer': 'AI提供的信息可能存在错误。重要决定请务必咨询专业人士。😊',
      'save_screenshot': '保存结果',
      'screenshot_saved': '结果已保存到相册',
      'screenshot_failed': '保存失败',
      'storage_permission_needed': '需要存储权限',
      'save_result': '保存结果',
      'result_name': '名称',
      'enter_result_name': '请输入结果名称',
      'cancel': '取消',
      'save': '保存',
      'result_saved': '结果已保存',
      'save_failed': '保存失败',
      'saved_results': '已保存的结果',
      'no_saved_results': '没有已保存的结果',
      'analysis': '分析',
      'comparison': '比较',
      'edit_name': '编辑名称',
      'delete': '删除',
      'confirm_delete': '删除确认',
      'confirm_delete_message': '您确定要删除吗？',
      'delete_success': '删除成功',
      'delete_failed': '删除失败',
      'analysis_results': '分析结果',
      'compare': '比较',
      'product_a': '产品 A',
      'product_b': '产品 B',
      'compare_ingredients': '成分比较',
      'select_both_products': '请选择两个产品进行比较',
      'overall_comparison': '综合比较分析',
      'tap_to_add': '点击添加',
      'compare_instruction': '拍摄或选择每个产品的成分表进行比较'
    },
    'ja': {
      'app_name': 'AI成分分析',
      'main_title': 'AI成分分析器',
      'section_title': 'カテゴリ',
      'section_subtitle': '写真を撮って成分を分析',
      'recent_results_title': '最近の分析記録',
      'recent_results_subtitle': '最近分析した結果です',
      'no_recent_results': '最近の分析結果がありません',
      'announcements_title': 'お知らせ',
      'announcements_subtitle': '最新の更新情報とニュースをご確認ください',
      'no_announcements': '新しいお知らせはありません',
      'time_days_ago': '{days}日前',
      'time_hours_ago': '{hours}時間前',
      'time_minutes_ago': '{minutes}分前',
      'time_just_now': 'たった今',
      'select_category': 'カテゴリを選択',
      'select_action': 'やりたいことを選んでください',
      'food': '食品',
      'cosmetics': '化粧品',
      'baby_products': 'ベビー用品',
      'pet_products': 'ペット用品',
      'medicine': '医薬品',
      'cleaning_products': '洗剤',
      'vegan_products': 'ビーガン製品',
      'other': 'その他',
      'analyze': '分析',
      'select_image_source': '画像ソースを選択',
      'ingredient_photography': '撮影',
      'camera': 'カメラ',
      'gallery': 'ギャラリー',
      'crop_image': '画像をトリミング',
      'crop_instruction': '成分表がある部分をドラッグして選択してください',
      'confirm': '確認',
      'cancel': 'キャンセル',
      'analysis_notice':
          'AI分析には5〜20秒かかります（ネットワーク状況により異なります）。分析中はサービス運営のため広告が表示され、5秒後に広告を閉じることができます。',
      'dont_show_again': '次回から表示しない',
      'positive_ingredients': '良い成分',
      'negative_ingredients': '悪い成分',
      'other_ingredients': 'その他の成分',
      'overall_review': '総評',
      'error': 'エラー',
      'network_error': 'ネットワークエラーが発生しました。もう一度お試しください。',
      'analysis_failed': '分析に失敗しました。もう一度お試しください。',
      'no_ingredients_found': '成分が見つかりません。',
      'loading': '読み込み中...',
      'analyzing': '分析中...',
      'please_select_category': 'カテゴリを選択してください',
      'enter_custom_category': 'カスタムカテゴリを入力してください',
      'take_photo_for_category': '{category}カテゴリの製品を撮影してください',
      'take_photo_of_ingredients': '{category}成分表をカメラで撮影するか、ギャラリーから写真を選択してください',
      'camera_permission_needed': 'カメラの権限が必要です。',
      'settings': '設定',
      'photo_error': '写真撮影中にエラーが発生しました：{error}',
      'photo_taken': '撮影完了',
      'category_label': 'カテゴリ：{category}',
      'taking_photo': '撮影中...',
      'photo_instruction': '撮影後に成分表の範囲を指定できますので、ゆっくり撮影してください。',
      'check_photo_in_range': '成分表は枠内にきちんと撮影されましたか？',
      'take_photo': '写真撮影',
      'horizontal_guide': '横向',
      'vertical_guide': '縦向',
      'close': '閉じる',
      'confirm_analysis_notice':
          '確認をクリックするとすぐにAI分析が開始され、広告が表示されます。\n(AI分析には約10秒かかります。)',
      'app_subtitle': 'AI搭載の成分分析ツール',
      'ai_disclaimer': 'AIが提供する情報には誤りがある可能性があります。重要な決定は必ず専門家にご相談ください。😊',
      'save_screenshot': '結果を保存',
      'screenshot_saved': '結果がギャラリーに保存されました',
      'screenshot_failed': '保存に失敗しました',
      'storage_permission_needed': 'ストレージの権限が必要です',
      'save_result': '結果保存',
      'result_name': '名前',
      'enter_result_name': '結果名を入力してください',
      'cancel': 'キャンセル',
      'save': '保存',
      'result_saved': '結果が保存されました',
      'save_failed': '保存に失敗しました',
      'saved_results': '保存された結果',
      'no_saved_results': '保存された結果がありません',
      'analysis': '分析',
      'comparison': '比較',
      'edit_name': '名前編集',
      'delete': '削除',
      'confirm_delete': '削除確認',
      'confirm_delete_message': '本当に削除しますか？',
      'delete_success': '削除されました',
      'delete_failed': '削除に失敗しました',
      'analysis_results': '分析結果',
      'compare': '比較',
      'product_a': '製品 A',
      'product_b': '製品 B',
      'compare_ingredients': '成分比較',
      'select_both_products': '比較する2つの製品を選択してください',
      'overall_comparison': '総合比較分析',
      'tap_to_add': 'タップして追加',
      'compare_instruction': '各製品の成分表を撮影または選択して比較してください'
    },
    'es': {
      'app_name': 'Analizador de Ingredientes',
      'main_title': 'Analizador de ingredientes IA',
      'section_title': 'Categoría',
      'section_subtitle': 'Toma una foto y analiza los ingredientes',
      'recent_results_title': 'Resultados Recientes',
      'recent_results_subtitle': 'Estos son los resultados de un análisis reciente',
      'no_recent_results': 'No hay resultados de análisis recientes',
      'announcements_title': 'Anuncios',
      'announcements_subtitle': 'Consulta nuestras últimas actualizaciones y noticias',
      'no_announcements': 'No hay nuevos anuncios',
      'time_days_ago': 'hace {days} días',
      'time_hours_ago': 'hace {hours} horas',
      'time_minutes_ago': 'hace {minutes} minutos',
      'time_just_now': 'Ahora mismo',
      'select_category': 'Seleccionar Categoría',
      'select_action': 'Elige lo que quieres hacer',
      'food': 'Alimentos',
      'cosmetics': 'Cosméticos',
      'baby_products': 'Productos para Bebés',
      'pet_products': 'Productos para Mascotas',
      'medicine': 'Medicina',
      'cleaning_products': 'Productos de Limpieza',
      'vegan_products': 'Productos Veganos',
      'other': 'Otro',
      'analyze': 'Analizar',
      'select_image_source': 'Seleccionar Fuente de Imagen',
      'ingredient_photography': 'Captura',
      'camera': 'Cámara',
      'gallery': 'Galería',
      'crop_image': 'Recortar Imagen',
      'crop_instruction':
          'Por favor, arrastre para seleccionar el área donde se encuentra la lista de ingredientes',
      'confirm': 'Confirmar',
      'cancel': 'Cancelar',
      'analysis_notice':
          'El análisis de IA toma 5-20 segundos (puede variar según las condiciones de la red). Se mostrarán anuncios durante el análisis para apoyar el servicio. Puede cerrar el anuncio después de 5 segundos.',
      'dont_show_again': 'No mostrar de nuevo',
      'positive_ingredients': 'Ingredientes Positivos',
      'negative_ingredients': 'Ingredientes Negativos',
      'other_ingredients': 'Otros Ingredientes',
      'overall_review': 'Revisión General',
      'error': 'Error',
      'network_error': 'Error de red. Por favor, inténtelo de nuevo.',
      'analysis_failed': 'El análisis falló. Por favor, inténtelo de nuevo.',
      'no_ingredients_found': 'No se encontraron ingredientes.',
      'loading': 'Cargando...',
      'analyzing': 'Analizando...',
      'please_select_category': 'Por favor seleccione una categoría',
      'enter_custom_category': 'Por favor ingrese una categoría personalizada',
      'take_photo_for_category': 'Tome una foto para la categoría {category}',
      'take_photo_of_ingredients':
          'Por favor tome una foto de los ingredientes de {category} con la cámara o seleccione una foto de la galería',
      'camera_permission_needed': 'Se requiere permiso de cámara.',
      'settings': 'Configuración',
      'photo_error': 'Error al tomar la foto: {error}',
      'photo_taken': 'Foto tomada',
      'category_label': 'Categoría: {category}',
      'taking_photo': 'Tomando foto...',
      'photo_instruction':
          'Tómese su tiempo para tomar fotos, ya que puede especificar el área de la lista de ingredientes después de la captura.',
      'check_photo_in_range':
          '¿La lista de ingredientes está bien capturada dentro del marco?',
      'take_photo': 'Tomar Foto',
      'horizontal_guide': 'Horizontal',
      'vertical_guide': 'Vertical',
      'close': 'Cerrar',
      'confirm_analysis_notice':
          'Hacer clic en Confirmar iniciará el análisis de IA inmediatamente y mostrará anuncios.\n(El análisis de IA toma aproximadamente 10 segundos.)',
      'app_subtitle': 'Analizador de ingredientes con IA',
      'ai_disclaimer':
          'La información proporcionada por la IA puede contener errores. Consulte siempre a profesionales para decisiones importantes. 😊',
      'save_screenshot': 'Guardar Resultados',
      'screenshot_saved': 'Resultados guardados en la galería',
      'screenshot_failed': 'Error al guardar',
      'storage_permission_needed': 'Se requiere permiso de almacenamiento',
      'save_result': 'Guardar Resultado',
      'result_name': 'Nombre',
      'enter_result_name': 'Ingrese el nombre del resultado',
      'cancel': 'Cancelar',
      'save': 'Guardar',
      'result_saved': 'Resultado guardado exitosamente',
      'save_failed': 'Error al guardar',
      'saved_results': 'Resultados Guardados',
      'no_saved_results': 'No hay resultados guardados',
      'analysis': 'análisis',
      'comparison': 'comparación',
      'edit_name': 'Editar Nombre',
      'delete': 'Eliminar',
      'confirm_delete': 'Confirmar Eliminación',
      'confirm_delete_message': '¿Está seguro de que desea eliminar?',
      'delete_success': 'Eliminado exitosamente',
      'delete_failed': 'Error al eliminar',
      'analysis_results': 'Resultados del Análisis',
      'compare': 'Comparar',
      'product_a': 'Producto A',
      'product_b': 'Producto B',
      'compare_ingredients': 'Comparar Ingredientes',
      'select_both_products':
          'Por favor seleccione ambos productos para comparar',
      'overall_comparison': 'Comparación General',
      'tap_to_add': 'Toca para agregar',
      'compare_instruction':
          'Captura o selecciona la lista de ingredientes de cada producto para comparar'
    },
    'pt': {
      'app_name': 'Analisador de Ingredientes',
      'main_title': 'Analisador de ingredientes IA',
      'section_title': 'Categoria',
      'section_subtitle': 'Tire uma foto e analise os ingredientes',
      'recent_results_title': 'Resultados Recentes',
      'recent_results_subtitle': 'Aqui estão os resultados de uma análise recente',
      'no_recent_results': 'Nenhum resultado de análise recente',
      'announcements_title': 'Anúncios',
      'announcements_subtitle': 'Confira nossas últimas atualizações e notícias',
      'no_announcements': 'Nenhum novo anúncio',
      'time_days_ago': '{days} dias atrás',
      'time_hours_ago': '{hours} horas atrás',
      'time_minutes_ago': '{minutes} minutos atrás',
      'time_just_now': 'Agora mesmo',
      'select_category': 'Selecionar Categoria',
      'select_action': 'Escolha o que você quer fazer',
      'food': 'Alimentos',
      'cosmetics': 'Cosméticos',
      'baby_products': 'Produtos para Bebês',
      'pet_products': 'Produtos para Pets',
      'medicine': 'Medicamentos',
      'cleaning_products': 'Produtos de Limpeza',
      'vegan_products': 'Produtos Veganos',
      'other': 'Outro',
      'analyze': 'Analisar',
      'select_image_source': 'Selecionar Fonte da Imagem',
      'ingredient_photography': 'Captura',
      'camera': 'Câmera',
      'gallery': 'Galeria',
      'crop_image': 'Cortar Imagem',
      'crop_instruction':
          'Por favor, arraste para selecionar a área onde está localizada a lista de ingredientes',
      'confirm': 'Confirmar',
      'cancel': 'Cancelar',
      'analysis_notice':
          'A análise de IA leva 5-20 segundos (pode variar dependendo das condições da rede). Anúncios serão exibidos durante a análise para apoiar o serviço. Você pode fechar o anúncio após 5 segundos.',
      'dont_show_again': 'Não mostrar novamente',
      'positive_ingredients': 'Ingredientes Positivos',
      'negative_ingredients': 'Ingredientes Negativos',
      'other_ingredients': 'Outros Ingredientes',
      'overall_review': 'Revisão Geral',
      'error': 'Erro',
      'network_error': 'Erro de rede. Por favor, tente novamente.',
      'analysis_failed': 'A análise falhou. Por favor, tente novamente.',
      'no_ingredients_found': 'Nenhum ingrediente encontrado.',
      'loading': 'Carregando...',
      'analyzing': 'Analisando...',
      'please_select_category': 'Por favor selecione uma categoria',
      'enter_custom_category': 'Por favor digite uma categoria personalizada',
      'take_photo_for_category': 'Tire uma foto para a categoria {category}',
      'take_photo_of_ingredients':
          'Por favor tire uma foto dos ingredientes de {category} com a câmera ou selecione uma foto da galeria',
      'camera_permission_needed': 'Permissão de câmera necessária.',
      'settings': 'Configurações',
      'photo_error': 'Erro ao tirar foto: {error}',
      'photo_taken': 'Foto tirada',
      'category_label': 'Categoria: {category}',
      'taking_photo': 'Tirando foto...',
      'photo_instruction':
          'Tire fotos com calma, pois você pode especificar a área da lista de ingredientes após a captura.',
      'check_photo_in_range':
          'A lista de ingredientes foi bem capturada dentro do quadro?',
      'take_photo': 'Tirar Foto',
      'horizontal_guide': 'Horizontal',
      'vertical_guide': 'Vertical',
      'close': 'Fechar',
      'confirm_analysis_notice':
          'Clicar em Confirmar iniciará imediatamente a análise de IA e exibirá anúncios.\n(A análise de IA leva aproximadamente 10 segundos.)',
      'app_subtitle': 'Analisador de ingredientes com IA',
      'ai_disclaimer':
          'As informações fornecidas pela IA podem conter erros. Sempre consulte profissionais para decisões importantes. 😊',
      'save_screenshot': 'Salvar Resultados',
      'screenshot_saved': 'Resultados salvos na galeria',
      'screenshot_failed': 'Falha ao salvar',
      'storage_permission_needed': 'Permissão de armazenamento necessária',
      'save_result': 'Salvar Resultado',
      'result_name': 'Nome',
      'enter_result_name': 'Digite o nome do resultado',
      'cancel': 'Cancelar',
      'save': 'Salvar',
      'result_saved': 'Resultado salvo com sucesso',
      'save_failed': 'Erro ao salvar',
      'saved_results': 'Resultados Salvos',
      'no_saved_results': 'Nenhum resultado salvo',
      'analysis': 'análise',
      'comparison': 'comparação',
      'edit_name': 'Editar Nome',
      'delete': 'Excluir',
      'confirm_delete': 'Confirmar Exclusão',
      'confirm_delete_message': 'Tem certeza de que deseja excluir?',
      'delete_success': 'Excluído com sucesso',
      'delete_failed': 'Falha ao excluir',
      'analysis_results': 'Resultados da Análise',
      'compare': 'Comparar',
      'product_a': 'Produto A',
      'product_b': 'Produto B',
      'compare_ingredients': 'Comparar Ingredientes',
      'select_both_products':
          'Por favor selecione ambos os produtos para comparar',
      'overall_comparison': 'Comparação Geral',
      'tap_to_add': 'Toque para adicionar',
      'compare_instruction':
          'Capture ou selecione a lista de ingredientes de cada produto para comparar'
    },
    'th': {
      'app_name': 'เครื่องวิเคราะห์ส่วนผสม',
      'main_title': 'เครื่องวิเคราะห์ส่วนผสม AI',
      'section_title': 'หมวดหมู่',
      'section_subtitle': 'ถ่ายภาพและวิเคราะห์ส่วนผสม',
      'recent_results_title': 'ผลการวิเคราะห์ล่าสุด',
      'recent_results_subtitle': 'นี่คือผลการวิเคราะห์ล่าสุด',
      'no_recent_results': 'ไม่มีผลการวิเคราะห์ล่าสุด',
      'announcements_title': 'ประกาศ',
      'announcements_subtitle': 'ตรวจสอบการอัปเดตและข่าวล่าสุดของเรา',
      'no_announcements': 'ไม่มีประกาศใหม่',
      'time_days_ago': '{days} วันที่แล้ว',
      'time_hours_ago': '{hours} ชั่วโมงที่แล้ว',
      'time_minutes_ago': '{minutes} นาทีที่แล้ว',
      'time_just_now': 'เมื่อกี้',
      'select_category': 'เลือกหมวดหมู่',
      'select_action': 'เลือกสิ่งที่คุณต้องการทำ',
      'food': 'อาหาร',
      'cosmetics': 'เครื่องสำอาง',
      'baby_products': 'ผลิตภัณฑ์สำหรับเด็ก',
      'pet_products': 'ผลิตภัณฑ์สำหรับสัตว์เลี้ยง',
      'medicine': 'ยา',
      'cleaning_products': 'ผลิตภัณฑ์ทำความสะอาด',
      'vegan_products': 'ผลิตภัณฑ์วีแกน',
      'other': 'อื่นๆ',
      'analyze': 'วิเคราะห์',
      'select_image_source': 'เลือกแหล่งรูปภาพ',
      'ingredient_photography': 'ถ่ายภาพ',
      'camera': 'กล้อง',
      'gallery': 'แกลเลอรี่',
      'crop_image': 'ครอปรูป',
      'crop_instruction': 'กรุณาลากเพื่อเลือกพื้นที่ที่มีรายการส่วนผสม',
      'confirm': 'ยืนยัน',
      'cancel': 'ยกเลิก',
      'analysis_notice':
          'การวิเคราะห์ AI ใช้เวลา 5-20 วินาที (อาจแตกต่างกันตามสภาพเครือข่าย) จะมีการแสดงโฆษณาระหว่างการวิเคราะห์เพื่อสนับสนุนบริการ คุณสามารถปิดโฆษณาได้หลังจาก 5 วินาที',
      'dont_show_again': 'ไม่ต้องแสดงอีก',
      'positive_ingredients': 'ส่วนผสมที่ดี',
      'negative_ingredients': 'ส่วนผสมที่ไม่ดี',
      'other_ingredients': 'ส่วนผสมอื่นๆ',
      'overall_review': 'สรุปภาพรวม',
      'error': 'ข้อผิดพลาด',
      'network_error': 'เกิดข้อผิดพลาดเครือข่าย กรุณาลองอีกครั้ง',
      'analysis_failed': 'การวิเคราะห์ล้มเหลว กรุณาลองอีกครั้ง',
      'no_ingredients_found': 'ไม่พบส่วนผสม',
      'loading': 'กำลังโหลด...',
      'analyzing': 'กำลังวิเคราะห์...',
      'please_select_category': 'กรุณาเลือกหมวดหมู่',
      'enter_custom_category': 'กรุณาใส่หมวดหมู่ที่กำหนดเอง',
      'take_photo_for_category': 'ถ่ายภาพสำหรับหมวดหมู่ {category}',
      'take_photo_of_ingredients':
          'โปรดถ่ายภาพส่วนผสมของ {category} ด้วยกล้องหรือเลือกรูปภาพจากแกลเลอรี่',
      'camera_permission_needed': 'ต้องการสิทธิ์กล้อง',
      'settings': 'การตั้งค่า',
      'photo_error': 'เกิดข้อผิดพลาดขณะถ่ายภาพ: {error}',
      'photo_taken': 'ถ่ายภาพสำเร็จ',
      'category_label': 'หมวดหมู่: {category}',
      'taking_photo': 'กำลังถ่ายภาพ...',
      'photo_instruction':
          'ถ่ายภาพได้อย่างสบายใจ เพราะคุณสามารถระบุพื้นที่รายการส่วนผสมได้หลังจากถ่ายภาพ',
      'check_photo_in_range': 'รายการส่วนผสมถูกถ่ายอยู่ในกรอบดีหรือไม่?',
      'take_photo': 'ถ่ายรูป',
      'horizontal_guide': 'แนวนอน',
      'vertical_guide': 'แนวตั้ง',
      'close': 'ปิด',
      'confirm_analysis_notice':
          'การคลิกยืนยันจะเริ่มการวิเคราะห์ AI ทันทีและแสดงโฆษณา\n(การวิเคราะห์ AI ใช้เวลาประมาณ 10 วินาที)',
      'app_subtitle': 'เครื่องวิเคราะห์ส่วนผสมด้วย AI',
      'ai_disclaimer':
          'ข้อมูลที่ AI ให้มาอาจมีข้อผิดพลาดได้ การตัดสินใจที่สำคัญควรปรึกษาผู้เชี่ยวชาญเสมอ 😊',
      'save_screenshot': 'บันทึกผลลัพธ์',
      'screenshot_saved': 'บันทึกผลลัพธ์ไปยังแกลเลอรี่แล้ว',
      'screenshot_failed': 'บันทึกล้มเหลว',
      'storage_permission_needed': 'ต้องการสิทธิ์การจัดเก็บข้อมูล',
      'save_result': 'บันทึกผลลัพธ์',
      'result_name': 'ชื่อ',
      'enter_result_name': 'ใส่ชื่อผลลัพธ์',
      'cancel': 'ยกเลิก',
      'save': 'บันทึก',
      'result_saved': 'บันทึกผลลัพธ์สำเร็จ',
      'save_failed': 'บันทึกล้มเหลว',
      'saved_results': 'ผลลัพธ์ที่บันทึก',
      'no_saved_results': 'ไม่มีผลลัพธ์ที่บันทึก',
      'analysis': 'การวิเคราะห์',
      'comparison': 'การเปรียบเทียบ',
      'edit_name': 'แก้ไขชื่อ',
      'delete': 'ลบ',
      'confirm_delete': 'ยืนยันการลบ',
      'confirm_delete_message': 'คุณแน่ใจหรือไม่ว่าต้องการลบ?',
      'delete_success': 'ลบเรียบร้อยแล้ว',
      'delete_failed': 'ลบไม่สำเร็จ',
      'analysis_results': 'ผลการวิเคราะห์',
      'compare': 'เปรียบเทียบ',
      'product_a': 'ผลิตภัณฑ์ A',
      'product_b': 'ผลิตภัณฑ์ B',
      'compare_ingredients': 'เปรียบเทียบส่วนผสม',
      'select_both_products': 'กรุณาเลือกผลิตภัณฑ์ทั้งสองเพื่อเปรียบเทียบ',
      'overall_comparison': 'การเปรียบเทียบโดยรวม',
      'tap_to_add': 'แตะเพื่อเพิ่ม',
      'compare_instruction':
          'ถ่ายภาพหรือเลือกรายการส่วนผสมของแต่ละผลิตภัณฑ์เพื่อเปรียบเทียบ'
    },
    'vi': {
      'app_name': 'Phân Tích Thành Phần',
      'main_title': 'Phân tích thành phần AI',
      'section_title': 'Danh mục',
      'section_subtitle': 'Chụp ảnh và phân tích thành phần',
      'recent_results_title': 'Kết Quả Gần Đây',
      'recent_results_subtitle': 'Đây là kết quả của phân tích gần đây',
      'no_recent_results': 'Không có kết quả phân tích gần đây',
      'announcements_title': 'Thông Báo',
      'announcements_subtitle': 'Kiểm tra các cập nhật và tin tức mới nhất của chúng tôi',
      'no_announcements': 'Không có thông báo mới',
      'time_days_ago': '{days} ngày trước',
      'time_hours_ago': '{hours} giờ trước',
      'time_minutes_ago': '{minutes} phút trước',
      'time_just_now': 'Vừa xong',
      'select_category': 'Chọn Danh Mục',
      'select_action': 'Chọn những gì bạn muốn làm',
      'food': 'Thực Phẩm',
      'cosmetics': 'Mỹ Phẩm',
      'baby_products': 'Sản Phẩm Em Bé',
      'pet_products': 'Sản Phẩm Thú Cưng',
      'medicine': 'Thuốc',
      'cleaning_products': 'Sản Phẩm Tẩy Rửa',
      'vegan_products': 'Sản Phẩm Thuần Chay',
      'other': 'Khác',
      'analyze': 'Phân Tích',
      'select_image_source': 'Chọn Nguồn Hình Ảnh',
      'ingredient_photography': 'Chụp Ảnh',
      'camera': 'Máy Ảnh',
      'gallery': 'Thư Viện',
      'crop_image': 'Cắt Hình',
      'crop_instruction':
          'Vui lòng kéo để chọn khu vực có danh sách thành phần',
      'confirm': 'Xác Nhận',
      'cancel': 'Hủy',
      'analysis_notice':
          'Phân tích AI mất 5-20 giây (có thể thay đổi tùy theo điều kiện mạng). Quảng cáo sẽ được hiển thị trong quá trình phân tích để hỗ trợ dịch vụ. Bạn có thể đóng quảng cáo sau 5 giây.',
      'dont_show_again': 'Không hiển thị lại',
      'positive_ingredients': 'Thành Phần Tốt',
      'negative_ingredients': 'Thành Phần Xấu',
      'other_ingredients': 'Thành Phần Khác',
      'overall_review': 'Đánh Giá Tổng Thể',
      'error': 'Lỗi',
      'network_error': 'Lỗi mạng. Vui lòng thử lại.',
      'analysis_failed': 'Phân tích thất bại. Vui lòng thử lại.',
      'no_ingredients_found': 'Không tìm thấy thành phần.',
      'loading': 'Đang tải...',
      'analyzing': 'Đang phân tích...',
      'please_select_category': 'Vui lòng chọn danh mục',
      'enter_custom_category': 'Vui lòng nhập danh mục tùy chỉnh',
      'take_photo_for_category': 'Chụp ảnh cho danh mục {category}',
      'take_photo_of_ingredients':
          'Vui lòng chụp ảnh thành phần của {category} bằng máy ảnh hoặc chọn ảnh từ thư viện',
      'camera_permission_needed': 'Cần quyền truy cập camera.',
      'settings': 'Cài đặt',
      'photo_error': 'Lỗi khi chụp ảnh: {error}',
      'photo_taken': 'Đã chụp ảnh',
      'category_label': 'Danh mục: {category}',
      'taking_photo': 'Đang chụp ảnh...',
      'photo_instruction':
          'Hãy thoải mái chụp ảnh vì bạn có thể chỉ định khu vực danh sách thành phần sau khi chụp.',
      'check_photo_in_range':
          'Danh sách thành phần đã được chụp rõ trong khung chưa?',
      'take_photo': 'Chụp Ảnh',
      'horizontal_guide': 'Ngang',
      'vertical_guide': 'Dọc',
      'close': 'Đóng',
      'confirm_analysis_notice':
          'Nhấp vào Xác nhận sẽ bắt đầu phân tích AI ngay lập tức và hiển thị quảng cáo.\n(Phân tích AI mất khoảng 10 giây.)',
      'app_subtitle': 'Công cụ phân tích thành phần bằng AI',
      'ai_disclaimer':
          'Thông tin do AI cung cấp có thể chứa lỗi. Luôn tham khảo ý kiến chuyên gia cho các quyết định quan trọng. 😊',
      'save_screenshot': 'Lưu Kết Quả',
      'screenshot_saved': 'Kết quả đã được lưu vào thư viện',
      'screenshot_failed': 'Lưu thất bại',
      'storage_permission_needed': 'Cần quyền truy cập bộ nhớ',
      'save_result': 'Lưu Kết Quả',
      'result_name': 'Tên',
      'enter_result_name': 'Nhập tên kết quả',
      'cancel': 'Hủy',
      'save': 'Lưu',
      'result_saved': 'Lưu kết quả thành công',
      'save_failed': 'Lưu thất bại',
      'saved_results': 'Kết Quả Đã Lưu',
      'no_saved_results': 'Không có kết quả đã lưu',
      'analysis': 'Phân Tích',
      'comparison': 'So Sánh',
      'edit_name': 'Sửa Tên',
      'delete': 'Xóa',
      'confirm_delete': 'Xác Nhận Xóa',
      'confirm_delete_message': 'Bạn có chắc chắn muốn xóa không?',
      'delete_success': 'Xóa thành công',
      'delete_failed': 'Xóa thất bại',
      'analysis_results': 'Kết Quả Phân Tích',
      'compare': 'So Sánh',
      'product_a': 'Sản Phẩm A',
      'product_b': 'Sản Phẩm B',
      'compare_ingredients': 'So Sánh Thành Phần',
      'select_both_products': 'Vui lòng chọn cả hai sản phẩm để so sánh',
      'overall_comparison': 'So Sánh Tổng Thể',
      'tap_to_add': 'Chạm để thêm',
      'compare_instruction':
          'Chụp hoặc chọn danh sách thành phần của mỗi sản phẩm để so sánh'
    },
  };

  String translate(String key, [Map<String, String>? params]) {
    String text = _localizedStrings[locale.languageCode]?[key] ?? key;

    if (params != null) {
      params.forEach((paramKey, paramValue) {
        text = text.replaceAll('{$paramKey}', paramValue);
      });
    }

    return text;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return LocalizationService.supportedLocales.contains(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
