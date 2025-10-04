import 'package:flutter/material.dart';
import 'package:ingredient_lens/l10n/app_localizations.dart';
// import 'package:ingredient_lens/widgets/ad_banner_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/localization_service.dart';
import '../services/analytics_service.dart';
import '../utils/theme.dart';
import '../widgets/tab_header_widget.dart';
import 'language_settings_screen.dart';
import 'profile_screen.dart';
import 'baby_info_screen.dart';
import 'pet_info_screen.dart';
import 'saved_results_screen.dart';

class MenuScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const MenuScreen({super.key, this.scrollController});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  Future<void> _launchHelpFeedback(BuildContext context) async {
    final currentLocale = LocalizationService.instance.locale;
    String feedbackUrl;

    switch (currentLocale.languageCode) {
      case 'ko':
        feedbackUrl =
            'https://docs.google.com/forms/d/1gwE2nDOU0nIhrWyrhyAUj36Cm_X0OdTLNp4xSL8QKkU';
        break;
      case 'en':
        feedbackUrl =
            'https://docs.google.com/forms/d/1BtVw-Nh1wZM6HBE9nAJIgBhHKuQ-89W2WnzGO7Nsu4k';
        break;
      case 'zh':
        feedbackUrl =
            'https://docs.google.com/forms/d/1hlK0T03Fa_MoqZtvlB20om_qgfSnTjzvPjCB6KoymNc';
        break;
      case 'hi':
        feedbackUrl =
            'https://docs.google.com/forms/d/1Wtx-Dbo67td2LuJJBqjJ-tXEWTh5VP0-eKjqr3Vh1pY';
        break;
      case 'ja':
        feedbackUrl =
            'https://docs.google.com/forms/d/1JNqnZj6xRWmFaTpqjcAPCkdJzzbqDVX11KGmlpNoLbU';
        break;
      case 'vi':
        feedbackUrl =
            'https://docs.google.com/forms/d/1Z0EvtvvmZvdL-JflOqpB0avttn34coMatHhWPLlatDU';
        break;
      case 'th':
        feedbackUrl =
            'https://docs.google.com/forms/d/1_QdxMNihXJg2-1fqlk38ucfxLVuc2A8lFUpkMdVkCkU';
        break;
      case 'pt':
        feedbackUrl =
            'https://docs.google.com/forms/d/1L76v_piWdi7cTHxBUcTO5pzNjhaiIfah_UO2mIoMRcg';
        break;
      case 'es':
        feedbackUrl =
            'https://docs.google.com/forms/d/12jBLeo4sK0Z6MeyqNQhKbUPU-gXIF1zrPnCaNruckSA';
        break;
      default:
        feedbackUrl =
            'https://docs.google.com/forms/d/1BtVw-Nh1wZM6HBE9nAJIgBhHKuQ-89W2WnzGO7Nsu4k'; // Default to English
        break;
    }

    final Uri url = Uri.parse(feedbackUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Help & Feedback'),
            backgroundColor: AppTheme.negativeColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
          ),
        ),
        child: Column(
          children: [
            // 고정 헤더
            SafeArea(
              bottom: false,
              child: TabHeaderWidget(
                title: AppLocalizations.of(context)!.menu,
              ),
            ),
            Expanded(
                child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Settings Items
                  _buildSettingsItem(
                    iconPath: 'assets/images/icons/user_info.webp',
                    title: AppLocalizations.of(context)!.user_info,
                    onTap: () {
                      // Analytics: 사용자 정보 화면 진입
                      AnalyticsService.logScreenView('user_info');

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    showArrow: true,
                  ),

                  const SizedBox(height: 2),

                  _buildSettingsItem(
                    iconPath: 'assets/images/icons/baby_info.webp',
                    title: AppLocalizations.of(context)!.baby_info,
                    onTap: () {
                      // Analytics: 아기 정보 화면 진입
                      AnalyticsService.logScreenView('baby_info');

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BabyInfoScreen(),
                        ),
                      );
                    },
                    showArrow: true,
                  ),

                  const SizedBox(height: 2),

                  _buildSettingsItem(
                    iconPath: 'assets/images/icons/pet_info.webp',
                    title: AppLocalizations.of(context)!.pet_info,
                    onTap: () {
                      // Analytics: 반려동물 정보 화면 진입
                      AnalyticsService.logScreenView('pet_info');

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PetInfoScreen(),
                        ),
                      );
                    },
                    showArrow: true,
                  ),

                  const SizedBox(height: 2),

                  _buildSettingsItem(
                    iconPath: 'assets/images/icons/save.webp',
                    title: AppLocalizations.of(context)!.saved_analysis,
                    onTap: () {
                      // Analytics: 저장된 분석 화면 진입
                      AnalyticsService.logScreenView('saved_results');

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavedResultsScreen(),
                          settings: const RouteSettings(name: '/saved-results'),
                        ),
                      );
                    },
                    showArrow: true,
                  ),

                  const SizedBox(height: 2),

                  _buildSettingsItem(
                    iconPath: 'assets/images/icons/language.webp',
                    title: AppLocalizations.of(context)!.language,
                    onTap: () {
                      // Analytics: 언어 설정 화면 진입
                      AnalyticsService.logScreenView('language_settings');

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguageSettingsScreen(),
                        ),
                      );
                    },
                    showArrow: true,
                  ),

                  const SizedBox(height: 2),

                  _buildSettingsItem(
                    iconPath: 'assets/images/icons/feedback.webp',
                    title: AppLocalizations.of(context)!.help_feedback,
                    onTap: () => _launchHelpFeedback(context),
                    showArrow: false,
                  ),

                  const SizedBox(height: 20),

                  // Container(
                  //   width: double.infinity,
                  //   height: 6,
                  //   color: AppTheme.dividerColor,
                  // ),

                  // const AdBannerWidget(),

                  Container(
                    width: double.infinity,
                    height: 6,
                    color: AppTheme.dividerColor,
                  ),

                  const SizedBox(height: 20),

                  // Version Info
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Text(
                      _version.isNotEmpty ? 'Version $_version' : '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color.fromARGB(120, 0, 0, 0),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required String iconPath,
    required String title,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
        child: Row(
          children: [
            // 아이콘 컨테이너
            Container(
              width: 48,
              height: 48,
              // decoration: BoxDecoration(
              //   color: AppTheme.gray100,
              //   borderRadius: BorderRadius.circular(12),
              // ),
              child: Center(
                child: Image.asset(
                  iconPath,
                  width: 38,
                  height: 38,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(180, 0, 0, 0),
                  height: 1.3,
                ),
              ),
            ),
            if (showArrow)
              ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  AppTheme.gray600,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/icons/right-arrow.webp',
                  width: 12,
                  height: 12,
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
