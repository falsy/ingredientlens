// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get app_name => 'Thành Phần Lens';

  @override
  String get main_title => 'Phân tích thành phần AI';

  @override
  String get ingredient_screen_header_title_1 =>
      'Thành phần thật\nđằng sau marketing!';

  @override
  String get ingredient_screen_header_text_1 =>
      'AI phân tích khách quan cho bạn.';

  @override
  String get category_section_title => 'Danh mục';

  @override
  String get category_section_subtitle =>
      'Hãy chọn danh mục\nđể AI phân tích thành phần.';

  @override
  String get popular_category_section_title => 'Danh mục phổ biến';

  @override
  String get popular_category_section_subtitle =>
      'Danh mục được nhiều người phân tích.';

  @override
  String get ingredient_recent_title => 'Phân tích gần đây';

  @override
  String get ingredient_recent_subtitle =>
      'Bạn có thể xem lại\nkết quả phân tích gần đây!';

  @override
  String get nutrition_screen_header_title =>
      'Chụp dinh dưỡng\nđể chọn lành mạnh!';

  @override
  String get nutrition_screen_header_text => 'Lời khuyên sức khỏe từ AI.';

  @override
  String get nutrition_warnings => 'Cảnh báo dinh dưỡng';

  @override
  String get nutrition_benefits => 'Lợi ích dinh dưỡng';

  @override
  String get calorie_screen_header_title_1 =>
      'Chụp ảnh thức ăn\nđể kiểm tra calo!';

  @override
  String get calorie_screen_header_text_1 => 'AI tính toán dễ dàng cho bạn.';

  @override
  String get meal_type_main_meal => 'Bữa chính';

  @override
  String get meal_type_snack => 'Đồ ăn vặt';

  @override
  String get meal_type_late_night => 'Tráng miệng';

  @override
  String get section_title => 'Danh mục';

  @override
  String get section_subtitle => 'Chụp ảnh và phân tích thành phần';

  @override
  String get ingredient_analysis_title => 'Phân tích thành phần';

  @override
  String get ingredient_analysis_subtitle => 'Chụp ảnh và phân tích thành phần';

  @override
  String get recent_results_title => 'Kết Quả Gần Đây';

  @override
  String get recent_results_subtitle => 'Đây là kết quả của phân tích gần đây';

  @override
  String get no_recent_results => 'Không có kết quả phân tích gần đây';

  @override
  String get no_recent_nutrition_results =>
      'Không có kết quả phân tích dinh dưỡng gần đây';

  @override
  String get ads_title => 'Quảng Cáo';

  @override
  String get consent_required_title => 'Cần Sự Đồng Ý';

  @override
  String get consent_required_description =>
      'Để cung cấp dịch vụ phân tích thành phần bằng AI, chúng tôi cần hiển thị quảng cáo được cá nhân hóa. Điều này giúp chúng tôi trang trải chi phí xử lý AI.';

  @override
  String get consent_required_info =>
      'Quyền riêng tư của bạn rất quan trọng đối với chúng tôi. Chúng tôi chỉ thu thập dữ liệu cần thiết để hiển thị quảng cáo phù hợp và cải thiện trải nghiệm của bạn.';

  @override
  String get consent_agree_button => 'Đồng ý và tiếp tục';

  @override
  String get consent_exit_button => 'Thoát ứng dụng';

  @override
  String get consent_decline_button => 'Từ chối';

  @override
  String get announcements_title => 'Thông Báo';

  @override
  String get announcements_subtitle =>
      'Kiểm tra các cập nhật và tin tức mới nhất của chúng tôi';

  @override
  String get no_announcements => 'Không có thông báo mới';

  @override
  String get notifications => 'Thông báo';

  @override
  String get no_notifications => 'Không có thông báo';

  @override
  String time_days_ago(Object days) {
    return '$days ngày trước';
  }

  @override
  String time_hours_ago(Object hours) {
    return '$hours giờ trước';
  }

  @override
  String time_minutes_ago(Object minutes) {
    return '$minutes phút trước';
  }

  @override
  String get time_just_now => 'Vừa xong';

  @override
  String get select_category => 'Chọn Danh Mục';

  @override
  String get select_action =>
      'Chọn ‘Phân tích’ để xem một bảng thành phần, hoặc ‘So sánh’ để so sánh hai bảng.';

  @override
  String get food => 'Thực Phẩm';

  @override
  String get cosmetics => 'Mỹ Phẩm';

  @override
  String get baby_products => 'Sản Phẩm Em Bé';

  @override
  String get pet_products => 'Sản Phẩm Thú Cưng';

  @override
  String get medicine => 'Thuốc';

  @override
  String get household_products => 'Sản Phẩm Gia Đình';

  @override
  String get cleaning_products => 'Sản Phẩm Tẩy Rửa';

  @override
  String get vegan_products => 'Sản Phẩm Thuần Chay';

  @override
  String get other => 'Khác';

  @override
  String get nutrition_analysis => 'Phân tích dinh dưỡng';

  @override
  String get nutrition_analysis_title => 'Phân tích dinh dưỡng';

  @override
  String get nutrition_analysis_subtitle =>
      'Phân tích dinh dưỡng để\nduy trì chế độ ăn cân bằng.';

  @override
  String get calorie_analysis => 'Phân tích Calo';

  @override
  String get add_calorie => 'Thêm Calo';

  @override
  String get processed_food => 'Thực phẩm chế biến';

  @override
  String get dessert => 'Tráng miệng';

  @override
  String get beverages => 'Đồ uống';

  @override
  String get subcategories => 'Danh mục phụ';

  @override
  String get select_none => 'Không chọn';

  @override
  String get subcategory_help_message =>
      'Chọn danh mục phụ sẽ cho kết quả chính xác hơn.';

  @override
  String get food_health_food => 'Thực phẩm sức khỏe';

  @override
  String get food_diet_food => 'Thực phẩm ăn kiêng';

  @override
  String get food_dairy => 'Sản phẩm sữa';

  @override
  String get food_processed => 'Thực phẩm chế biến';

  @override
  String get food_instant => 'Thực phẩm nhanh';

  @override
  String get food_beverages => 'Đồ uống';

  @override
  String get food_snacks => 'Snack';

  @override
  String get food_bakery => 'Bánh kẹo';

  @override
  String get food_seasoning => 'Gia vị';

  @override
  String get cosmetics_skincare => 'Chăm sóc da';

  @override
  String get cosmetics_cleansing => 'Tẩy trang';

  @override
  String get cosmetics_suncare => 'Chống nắng';

  @override
  String get cosmetics_mask => 'Mặt nạ';

  @override
  String get cosmetics_makeup => 'Trang điểm';

  @override
  String get cosmetics_bodycare => 'Chăm sóc cơ thể';

  @override
  String get cosmetics_haircare => 'Chăm sóc tóc';

  @override
  String get cosmetics_handcare => 'Chăm sóc tay';

  @override
  String get cosmetics_footcare => 'Chăm sóc chân';

  @override
  String get cosmetics_mens => 'Mỹ phẩm nam';

  @override
  String get medicine_skin_treatment => 'Thuốc da liễu';

  @override
  String get medicine_allergy => 'Thuốc dị ứng';

  @override
  String get medicine_womens => 'Thuốc phụ khoa';

  @override
  String get medicine_general => 'Thuốc thông thường';

  @override
  String get medicine_supplements => 'Thực phẩm bổ sung';

  @override
  String get baby_skincare => 'Chăm sóc da em bé';

  @override
  String get baby_cleansers => 'Sữa tắm em bé';

  @override
  String get baby_medicine => 'Thuốc em bé';

  @override
  String get baby_food => 'Thức ăn dặm';

  @override
  String get baby_formula => 'Sữa bột';

  @override
  String get baby_sanitizers => 'Sát khuẩn';

  @override
  String get baby_detergent => 'Bột giặt em bé';

  @override
  String get baby_toys => 'Đồ chơi em bé';

  @override
  String get pet_supplements => 'Thực phẩm bổ sung thú cưng';

  @override
  String get pet_medicine => 'Thuốc thú cưng';

  @override
  String get pet_shampoo => 'Dầu gội thú cưng';

  @override
  String get pet_special_food => 'Thức ăn đặc biệt';

  @override
  String get pet_food => 'Thức ăn thú cưng';

  @override
  String get pet_treats => 'Snack thú cưng';

  @override
  String get pet_waste => 'Vệ sinh thú cưng';

  @override
  String get pet_toys => 'Đồ chơi thú cưng';

  @override
  String get household_products_dishwashing => 'Nước rửa bát';

  @override
  String get household_products_air_freshener => 'Xịt thơm phòng';

  @override
  String get household_products_cleaner => 'Chất tẩy rửa';

  @override
  String get household_products_deodorizer => 'Khử mùi';

  @override
  String get analyze => 'Phân Tích';

  @override
  String get select_image_source => 'Chọn Nguồn Hình Ảnh';

  @override
  String get ingredient_photography => 'Chụp Ảnh';

  @override
  String get camera => 'Máy Ảnh';

  @override
  String get gallery => 'Thư Viện';

  @override
  String get crop_image => 'Cắt Hình';

  @override
  String get crop_instruction =>
      'Vui lòng điều chỉnh vị trí và kích thước để nội dung thành phần nằm trong hộp màu trắng. Bạn có thể chụm hai ngón tay để phóng to/thu nhỏ và kéo viền trắng để di chuyển hộp.';

  @override
  String get nutrition_crop_instruction =>
      'Vui lòng điều chỉnh vị trí và kích thước để nội dung dinh dưỡng nằm trong hộp màu trắng. Bạn có thể chụm hai ngón tay để phóng to/thu nhỏ và kéo viền trắng để di chuyển hộp.';

  @override
  String get reset_zoom => 'Đặt Lại Thu Phóng';

  @override
  String get get_started => 'Bắt đầu';

  @override
  String get onboarding_step1_title =>
      'Bắt đầu phân tích thành phần thông minh';

  @override
  String get onboarding_step1_description =>
      'Lựa chọn từ các danh mục khác nhau như thực phẩm, mỹ phẩm, sản phẩm em bé, v.v. Việc chọn danh mục phụ sẽ giúp bạn có kết quả phân tích chính xác hơn.';

  @override
  String get onboarding_step2_title =>
      'Phân tích thành phần thông minh bằng AI';

  @override
  String get onboarding_step2_description =>
      'Chỉ cần chụp ảnh danh sách thành phần của sản phẩm, AI sẽ ngay lập tức phân tích tính an toàn, đặc điểm, và sự phù hợp cá nhân. Bạn cũng có thể xem thông tin chi tiết của từng thành phần nữa!';

  @override
  String get onboarding_step3_title =>
      'Phân tích dinh dưỡng cho bữa ăn hàng ngày';

  @override
  String get onboarding_step3_description =>
      'Chụp ảnh bảng dinh dưỡng hoặc menu trong siêu thị, quán cafe, nhà hàng. AI sẽ cho bạn biết món nào tốt hơn cho sức khỏe!';

  @override
  String get onboarding_step4_title => 'Kiểm tra sự cân bằng dinh dưỡng';

  @override
  String get onboarding_step4_description =>
      'AI phân tích bảng dinh dưỡng và cho biết tỷ lệ cân bằng của carbohydrate, chất béo, protein và tác động đến sức khỏe. Chọn lựa chọn lành mạnh!';

  @override
  String get onboarding_step5_title => 'Ghi lại calo thực phẩm hàng ngày';

  @override
  String get onboarding_step5_description =>
      'Chụp ảnh ăn sáng, ăn trưa, ăn tối, và đồ ăn vặt. Nhấn nút + để ghi lại một cách dễ dàng. Theo dõi lượng calo tiêu thụ hàng ngày!';

  @override
  String get onboarding_step6_title =>
      'Phân tích calo bằng AI và theo dõi dữ liệu';

  @override
  String get onboarding_step6_description =>
      'AI nhận diện thực phẩm từ ảnh và tính toán calo chính xác. Quản lý chế độ ăn uống lành mạnh với biểu đồ dữ liệu hàng ngày và hàng tuần!';

  @override
  String get confirm => 'Xác Nhận';

  @override
  String get cancel => 'Hủy';

  @override
  String get analysis_notice =>
      'Phân tích AI mất 5-20 giây (có thể thay đổi tùy theo điều kiện mạng). Quảng cáo sẽ được hiển thị trong quá trình phân tích để hỗ trợ dịch vụ. Bạn có thể đóng quảng cáo sau 5 giây.';

  @override
  String get dont_show_again => 'Không hiển thị lại';

  @override
  String get positive_ingredients => 'Thành Phần Tốt';

  @override
  String get negative_ingredients => 'Thành Phần Xấu';

  @override
  String get other_ingredients => 'Thành Phần Khác';

  @override
  String get overall_review => 'Đánh Giá Tổng Thể';

  @override
  String get category_analysis => 'Phân Tích Chỉ Số';

  @override
  String get category_comparison => 'So Sánh Chỉ Số';

  @override
  String get nutritional_value => 'Giá Trị Dinh Dưỡng';

  @override
  String get safety => 'An Toàn';

  @override
  String get natural_ingredients => 'Thành Phần Tự Nhiên';

  @override
  String get functional_benefits => 'Lợi Ích Chức Năng';

  @override
  String get taste_quality => 'Chất Lượng Hương Vị';

  @override
  String get moisturizing => 'Dưỡng Ẩm';

  @override
  String get hypoallergenic => 'Ít Gây Dị Ứng';

  @override
  String get longevity => 'Độ Bền';

  @override
  String get stability => 'Ổn Định';

  @override
  String get absorption => 'Hấp Thụ';

  @override
  String get effectiveness => 'Hiệu Quả';

  @override
  String get gentleness => 'Nhẹ Nhàng';

  @override
  String get safety_standards => 'Tiêu Chuẩn An Toàn';

  @override
  String get nutritional_balance => 'Cân Bằng Dinh Dưỡng';

  @override
  String get digestibility => 'Tiêu Hóa';

  @override
  String get palatability => 'Khẩu Vị';

  @override
  String get functionality => 'Chức Năng';

  @override
  String get side_effects => 'Rủi Ro Thấp';

  @override
  String get quality_standards => 'Tiêu Chuẩn Chất Lượng';

  @override
  String get interactions => 'Tương Tác';

  @override
  String get error => 'Lỗi';

  @override
  String get network_error => 'Lỗi mạng. Vui lòng thử lại.';

  @override
  String get analysis_failed => 'Phân tích thất bại. Vui lòng thử lại.';

  @override
  String get no_ingredients_found => 'Không tìm thấy thành phần.';

  @override
  String get loading => 'Đang tải...';

  @override
  String get analyzing => 'Đang phân tích...';

  @override
  String get ai_analysis_message =>
      'Vui lòng đợi một chút! AI đang phân tích thông tin thành phần một cách chính xác✨ (Mất khoảng 10 giây)';

  @override
  String get please_select_category => 'Vui lòng chọn danh mục';

  @override
  String get enter_custom_category => 'Vui lòng nhập danh mục tùy chỉnh';

  @override
  String take_photo_for_category(Object category) {
    return 'Chụp ảnh cho danh mục $category';
  }

  @override
  String take_photo_of_ingredients(Object category) {
    return 'Vui lòng chụp ảnh thành phần của $category bằng máy ảnh hoặc chọn ảnh từ thư viện';
  }

  @override
  String get camera_permission_needed => 'Cần quyền truy cập camera.';

  @override
  String get settings => 'Cài đặt';

  @override
  String get menu => 'Menu';

  @override
  String photo_error(Object error) {
    return 'Lỗi khi chụp ảnh: $error';
  }

  @override
  String get photo_taken => 'Đã chụp ảnh';

  @override
  String category_label(Object category) {
    return 'Danh mục: $category';
  }

  @override
  String get taking_photo => 'Đang chụp ảnh...';

  @override
  String get photo_instruction =>
      'Hãy thoải mái chụp ảnh vì bạn có thể chỉ định khu vực danh sách thành phần sau khi chụp.';

  @override
  String get check_photo_in_range =>
      'Danh sách thành phần đã được chụp rõ trong khung chưa?';

  @override
  String get take_photo => 'Chụp Ảnh';

  @override
  String get horizontal_guide => 'Ngang';

  @override
  String get vertical_guide => 'Dọc';

  @override
  String get close => 'Đóng';

  @override
  String get rotate => 'Xoay';

  @override
  String get done => 'Hoàn tất';

  @override
  String get confirm_analysis_notice =>
      'Khi bạn nhấn phân tích, việc phân tích AI sẽ tiến hành ngay lập tức và quảng cáo sẽ được hiển thị trong quá trình phân tích.';

  @override
  String get app_subtitle => 'Công cụ phân tích thành phần bằng AI';

  @override
  String get ai_disclaimer =>
      'Việc phân tích thành phần và dinh dưỡng trong ứng dụng này được AI tự động tạo ra và không dựa trên bất kỳ tổ chức cụ thể nào hoặc nguồn chính thức. Thông tin được cung cấp chỉ mang tính chất tham khảo và có thể chứa lỗi. Hãy tham khảo ý kiến chuyên gia cho các quyết định quan trọng. 😊';

  @override
  String get save_screenshot => 'Lưu Kết Quả';

  @override
  String get screenshot_saved => 'Kết quả đã được lưu vào thư viện';

  @override
  String get screenshot_failed => 'Lưu thất bại';

  @override
  String get storage_permission_needed => 'Cần quyền truy cập bộ nhớ';

  @override
  String get save_result => 'Lưu Kết Quả';

  @override
  String get result_name => 'Tên';

  @override
  String get enter_result_name => 'Nhập tên kết quả';

  @override
  String get save => 'Lưu';

  @override
  String get result_saved => 'Lưu kết quả thành công';

  @override
  String get save_failed_simple => 'Lưu thất bại';

  @override
  String get saved_results => 'Kết Quả Đã Lưu';

  @override
  String get saved_analysis => 'Phân Tích Đã Lưu';

  @override
  String get no_saved_results => 'Không có kết quả đã lưu';

  @override
  String get analysis => 'Phân Tích';

  @override
  String get comparison => 'So Sánh';

  @override
  String get edit_name => 'Sửa Tên';

  @override
  String get delete => 'Xóa';

  @override
  String get confirm_delete => 'Xác Nhận Xóa';

  @override
  String get confirm_delete_message => 'Bạn có chắc chắn muốn xóa không?';

  @override
  String get delete_success => 'Xóa thành công';

  @override
  String get delete_failed => 'Xóa thất bại';

  @override
  String get analysis_results => 'Kết Quả Phân Tích';

  @override
  String get compare => 'So Sánh';

  @override
  String get product_a => 'Sản Phẩm A';

  @override
  String get product_b => 'Sản Phẩm B';

  @override
  String get compare_ingredients => 'So Sánh Thành Phần';

  @override
  String get select_both_products => 'Vui lòng chọn cả hai sản phẩm để so sánh';

  @override
  String get overall_comparison => 'So Sánh Tổng Thể';

  @override
  String get tap_to_add => 'Chạm để thêm';

  @override
  String get compare_instruction =>
      'Vui lòng chụp hoặc chọn bảng thành phần của từng sản phẩm.';

  @override
  String get ingredient_search => 'Tìm Kiếm Thành Phần';

  @override
  String ingredient_search_message(Object ingredient) {
    return 'Chúng ta cùng tìm hiểu thêm về \"$ingredient\" nhé?';
  }

  @override
  String get search => 'Tìm Kiếm';

  @override
  String get save_ingredient => 'Lưu thông tin thành phần';

  @override
  String get enter_save_name => 'Vui lòng nhập tên để lưu';

  @override
  String get save_name_hint => 'Ví dụ: Thông tin Vitamin C';

  @override
  String get enter_name => 'Vui lòng nhập tên';

  @override
  String get save_complete => 'Lưu hoàn tất';

  @override
  String get recent_ingredients_title => 'Tìm Kiếm Thành Phần Gần Đây';

  @override
  String get recent_ingredients_subtitle =>
      'Thông tin thành phần đã tìm kiếm gần đây';

  @override
  String get no_recent_ingredients =>
      'Không có bản ghi tìm kiếm thành phần gần đây';

  @override
  String get ingredients => 'thành phần';

  @override
  String get no_saved_ingredients => 'Không có thành phần đã lưu';

  @override
  String get searching => 'Đang tìm kiếm...';

  @override
  String get searching_ingredient_info =>
      'Đang tìm kiếm thông tin thành phần...';

  @override
  String get description => 'Mô tả';

  @override
  String get alternative_names => 'Tên khác';

  @override
  String get primary_functions => 'Chức năng chính';

  @override
  String get benefits => 'Lợi ích';

  @override
  String get precautions => 'Lưu ý';

  @override
  String get additional_info => 'Thông tin bổ sung';

  @override
  String get ingredient_detail_search => 'Xem Chi Tiết';

  @override
  String get share => 'Chia sẻ';

  @override
  String get sharing => 'Đang chia sẻ...';

  @override
  String get profile => 'Hồ sơ';

  @override
  String get user_info => 'Thông tin người dùng';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get privacy_policy => 'Chính sách Bảo mật';

  @override
  String get terms_of_service => 'Điều khoản Dịch vụ';

  @override
  String get help_feedback => 'Trợ giúp & Phản hồi';

  @override
  String get religion => 'Tôn giáo';

  @override
  String get skin => 'Loại da';

  @override
  String get allergy => 'Dị ứng';

  @override
  String get diet => 'Hạn chế chế độ ăn';

  @override
  String get health => 'Tình trạng sức khỏe';

  @override
  String get add_custom => 'Thêm tùy chỉnh';

  @override
  String get enter_custom_value => 'Nhập giá trị tùy chỉnh';

  @override
  String get custom_value_hint => 'ví dụ: Không dung nạp lactose';

  @override
  String get value_already_exists => 'Giá trị này đã tồn tại';

  @override
  String get preference_added => 'Đã thêm sở thích thành công';

  @override
  String get preference_removed => 'Đã xóa sở thích thành công';

  @override
  String get select_preferred_language => 'Chọn ngôn ngữ ưa thích của bạn';

  @override
  String language_changed_to(Object language) {
    return 'Đã đổi ngôn ngữ thành $language';
  }

  @override
  String get christianity => 'Cơ đốc giáo';

  @override
  String get islam => 'Hồi giáo';

  @override
  String get hinduism => 'Ấn Độ giáo';

  @override
  String get buddhism => 'Phật giáo';

  @override
  String get sensitive => 'Nhạy cảm';

  @override
  String get dry => 'Khô';

  @override
  String get oily => 'Dầu';

  @override
  String get combination => 'Hỗn hợp';

  @override
  String get normal => 'Bình thường';

  @override
  String get acne_prone => 'Dễ bị mụn';

  @override
  String get atopic => 'Viêm da cơ địa';

  @override
  String get nuts => 'Hạt';

  @override
  String get dairy => 'Sản phẩm từ sữa';

  @override
  String get eggs => 'Trứng';

  @override
  String get soy => 'Đậu nành';

  @override
  String get gluten => 'Gluten';

  @override
  String get shellfish => 'Hải sản có vỏ';

  @override
  String get fish => 'Cá';

  @override
  String get sesame => 'Mè';

  @override
  String get vegetarian => 'Ăn chay';

  @override
  String get vegan => 'Thuần chay';

  @override
  String get low_carb => 'Ít carb';

  @override
  String get gluten_free => 'Không gluten';

  @override
  String get dairy_free => 'Không sữa';

  @override
  String get sugar_free => 'Không đường';

  @override
  String get halal => 'Halal';

  @override
  String get diabetes => 'Tiểu đường';

  @override
  String get hypertension => 'Tăng huyết áp';

  @override
  String get heart_disease => 'Bệnh tim';

  @override
  String get kidney_disease => 'Bệnh thận';

  @override
  String get pregnancy => 'Thai kỳ';

  @override
  String get breastfeeding => 'Cho con bú';

  @override
  String get daily_limit_reached =>
      'Đã đạt giới hạn sử dụng hàng ngày. Vui lòng thử lại vào ngày mai.';

  @override
  String get custom_limit_reached => 'Tối đa cho phép 3 mục tùy chỉnh';

  @override
  String get invalid_characters => 'Không được phép dùng ký tự đặc biệt';

  @override
  String get text_too_long => 'Tối đa cho phép 20 ký tự';

  @override
  String get apply_profile => 'Áp dụng tùy chọn hồ sơ của tôi';

  @override
  String get profile_settings => 'Cài đặt hồ sơ';

  @override
  String get crop_area_required =>
      'Chưa chọn khu vực thành phần. Vui lòng điều chỉnh hộp màu trắng để bao gồm danh sách thành phần.';

  @override
  String get baby_info => 'Thông tin em bé';

  @override
  String get pet_info => 'Thông tin thú cưng';

  @override
  String get baby_age => 'Tuổi';

  @override
  String get pet_type => 'Loại';

  @override
  String get pet_breed => 'Giống';

  @override
  String get weight => 'Cân nặng';

  @override
  String get neutered => 'Tình trạng triệt sản';

  @override
  String get dog => 'Chó';

  @override
  String get cat => 'Mèo';

  @override
  String get bird => 'Chim';

  @override
  String get rabbit => 'Thỏ';

  @override
  String get hamster => 'Chuột hamster';

  @override
  String get neutered_yes => 'Có';

  @override
  String get neutered_no => 'Không';

  @override
  String get baby_age_0_6_months => '0-6 tháng';

  @override
  String get baby_age_6_12_months => '6-12 tháng';

  @override
  String get baby_age_1_2_years => '1-2 tuổi';

  @override
  String get baby_age_2_3_years => '2-3 tuổi';

  @override
  String get baby_age_3_5_years => '3-5 tuổi';

  @override
  String get baby_age_5_plus_years => '5+ tuổi';

  @override
  String get baby_health_healthy => 'Khỏe mạnh';

  @override
  String get baby_health_asthma => 'Hen suyễn';

  @override
  String get baby_health_digestive_sensitivity => 'Nhạy cảm tiêu hóa';

  @override
  String get baby_health_constipation => 'Táo bón';

  @override
  String get baby_health_diarrhea => 'Tiêu chảy';

  @override
  String get pet_age_0_1_year => '0-1 tuổi';

  @override
  String get pet_age_1_3_years => '1-3 tuổi';

  @override
  String get pet_age_3_5_years => '3-5 tuổi';

  @override
  String get pet_age_5_7_years => '5-7 tuổi';

  @override
  String get pet_age_7_10_years => '7-10 tuổi';

  @override
  String get pet_age_10_plus_years => '10+ tuổi';

  @override
  String get pet_weight_under_1kg => 'Dưới 1kg';

  @override
  String get pet_weight_1_3kg => '1-3kg';

  @override
  String get pet_weight_3_5kg => '3-5kg';

  @override
  String get pet_weight_5_10kg => '5-10kg';

  @override
  String get pet_weight_10_20kg => '10-20kg';

  @override
  String get pet_weight_over_20kg => 'Trên 20kg';

  @override
  String get pet_allergy_grains => 'Ngũ cốc';

  @override
  String get pet_allergy_chicken => 'Thịt gà';

  @override
  String get pet_allergy_beef => 'Thịt bò';

  @override
  String get pet_health_healthy => 'Khỏe mạnh';

  @override
  String get pet_health_arthritis => 'Viêm khớp';

  @override
  String get pet_health_heart_disease => 'Bệnh tim';

  @override
  String get pet_health_kidney_disease => 'Bệnh thận';

  @override
  String get pet_health_liver_disease => 'Bệnh gan';

  @override
  String get pet_health_diabetes => 'Tiểu đường';

  @override
  String get pet_health_skin_disease => 'Bệnh da';

  @override
  String get pet_health_digestive_disease => 'Bệnh tiêu hóa';

  @override
  String get pet_breed_input_message => 'Vui lòng nhập giống trực tiếp';

  @override
  String get apply_user_info => 'Áp dụng thông tin người dùng';

  @override
  String get apply_baby_info => 'Áp dụng thông tin em bé';

  @override
  String get apply_pet_info => 'Áp dụng thông tin thú cưng';

  @override
  String get vision_api_error =>
      'Không thể tìm thấy văn bản thành phần trong hình ảnh.';

  @override
  String get ai_evaluation_score => 'Điểm AI';

  @override
  String get excellent => 'Xuất Sắc';

  @override
  String get good => 'Tốt';

  @override
  String get average => 'Trung Bình';

  @override
  String get caution => 'Cẩn Thận';

  @override
  String get points => 'điểm';

  @override
  String get personalized_info_applied => '(Thông Tin Tùy Chỉnh Được Áp Dụng)';

  @override
  String get height => 'Chiều cao';

  @override
  String get current_weight => 'Cân nặng hiện tại';

  @override
  String get target_weight => 'Cân nặng mục tiêu';

  @override
  String get height_cm => 'Chiều cao (cm)';

  @override
  String get weight_kg => 'Cân nặng (kg)';

  @override
  String get target_weight_kg => 'Cân nặng mục tiêu (kg)';

  @override
  String get physical_info => 'Thông tin thể chất';

  @override
  String get baby_weight => 'Cân nặng';

  @override
  String get baby_weight_under_5kg => 'Dưới 5kg';

  @override
  String get baby_weight_5_10kg => '5-10kg';

  @override
  String get baby_weight_10_15kg => '10-15kg';

  @override
  String get baby_weight_15_20kg => '15-20kg';

  @override
  String get baby_weight_over_20kg => 'Trên 20kg';

  @override
  String get direct_input => 'Direct Input';

  @override
  String get bottom_nav_ingredient_analysis => 'Ingredient Analysis';

  @override
  String get bottom_nav_nutrition_analysis => 'Nutrition Analysis';

  @override
  String get bottom_nav_storage => 'Storage';

  @override
  String get recent_history => 'Lịch sử gần đây';

  @override
  String get calorie_management => 'Quản lý calo';

  @override
  String get ingredients_short => 'Thành phần';

  @override
  String get nutrition_short => 'Dinh dưỡng';

  @override
  String get history_short => 'Lịch sử';

  @override
  String get calorie_short => 'Calo';

  @override
  String get today_calories_section_title => 'Calo hôm nay';

  @override
  String get today_calories_section_subtitle =>
      'Kiểm tra calo bạn đã ghi nhận hôm nay.';

  @override
  String get no_calories_today => 'Không có calo nào được ghi lại hôm nay';

  @override
  String more_items_count(Object count) {
    return 'Còn $count mục nữa';
  }

  @override
  String get weekly_calories_section_title => 'Calo hàng tuần';

  @override
  String get weekly_calories_section_subtitle =>
      'Xem thay đổi lượng calo\nhằng ngày trong tuần.';

  @override
  String daily_average_calories(Object calories) {
    return 'TB ngày $calories kcal';
  }

  @override
  String get weekday_mon => 'T2';

  @override
  String get weekday_tue => 'T3';

  @override
  String get weekday_wed => 'T4';

  @override
  String get weekday_thu => 'T5';

  @override
  String get weekday_fri => 'T6';

  @override
  String get weekday_sat => 'T7';

  @override
  String get weekday_sun => 'CN';

  @override
  String get monthly_calorie_report => 'Báo cáo calo hàng tháng';

  @override
  String get calorie_analysis_result => 'Kết quả phân tích calo';

  @override
  String get calorie_saved => 'Calo đã được lưu thành công';

  @override
  String save_failed_with_error(Object error) {
    return 'Lưu thất bại: $error';
  }

  @override
  String get delete_error => 'Có lỗi xảy ra khi xóa';

  @override
  String get total_calories => 'Tổng calo';

  @override
  String get meal_type => 'Loại bữa ăn';

  @override
  String get date_and_time => 'Ngày và giờ';

  @override
  String get food_detail => 'Chi tiết thức ăn';

  @override
  String get nutrition_info => 'Thông tin dinh dưỡng';

  @override
  String get delete_calorie => 'Xóa calo';

  @override
  String get delete_item => 'Xóa';

  @override
  String per_unit(Object amount, Object calories) {
    return '$calories kcal trên $amount';
  }

  @override
  String get protein => 'Protein';

  @override
  String get fat => 'Chất béo';

  @override
  String get carbohydrate => 'Carbohydrate';

  @override
  String get sodium => 'Natri';

  @override
  String get sugar => 'Đường';

  @override
  String get trans_fat => 'Chất béo trans';

  @override
  String get saturated_fat => 'Chất béo bão hòa';

  @override
  String get cholesterol => 'Cholesterol';

  @override
  String get food_name_edit => 'Sửa tên thức ăn';

  @override
  String get enter_calorie => 'Nhập calo';

  @override
  String get enter_food_name => 'Nhập tên thức ăn';

  @override
  String get valid_calorie_error => 'Vui lòng nhập calo hợp lệ';

  @override
  String get food_name_error => 'Vui lòng nhập tên thức ăn';

  @override
  String get food_not_found =>
      'Không tìm thấy thông tin thức ăn trong hình ảnh.';

  @override
  String get nutrition_not_found =>
      'Không tìm thấy thông tin dinh dưỡng trong hình ảnh.';

  @override
  String share_error(Object error) {
    return 'Đã xảy ra lỗi khi chia sẻ: $error';
  }

  @override
  String get daily_total_calories => 'Tổng Calo Hàng Ngày';

  @override
  String get ingredient_analysis_photo_subtitle =>
      'Chụp ảnh thành phần để nhận phân tích AI';

  @override
  String get nutrition_analysis_photo_subtitle =>
      'Chụp ảnh bảng thành phần dinh dưỡng để kiểm tra thông tin sức khỏe';

  @override
  String get calorie_analysis_photo_subtitle =>
      'Chụp ảnh và AI sẽ phân tích lượng calo cho bạn';
}
