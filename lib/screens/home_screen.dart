import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/category.dart';
import '../services/localization_service.dart';
import '../services/preferences_service.dart';
import '../utils/theme.dart';
import '../widgets/ad_banner_widget.dart';
import 'image_source_screen.dart';
import 'compare_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;
  String? _customCategory;
  final TextEditingController _customCategoryController =
      TextEditingController();
  bool _showCustomInput = false;

  @override
  void initState() {
    super.initState();
    _loadLastSelectedCategory();
    // 홈 화면에서 상태바와 네비게이션 바 색상 설정
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppTheme.backgroundColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _loadLastSelectedCategory() {
    final lastCategory = PreferencesService.instance.getLastSelectedCategory();
    if (lastCategory != null) {
      setState(() {
        _selectedCategory = lastCategory;
      });
    }
  }

  @override
  void dispose() {
    _customCategoryController.dispose();
    super.dispose();
  }

  Widget _buildCategoryCard(Category category) {
    final isSelected = _selectedCategory == category.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category.id;
          _customCategory = null;
          _showCustomInput = false;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.whiteColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.whiteColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.cardShadow.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              16, 14, 14, 16), // 왼쪽, 위, 오른쪽, 아래 (border 2px 보정)
          child: Stack(
            children: [
              // 오른쪽 위 아이콘
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  category.icon,
                  size: 28,
                  color: AppTheme.primaryGreen,
                ),
              ),
              // 왼쪽 아래 텍스트
              Positioned(
                bottom: 0,
                left: 0,
                right: 8,
                child: Text(
                  AppLocalizations.of(context)!.translate(category.nameKey),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtherCard() {
    final isSelected = _selectedCategory == 'other';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = 'other';
          _showCustomInput = true;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.whiteColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.whiteColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              16, 14, 14, 16), // 왼쪽, 위, 오른쪽, 아래 (border 2px 보정)
          child: Stack(
            children: [
              // 오른쪽 위 아이콘
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.more_horiz,
                  size: 26,
                  color: AppTheme.primaryGreen,
                ),
              ),
              // 왼쪽 아래 텍스트
              Positioned(
                bottom: 0,
                left: 0,
                right: 8,
                child: Text(
                  AppLocalizations.of(context)!.translate('other'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onComparePressed() {
    String? categoryToCompare;

    if (_selectedCategory == 'other') {
      categoryToCompare = _customCategory?.trim();
      if (categoryToCompare == null || categoryToCompare.isEmpty) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate('enter_custom_category')),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
        return;
      }
    } else {
      categoryToCompare = _selectedCategory;
    }

    if (categoryToCompare == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .translate('please_select_category')),
          backgroundColor: AppTheme.negativeColor,
        ),
      );
      return;
    }

    // Navigate to compare screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompareScreen(category: categoryToCompare!),
        settings: const RouteSettings(name: '/compare'),
      ),
    );
  }

  void _onAnalyzePressed() {
    String? categoryToAnalyze;

    if (_selectedCategory == 'other') {
      categoryToAnalyze = _customCategory?.trim();
      if (categoryToAnalyze == null || categoryToAnalyze.isEmpty) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate('enter_custom_category')),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
        return;
      }
    } else {
      categoryToAnalyze = _selectedCategory;
    }

    if (categoryToAnalyze == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .translate('please_select_category')),
          backgroundColor: AppTheme.negativeColor,
        ),
      );
      return;
    }

    if (_selectedCategory != null && _selectedCategory != 'other') {
      PreferencesService.instance.setLastSelectedCategory(_selectedCategory!);
    }

    _navigateToImageSource(categoryToAnalyze);
  }

  void _navigateToImageSource(String category) {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageSourceScreen(category: category),
        ),
      );
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse('https://falsy.me/ingredientlens/privacy.html');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open Privacy Policy'),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
    }
  }

  Future<void> _launchTermsOfService() async {
    final Uri url = Uri.parse('https://falsy.me/ingredientlens/terms.html');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open Terms of Service'),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false, // 하단 SafeArea 비활성화
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight - 48, // vertical padding 제외
                      ),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 340),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 18),
                                  // App Title (왼쪽 정렬)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 2),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .translate('app_name')
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: AppTheme.primaryGreen,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // App Subtitle
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 2),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .translate('app_subtitle')
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: AppTheme.primaryGreen,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Category Grid
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(
                                        4), // 그림자를 위한 패딩 추가
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 20,
                                      childAspectRatio: 1.0, // 정사각형
                                    ),
                                    itemCount:
                                        categories.length + 1, // +1 for Other
                                    itemBuilder: (context, index) {
                                      if (index < categories.length) {
                                        return _buildCategoryCard(
                                            categories[index]);
                                      } else {
                                        return _buildOtherCard();
                                      }
                                    },
                                  ),

                                  const SizedBox(height: 18),

                                  // Custom category input (like search bar)
                                  if (_showCustomInput) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppTheme.whiteColor,
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border: Border.all(
                                            color: AppTheme.primaryGreen
                                                .withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: _customCategoryController,
                                          onChanged: (value) {
                                            setState(() {
                                              _customCategory = value;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hintText: AppLocalizations.of(
                                                    context)!
                                                .translate(
                                                    'enter_custom_category'),
                                            hintStyle: TextStyle(
                                              color: AppTheme.primaryGreen
                                                  .withOpacity(0.4),
                                              fontSize: 13,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 18,
                                              vertical: 12,
                                            ),
                                          ),
                                          style: TextStyle(
                                            color: AppTheme.primaryGreen,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],

                                  // Analyze button
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: _onAnalyzePressed,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppTheme.primaryGreen,
                                          foregroundColor: AppTheme.whiteColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          elevation: 2,
                                        ),
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .translate('analyze'),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Compare button
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: OutlinedButton(
                                        onPressed: _onComparePressed,
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              color: AppTheme.primaryGreen,
                                              width: 1.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                        ),
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .translate('compare'),
                                          style: TextStyle(
                                            color: AppTheme.primaryGreen,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                ],
                              ),

                              // Footer with copyright and links
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '© Falsy.',
                                      style: TextStyle(
                                        color: AppTheme.gray700,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: _launchPrivacyPolicy,
                                      child: Text(
                                        'Privacy Policy',
                                        style: TextStyle(
                                          color: AppTheme.gray700,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: _launchTermsOfService,
                                      child: Text(
                                        'Terms of Service',
                                        style: TextStyle(
                                          color: AppTheme.gray700,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Ad banner at bottom
          const AdBannerWidget(),
        ],
      ),
    );
  }
}
